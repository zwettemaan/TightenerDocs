# Tightener Coordinator, Gateway, and Pipe Regression Coverage Inventory

## Purpose

This document inventories the current regression surface for:

- coordinator routing
- sibling/gateway forwarding
- event-driven named pipes
- helper scripts and config that enable those paths

It is intentionally limited to what is already in-tree today. It does not propose code changes.

## Current State Summary

- The compiled test suite is shared by `Tightener` and `TightenerGW` through `Test::runAll()` when `runTests=1` is set for a coordinator entry. See `Tightener/TghMain/main.cpp:977`, `TightenerGW/TightenerGW/TightenerGW.cpp:201`, and `Tightener/TghCoordinator/TghInternalCoordinator.cpp:230`.
- The most relevant compiled coverage for this surface is in:
  - `InternalCoordinatorTest`
  - `SiblingCoordinatorTest`
  - `DirsTest`
- There is no dedicated `TghPipes` test class registered in `gTestFactoryFtnList`. The pipe layer is currently covered only indirectly through coordinator behavior and one low-level read/write loop in `DirsTest`.
- `TightenerGW` has no gateway-specific test fixtures or scripts under its own project folder. The current gateway-side automated surface is the same shared compiled test suite.
- The existing manual surface is centered around reflector-style coordinators and remote/local TQL scripts.

## Relevant Automated Assets

| Asset | Type | Coverage area | Evidence |
| --- | --- | --- | --- |
| `Tightener/TghCoordinator/TghInternalCoordinatorTest.cpp` | Compiled test | local delivery, relay/not-relay classification, event loop completion, internal service tree routing | `classTest_ping()` at `:39`; `classTest_IPC()` at `:268` |
| `Tightener/TghCoordinator/TghSiblingCoordinatorTest.cpp` | Compiled test | sibling coordinator factory, reflector launch/ping/terminate flow | `classTest_testReflector()` at `:61` |
| `Tightener/TghUtils/TghDirsTest.cpp` | Compiled test | raw named-pipe open/write/read/close loop, binary payload with embedded NUL, repeated open/close | pipe loop at `:136` |
| `Tightener/BuildScripts/runReleaseTestsMac` | Helper script | release smoke path for `verifier` coordinator on Mac | `copyDebugConfig` and `Tightener -N verifier` at `:11-17` |
| `Tightener/BuildScripts/runReleaseTestsLinux` | Helper script | release smoke path for `verifier` coordinator on Linux | `copyDebugConfig` and `Tightener -N verifier` at `:11-17` |
| `Tightener/BuildScripts/runReleaseTests.bat` | Helper script | release smoke path for `verifier` coordinator on Windows | `copyDebugConfig` and `Tightener.exe -N verifier` at `:9-18` |
| `Tightener/BuildScripts/testConfig.ini` | Config | coordinator aliases, reflector/scriptrunner/verifier launch definitions, test toggles, IPC/timing log file paths | `urlMap`/`coordinatorMap` at `:1-32`; test knobs at `:147-167`; coordinator blocks at `:208-343` |
| `Tightener/BuildScripts/TestScripts/runTests` | Manual helper script | starts `scriptrunner`, `scriptrunner2`, `scriptrunner3` against reflector scripts | launch lines at `:9-12` |
| `Tightener/BuildScripts/TestScripts/reflector*.tql` | Manual test scripts | remote eval round-trip, payload framing, response-length/prefix/suffix validation | `reflector.tql:6-63` and siblings |

## Relevant Manual and Sample Assets

| Asset | Type | Coverage area | Evidence |
| --- | --- | --- | --- |
| `TightenerDocs/CurrentRelease/ScriptModules/startupScriptReflector.tql` | Startup script | reflector callback behavior for `sendData()`, split-stream parsing, reply formatting | callback definitions at `:18-57` |
| `TightenerDocs/CurrentRelease/SampleScripts/localPingReflector.tql` | Manual sample | same-machine remote eval loop to reflector, async and blocking eval forms | target and loops at `:27-58` |
| `TightenerDocs/CurrentRelease/SampleScripts/remotePingReflector.tql` | Manual sample | cross-host remote eval to a configurable coordinator | target construction and loop at `:13-66` |
| `TightenerDocs/CurrentRelease/SampleScripts/localQuitReflector.tql` | Manual sample | same-machine remote quit path | `eval("quit();", ...)` |
| `TightenerDocs/CurrentRelease/SampleScripts/remoteQuitReflector.tql` | Manual sample | cross-host remote quit path | `eval("quit();", ...)` |
| `TightenerDocs/CurrentRelease/SampleScripts/remoteSettings.json` | Manual config | remote-host selector for future `tightenerlinux` / `tightenerwindows` use | `remoteHost`, `coordinatorName`, `timeout` at `:1-8` |
| `InDesignTightener/TestScripts/runEmbeddedCommunicationRegression.tql` | Manual smoke script | embedded InDesign `self`, `main`, `reflector` communication wrapper | runs `pingSelf.tql`, `pingMain.tql`, `pingReflector.tql` |
| `InDesignTightener/TestScripts/pingSelf.tql` | Manual smoke script | embedded InDesign in-app coordinator -> self | target built from `sysInfo().coordinatorName` and `$.engineName` |
| `TightenerDocs/CurrentRelease/Plug-Ins/TightenerESDLL/testCommunication.jsx` | Manual smoke script | embedded ExtendScript `self`, `main`, `reflector` communication wrapper | inline TQL eval against same-machine targets |
| `TightenerDocs/Tightener_RegressionCoverage_EmbeddedInDesignExtendScript.md` | Documentation | embedded InDesign / ExtendScript coverage plus ExtendScript gateway limitation | Session F coverage summary |
| `Tightener/Docs/README.md` | Manual instructions | local console smoke, `consoletested`, sample remote-script invocations from debugger | testing section around `:739-785` and Xcode args around `:1019-1028` |

## Coverage Mapping

### 1. In-process and same-coordinator behavior

- Covered by `InternalCoordinatorTest::classTest_ping()`.
- Verifies local coordinator delivery plus message-received event handling.
- Uses a small service tree and expects four `PING` payload observations after the event loop completes.

### 2. Same-machine sibling relay behavior

- Covered partially by `InternalCoordinatorTest::classTest_IPC()`.
- This checks that a local unresolved target and a remote unresolved target both flow through sibling relay classification, using `messageRelayed` and `messageNotRelayed`.
- Covered additionally by `SiblingCoordinatorTest::classTest_testReflector()`, which exercises launch, ping reply, and terminate against the named `reflector` sibling.

### 3. Raw event-driven named-pipe behavior

- Covered only minimally by `DirsTest`.
- The test opens a read pipe and write pipe, sends one binary payload containing an embedded `NUL`, waits for completion, compares payload bytes, and closes both handles.
- This confirms the basic pipe API works, but it does not exercise the newer event-driven BG/FG wake-and-backlog behavior directly.

### 4. Configured coordinator launch topology

- `testConfig.ini` defines the short names and coordinator blocks used by the current test surface:
  - `verifier`
  - `consoletested`
  - `scriptrunner`, `scriptrunner2`, `scriptrunner3`
  - `reflector`, `reflector2`, `reflector3`
- It also exposes dormant regression knobs that matter to the pipe layer:
  - `quitReflectorTimesliceForTestsMicroseconds`
  - `scanActiveSiblingsIntervalMicroseconds`
  - `scanConfigSiblingsIntervalMicroseconds`
  - `scanNamedPipeSiblingsIntervalMicroseconds`
  - `interCoordinatorPipeWaitTimeMicroseconds.windows`

### 5. Manual reflector-based remote-eval coverage

- `BuildScripts/TestScripts/runTests` plus `reflector*.tql` validate a practical remote-eval path across multiple helper coordinators.
- `localPingReflector.tql` and `remotePingReflector.tql` extend the same idea from the released sample area.
- These scripts are good smoke assets for future remote-node work because they already separate target selection from the calling coordinator.

### 6. Embedded InDesign / ExtendScript communication coverage

- `InDesignTightener/TestScripts/runEmbeddedCommunicationRegression.tql` now provides one checked-in wrapper for:
  - in-app coordinator -> self
  - in-app coordinator -> main
  - in-app coordinator -> reflector
- It reuses the existing `pingMain.tql` and `pingReflector.tql` scripts and adds `pingSelf.tql` for the self-route.
- `TightenerDocs/CurrentRelease/Plug-Ins/TightenerESDLL/testCommunication.jsx` provides the same-machine ExtendScript DLL counterpart for `self`, `main`, and `reflector`.
- ExtendScript gateway-forwarding remains unsupported; that limitation is now documented and surfaced explicitly by the host loop instead of being hidden.

## Pipe-Specific Hooks Present but Not Covered Directly

The codebase already exposes several pipe-specific behaviors that currently lack dedicated regression coverage:

- backlog limit and policy selection:
  - `maxReadPipeBufferedPackets`
  - `readPipeBacklogPolicy`
  - parsing in `Tightener/TghCoordinator/TghInternalCoordinator.cpp:3479-3504`
  - enforcement in `Tightener/TghUtils/TghPipes.cpp:705-739`
- wake-pipe creation and shutdown signaling:
  - `Tightener/TghUtils/TghPipes.cpp:1152-1163`
  - Windows wait path via `WaitForMultipleObjects(..., INFINITE)` at `:1798-1805`
  - POSIX wait path via `poll(..., -1)` at `:1905-1929`
- force-error hook:
  - `Pipes::setIsForceErrorsForTesting()` at `Tightener/TghUtils/TghPipes.cpp:4170-4176`

These are exactly the hooks a direct `TghPipes` regression suite should target later.

## Missing Coverage

### Automated gaps

- No dedicated compiled tests for `TghPipes`.
- No direct assertions for wake-pipe shutdown while a read thread is blocked.
- No automated coverage for reconnect/reopen after sibling or pipe disappearance.
- No automated coverage for multi-packet assembly beyond a single small payload in `DirsTest`.
- No automated coverage for backlog `stall` behavior.
- No automated subprocess coverage for backlog `crash` behavior.
- No automated coverage for forced pipe errors using `Pipes::setIsForceErrorsForTesting()`.
- No automated gateway-specific assertions inside `TightenerGW`.
- No automated cross-host route using real remote nodes.
- No automated reply-path coverage through `main -> gateway -> remote gateway -> remote coordinator -> origin`.
- No real cross-host gateway coverage from the ExtendScript host loop.

### Manual/process gaps

- No checked-in runner for `tightenerlinux` or `tightenerwindows`.
- No checked-in log collection workflow for cross-host failures.
- No explicit manual scenario for sibling restart/reconnect after reflector termination.
- No explicit manual scenario for pipe disappearance during in-flight traffic.
- No explicit manual scenario for high-volume or large multi-packet payload stress.

### Documentation gaps

- `Tightener/Docs/README.md` references `TightenerDocs/CurrentRelease/SampleScripts/ReleaseTestScripts/sendData.tql`, but that file is not present in the tree.
- There is no single document today that explains how compiled tests, helper scripts, reflector scripts, and config blocks fit together as one communication-stack regression surface.

## Practical Takeaways

- The current automated baseline is good for local coordinator semantics and one narrow raw-pipe smoke path.
- The current manual baseline is good for reflector-based remote eval smoke tests.
- The weakest areas today are direct event-driven pipe regressions, gateway-specific path assertions, and real cross-host runs.
