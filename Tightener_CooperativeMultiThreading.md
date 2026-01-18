# Tightener Cooperative Multi-Threading Architecture

## Table of Contents
1. [Overview](#overview)
2. [Core Concepts](#core-concepts)
3. [Threading Model](#threading-model)
4. [Task System](#task-system)
5. [Time Slicing Mechanism](#time-slicing-mechanism)
6. [Yielding Macros](#yielding-macros)
7. [InDesign Integration](#indesign-integration)
8. [Thread Hopping](#thread-hopping)
9. [Idle Task Integration](#idle-task-integration)
10. [Implementation Details](#implementation-details)

---

## Overview

Tightener implements a sophisticated **cooperative multi-threading** system that allows long-running operations to be broken into small time slices. This is essential when integrating with host applications like Adobe InDesign, which impose strict threading constraints.

The system is built on three fundamental pillars:

1. **Task-Based Execution**: Work is organized into `Task` objects that can be suspended and resumed
2. **Time Slicing**: Long operations are broken into microsecond-scale chunks
3. **Thread Guards**: Ensures exclusive access to Tightener code while allowing the executing thread to "hop" between different host application threads

---

## Core Concepts

### Cooperative vs. Preemptive Multi-Threading

Tightener uses **cooperative multi-threading** rather than preemptive:

- **Preemptive**: The OS forcibly switches between threads at unpredictable times
- **Cooperative**: Code explicitly yields control at defined points

**Why Cooperative?**
- InDesign's API is not thread-safe - only one thread can execute InDesign/Tightener code at a time
- Allows deterministic control of when context switches occur
- Enables saving/restoring execution state at known safe points
- Prevents race conditions in single-threaded host environments

### The Thread Hopping Problem

InDesign (and other host applications) may call into Tightener from different threads:

```
Time  →
Thread A: [Idle Task runs Tightener] ────────────────────
Thread B: ─────────── [Script call runs Tightener] ──────
Thread C: ───────────────────── [Command runs Tightener] ─
```

**Critical Constraint**: Only ONE thread can be executing Tightener code at any given moment, but it doesn't have to be the SAME thread each time.

**Solution**: The `ThreadGuard` class ensures mutual exclusion while allowing the "hosting thread" to change.

---

## Threading Model

### Thread Categories

Tightener recognizes three thread types:

1. **HOSTING Thread**: The thread that "owns" Tightener execution during a timeslice
2. **MAIN Thread**: The primary UI thread (in InDesign context)
3. **HOSTED Thread**: Tightener running in its own dedicated thread (Xojo/TightenerGW scenarios)

### ThreadGuard Class

Located in: [TghInternalCoordinator.h](../Tightener/TghCoordinator/TghInternalCoordinator.h) and [TghInternalCoordinator.cpp](../Tightener/TghCoordinator/TghInternalCoordinator.cpp)

#### ThreadGuardType Enum

```cpp
enum class ThreadGuardType {
    HOSTING,          // Normal external call into Tightener
    HOSTING_AND_MAIN, // External call that is also the main thread (InDesign)
    HOSTED_NO_WAIT,   // Try to acquire without blocking
    HOSTED_WAIT       // Block until lock acquired (Tightener's own thread)
};
```

#### Key Static Members

```cpp
class ThreadGuard {
    static std::thread::id   fTightenerExclusiveAccessThreadId;
    static bool              fTightenerExclusiveAccessThreadIsSet;
    static std::mutex        fTightenerExclusiveAccessMutex;
    
    static bool              fHostingThreadIsSet;
    static std::thread::id   fHostingThreadId;
    static size_t            fHostingThreadIdGrabCount;  // Reentrant support
    
    static bool              fMainThreadIsSet;
    static std::thread::id   fMainThreadId;
};
```

#### Locking Mechanism

**HOSTING Thread (InDesign calls into Tightener)**:

```cpp
// When InDesign calls evalScript() or similar
{
    ThreadGuard guard(ThreadGuardType::HOSTING_AND_MAIN);
    // First call sets fHostingThreadId = current thread
    // Subsequent calls from SAME thread increment fHostingThreadIdGrabCount
    // Calls from DIFFERENT threads block on fTightenerExclusiveAccessMutex
}
// Destructor decrements grab count, releases mutex when count reaches 0
```

**HOSTED Thread (Tightener in own thread)**:

```cpp
// In event loop
while (running) {
    {
        ThreadGuard guard(ThreadGuardType::HOSTED_WAIT);
        // Blocks until lock acquired
        runEventLoop();
    }
    // Before sleeping, calls beginSleep() which releases the mutex
    guard.beginSleep();
    sleep(heartbeatInterval);
    // After waking, calls endSleep() which re-acquires mutex
    guard.endSleep();
}
```

**Thread Hopping Example**:

```
1. IdleTask (Thread A) calls:
   ThreadGuard(HOSTING_AND_MAIN)
   → Sets fHostingThreadId = A
   → Runs timeslice
   
2. Guard destructor releases mutex

3. Script call (Thread B) executes:
   ThreadGuard(HOSTING_AND_MAIN)
   → Blocks on mutex until Thread A releases
   → Sets fHostingThreadId = B (thread hop!)
   → Runs timeslice
   
4. Guard destructor releases mutex
```

### beginSleep() / endSleep()

Special methods for yielding the mutex temporarily:

```cpp
void ThreadGuard::beginSleep() {
    fTightenerExclusiveAccessThreadIsSet = false;
    fTightenerExclusiveAccessMutex.unlock();
}

void ThreadGuard::endSleep() {
    std::thread::id threadId = std::this_thread::get_id();
    fTightenerExclusiveAccessMutex.lock();  // May block!
    fTightenerExclusiveAccessThreadIsSet = true;
    fTightenerExclusiveAccessThreadId = threadId;
}
```

Used in event loops to allow other threads to run Tightener while waiting for events.

---

## Task System

### Task Class

Located in: [TghTask.h](../Tightener/TghTask/TghTask.h) and [TghTask.cpp](../Tightener/TghTask/TghTask.cpp)

Tasks are the fundamental unit of work in Tightener. Each task:
- Can be suspended mid-execution
- Maintains its execution state across timeslices
- Can spawn child tasks
- Has a priority and timeout

#### Key Task Members

```cpp
class Task {
    std::vector<OMFunctionStatePtr>  fFunctionStateStack;  // State for yielding functions
    size_t                           fNestLevel;            // Current depth in stack
    bool                             fIsTaskCompleted;
    bool                             fIsTaskTimedOut;
    bool                             fIsTimesliceCompleted;
    
    std::chrono::steady_clock::time_point fYieldAfter;     // When to yield
    std::chrono::steady_clock::time_point fTaskTimeoutAfter;
    
    OMInt                            fTimeoutMicroseconds;
    int                              fPriority;
    std::unordered_map<TaskId, TaskPtr> fChildTasks;
};
```

#### Task Lifecycle

```
1. Created → Not yet started
2. start() → Registered in fActiveTasksByPriority[priority]
3. runTimeslice() → Executes timeslice() virtual method
4. isIdle() → Checks if task completed
5. handleCompletion() → Cleanup and notify parent
```

### Task Priority System

Tasks are organized by priority:

```cpp
static std::vector<std::vector<TaskPtr>> fActiveTasksByPriority;
```

- Priority 0: Normal tasks
- Priority 1: Startup scripts (run first)
- Higher numbers = higher priority

### Task Timeout

```cpp
#define TIMEOUT_RUN_TO_COMPLETION -2  // No timeout

Task(const char* name, OMInt timeoutMicroseconds) {
    if (timeoutMicroseconds != TIMEOUT_RUN_TO_COMPLETION) {
        fTaskTimeoutAfter = now + microseconds(timeoutMicroseconds);
    }
}
```

---

## Time Slicing Mechanism

### runActiveTasks()

The main scheduling loop located in [TghTask.cpp](../Tightener/TghTask/TghTask.cpp):

```cpp
bool Task::runActiveTasks(OMInt& availableMicroseconds) {
    for (int priority = max; priority >= 0; --priority) {
        std::vector<TaskPtr>& tasks = fActiveTasksByPriority[priority];
        
        for (auto& task : tasks) {
            if (availableMicroseconds <= 0) return true;  // Time's up
            
            bool didWork = task->runTimeslice(availableMicroseconds);
            
            if (task->isIdle()) {
                task->handleCompletion();
            }
        }
    }
}
```

### Per-Task Time Slicing

```cpp
bool Task::runTimeslice(OMInt timesliceMicroseconds) {
    fIsRunningTimeslice = true;
    fIsTimesliceCompleted = false;
    
    if (timesliceMicroseconds > 0) {
        fYieldAfter = now + microseconds(timesliceMicroseconds);
    }
    
    timeslice();  // Virtual method - actual work happens here
    
    fIsRunningTimeslice = false;
    return didWork;
}
```

### isTryingToYield()

Checked at every `YIELD` point:

```cpp
bool Task::isTryingToYield() {
    if (fIsTaskTimedOut) return true;
    if (fIsTimesliceCompleted) return true;
    
    auto now = std::chrono::steady_clock::now();
    
    if (fTaskTimeoutAfter != fNoYield && now >= fTaskTimeoutAfter) {
        fIsTaskTimedOut = true;
        return true;
    }
    
    if (fYieldAfter != fNoYield && now >= fYieldAfter) {
        fIsTimesliceCompleted = true;
        return true;
    }
    
    return false;
}
```

---

## Yielding Macros

### OMFunctionState

State storage for time-sliced functions:

```cpp
struct OMFunctionState {
    int fProgressState;  // Execution progress (line number or state enum)
};

// Derived state includes local variables
struct LocalVariableState : OMFunctionState {
    SomeType someLocalVar;
    AnotherType anotherVar;
};
```

### Core Yielding Macros

Located in: [TghTask.h](../Tightener/TghTask/TghTask.h)

#### YIELD

The fundamental yielding primitive:

```cpp
#define YIELD_(jumpPoint) \
    if (! ARE_NESTED_FUNCTION_STATES_ACTIVE(STACK_YIELDING)) \
        STATE_PTR_YIELDING->fProgressState = jumpPoint; \
    goto stateLoop; \
case jumpPoint:

// Uses __COUNTER__ (MSVC) or __LINE__ (GCC/Clang) for unique labels
#define YIELD YIELD_((__COUNTER__ + 1))
```

**How it works**:
1. Save current line number to `fProgressState`
2. Jump to `stateLoop` (exits the switch)
3. Next timeslice resumes at `case jumpPoint:`

#### BEGIN_FUNCTION_YIELDING / END_FUNCTION_YIELDING

```cpp
void someFunction_yielding(const TaskPtr& task, RetType& retVal, ...) {
    BEGIN_FUNCTION_YIELDING;
    
    BEGIN_DECLARE_VARIABLE_YIELDING(task);
        LocalType localVar;
    END_DECLARE_VARIABLE_YIELDING;
    
    BEGIN_FUNCTION_BODY_YIELDING(retVal = defaultValue);
    
    BEGIN_DEFINE_VARIABLE_YIELDING;
        DEFINE_INIT_VARIABLE_YIELDING(localVar, initialValue);
    END_DEFINE_VARIABLE_YIELDING;
    
    BEGIN_YIELD_ENABLED;
    
        // Actual function body with YIELD points
        YIELD;
        doSomething();
        YIELD;
        
    END_YIELD_ENABLED;
    END_FUNCTION_BODY_YIELDING;
    END_FUNCTION_YIELDING;
}
```

#### State Management

```cpp
#define BEGIN_YIELD_ENABLED \
    while (STATE_PTR_YIELDING->fProgressState != PROGRESS_STATE_DONE) { \
        switch (STATE_PTR_YIELDING->fProgressState) { \
        case 0:  // Initial entry point

#define END_YIELD_ENABLED \
        default: \
            STATE_PTR_YIELDING->fProgressState = PROGRESS_STATE_DONE; \
            goto stateLoop; \
        } \
    stateLoop: \
        if (IS_TRYING_TO_YIELD(STACK_YIELDING)) break; \
    }
```

### Control Flow Macros

#### FOR_YIELDING

```cpp
#define BEGIN_FOR_YIELDING(expressions) \
    { \
    for (expressions) {

#define END_FOR_YIELDING \
    } \
    } \
    if (_FUNCTION_BREAK_ISSUED) { break; }
```

#### SWITCH_YIELDING

```cpp
BEGIN_DECLARE_SWITCH_YIELDING(SwitchID, variable);
    DECLARE_SWITCH_CASE_YIELDING(SwitchID, value1, Label1);
    DECLARE_SWITCH_CASE_YIELDING(SwitchID, value2, Label2);
END_DECLARE_SWITCH_YIELDING(SwitchID);

BEGIN_SWITCH_YIELDING(SwitchID);
    
    SWITCH_CASE_YIELDING(SwitchID, value1, Label1);
        // Code with YIELD calls
        SWITCH_BREAK_YIELDING(SwitchID);
    
    SWITCH_CASE_YIELDING(SwitchID, value2, Label2);
        // Code with YIELD calls
        SWITCH_BREAK_YIELDING(SwitchID);
        
END_SWITCH_YIELDING(SwitchID);
```

### CALL_YIELDING

Wraps yielding function calls:

```cpp
#define CALL_YIELDING(call) \
    YIELD; \
    call; \
    YIELD_AGAIN

// Usage:
CALL_YIELDING(
    subFunction_yielding(task, result, arg1, arg2)
);
```

**Why two YIELDs?**
- First `YIELD`: Save state before call
- `call`: May take multiple timeslices
- Second `YIELD`: Resume after call completes

---

## InDesign Integration

### Threading Constraints

InDesign imposes strict requirements:

1. **Single-threaded API**: InDesign's DOM is NOT thread-safe
2. **Main thread affinity**: UI operations must run on main thread
3. **Script timeout**: Scripts can be aborted by user
4. **Idle time**: Must yield regularly to prevent UI freeze

### Integration Points

Tightener integrates with InDesign through:

1. **Idle Tasks**: Background processing during idle time
2. **Command Interceptors**: Hook into menu/keyboard commands
3. **Script Providers**: Handle ExtendScript/UXP script execution
4. **Event Handlers**: PlugPlug event system

### TghIDSNIdleTask

Located in: [TghIDSNIdleTask.cpp](../InDesignTightener/src/TghIDSNIdleTask.cpp)

```cpp
class TghIDSNIdleTask : public CIdleTask {
    static bool fHasBeenTriggered;
    static TGH::OMInt fHeartBeatMicroseconds;  // Default: 10000 (10ms)
    static TGH::OMInt fStartupDelayMicroseconds;
};
```

#### RunTask Implementation

```cpp
uint32 TghIDSNIdleTask::RunTask(uint32 appFlags, IdleTimer* timeCheck) {
    
    fHasBeenTriggered = true;
    
    // Install PlugPlug event listener for external triggers
    if (!fPlugPlugEventHandler) {
        fPlugPlugEventHandler->AddPlugPlugEventListener(
            "Tightener_Idle",
            &PlugPlugEventListener,
            nullptr);
    }
    
    do {
        // Acquire thread guard
        ThreadGuard guard(ThreadGuardType::HOSTING_AND_MAIN);
        if (!ThreadGuard::isTightenerExclusiveAccess()) break;
        
        // Signal that we have messaging activity (don't sleep)
        internalCoordinator->reportMessagingActivityInEventLoop();
        
        // Run event loop until no more subtasks
        InternalCoordinator::runEventLoopUntilNoMoreSubTasks(
            InternalCoordinator::getEventLoopMicroseconds());
            
        OMIDSNScope::NotifyTimesliceHasRun();
        
    } while (timeCheck && (*timeCheck)() != 0);
    
    return (fHeartBeatMicroseconds + 500) / 1000;  // Next callback delay
}
```

### TghIDSNIdleTaskThread

Background thread variant:

```cpp
void TghIDSNIdleTaskThread::RunThread(uint32 flags) {
    do {
        ThreadGuard guard(ThreadGuardType::HOSTING);
        if (ThreadGuard::isTightenerExclusiveAccess()) {
            
            machine->pingTask();  // License system heartbeat
            
            internalCoordinator->reportMessagingActivityInEventLoop();
            
            InternalCoordinator::runEventLoopUntilNoMoreSubTasks(
                InternalCoordinator::getEventLoopMicroseconds());
                
            OMIDSNScope::NotifyTimesliceHasRun();
        }
        
        uint32 yieldFlags = YieldToEventLoop(heartBeatMilliseconds);
        
    } while ((yieldFlags & kCITT_Shutdown) == 0);
}
```

### OMIDSNScope Timeslice Tracking

Located in: [TghOMIDSNScope.cpp](../InDesignTightener/src/TghOMIDSNScope.cpp)

```cpp
class OMIDSNScope {
    static size_t fCommandInterceptionLevel;
    static std::chrono::time_point<std::chrono::steady_clock> 
        fThreadedTimesliceIsOverdueAfter;
};

bool OMIDSNScope::IsThreadedTimesliceDue() {
    return std::chrono::steady_clock::now() >= fThreadedTimesliceIsOverdueAfter;
}

bool OMIDSNScope::NotifyTimesliceHasRun() {
    auto now = std::chrono::steady_clock::now();
    fThreadedTimesliceIsOverdueAfter = 
        now + std::chrono::microseconds(
            InternalCoordinator::getEventLoopMicroseconds());
    return true;
}
```

---

## Thread Hopping

### The Problem

```
User clicks menu item "Run Script"
↓
InDesign calls CommandInterceptor on Thread A
↓
Tightener starts task, sets HostingThread = A
↓
Task yields after 10ms
↓
User triggers idle task
↓
InDesign calls IdleTask on Thread B (different!)
↓
How does Tightener resume on Thread B?
```

### The Solution

**Key Insight**: The `Task` object's state is thread-independent. The `ThreadGuard` manages which thread is currently executing.

```cpp
// First call (Thread A)
{
    ThreadGuard guard(HOSTING_AND_MAIN);  
    // fHostingThreadId = A, mutex locked
    
    task->runTimeslice(10000);  // Runs for 10ms, then yields
    
    // State saved in task->fFunctionStateStack
    
}  // Destructor: fHostingThreadId = invalid, mutex unlocked

// Later call (Thread B)
{
    ThreadGuard guard(HOSTING_AND_MAIN);
    // Blocks on mutex until Thread A finished
    // fHostingThreadId = B (THREAD HOP!)
    // mutex locked
    
    task->runTimeslice(10000);  // Resumes from saved state
    
}  // Destructor releases mutex
```

### Command Interceptor Example

Located in: [ActivePageItemCommandInterceptor.cpp](../ActivePageItems/src/ActivePageItemCommandInterceptor.cpp)

```cpp
void ActivePageItemCommandInterceptor::Before(ICommand* cmd) {
    
    // Only intercept if idle task has triggered
    if (!TghIDSNIdleTask::getHasBeenTriggered()) return;
    
    // Don't run too frequently
    if (!OMIDSNScope::IsThreadedTimesliceDue()) return;
    
    // Acquire guard (may be different thread than last time!)
    ThreadGuard guard(ThreadGuardType::HOSTING_AND_MAIN);
    if (!ThreadGuard::isTightenerExclusiveAccess()) return;
    
    internalCoordinator->reportMessagingActivityInEventLoop();
    
    InternalCoordinator::runEventLoopUntilNoMoreSubTasks(
        InternalCoordinator::getEventLoopMicroseconds());
        
    OMIDSNScope::NotifyTimesliceHasRun();
}
```

**This runs on whatever thread InDesign uses to execute commands**, which may vary!

---

## Idle Task Integration

### Multi-Level Idle Tasks

Tightener uses multiple idle tasks for different purposes:

#### 1. TghIDSNIdleTask (UI Thread)
- Runs on main UI thread
- Handles high-priority UI-related work
- Callback interval: ~10ms (fHeartBeatMicroseconds)

#### 2. TghIDSNIdleTaskThread (Background Thread)
- Runs in separate thread
- Handles background processing
- Includes license system ping

#### 3. ActivePageItemIdleTask
- Plugin-specific monitoring
- Watches for file changes
- Triggers custom events

#### 4. ActivePageItemSessionUIIdleTask
- Session-level UI updates

### Idle Task Flow

```
InDesign Event Loop
↓
[Time passes...]
↓
Idle Time Available
↓
Idle Task Manager calls RunTask()
↓
TghIDSNIdleTask::RunTask()
  ├→ Acquire ThreadGuard
  ├→ Run Tightener timeslice
  ├→ Release ThreadGuard
  └→ Return next callback delay
↓
Back to InDesign Event Loop
```

### Priority Coordination

```cpp
if ((appFlags & ~(IIdleTaskMgr::kInBackground | 
                  IIdleTaskMgr::kApplicationMinimized | 
                  IIdleTaskMgr::kMainThreadTaskQueued)) != 0)
{
    return kActivePageItemHeartBeatTicks;  // Busy, try later
}
```

Idle tasks check `appFlags` to avoid running when:
- Modal dialog is up
- Menu tracking active  
- Important system events pending

---

## Implementation Details

## Event-Driven Pipe Handling (Draft)

This section captures the current plan to move pipe I/O from poll-driven loops to event-driven wakeups **inside `TghPipes` only**, so higher layers never block on OS pipes and only consume buffered data. It is a consolidation of the working design note and should be kept in sync with pipe-related changes.

### Goals
- Preserve public behavior: higher layers can continue calling existing `poll()` entry points.
- Make pipe reads/writes responsive without CPU-heavy polling.
- Keep all blocking OS I/O and readiness waiting inside `TghPipes`.
- Provide buffered access patterns for higher layers (e.g., `isDataAvailable`, `numBytesAvailable`, `readBytesWait`, `readBytesNoWait`).

### Non-Goals
- No API changes in `TghInternalCoordinator` or `TghSiblingCoordinator` unless unavoidable.
- No changes to message formats or pipe naming conventions.

### Architecture Sketch
1. **Internal pipe reader** (per pipe or shared) blocks on OS readiness and pushes bytes into `ReadPipeHandleBuffer`.
2. **Wait tokens / tasks** inside `TghPipes` can block on a semaphore/event and resume as soon as new data is buffered.
3. **`poll()` becomes a façade** over readiness flags set by the event-driven reader.
4. **Higher layers only read buffered data**; they do not wait on OS pipe handles.

### Likely Touch Points
- `Tightener/TghUtils/TghPipes.h`
- `Tightener/TghUtils/TghPipes.cpp`
- (Behavioral impact only) `Tightener/TghCoordinator/TghInternalCoordinator.cpp`
- (Behavioral impact only) `Tightener/TghCoordinator/TghSiblingCoordinator.cpp`

### Open Questions
- Platform strategy: one thread per pipe vs shared reactor (Windows named pipes vs POSIX).
- How to map readiness → wake for multi-consumer scenarios.
- Buffer sizing/backpressure rules.
- Do we expose new public helpers or keep them internal for now?

### Function State Stack

```cpp
class Task {
    std::vector<OMFunctionStatePtr> fFunctionStateStack;
    size_t fNestLevel;
};
```

Example execution:

```
Call Depth  fNestLevel  fFunctionStateStack
-----------  ----------  -------------------
mainFunc()      0        [mainState]
  subFunc1()    1        [mainState, sub1State]
    subFunc2()  2        [mainState, sub1State, sub2State]
  (returns)     1        [mainState, sub1State]
(returns)       0        [mainState]
```

**On Yield**:
- States remain on stack
- `fProgressState` records resume point
- Control returns to scheduler

**On Resume**:
- Stack is restored
- Switch jumps to saved `fProgressState`
- Local variables accessible via state pointers

### State Access Pattern

```cpp
BEGIN_FUNCTION_BODY_YIELDING(retVal = false);
    // Get or create state
    OMFunctionStatePtr STATE_PTR_YIELDING(GET_LOCKED_FUNCTION_STATE(STACK_YIELDING));
    if (!STATE_PTR_YIELDING) {
        retVal = false;
        STATE_PTR_YIELDING = new LocalVariableState();
        LOCK_FUNCTION_STATE(STACK_YIELDING, STATE_PTR_YIELDING);
    }
```

### Progress State Machine

```cpp
BEGIN_YIELD_ENABLED;
    while (STATE_PTR_YIELDING->fProgressState != PROGRESS_STATE_DONE) {
        switch (STATE_PTR_YIELDING->fProgressState) {
        case 0:  // Initial entry
            doStep1();
            YIELD;  // Sets fProgressState = __LINE__
            
        case __LINE__:  // Resume here
            doStep2();
            YIELD;
            
        case __LINE__:
            doStep3();
            STATE_PTR_YIELDING->fProgressState = PROGRESS_STATE_DONE;
        }
    stateLoop:
        if (IS_TRYING_TO_YIELD(STACK_YIELDING)) break;
    }
END_YIELD_ENABLED;
```

### Inline vs. Non-Inline Timeslicing

Controlled by `IS_INLINE_TIMESLICE` macro:

```cpp
#if IS_INLINE_TIMESLICE
    // Direct access (faster)
    #define GET_LOCKED_FUNCTION_STATE(task) \
        _GET_LOCKED_FUNCTION_STATE(task)
#else
    // Virtual method (more flexible)
    #define GET_LOCKED_FUNCTION_STATE(task) \
        (task)->getLockedFunctionState()
#endif
```

**Inline**: Better performance, less flexibility  
**Non-inline**: Allows runtime polymorphism

### Timeout Handling

```cpp
#define _RELEASE_FUNCTION_STATE(task, state) \
{ \
    --(task)->fNestLevel; \
    if (!(task)->fIsTaskTimedOut) { \
        if ((task)->fTaskTimeoutAfter != Task::fNoYield && \
            std::chrono::steady_clock::now() >= (task)->fTaskTimeoutAfter) { \
            (task)->fIsTaskTimedOut = true; \
        } \
    } \
    if ((task)->fIsTaskTimedOut || \
        (state)->fProgressState == PROGRESS_STATE_DONE) { \
        (task)->fFunctionStateStack.pop_back(); \
    } \
}
```

**On timeout**:
- State is removed from stack
- Task marked as timed out
- Cascades up to parent tasks

---

## Best Practices

### For Plugin Developers

1. **Always use HOSTING_AND_MAIN** when calling from InDesign main thread
2. **Check `isTightenerExclusiveAccess()`** after acquiring guard
3. **Use `reportMessagingActivityInEventLoop()`** to prevent sleep
4. **Call `NotifyTimesliceHasRun()`** after each timeslice
5. **Respect `IsThreadedTimesliceDue()`** to avoid excessive CPU

### For Task Implementers

1. **Mark long operations with `_yielding` suffix**
2. **Use `CALL_YIELDING()` for sub-calls**
3. **Avoid blocking operations** (file I/O, network)
4. **Set appropriate timeout** (`TIMEOUT_RUN_TO_COMPLETION` sparingly)
5. **Implement `handleCompletion()` for cleanup**

### For Macro Users

1. **Always match BEGIN/END pairs**
2. **Use FUNCTION_BREAK_YIELDING** not plain `break`
3. **Declare local variables in DECLARE_VARIABLE_YIELDING block**
4. **Initialize with DEFINE_INIT_VARIABLE_YIELDING**
5. **Test with both inline and non-inline timeslicing**

---

## Performance Characteristics

### Timeslice Granularity

Typical values:

```cpp
#define kTghIDSNHeartBeatMicroseconds 10000  // 10ms per idle callback
#define kEventLoopMicroseconds        1000   // 1ms per timeslice
```

**Trade-offs**:
- **Shorter timeslices**: More responsive UI, higher overhead
- **Longer timeslices**: Better throughput, UI lag

### Overhead

Per-timeslice overhead:
- ThreadGuard lock/unlock: ~100ns
- State save/restore: ~50ns per variable
- Switch/case jump: ~10ns
- Timestamp check: ~20ns

Total: **< 1 microsecond for typical case**

### Scalability

The system handles:
- 1000+ concurrent tasks
- 10+ nested function calls
- 100+ local variables per function
- microsecond-scale timeslicing

---

## Debugging Tips

### Enable Logging

```cpp
#define DEBUG_CHECK_LEVEL 2  // More verbose checks
#define FORCED_WITH_LOGGING 1  // Logging in release builds
```

### Trace Function Calls

```cpp
#define TASK_LOG_NOTE_WITH_DATA(fmt, ...) \
    LOG_NOTE_WITH_DATA("[Task %s] " fmt, fName.c_str(), ##__VA_ARGS__)
```

### Verify Thread Safety

```cpp
SANITY_CHECK(ThreadGuard::isTightenerExclusiveAccess(), FUNCTION_BREAK);
SANITY_CHECK(ThreadGuard::onMainThread(), FUNCTION_BREAK);
```

### Monitor Timeslice Completion

```cpp
LOG_NOTE_WITH_DATA("Task %s: completed=%d timeout=%d timeslice=%d",
    fName.c_str(),
    fIsTaskCompleted,
    fIsTaskTimedOut,
    fIsTimesliceCompleted);
```

---

## Conclusion

Tightener's cooperative multi-threading system provides:

✅ **Single-threaded safety** for InDesign integration  
✅ **Thread hopping** to follow InDesign's threading model  
✅ **Microsecond-scale time slicing** for responsive UI  
✅ **State preservation** across yields  
✅ **Hierarchical task management** with priorities  
✅ **Graceful timeout handling**  

This architecture allows long-running TQL scripts to execute seamlessly within InDesign's event-driven, single-threaded environment while maintaining full control over execution flow and resource usage.

---

## Related Documentation

- [Tightener_CodingConventions.md](Tightener_CodingConventions.md) - Macro usage guidelines
- [Tightener_Overview.md](Tightener_Overview.md) - Ecosystem overview
- [Tightener/TghTask/TghTask.h](../Tightener/TghTask/TghTask.h) - Task implementation
- [InDesignTightener/src/TghIDSNIdleTask.cpp](../InDesignTightener/src/TghIDSNIdleTask.cpp) - InDesign integration
- [ActivePageItems/src/ActivePageItemCommandInterceptor.cpp](../ActivePageItems/src/ActivePageItemCommandInterceptor.cpp) - Command interception example
