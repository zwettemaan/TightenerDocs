# Tightener Release Testing System Documentation

## Overview

The Tightener release testing system is an automated test harness that validates Tightener releases across all platforms (Mac, Linux, Windows). It uses a special "verifier" coordinator configuration that runs built-in C++ unit tests and TQL script tests.

## Entry Points

### Platform-Specific Scripts
- **[runReleaseTestsMac](runReleaseTestsMac)** - macOS test execution
- **[runReleaseTestsLinux](runReleaseTestsLinux)** - Linux test execution  
- **[runReleaseTests.bat](runReleaseTests.bat)** - Windows test execution
- **[runReleaseTests](runReleaseTests)** - Platform detector (dispatches to Mac/Linux)

### Integration Points
The release tests are automatically invoked as part of the build process:
- **[buildCmdLineAppMac](buildCmdLineAppMac)** - Runs `runReleaseTestsMac` after building Mac binaries
- **[buildCmdLineAppLinux](buildCmdLineAppLinux)** - Runs `runReleaseTestsLinux` after building Linux binaries
- **[buildCmdLineApp.bat](buildCmdLineApp.bat)** - Runs `runReleaseTests` after building Windows binaries

## Test Execution Flow

### 1. Environment Setup
All scripts start by sourcing the environment:
```bash
. setEnv  # Mac/Linux
CALL setEnv.bat  # Windows
```

This loads platform-specific environment variables including:
- `TIGHTENER_BINARIES` - Path to compiled Tightener executables
- `TIGHTENER_RELEASE_ROOT` - Path to release root directory
- Build paths, certificate paths, etc.

### 2. Application Cleanup
Before testing, all Tightener processes are terminated:
```bash
killApps
```

The `killApps` script (located in `TightenerDocs/CurrentRelease/CommandLine/Scripts/`):
- Terminates all running Tightener instances: `Tightener`, `XojoTightener`, `TightenerGW`, `TightenerGW_Cpp`
- Cleans up IPC artifacts:
  - **Mac**: `~/Library/Application Support/net.tightener/NamedPipes/*` and `SessionData/*`
  - **Linux**: `~/.net.tightener/net.tightener/NamedPipes/*` and `SessionData/*`

### 3. Test Configuration Installation

The core of the testing system is a custom configuration file that defines the "verifier" coordinator:

```bash
copyDebugConfig "${TIGHTENER_BUILD_SCRIPTS}testConfig.ini"
```

#### What `copyDebugConfig` Does

**Platform-specific implementations**:
- [copyDebugConfigMac](copyDebugConfigMac)
- [copyDebugConfigLinux](copyDebugConfigLinux)
- [copyDebugConfig.bat](copyDebugConfig.bat) (Windows)

**Process**:
1. **Saves existing config** via `saveConfigMac`/`saveConfigLinux`/`saveConfig.bat`:
   - Checks if `config.ini` exists and isn't already a debug config
   - Backs it up to `savedConfig.ini`
   
2. **Creates new test config**:
   - Writes header with platform-specific placeholders
   - Appends the provided test config file (`testConfig.ini`)
   
**Output location**:
- **Mac**: `~/Library/Application Support/net.tightener/SysConfig/config.ini`
- **Linux**: `~/.net.tightener/net.tightener/SysConfig/config.ini`  
- **Windows**: `%APPDATA%\net.tightener\SysConfig\config.ini`

### 4. Test Configuration Structure

The [testConfig.ini](testConfig.ini) file defines the complete test environment. Key sections:

#### URL Map
Maps symbolic coordinator names to TQL URLs:
```ini
[urlMap]
verifier = tgh:///verifier/default
reflector = tgh:///reflector/default
scriptrunner = tgh:///scriptrunner/default
main = tgh:///main/default
```

#### Coordinator Map
Maps URL names to coordinator identifiers:
```ini
[coordinatorMap]
verifier = net.tightener.coordinator.verifier
reflector = net.tightener.coordinator.reflector
main = net.tightener.coordinator.main
```

#### Placeholders
Defines reusable path variables (platform-aware via `.mac`, `.windows`, `.linux` suffixes):
```ini
[placeholders]
LOCAL_TIGHTENER_RELEASE.mac = "${TIGHTENER_BINARIES}Tightener"
LOCAL_TIGHTENER_RELEASE.windows = "${TIGHTENER_BINARIES}Tightener.exe"
LOCAL_TIGHTENER_RELEASE.linux = "${TIGHTENER_BINARIES}Tightener"

SHARED_HELPER_APP = "${LOCAL_TIGHTENER_RELEASE}"
VERIFIER_APP = "${SHARED_HELPER_APP}","-N","verifier"
```

#### Global Config
Default settings for all coordinators:
```ini
[config]
logLevel = 2
logIPC = 0
logScriptError = 0
logTiming = 0
startupScriptFile = "${TIGHTENER_RELEASE_ROOT}ScriptModules/startupScript.tql"
runTests = 0
isServer = 0
isInteractive = 0
```

#### Verifier Coordinator Config
The critical section that enables testing:
```ini
[config.net.tightener.coordinator.verifier]
appPath = "${VERIFIER_APP}"
isInteractive = 0
runTests = 1          # ← This triggers test execution!
logLevel = 2
logFile = "${DESKTOP_DIR}verifier.log"
```

**Key setting**: `runTests = 1` causes the Tightener executable to run its built-in test suite when launched with `-N verifier`.

### 5. Test Execution

The actual test run is triggered by launching Tightener with the "verifier" coordinator:

```bash
${TIGHTENER_BINARIES}/Tightener -N verifier -f - << EOF
quit();
EOF
```

**Command breakdown**:
- `-N verifier` - Use the "verifier" coordinator (as defined in config.ini)
- `-f -` - Read script from stdin
- `quit();` - Simple TQL command to quit after tests complete

#### What Happens Inside Tightener

When `runTests = 1` is set in the configuration, the Tightener main loop ([main.cpp:977-983](../TghMain/main.cpp#L977-L983)) executes:

```cpp
if (InternalCoordinator::getIsRunTests())
{
    LOG_NOTE("running tests");
    setIsRunningTests(true);
    Test::runAll();
    setIsRunningTests(false);
    LOG_NOTE("tests completed");
}
```

**Test Execution Path**:
1. `Test::runAll()` iterates through all registered test instances
2. Each test runs its `test()` method which may include:
   - **C++ unit tests** (e.g., `TghBoilerplateClassTest`, `OMTest`, `ServiceSampleForTestsTest`)
   - **TQL script tests** from `Release/SampleScripts/ReleaseTestScripts/` directory
3. Test results are logged to `~/Desktop/verifier.log`
4. Failures are logged with detailed error messages

#### Built-in Test Types

**C++ Class Tests**:
- Located in `Tightener/Tgh*/` subdirectories
- Examples: `TghOMTest.cpp`, `TghBoilerplateClassTest.cpp`, `TghServiceSampleForTestsTest.cpp`
- Test object factories, type systems, and core functionality

**TQL Script Tests**:
- Located in `TightenerDocs/CurrentRelease/SampleScripts/ReleaseTestScripts/`
- `OMTest::test_scripts()` ([TghOMTest.cpp:2656-2710](../TghParser/TghOMTest.cpp#L2656-L2710)) scans this directory
- Each `.tql` file is executed and must return "OK" to pass
- Example tests from TestScripts folder:
  - [reflector.tql](TestScripts/reflector.tql) - Tests remote eval and data reflection
  - [reflector2.tql](TestScripts/reflector2.tql) - Secondary reflector test
  - [reflector3.tql](TestScripts/reflector3.tql) - Tertiary reflector test

### 6. Startup Script Execution

Before tests run, each coordinator executes its startup script (if configured):

```ini
startupScriptFile = "${TIGHTENER_RELEASE_ROOT}ScriptModules/startupScript.tql"
```

#### [startupScript.tql](../../TightenerDocs/CurrentRelease/ScriptModules/startupScript.tql)

This script initializes the TQL runtime environment:

**Key Functions**:
- Loads utility libraries: `util.mtql`, `log.mtql`
- Sets up global namespace: `G = {}`
- Configures REPL callback IDs for different scripting environments:
  - `G.CALL_BACK_ID_TQL` - TQL command callbacks
  - `G.CALL_BACK_ID_EXTENDSCRIPT` - ExtendScript evaluation
  - `G.CALL_BACK_ID_UXPSCRIPT` - UXP script evaluation
- Registers data request callbacks for interactive command processing
- Handles platform-specific execution (InDesign vs. standalone)

**For Reflector Coordinators**:
The reflector coordinators use [startupScriptReflector.tql](../../TightenerDocs/CurrentRelease/ScriptModules/startupScriptReflector.tql) which:
- Includes `startupScript.tql` as a base
- Adds test functions like `plusOne()`
- Registers additional callbacks for split TQL streams
- Implements echo/reflection behavior for testing IPC

### 7. Test Result Collection

After test execution completes:
```bash
rm -f ~/Desktop/verifier.log  # Clear previous log

# ... test execution ...

killApps  # Clean shutdown

if [ -f ~/Desktop/verifier.log ]; then
    echo "Some tests failed - see ~/Desktop/verifier.log"
fi
```

**Success/Failure Detection**:
- If **all tests pass**: No `verifier.log` file is created
- If **any test fails**: Detailed failure info is written to `~/Desktop/verifier.log`
- The script checks for log file existence to report overall status

### 8. Configuration Restoration

Finally, the original config is restored:
```bash
restoreConfig
```

The `restoreConfig` scripts:
- Check if `savedConfig.ini` exists
- Delete current `config.ini`
- Rename `savedConfig.ini` back to `config.ini`
- Ensures the test environment doesn't persist beyond the test run

## Test Scripts in Detail

### Development Test Scripts

Located in [BuildScripts/TestScripts/](TestScripts/):

**[runTests](TestScripts/runTests)** - Manual test runner for development:
```bash
killApps
copyDebugConfig "${TIGHTENER_TEST_SCRIPTS}../testConfig.ini"

# Launch three scriptrunner coordinators with reflector scripts
Tightener -N scriptrunner -t n -w 10000 -f reflector.tql &
sleep 2
Tightener -N scriptrunner2 -t n -w 10000 -f reflector2.tql &
Tightener -N scriptrunner3 -t n -w 10000 -f reflector3.tql &
```

**Script Runner Flags**:
- `-N scriptrunner` - Use the scriptrunner coordinator
- `-t n` - Non-interactive mode
- `-w 10000` - 10-second timeout
- `-f reflector.tql` - Execute this script file
- `&` - Run in background

**Purpose**: Sets up a test environment with multiple coordinators for inter-coordinator communication testing. Does NOT automatically restore config (manual `restoreConfig` required).

### Reflector Test Scripts

The reflector scripts ([reflector.tql](TestScripts/reflector.tql), [reflector2.tql](TestScripts/reflector2.tql), [reflector3.tql](TestScripts/reflector3.tql)) test remote evaluation:

**Test Pattern**:
1. Construct a script with known data structure
2. Send to remote reflector coordinator via `eval(script, target, callback, timeout)`
3. Verify response structure:
   - Length prefix (6-digit padded)
   - Data prefix marker
   - Content (sysInfo data)
   - Data suffix marker
4. Report "OK" or detailed failure message

**Example from reflector.tql**:
```javascript
target = "tgh://127.0.0.1/reflector/default";
timeOut_ms = 10000;

script = <<EOF
padding = "000000";
prefix = "BEGIN_DATA";
suffix = "END_DATA";
longString = prefix + sysInfo().toString() + suffix;
// ... length calculation ...
longString
EOF

result = "BEFORE";
eval(script, target, function(callBackResult) {    
    result = callBackResult;
}, timeOut_ms);

// Validate result structure
retVal = "OK";    
if (! result) {
    retVal = "fail - no result";
}
// ... more validation ...

feedBack(retVal);
```

## Configuration System Deep Dive

### How Config Files are Processed

1. **Parsing**: Config files use INI format with sections `[section]` and `key = value` pairs
2. **Placeholder Expansion**: Variables like `${TIGHTENER_BINARIES}` are recursively expanded
3. **Platform Suffixes**: Keys ending in `.mac`, `.windows`, `.linux` override base keys on respective platforms
4. **Coordinator-Specific Sections**: `[config.net.tightener.coordinator.verifier]` overrides `[config]` for the verifier coordinator
5. **Wildcards**: `[config.net.tightener.coordinator.indesign.*]` matches multiple InDesign coordinators

### Environment Variable Integration

The `copyDebugConfig` scripts inject platform-specific environment variables:

**Mac/Linux**:
```bash
cat > "${HOME}/Library/Application Support/net.tightener/SysConfig/config.ini" <<EOF
[placeholders]
TIGHTENER_RELEASE_ROOT = "${TIGHTENER_RELEASE_ROOT}"
TIGHTENER_BINARIES = "${TIGHTENER_BINARIES}"
TIGHTENER_APPS_PLATFORM = "macOS Universal"
EOF
```

**Windows**:
```batch
ECHO [placeholders] > "%APPDATA%\net.tightener\SysConfig\config.ini"
ECHO TIGHTENER_RELEASE_ROOT = %TIGHTENER_RELEASE_ROOT% >> "%APPDATA%\net.tightener\SysConfig\config.ini"
ECHO TIGHTENER_BINARIES = %TIGHTENER_BINARIES% >> "%APPDATA%\net.tightener\SysConfig\config.ini"
```

These values are then available throughout the config file via placeholder expansion.

### Coordinator Selection

When Tightener is launched with `-N coordinatorName`, it:

1. Looks up the URL in `[urlMap]`: `verifier = tgh:///verifier/default`
2. Looks up the coordinator ID in `[coordinatorMap]`: `verifier = net.tightener.coordinator.verifier`
3. Loads config from `[config.net.tightener.coordinator.verifier]` section (merged with `[config]` defaults)
4. Expands `appPath` placeholder to actual executable path
5. Applies coordinator-specific settings like `runTests = 1`

## Logging and Output

### Log Files

Test execution creates multiple log files on the Desktop:

**Verifier Coordinator**:
- `verifier.log` - Main test results (only created on failure)

**Other Coordinators** (when used):
- `main.log`, `main.ipc.log`, `main.script.log`, `main.timing.log`
- `console.log`, `console.ipc.log`, `console.script.log`
- `scriptrunner.log`, `scriptrunner.ipc.log`, `scriptrunner.script.log`
- `reflector.log`, `reflector.ipc.log`, `reflector.script.log`

**Log Types**:
- `.log` - General execution log (logLevel controlled)
- `.ipc.log` - IPC message traffic (when `logIPC = 1`)
- `.script.log` - Script errors (when `logScriptError = 1`)
- `.timing.log` - Performance timing data (when `logTiming = 1`)

### Log Levels

```ini
logLevel = 0  # Silent (errors only)
logLevel = 1  # Warnings
logLevel = 2  # Notes (default for tests)
logLevel = 3  # Verbose debugging
```

## Advanced Testing Scenarios

### Running Manual Tests

For development/debugging without full release automation:

```bash
cd Tightener/BuildScripts/TestScripts
./runTests
# ... manually interact with test environment ...
restoreConfig  # When done
```

### Testing Specific Components

Modify `testConfig.ini` to enable logging for specific components:

```ini
[config.net.tightener.coordinator.verifier]
logLevel = 3                    # Verbose
logIPC = 1                      # Enable IPC logging
logScriptError = 1              # Enable script error logging
logTiming = 1                   # Enable timing logging
```

### Adding New Tests

**C++ Tests**:
1. Create test class inheriting from `Test` or `ClassTest`
2. Implement `test()` method
3. Register with `Test::registerTest()` during static initialization
4. Tests automatically run when `runTests = 1`

**TQL Script Tests**:
1. Create `.tql` file in `TightenerDocs/CurrentRelease/SampleScripts/ReleaseTestScripts/`
2. Script must return string "OK" for success, or error description for failure
3. `OMTest::test_scripts()` automatically discovers and runs the script

## Common Issues and Debugging

### Tests Pass Locally but Fail in CI

**Cause**: Different environment variables or paths between local and build environment.

**Solution**: Check `setEnv` scripts and verify `TIGHTENER_BINARIES`, `TIGHTENER_RELEASE_ROOT` match expected values.

### verifier.log Not Created Despite Failures

**Cause**: Log file path configured incorrectly, or coordinator crashed before writing.

**Solution**: Check console output for crash messages. Verify `DESKTOP_DIR` placeholder expands correctly.

### Tests Never Complete

**Cause**: Deadlock in IPC communication or infinite loop in test code.

**Solution**: 
- Kill hanging processes manually: `killall Tightener`
- Check `.ipc.log` files for stuck message exchanges
- Add timeout parameters to test scripts

### Config Not Restoring After Tests

**Cause**: `savedConfig.ini` was deleted or script exited early.

**Solution**: Manually restore from backup if available, or recreate config using PluginInstaller.

## Summary

The Tightener release testing system is a sophisticated multi-layered test harness:

1. **Configuration Swapping**: Temporarily replaces user config with test config
2. **Coordinator Pattern**: Uses "verifier" coordinator with `runTests = 1` to trigger tests
3. **Built-in Tests**: C++ unit tests and TQL script tests execute automatically
4. **Multi-Platform**: Identical test logic across Mac, Linux, Windows via platform-specific scripts
5. **Build Integration**: Automatically runs after compilation to catch regressions
6. **Clean Environment**: Saves/restores config, kills processes, cleans IPC artifacts

The system ensures that every release is validated against a comprehensive test suite before distribution, maintaining code quality and preventing regressions.
