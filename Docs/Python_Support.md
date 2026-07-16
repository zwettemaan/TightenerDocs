# Python Support

This page is the canonical overview of Python-related work across the Tightener ecosystem.

## The four Python tracks

### 1. Jupyter notebooks and kernels

**Purpose:** drive Tightener targets interactively from notebooks.

**Current status:** active and implemented.

**What exists now:**
- Shared `tightenerkernel` implementation in [CurrentRelease/Plug-Ins/Python](../CurrentRelease/Plug-Ins/Python/)
- Three kernelspec flavors:
  - `jsxreplwrapper` for ExtendScript
  - `idjsreplwrapper` for UXP Script
  - `tqlreplwrapper` for TQL
- Installers for Mac, Windows, and Linux
- Sample notebook in `CurrentRelease/Plug-Ins/Python/jupyter_notebooks/`

**Primary docs:**
- [Jupyter_Notebooks.md](Jupyter_Notebooks.md)
- [TightenerPy_Plan.md](TightenerPy_Plan.md) for the kernel-hardening history and next-step context

**Notes:**
- This is the most mature Python-facing workflow today.
- The runtime artifacts under `CurrentRelease/Plug-Ins/Python/` are the practical source of truth for what ships.

### 2. Standalone Python with Tightener embedded

**Short description:** Python wraps Tightener.

The intended result is a bundled, per-platform Python distribution where `import tightener` works out of the box and Jupyter runs on that bundled interpreter.

**Current status:** planned, not yet shipped.

**What exists now:**
- Architectural plan for a bundled distribution
- Technical design notes for a native `tightener` Python module
- A dedicated repo that already builds static CPython libraries for Tightener use

**Primary docs:**
- [TightenerPy_Plan.md](TightenerPy_Plan.md)
- [Python_Tightener_Integration.md](Python_Tightener_Integration.md)
- [../../TightenerPython/README.md](../../TightenerPython/README.md)

**Important boundary:**
- `TightenerPython` currently builds static Python libraries.
- It does **not** yet produce the full relocatable end-user Python distribution described in `TightenerPy_Plan.md`.

### 3. Embedded Python inside the ExtendScript DLL

**Short description:** Tightener wraps Python.

This is the `ExtendPyScript` direction: embed Python into the ExtendScript DLL so Python can run inside the Adobe scripting environment and access the host DOM through the bridge.

**Current status:** exploratory / partially documented, not clearly landed as working product code.

**What exists now:**
- Project overviews and implementation notes in `ExtendPyScript`
- A strong dependency on `TightenerPython` static-library outputs
- Build/runtime context in `TightenerDLL`

**Primary docs:**
- [../../ExtendPyScript/Tightener_Overview_ExtendPyScript.md](../../ExtendPyScript/Tightener_Overview_ExtendPyScript.md)
- [../../ExtendPyScript/IMPLEMENTATION.md](../../ExtendPyScript/IMPLEMENTATION.md)
- [../../ExtendPyScript/CPYTHON_INTEGRATION_STATUS.md](../../ExtendPyScript/CPYTHON_INTEGRATION_STATUS.md)

**Important caution:**
- Several `ExtendPyScript` docs still speak in future-tense scaffolding language.
- In this repo snapshot, the documented `TghPythonInterpreter` / `TghPythonBridge` files are not present under `TightenerDLL/ESSDK/`, so treat the integration-status doc as design/history rather than current confirmed implementation.

### 4. Direct Python-to-Tightener connectors

This is the family of approaches where Python talks to Tightener more directly, without the existing notebook `pexpect` REPL layer.

**Current status:** design space, not the main shipped path.

**Primary doc:**
- [Python_Tightener_Integration.md](Python_Tightener_Integration.md)

**Strategies covered there:**
- one-shot subprocess calls
- persistent bridge subprocess
- pure-Python named-pipe connector
- native Python C extension

This document is best read as the technical option space behind track 2, not as a user-facing setup guide.

## Supporting repos

### `TightenerPython`

Role: build static CPython 3.14 libraries for macOS, Windows, and Linux.

Use this repo when the question is about:
- Python versioning
- static libs and include paths
- platform build outputs
- dependency management for embedded Python

Primary docs:
- [../../TightenerPython/README.md](../../TightenerPython/README.md)
- [../../TightenerPython/QUICKREF.md](../../TightenerPython/QUICKREF.md)
- [../../TightenerPython/MODULE_CONFIG.md](../../TightenerPython/MODULE_CONFIG.md)

### `ExtendPyScript`

Role: project area for Adobe/ExtendScript-facing embedded Python.

Use this repo when the question is about:
- loading Python through the ExtendScript DLL
- mapping Adobe DOM objects into Python
- packaging Python-driven Adobe scripting tools

### `TightenerDLL`

Role: host DLL infrastructure for ExtendScript integration.

Use this repo when the question is about:
- actual ESDLL implementation work
- debugging the DLL in Adobe tooling
- where embedded-Python code would ultimately have to live

## Recommended doc posture

When documenting Python support, treat the tracks as:

| Track | Status | Canonical doc |
|---|---|---|
| Jupyter kernels | current | `Jupyter_Notebooks.md` |
| Bundled Tightener Python distro | planned | `TightenerPy_Plan.md` |
| Embedded Python in ESDLL | exploratory | `ExtendPyScript/*` |
| Direct connector strategies | design notes | `Python_Tightener_Integration.md` |

## Concise plan

1. Keep **Jupyter kernels** as the current supported Python story and document them as such.
2. Treat **bundled TightenerPy** as the main strategic direction for general Python support.
3. Treat **ExtendPyScript** as a separate Adobe-specific track, not the default future of Python support overall.
4. Mark **connector strategy docs** as technical design notes that support the bundled-Python direction.
5. Avoid mixing build-infrastructure facts (`TightenerPython`) with product-status claims; they answer different questions.

## Suggested next cleanup

If we continue tidying this area, the next worthwhile edits are:

1. Add short status banners to `Jupyter_Notebooks.md`, `TightenerPy_Plan.md`, and the main `ExtendPyScript` docs.
2. Remove or ignore tracked runtime noise under `CurrentRelease/Plug-Ins/Python/` such as `__pycache__` and notebook checkpoints.
3. Decide whether `ExtendPyScript/CPYTHON_INTEGRATION_STATUS.md` should be rewritten as a design note or backed by code references.
