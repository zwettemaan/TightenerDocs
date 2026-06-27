# Tightener Remote Regression Harness

## Purpose

This harness prepares `tightenerlinux` and `tightenerwindows` for later gateway regression tests from the Mac build machine.

It does three things:

- installs a shared remote-test config built from the existing `BuildScripts/testConfig.ini`
- starts or stops a remote node in either `server` mode (`Tightener -s`) or `gateway` mode (`TightenerGW_Cpp`)
- collects the resulting logs and the applied config back to the Mac

It does **not** add the end-to-end message assertion suite yet.

## Entry Point

Use:

```bash
Tightener/BuildScripts/runRemoteRegressionHarnessMac
```

The script is Mac-only and follows the existing Tightener build environment:

- `. Tightener/BuildScripts/setEnv`
- `UBUNTU_*` variables for `tightenerlinux`
- `WINDOWS_*` variables for `tightenerwindows`
- remote `TIGHTENER_RELEASE_ROOT` / `TIGHTENER_BINARIES` already configured on each node

## Commands

Prepare local plus remote configs:

```bash
runRemoteRegressionHarnessMac prepare all
```

Start Linux or Windows in main-only server mode:

```bash
runRemoteRegressionHarnessMac start linux server
runRemoteRegressionHarnessMac start windows server
```

Start Linux or Windows in gateway mode:

```bash
runRemoteRegressionHarnessMac start linux gateway
runRemoteRegressionHarnessMac start windows gateway
```

Check status:

```bash
runRemoteRegressionHarnessMac status all
```

Collect logs:

```bash
runRemoteRegressionHarnessMac collect all /tmp/TightenerRemoteHarness/manual-run
```

Minimal smoke flow:

```bash
runRemoteRegressionHarnessMac smoke all gateway
```

## Typical Usage

Prepare the generated config on Mac, Linux, and Windows:

```bash
bash Tightener/BuildScripts/runRemoteRegressionHarnessMac prepare all
```

Start gateway mode on one remote node:

```bash
bash Tightener/BuildScripts/runRemoteRegressionHarnessMac start linux gateway
```

Check Linux and Windows status:

```bash
bash Tightener/BuildScripts/runRemoteRegressionHarnessMac status all
```

Collect logs into a known folder on the Mac:

```bash
bash Tightener/BuildScripts/runRemoteRegressionHarnessMac collect all /tmp/TightenerRemoteHarness/manual-run
```

Stop the remote nodes when done:

```bash
bash Tightener/BuildScripts/runRemoteRegressionHarnessMac stop all
```

For the standard end-to-end harness check after a full build, use:

```bash
bash Tightener/BuildScripts/runRemoteRegressionHarnessMac smoke all gateway
```

## Config Pattern

The harness appends `BuildScripts/testConfigRemoteHarness.ini` to the existing `BuildScripts/testConfig.ini`.

That fragment:

- turns on IPC logging
- adds stable URL shorthands for `tightenerlinux` and `tightenerwindows`

When you run `start`, the harness reapplies a mode-specific overlay before launch:

- `server` mode enables `main` and keeps `gateway` disabled
- `gateway` mode launches `TightenerGW_Cpp -N gateway`, enables `gateway`, and disables `main` so both do not compete for the same listener port

The generated config is installed with the existing `copyDebugConfig` scripts, so it uses the same SysConfig locations as the current local release-test flow.

## Collected Artifacts

For each remote node the harness bundles:

- `main*.log`
- `gateway*.log`
- `reflector*.log`
- `scriptrunner*.log`
- `verifier.log`
- `remoteHarness.server.out`
- `remoteHarness.gateway.out`
- the applied `config.ini`
- a status snapshot of running Tightener processes and named pipes

## Notes

- `gateway` mode replaces `server` mode on a node because both flows begin with `killApps`.
- Each `start` run clears the prior harness log files on the remote desktop before launch so collected evidence is from the current run only.
- The harness sets `TIGHTENER_CONFIG_NODE_NAME` to `tightenerlinux` or `tightenerwindows` for the launched process so later gateway tests can use stable host names.
- Windows remote launch uses detached process creation rather than a plain child of the SSH session, so the gateway survives after the SSH command exits.
- Windows status collection is implemented directly in PowerShell because `whatIsRunning.bat` ends with `pause` and is not suitable for non-interactive SSH use.
