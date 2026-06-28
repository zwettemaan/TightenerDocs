# Tightener Coordinator, Gateway, and Pipe Proposed Regression Matrix

## Purpose

This matrix turns the current inventory into a target regression plan. It separates:

- already covered
- partially covered
- missing and recommended next

## Legend

- `Automated`: exercised by compiled tests or scripted runner
- `Manual`: exercised by checked-in scripts or documented operator steps
- `Missing`: no meaningful in-tree coverage today

## Coverage Matrix

| Scenario | Current status | Current assets | Main gaps | Recommended next owner/session |
| --- | --- | --- | --- | --- |
| In-process local delivery within one coordinator | Automated | `InternalCoordinatorTest::classTest_ping()` | does not stress message volume or timing edges | Session B |
| Same-machine sibling launch and ping reply | Automated | `SiblingCoordinatorTest::classTest_testReflector()` | no restart-after-quit assertion | Session B |
| Same-machine relay classification (`relayed` vs `not relayed`) | Automated | `InternalCoordinatorTest::classTest_IPC()` | classification only; not end-to-end payload return through sibling | Session B |
| Raw named-pipe open/write/read/close | Automated | `DirsTest` | single basic payload only; no dedicated pipe suite | Session C |
| Embedded `NUL` payload handling through pipe API | Automated | `DirsTest` | only single payload size/path | Session C |
| Multi-packet payload assembly | Partial | reflector scripts send larger string payloads indirectly | no direct compiled assertion at `TghPipes` layer | Session C |
| Close while blocked on read | Missing | none | wake-pipe shutdown is implemented but untested directly | Session C |
| Reopen after peer disconnect / pipe reappearance | Missing | none | no direct regression around reappearance and resend | Session C / E |
| Backlog policy `stall` | Missing | config knob exists | no runner that constrains `maxReadPipeBufferedPackets` and verifies blocking/unblocking | Session C |
| Backlog policy `crash` | Missing | config knob exists | needs subprocess-style assertion, not in-process abort | Session C |
| Forced pipe error path | Missing | `Pipes::setIsForceErrorsForTesting()` exists | no tests use it | Session C |
| Same-machine `main -> reflector` remote eval | Manual | `localPingReflector.tql`, `localQuitReflector.tql` | not wired into release/CI runner | Session B / G |
| Same-machine multi-run helper coordinators | Manual | `BuildScripts/TestScripts/runTests` + `reflector*.tql` | smoke only; no pass/fail summary artifact | Session G |
| Release smoke through `verifier` | Automated | `runReleaseTestsMac`, `runReleaseTestsLinux`, `runReleaseTests.bat` | broad suite but poor stack-specific reporting | Session G |
| Interactive broad suite through `consoletested` | Automated | `testConfig.ini` + `README` instructions | not specific to gateway/pipe scenarios | Session G |
| Local gateway binary invoking shared compiled tests | Automated but indirect | `TightenerGW` main calls `Test::runAll()` | no gateway-specific fixtures or assertions | Session E |
| Cross-host remote eval to configurable host | Manual | `remotePingReflector.tql`, `remoteQuitReflector.tql`, `remoteSettings.json` | no standard remote-node harness | Session D |
| Mac -> `tightenerlinux` coordinator | Missing | none yet beyond reusable remote script pattern | no launch/log/cleanup automation | Session D / E |
| Mac -> `tightenerwindows` coordinator | Missing | none yet beyond reusable remote script pattern | no launch/log/cleanup automation | Session D / E |
| Mac main -> local gateway -> remote gateway -> linux coordinator | Missing | none | no gateway harness or assertions | Session E |
| Mac main -> local gateway -> remote gateway -> windows coordinator | Missing | none | no gateway harness or assertions | Session E |
| End-to-end reply path back to origin across gateways | Missing | none | no route-level verifier | Session E |
| Remote coordinator restart/reconnect under traffic | Missing | none | no automation or documented manual flow | Session E |
| Embedded InDesign / ExtendScript -> self | Manual | `InDesignTightener/TestScripts/pingSelf.tql`, `runEmbeddedCommunicationRegression.tql`, `CurrentRelease/Plug-Ins/TightenerESDLL/testCommunication.jsx` | not part of the compiled/release runner yet | Session G |
| Embedded InDesign / ExtendScript -> main/reflector | Manual | `InDesignTightener/TestScripts/pingMain.tql`, `pingReflector.tql`, `runEmbeddedCommunicationRegression.tql`, `CurrentRelease/Plug-Ins/TightenerESDLL/testCommunication.jsx`, `Tightener_RegressionCoverage_EmbeddedInDesignExtendScript.md` | ExtendScript host loop still has no gateway-forwarding implementation | Session G |

## Recommended Minimum Regression Set

### Phase 1: Strengthen the local automated baseline

- Keep using the shared compiled suite through `verifier`.
- Add direct compiled pipe tests instead of relying on `DirsTest` for all pipe behavior.
- Expand sibling/coordinator tests to include restart/reconnect and same-machine route completion.

### Phase 2: Convert useful manual reflector scripts into repeatable smoke runs

- Treat `localPingReflector.tql` as the canonical same-machine remote-eval smoke.
- Treat `remotePingReflector.tql` as the canonical cross-host smoke shape.
- Add a single summarized pass/fail output and log pointers.

### Phase 3: Add real remote-node and gateway paths

- Introduce reusable launch, cleanup, and log collection commands for:
  - `tightenerlinux`
  - `tightenerwindows`
- After that, add route assertions through local and remote gateway legs.

## Proposed Matrix by Environment

| Environment | Must cover | Nice to have |
| --- | --- | --- |
| Local Mac | compiled coordinator tests, direct pipe tests, reflector smoke, backlog policy tests | gateway binary smoke |
| `tightenerlinux` | remote coordinator launch, remote eval smoke, gateway route, reconnect | stress / large payload |
| `tightenerwindows` | remote coordinator launch, remote eval smoke, gateway route, reconnect, Windows-specific pipe wait timing | stress / large payload |
| Embedded InDesign | self/main/reflector smoke | gateway limitations documentation plus any safe automated hooks |

## Pass/Fail Signals to Standardize Later

These are not implemented yet, but the matrix depends on them:

- explicit per-scenario pass/fail lines
- per-host log file locations
- timeout values used for each scenario
- a clear distinction between:
  - route setup failure
  - send failure
  - no reply
  - wrong payload
  - reconnect timeout

## Out-of-Scope for This Session

- code changes
- new test harnesses
- remote-node automation
- embedded InDesign regression work
