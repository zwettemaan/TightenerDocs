# Tightener Regression Test Session Plan

## Purpose

This document sequences the regression-test work for Tightener coordinator, pipe, gateway, and embedded communication paths. Each task is designed to be handled in a separate agent session with a focused prompt.

The plan assumes we can use:

- local Mac environment
- `ssh tightenerlinux`
- `ssh tightenerwindows`

## Working Order

1. Session A: Inventory and coverage matrix
2. Session B: Local compiled coordinator tests
3. Session C: Pipe and backlog regression tests
4. Session D: Cross-host remote harness
5. Session E: Real remote gateway tests
6. Session F: Embedded and InDesign coordinator tests
7. Session G: Unified runner and final documentation

---

## Session A

### Task

Document the current test surface and define the target regression matrix.

### Scope

- Existing compiled tests in `Tightener`
- Existing helper scripts in `Tightener/BuildScripts`
- Existing sample and manual scripts in `InDesignTightener` and `TightenerDocs`
- Existing gateway and coordinator config coverage

### Deliverables

- One markdown inventory of current tests and scripts
- One coverage matrix mapping current and missing coverage across:
  - in-process / in-app
  - same-machine sibling coordinator
  - same-machine via main coordinator
  - cross-machine via gateway
  - reply path
  - disconnect / reconnect
  - backlog stall / crash
  - embedded InDesign / ExtendScript
- Suggested artifact names:
  - `TightenerDocs/Tightener_RegressionCoverage_CoordinatorGatewayPipes_Inventory.md`
  - `TightenerDocs/Tightener_RegressionCoverage_CoordinatorGatewayPipes_Matrix.md`

### Prompt

```text
Review the Tightener coordinator/gateway/event-driven pipes test surface and create a regression coverage inventory plus a proposed matrix. Do not add code yet. Produce markdown docs that map existing compiled tests, helper scripts, config, and manual scripts to coverage areas, and list the missing cases. Assume we can also use remote nodes on `tightenerlinux` and `tightenerwindows` later.
```

---

## Session B

### Task

Strengthen local compiled coordinator tests before touching remote gateway infrastructure.

### Scope

- `TghInternalCoordinatorTest.cpp`
- `TghSiblingCoordinatorTest.cpp`
- `TghServiceOMTest.cpp`

### Deliverables

- Better local routing coverage
- Better reflector lifecycle coverage
- Clear assertions around:
  - local internal delivery
  - sibling coordinator start / request / terminate / restart
  - main coordinator routing on same machine

### Prompt

```text
Expand the Tightener compiled coordinator tests for same-machine behavior. Focus on `TghInternalCoordinatorTest.cpp`, `TghSiblingCoordinatorTest.cpp`, and `TghServiceOMTest.cpp`. Add regression coverage for local routing through main and for reflector lifecycle behavior including restart/reconnect. Preserve existing Tightener C++ conventions and fail loudly rather than adding fallback behavior.
```

---

## Session C

### Task

Add direct regression coverage for the event-driven pipe implementation and its backlog policies.

### Scope

- `TghPipes.cpp`
- `TghPipes.h`
- compiled test registration in `TghInternalCoordinator.cpp`

### Deliverables

- A dedicated `TghPipes` test class
- Coverage for:
  - basic send/receive
  - close while blocked
  - reopen after disconnect
  - multi-packet assembly
  - wake-pipe shutdown
  - bounded backlog with `stall`
  - subprocess-style coverage for `crash` if appropriate

### Prompt

```text
Add direct regression tests for Tightener's event-driven pipe layer. Create dedicated compiled test coverage for `TghPipes` instead of relying only on indirect coordinator tests. Cover basic traffic, blocked-read shutdown, reconnect/reopen, packet assembly, and backlog-policy behavior (`stall` and, if practical, `crash` via subprocess). Keep to Tightener C++ test and macro conventions.
```

---

## Session D

### Task

Build a reusable cross-host harness for launching remote coordinators and gateways over SSH.

### Scope

- local launch scripts / config
- remote startup / cleanup conventions
- log collection conventions

### Deliverables

- Reusable harness scripts or documented command entry points for:
  - `ssh tightenerlinux`
  - `ssh tightenerwindows`
- Config fragments for remote coordinator and gateway startup
- Remote log locations
- Cleanup commands

### Prompt

```text
Create a reusable Tightener regression harness for remote nodes on `tightenerlinux` and `tightenerwindows`. Use existing Tightener build/test/config patterns. Focus on launching remote coordinators and gateways over SSH, collecting logs, and making the setup reusable by later gateway regression tests. Do not add the full message-assertion suite yet unless needed to validate the harness.
```

---

## Session E

### Task

Add real end-to-end remote gateway regression tests using Linux and Windows nodes.

### Scope

- local main and gateway
- remote gateway on Linux
- remote gateway on Windows
- remote coordinators on each host

### Deliverables

- End-to-end tests for:
  - local main -> local gateway -> linux gateway -> linux coordinator
  - local main -> local gateway -> windows gateway -> windows coordinator
  - reply path back to origin
  - remote coordinator restart / reconnect
- Logs and pass/fail output that show which leg failed

### Prompt

```text
Using the existing remote harness, add end-to-end Tightener gateway regression tests across real hosts. Cover local main -> local gateway -> remote gateway -> remote coordinator on both `tightenerlinux` and `tightenerwindows`, plus the reply path back to the origin and remote coordinator restart/reconnect behavior. Reuse existing Tightener config patterns and make failures explicit in logs and test output.
```

---

## Session F

### Task

Cover embedded and InDesign communication paths, with explicit notes about unsupported gateway behavior in the ExtendScript host loop.

### Scope

- `InDesignTightener`
- `TightenerDLL`
- `Tightener/TightenerDaemon/jsx`

### Deliverables

- Automated or semi-automated smoke coverage for:
  - in-app coordinator -> self
  - in-app coordinator -> main
  - in-app coordinator -> reflector
- Documentation of current limitations, especially where the ExtendScript loop discards host/gateway messages

### Prompt

```text
Add regression coverage for the embedded Tightener communication path used by InDesign and ExtendScript. Focus on in-app coordinator -> self, in-app coordinator -> main, and in-app coordinator -> reflector. Reuse existing InDesignTightener test scripts where practical. Also document clearly any unsupported gateway behavior in the ExtendScript host loop instead of hiding it.
```

---

## Session G

### Task

Unify the new regression work behind a single runner and finish the documentation.

### Scope

- local compiled tests
- pipe tests
- remote harness
- remote gateway tests
- embedded smoke tests

### Deliverables

- One documented entry point for modes such as:
  - `local`
  - `linux-remote`
  - `windows-remote`
  - `embedded-smoke`
- Final docs summarizing:
  - what is covered
  - what is still manual
  - platform-specific limitations
  - how to collect logs when a run fails

### Prompt

```text
Create a unified regression-test entry point for the Tightener communication stack and finalize the documentation. The runner should make it clear how to execute local compiled tests, pipe/backlog tests, linux/windows remote gateway tests, and embedded smoke tests. Produce concise final docs describing coverage, remaining gaps, platform notes, and failure-log collection steps.
```

---

## Notes For Every Session

- Follow `TightenerDocs/Tightener_CodingConventions.md`
- Do not add silent fallback behavior
- Prefer explicit failure and clear logging
- Preserve cross-platform behavior across Mac, Linux, and Windows
- Reuse existing config and launch patterns where possible
- Leave behind runnable artifacts, not just analysis
