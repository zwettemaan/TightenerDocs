# Tightener Coding Conventions

This document outlines the coding conventions used in the Tightener ecosystem. These conventions are derived from the existing codebase and should be followed for all new development.

## 1. Formatting

### Indentation
- **Style**: Spaces (no tabs).
- **Width**: 4 spaces per indentation level.

### Braces
- **C/C++**: Allman style (braces are placed on their own lines).
  ```cpp
  if (condition)
  {
      // code
  }
  ```
- **JavaScript / ExtendScript**: K&R / 1TBS style (opening brace on the same line).
  ```javascript
  if (condition) {
      // code
  }
  ```

### Line Endings
- Standard Unix-style (`\n`) line endings are preferred, though the codebase may contain mixed endings due to cross-platform development (Mac/Windows).

## 2. Naming Conventions

### General
- Names should be descriptive and clear.
- Avoid abbreviations unless they are widely understood or standard within the project (e.g., `Tgh` for Tightener).

### Classes and Structs
- **Style**: PascalCase.
- **Example**: `ThreadedTightenerData`, `InternalCoordinator`, `LogMessage`.

### Functions and Methods
- **Style**: camelCase.
- **Example**: `logLevelGetter`, `consoleLoop`, `runRemoteScript`.

### Member Variables
- **Style**: `f` prefix followed by PascalCase.
- **Example**: `fIsInitialized`, `fLogMessageQueue`, `fInternalCoordinator`.

### Constants and Statics
- **Style**: UPPER_SNAKE_CASE.
- **Example**: `IPC_ESCAPE_CHARS`, `STARTUP_THREAD_WAIT_MICROSECONDS`.

### Namespaces
- **Style**: UPPER_CASE.
- **Example**: `TGH`.

## 3. Control Flow and Macros

The Tightener C/C++ codebase relies heavily on a set of custom macros to enforce a compact, uniform, and error-resistant coding style. **This is the target style for all native code in the ecosystem.**

> [!NOTE]
> Older projects (e.g., **ActivePageItems**) are gradually being refactored to adopt this new, more compact style. New code should strictly adhere to these conventions.

### Function Boundaries & Tracing
These macros manage function entry/exit and automatically handle logging (logentry/logexit) for tracing execution flow.
- **`BEGIN_FUNCTION`**: Marks the start of a void function. Initializes the stack frame for tracing.
- **`END_FUNCTION`**: Marks the end of a void function. Handles cleanup and "logexit" tracing.
- **`BEGIN_BOOL_STATUS_FUNCTION`**: Starts a function that returns a boolean status (success/failure).
- **`END_BOOL_STATUS_FUNCTION`**: Ends a boolean status function.
  - **`REPORT_SUCCESS`**: Used at the end of the block to return `true`.

### Error Handling and Sanity Checks
The "Sanity Check" pattern is preferred over standard exceptions or error codes for internal consistency checks.
- **`FUNCTION_BREAK`**: Breaks out of the current function scope (implemented via a `do { ... } while(false)` loop).
- **`SANITY_CHECK(condition, action)`**: The primary assertion macro. If `condition` is false:
  1. Logs a "sanity check failed" message.
  2. Executes `action` (typically `FUNCTION_BREAK` to exit the macro scope).
- **`L1_SANITY_CHECK(condition, action)`**: A lower-priority check, often used for debug-only or non-critical validations.

### Control Flow Wrappers
Standard C++ control structures are wrapped in macros to ensure consistent scoping and interaction with the `FUNCTION_BREAK` mechanism.
- **`BEGIN_FOR(init; cond; incr)` / `END_FOR`**: Wrapper for `for` loops.
- **`BEGIN_DO_WHILE` / `END_DO_WHILE(cond)`**: Wrapper for `do-while` loops.
- **`BEGIN_SWITCH(val)` / `SWITCH_CASE(val)` / `SWITCH_BREAK` / `END_SWITCH`**: Wrapper for `switch` statements.

### Condition Ladders
- **Style**: "If-Break" pattern.
- Avoid deep nesting or long `else if` chains. Instead, use a series of `if` statements that break out of the current scope (loop or function) upon success or failure.
  ```cpp
  // Inside a loop or macro-wrapped function
  if (condition1)
  {
      // handle condition 1
      FUNCTION_BREAK; // or break;
  }

  if (condition2)
  {
      // handle condition 2
      FUNCTION_BREAK;
  }
  ```

## 4. Project-Specific Variations

> [!NOTE]
> Coding conventions may differ based on the context or the age of the subproject.

- **Older Projects**: Projects like **ActivePageItems** may follow older conventions that differ from the core Tightener style. When modifying these projects, follow the existing style of the file.
- **Language Differences**: As noted above, JavaScript/ExtendScript projects follow different formatting rules (e.g., brace placement) compared to C/C++ projects.

## 4. Logging

- **Mechanism**: Use the `TGH::logMessage` function or project-specific wrappers.
- **Levels**: Log levels are integer-based.
- **Patterns**:
    - `logentry` / `logexit` patterns are often used to trace function entry and exit (sometimes implicitly handled by `BEGIN_FUNCTION` macros in debug builds).
    - **Flexible Logger**: The logging system supports multiple sinks (console, file, remote).

## 5. File Structure

- **Headers**: Use `#pragma once` or standard `#ifndef` include guards.
- **Namespaces**: Most core code resides within the `TGH` namespace.
- **Organization**: Code is organized into modules (e.g., `TghMain`, `TghUtils`, `TghNetwork`).

## 6. C++ Standards
- The codebase targets C++11 standard.
- Use `std::shared_ptr` (often aliased as `Ptr` types, e.g., `IInternalCoordinatorPtr`) for memory management.
- Avoid raw pointers where possible.

## 7. Comments
- Use `//` for single-line comments.
- Use `/* ... */` for multi-line comments.
- Javadoc-style comments (`///`) are used for documentation generation in some headers.
