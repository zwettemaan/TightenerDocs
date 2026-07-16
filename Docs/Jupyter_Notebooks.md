# Jupyter Notebooks for Creative Cloud Scripting

> Status: current supported Python workflow. The shared `tightenerkernel` implementation is present under `TightenerDocs/CurrentRelease/Plug-Ins/Python/` and is the practical source of truth for what ships today.

## Overview

Tightener includes Jupyter Notebook kernels that let you write and run Creative Cloud scripts interactively in a browser-based REPL. Each notebook cell is sent to the running application (InDesign, etc.) and the result is shown inline.

Three kernels are provided:

| Kernel name | Display name | Language | Shell script | Default target |
|---|---|---|---|---|
| `jsxreplwrapper` | TightenerJSX | ExtendScript (.jsx) | `rre_Jupyter` | `JupyterInDesign` |
| `idjsreplwrapper` | TightenerIDJS | UXP Script (.idjs) | `rru_Jupyter` | `JupyterInDesign` |
| `tqlreplwrapper` | TightenerTQL | TQL (.tql) | `rrt_Jupyter` | `reflector` |
| `tqlindesignreplwrapper` | TightenerTQL (InDesign) | TQL (.tql) | `rrt_Jupyter` | `JupyterInDesign` |

The plain TightenerTQL kernel talks to the reflector (no InDesign needed; no
InDesign DOM). TightenerTQL (InDesign) runs TQL inside InDesign's Tightener
engine, where `app` resolves to the InDesign DOM. Note that variables only
persist between cells on the reflector kernel (its handler evaluates with
`evalGlobal`); against InDesign each TQL cell currently evaluates in a fresh
scope.

All three are thin flavors of one shared implementation, the `tightenerkernel` Python package (installed into site-packages by the install scripts). The kernel starts its Tightener subprocess lazily on the first cell, shuts it down cleanly on **Kernel > Shutdown**, and auto-reconnects after crashes or timeouts.

### How it works

```
Jupyter cell
  → Python kernel (pexpect.replwrap)
    → shell script (rre_Jupyter / rru_Jupyter / rrt_Jupyter)
      → Tightener CLI running a REPL .tql script
        → sendData() to InDesign / other app
          → result back up the chain → cell output
```

Each kernel spawns a Tightener process that reads code from stdin, forwards it to the target app via `sendData()`, and writes the result to stdout. `pexpect.replwrap` detects a prompt string in stdout to know when a result is complete.

---

## Prerequisites

- **Tightener** installed and configured (see below)
- **Python 3.9+** with `jupyter`, `ipykernel`, and `pexpect`
- InDesign with either the **InDesignTightener native plug-in** or **TightenerESDLL** loaded

---

## Mac Setup

### 1. Install Python

```bash
brew install python3
```

Confirm: `python3 --version`

### 2. Create a virtual environment (recommended)

```bash
python3 -m venv ~/.tightener-jupyter
source ~/.tightener-jupyter/bin/activate
```

### 3. Install Jupyter and dependencies

```bash
pip install jupyter ipykernel pexpect
```

### 4. Install Tightener

Download the latest `.zip` from the TightenerDocs Releases page. Unzip to a convenient location (e.g. `~/Tightener`).

Right-click `install.command` and choose **Open** (required once to clear Gatekeeper). This appends settings to `~/.zshenv` and `~/.profile`, including `TIGHTENER_DEFAULT_REPL_TIMEOUT_MS=20000`.

Open a **new** Terminal and verify:

```bash
cd_tightener
```

### 5. Configure the InDesign target

```bash
editConfig
```

In the `[sampleScripts]` section, set `INDESIGN_SDK_VERSION` to match your installed InDesign (e.g. `18.0` for InDesign 2023). The shorthand target `InDesign` in the kernels resolves to `net.tightener.coordinator.indesign.${INDESIGN_SDK_VERSION}`.

### 6. Install the Jupyter kernels

```bash
cd "${TIGHTENER_RELEASE_ROOT}Plug-Ins/Python"
cp dirconfig_sample.sh dirconfig.sh
```

Edit `dirconfig.sh`. With the venv from step 2:

```bash
VENV=~/.tightener-jupyter
export DIR_KERNELS="${VENV}/share/jupyter/kernels"
export DIR_SITE_PACKAGES="${VENV}/lib/python3.12/site-packages"   # adjust version
```

Without a venv (adjust Python version as needed):

```bash
export DIR_KERNELS=~/Library/Python/3.12/share/jupyter/kernels
export DIR_SITE_PACKAGES=~/Library/Python/3.12/lib/python/site-packages
```

Run the installer (with the venv active if applicable):

```bash
./installMac.command
```

This creates symlinks for all three kernels inside `DIR_KERNELS` and `DIR_SITE_PACKAGES`.

### 7. Launch Jupyter

```bash
jupyter notebook
```

Create a new notebook and pick a kernel from the **Kernel** menu.

---

## Windows Setup

### 1. Install Python

Download from python.org and tick **Add Python to PATH**, or:

```
winget install Python.Python.3
```

### 2. Install Jupyter and dependencies

```
pip install jupyter ipykernel pexpect
```

### 3. Install Tightener

Unzip the release to a convenient location (e.g. `C:\Tightener`). Double-click `install.bat`. This writes user-level environment variables including `TIGHTENER_DEFAULT_REPL_TIMEOUT_MS=20000`.

Open a **new** CMD window and verify: `cd_tightener`

### 4. Configure the InDesign target

```
editConfig
```

Set `INDESIGN_SDK_VERSION` as above.

### 5. Install the Jupyter kernels

```
cd %TIGHTENER_RELEASE_ROOT%Plug-Ins\Python
installWindows.bat
```

This calls `jupyter kernelspec install` for each kernel.

### 6. Launch Jupyter

```
jupyter notebook
```

---

## Connecting InDesign

The kernels' default target is the `JupyterInDesign` shorthand; the
`JUPYTER_INDESIGN_CHANNEL` placeholder in `config.ini` selects which of the
connection options below it resolves to.

### Option A: Native InDesignTightener plug-in (recommended)

Supports both ExtendScript (`jsxreplwrapper`) and UXP Script (`idjsreplwrapper`).

Copy `Tightener.InDesignPlugin` from `Plug-Ins/InDesign<version>/Mac/` (or `Windows/`) into InDesign's `Plug-Ins` folder. Restart InDesign.

The plug-in registers a coordinator named `net.tightener.coordinator.indesign.<version>`. The kernel shorthand target `InDesign` resolves to this.

> **⚠️ Incompatible with APID ToolAssistant — either/or, by design.**
> APID ToolAssistant embeds the same Tightener integration (same plug-in
> resources and the same `app.tightenerTimeslice()`/`app.evalTql()` scripting
> elements), so installing both makes InDesign report a plug-in conflict at
> startup. Install **one or the other**. With APID installed, use the APID
> channel instead (`JUPYTER_INDESIGN_CHANNEL = ${APID_INDESIGN_COORDINATOR}`,
> coordinator `net.tightener.coordinator.indesign.apid.engine.<version>`);
> functionality is equivalent.

### Option B: TightenerESDLL (ExtendScript only)

Use when a native plug-in cannot be installed.

The ESDLL is loaded into InDesign's ExtendScript engine as an `ExternalObject`. It registers a coordinator named `net.tightener.coordinator.adobeindesign.*`. The kernel shorthand `AdobeInDesign` resolves to this.

To activate it, run a JSX script inside InDesign that includes `lib/TightenerESDLLLoader.jsx` and calls `TIGHTENER.lib.tghInit(...)`. A ready-made sample is in `Plug-Ins/TightenerESDLL/sampleTightenerCode.jsx`.

Then set `RRE_JUPYTER_TARGET=AdobeInDesign` in your environment before launching Jupyter.

---

## Kernel environment variables

| Variable | Kernel | Default | Purpose |
|---|---|---|---|
| `RRE_JUPYTER_TARGET` | jsxreplwrapper | `InDesign` | Tightener coordinator shorthand or full URL |
| `RRU_JUPYTER_TARGET` | idjsreplwrapper | `InDesign` | Same, for UXP target |
| `RRT_JUPYTER_TARGET` | tqlreplwrapper | `reflector` | TQL target node |
| `TIGHTENER_SCRIPTS` | all | (from PATH) | Override path to Tightener scripts dir |
| `TIGHTENER_DEFAULT_REPL_TIMEOUT_MS` | all | `20000` | ms before `sendData()` gives up waiting |

Set these in your shell profile or source them before launching Jupyter.

---

## Known issues

### Scripts that time out or return "Timed out"

**Root cause**: The `sendData()` call inside `rre_REPL.tql` reads `TIMEOUT_MS` from the environment. Its fallback when that variable is absent is **10 seconds** (hardcoded). The `rre_Jupyter` and `rru_Jupyter` shell scripts do not export `TIMEOUT_MS`, so the 20-second value of `TIGHTENER_DEFAULT_REPL_TIMEOUT_MS` set by the Tightener installer is ignored, and any ExtendScript or UXP command taking more than 10 seconds returns `Timed out`.

This has been fixed in `rre_Jupyter` and `rru_Jupyter` — both now export `TIMEOUT_MS` and `QUIT_DELAY_MS` and pass them as `-o`/`-w` flags to Tightener, matching the existing Windows `.bat` behaviour. If you are using an older release, apply the patch manually.

For scripts that legitimately run longer than 20 seconds, raise the ceiling in your shell profile:

```bash
export TIGHTENER_DEFAULT_REPL_TIMEOUT_MS=120000  # 2 minutes
```

### InDesign "falling asleep"

InDesign may pause responding to ExtendScript while idle. Clicking its window usually wakes it. The `heartBeatMicroseconds` setting in `config.ini` under `[config.net.tightener.coordinator.indesign*]` controls how often Tightener yields to InDesign. Reducing it (e.g. to `200000` = 0.2 s) can help, at a small CPU cost.

### Kernel stops responding after closing the browser tab

**Fixed in kernel v2.0** (the shared `tightenerkernel` package): the kernel now implements `do_shutdown`, which sends `quit` to the Tightener REPL and terminates the subprocess when the notebook is closed or the kernel restarted. If a subprocess still dies or wedges for another reason, the kernel discards it and reconnects automatically on the next cell — errors appear as readable messages in the notebook (`TightenerStartupError`, `TightenerExited`, `TightenerTimeout`, `Interrupted`) instead of a dead kernel.

On older releases: run `killApps` in a Terminal before restarting, or always use **Kernel > Shutdown** before closing the tab.

### pexpect prompt collision

`pexpect.replwrap` looks for the string `$ ` to detect end-of-output. If a script prints bare `$ ` the kernel reads output early. Avoid printing that string in script output.

---

## Testing strategy for scripts that hang

1. **Isolate to Tightener, not Jupyter**: run the same script in the command-line REPL first:
   `rre_REPL InDesign` (Mac/Linux) or `rre_REPL.bat InDesign` (Windows).
   If it hangs there too, the issue is not Jupyter-specific.

2. **Raise the timeout**: set `TIGHTENER_DEFAULT_REPL_TIMEOUT_MS=300000` (5 min) and retry. If the script completes, it was simply too slow for the current timeout.

3. **Add progress checkpoints**: insert `$.writeln("step N")` calls throughout the script to narrow down where execution stalls.

4. **Enable IPC logging**: set `logIPC = 1` in `config.ini` and check `${DESKTOP_DIR}InDesign_Plug-In.ipc.log` (or `InDesign_ESDLL.log` for the ESDLL path) to see whether messages are being exchanged between Tightener and InDesign.

5. **Measure baseline latency**: `Plug-Ins/TightenerESDLL/benchmark.jsx` measures round-trip overhead and confirms the connection is healthy before scripting.

---

## Roadmap: improved connectors

The three existing kernels all use `pexpect.replwrap`, which wraps the Tightener CLI as an opaque subprocess REPL. Limitations:

- Timeout is a fixed environment variable, not configurable per cell.
- Exceptions come back as plain text, not structured errors.
- No streaming: a long script cannot emit partial output mid-run.
- Target app is fixed at kernel startup.

Next steps in order of effort:

**1. ~~Fix timeout forwarding~~** — done; `rre_Jupyter` and `rru_Jupyter` now forward `TIMEOUT_MS`/`QUIT_DELAY_MS`.

**2. Python socket connector** (medium) — replace the `pexpect` subprocess wrapper with a pure-Python client that talks directly to `TightenerGW` over TCP. Enables structured error objects, per-call timeouts, streaming progress, and switching target at runtime.

**3. Native Python C extension** (larger) — build a CPython `.so`/`.pyd` that links Tightener as a library (using the `TightenerDLL` and `TightenerPython` repos as the basis). Eliminates subprocess overhead entirely and exposes the full Tightener API as Python objects callable from any Python code, not just Jupyter.
