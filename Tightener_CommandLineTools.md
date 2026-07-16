# Tightener Command Line Tools Reference

## Overview

This document provides a comprehensive reference for all command line tools and scripts available in the Tightener ecosystem. These tools are located in `TightenerDocs/CurrentRelease/CommandLine/Scripts/` and provide automation, development, and management capabilities for Tightener and Adobe Creative Cloud applications.

## Table of Contents

- [Script Execution Tools](#script-execution-tools)
- [REPL and Interactive Tools](#repl-and-interactive-tools)
- [Jupyter Kernel Tools](#jupyter-kernel-tools)
- [Gateway and Server Tools](#gateway-and-server-tools)
- [InDesign Integration Tools](#indesign-integration-tools)
- [Environment Management Tools](#environment-management-tools)
- [Configuration Tools](#configuration-tools)
- [Navigation Shortcuts (Windows)](#navigation-shortcuts-windows)
- [Utility Tools](#utility-tools)
- [Platform-Specific Wrappers](#platform-specific-wrappers)

---

## Script Execution Tools

### `rt` - Run Tightener Script

**Purpose**: Execute a locally stored TQL (Tightener Query Language) script.

**Platforms**: Mac, Linux (bash script)

**Usage**:
```bash
rt scriptPath [quitDelayMilliseconds]
```

**Parameters**:
- `scriptPath`: Path to the `.tql` script file (required)
- `quitDelayMilliseconds`: Delay in milliseconds before quitting (default: 500)

**Example**:
```bash
rt hello.tql
rt myScript.tql 1000
```

**Description**: Creates a unique coordinator session and runs the TQL script locally using the Tightener executable with appropriate flags.

---

### `rrt` - Run Remote Tightener Script

**Purpose**: Execute a locally stored TQL script on a remote Tightener target.

**Platforms**: Mac, Linux (bash script)

**Usage**:
```bash
rrt target scriptPath [quitDelayMilliseconds]
```

**Parameters**:
- `target`: Target coordinator (short name or full TGH URI)
- `scriptPath`: Path to the `.tql` script file (required)
- `quitDelayMilliseconds`: Delay before quitting (uses `TIGHTENER_DEFAULT_RR_QUIT_DELAY_MS` if not specified)

**Examples**:
```bash
rrt reflector hello.tql 10000
rrt tgh://127.0.0.1/net.tightener.coordinator.reflector/default hello.tql 10000
rrt tgh://sandy.rorohiko.com/net.tightener.coordinator.indesign.17.0/main hello.tql
```

**Description**: Runs a TQL script remotely on a specified coordinator target with timeout handling.

---

### `rre` - Run Remote ExtendScript

**Purpose**: Execute a locally stored ExtendScript (.jsx) file on a remote Adobe application.

**Platforms**: Mac, Linux (bash script)

**Usage**:
```bash
rre target extendScriptPath [quitDelayMilliseconds]
```

**Parameters**:
- `target`: Target application (short name like `indesign` or full TGH URI)
- `extendScriptPath`: Path to the `.jsx` script file (required)
- `quitDelayMilliseconds`: Delay before quitting (uses `TIGHTENER_DEFAULT_RR_QUIT_DELAY_MS` if not specified)

**Examples**:
```bash
rre indesign hello.jsx 10000
rre tgh://freddy/indesign/main hello.jsx
rre tgh://sandy.rorohiko.com/net.tightener.coordinator.indesign.17.0/main hello.jsx
```

**Description**: Executes ExtendScript files remotely on Adobe Creative Cloud applications that support ExtendScript.

---

### `rru` - Run Remote UXP Script

**Purpose**: Execute a locally stored UXP Script (.idsj) file on a remote InDesign/InCopy/InDesign Server instance.

**Platforms**: Mac, Linux (bash script)

**Usage**:
```bash
rru target uxpScriptPath [quitDelayMilliseconds]
```

**Parameters**:
- `target`: Target application (short name like `indesign` or full TGH URI)
- `uxpScriptPath`: Path to the `.idsj` UXP script file (required)
- `quitDelayMilliseconds`: Delay before quitting (uses `TIGHTENER_DEFAULT_RR_QUIT_DELAY_MS` if not specified)

**Examples**:
```bash
rru indesign hello.idsj 10000
rru tgh://freddy/indesign/main hello.idsj
rru tgh://sandy.rorohiko.com/net.tightener.coordinator.indesign.18.0/main hello.idsj
```

**Description**: Executes UXP (Unified Extensibility Platform) scripts on InDesign 2021 and later versions.

---

### `evalTQL` - Evaluate TQL Expression

**Purpose**: Evaluate a TQL expression directly from the command line.

**Platforms**: Mac, Linux (bash script)

**Usage**:
```bash
evalTQL "expression"
```

**Parameters**:
- `expression`: TQL expression to evaluate (required, must be quoted)

**Examples**:
```bash
evalTQL "sqrt(2)"
evalTQL "13*13"
evalTQL "\"a\""  # Double quotes need double encoding
```

**Description**: Evaluates TQL expressions directly without requiring a script file. Uses stdin to pass the expression to Tightener.

---

## REPL and Interactive Tools

### `rrt_REPL` - Remote TQL REPL

**Purpose**: Start an interactive Read-Eval-Print Loop (REPL) for TQL commands on a remote target.

**Platforms**: Mac, Linux (bash script)

**Usage**:
```bash
rrt_REPL target [tqlCommand [quitDelayMS]]
```

**Parameters**:
- `target`: Target coordinator (required)
- `tqlCommand`: Optional single command to execute
- `quitDelayMS`: Optional quit delay

**Examples**:
```bash
rrt_REPL indesign
rrt_REPL illustrator
rrt_REPL tgh://sandy.rorohiko.com/net.tightener.coordinator.indesign.17.0/main
```

**Description**: Provides an interactive shell for executing TQL commands on remote coordinators.

---

### `rre_REPL` - Remote ExtendScript REPL

**Purpose**: Start an interactive REPL for ExtendScript commands on a remote Adobe application.

**Platforms**: Mac, Linux (bash script)

**Usage**:
```bash
rre_REPL target [jsxCommand [quitDelayMS]]
```

**Parameters**:
- `target`: Target application (required)
- `jsxCommand`: Optional single command to execute
- `quitDelayMS`: Optional quit delay

**Examples**:
```bash
rre_REPL indesign
rre_REPL illustrator
rre_REPL tgh://sandy.rorohiko.com/net.tightener.coordinator.indesign.17.0/main
```

**Description**: Provides an interactive JavaScript shell for Adobe applications supporting ExtendScript.

---

### `rru_REPL` - Remote UXP Script REPL

**Purpose**: Start an interactive REPL for UXP Script commands on InDesign/InCopy/InDesign Server.

**Platforms**: Mac, Linux (bash script)

**Usage**:
```bash
rru_REPL target [uxpCommand [quitDelayMS]]
```

**Parameters**:
- `target`: Target application (required)
- `uxpCommand`: Optional single command to execute
- `quitDelayMS`: Optional quit delay

**Examples**:
```bash
rru_REPL indesign
rru_REPL tgh://sandy.rorohiko.com/net.tightener.coordinator.indesign.17.0/main
```

**Description**: Provides an interactive UXP JavaScript shell for InDesign 2021 and later.

---

## Jupyter Kernel Tools

### `rrt_Jupyter` - TQL Jupyter Kernel

**Purpose**: Backend for Jupyter Notebook kernel supporting TQL.

**Platforms**: Mac, Linux (bash script)

**Usage**:
```bash
rrt_Jupyter target prompt continuationPrompt
```

**Parameters**:
- `target`: Target coordinator (required)
- `prompt`: Primary prompt string (required)
- `continuationPrompt`: Continuation prompt string (required)

**Description**: Provides Jupyter Notebook integration for TQL scripting. Used internally by Jupyter kernels.

---

### `rre_Jupyter` - ExtendScript Jupyter Kernel

**Purpose**: Backend for Jupyter Notebook kernel supporting ExtendScript.

**Platforms**: Mac, Linux (bash script)

**Usage**:
```bash
rre_Jupyter target prompt continuationPrompt
```

**Parameters**:
- `target`: Target application (required)
- `prompt`: Primary prompt string (required)
- `continuationPrompt`: Continuation prompt string (required)

**Description**: Provides Jupyter Notebook integration for ExtendScript. Used internally by Jupyter kernels.

---

### `rru_Jupyter` - UXP Script Jupyter Kernel

**Purpose**: Backend for Jupyter Notebook kernel supporting UXP Script.

**Platforms**: Mac, Linux (bash script)

**Usage**:
```bash
rru_Jupyter target prompt continuationPrompt
```

**Parameters**:
- `target`: Target application (required)
- `prompt`: Primary prompt string (required)
- `continuationPrompt`: Continuation prompt string (required)

**Description**: Provides Jupyter Notebook integration for UXP scripting. Used internally by Jupyter kernels.

---

## Gateway and Server Tools

### `gw` - Start Gateway (Console Mode)

**Purpose**: Start the Tightener Gateway in console mode.

**Platforms**: Mac, Linux (bash script)

**Usage**:
```bash
gw
```

**Description**: Kills existing Tightener processes and starts `TightenerGW_Cpp` in the background, providing gateway functionality for the Tightener network.

---

### `gwui` - Start Gateway (UI Mode)

**Purpose**: Start the Tightener Gateway with graphical user interface.

**Platforms**: Mac, Linux (bash script wrapper)

**Usage**:
```bash
gwui
```

**Description**: Platform-aware wrapper that calls `gwuiMac` on macOS or `gwuiLinux` on Linux to start the gateway with UI.

---

### `gwConsoleXojo` - Start Xojo Console Gateway

**Purpose**: Start the Xojo-based console gateway.

**Platforms**: Mac, Linux (bash script wrapper)

**Usage**:
```bash
gwConsoleXojo
```

**Description**: Platform-aware wrapper that calls the appropriate Xojo console gateway for the current platform.

---

### `startConsole` - Start Interactive Console

**Purpose**: Start an interactive Tightener console.

**Platforms**: Mac, Linux (bash script)

**Usage**:
```bash
startConsole
```

**Description**: Launches Tightener with console coordinator name, enabling interactive command execution with JSON output support.

---

### `startServer` - Start Tightener Server

**Purpose**: Start Tightener in server mode.

**Platforms**: Mac, Linux (bash script)

**Usage**:
```bash
startServer
```

**Description**: Kills existing Tightener processes and starts Tightener in server mode (`-s` flag).

---

## InDesign Integration Tools

### `idLaunch` - Launch InDesign with Tightener

**Purpose**: Launch InDesign with the appropriate Tightener plugin and start timeslicing.

**Platforms**: Mac (bash script)

**Usage**:
```bash
idLaunch
```

**Description**:
- Verifies Tightener plugin installation
- Launches InDesign or InDesign Server based on configuration
- For client mode: Opens InDesign and runs `idPoke` to start timeslicing
- For server mode: Launches InDesign Server with console flag

**Prerequisites**: Requires `idSetEnv` configuration and installed Tightener plugin.

---

### `idPoke` - Poke InDesign for Timeslicing

**Purpose**: Periodically trigger Tightener timeslice calls in InDesign.

**Platforms**: Mac (bash script using AppleScript)

**Usage**:
```bash
idPoke
```

**Description**: Creates and runs an AppleScript that repeatedly calls `app.tightenerTimeslice()` in the running InDesign instance to maintain Tightener responsiveness.

---

### `idPluginInstall` - Install InDesign Tightener Plugin

**Purpose**: Install the Tightener plugin into InDesign.

**Platforms**: Mac (bash script)

**Usage**:
```bash
idPluginInstall
```

**Description**:
- Removes existing Tightener plugin (calls `idPluginRemove`)
- Creates Rorohiko plugin folder if needed
- Copies appropriate plugin (Tightener or TightenerServer) based on configuration
- Requires sudo permissions for system folders

---

### `idPluginRemove` - Remove InDesign Tightener Plugin

**Purpose**: Remove the Tightener plugin from the configured InDesign version.

**Platforms**: Mac (bash script)

**Usage**:
```bash
idPluginRemove
```

**Description**: Removes Tightener or TightenerServer plugin from the Rorohiko plugin folder based on current configuration. Requires sudo permissions.

---

### `idPluginRemoveAll` - Remove All InDesign Tightener Plugins

**Purpose**: Remove Tightener plugins from ALL installed InDesign versions.

**Platforms**: Mac (bash script)

**Usage**:
```bash
idPluginRemoveAll
```

**Description**:
- Searches all InDesign installations in `/Applications/Adobe InDesign*`
- Removes all found Tightener and TightenerServer plugins
- Cleans up empty Rorohiko folders
- Requires sudo permissions

---

### `idSetEnv` - Set InDesign Environment Variables

**Purpose**: Configure environment variables for InDesign integration.

**Platforms**: Mac (bash script)

**Usage**:
```bash
. "${TIGHTENER_SCRIPTS}/idSetEnv"
```
(Note: Must be sourced, not executed)

**Description**:
- Reads configuration from `config.ini`
- Sets environment variables including:
  - `INDESIGN_TIGHTENER_VERSION`
  - `INDESIGN_TIGHTENER_SDK_VERSION`
  - `INDESIGN_TIGHTENER_IS_SERVER`
  - `INDESIGN_APP_ROOT`
  - `INDESIGN_RELEASE_PLUGIN_FOLDER`
  - `INDESIGN_TIGHTENER_CS_VERSION`
  - And many more...
- Used by other InDesign-related scripts

---

## Environment Management Tools

### `setupEnvironment` - Initialize Tightener Environment

**Purpose**: Set up the Tightener environment by updating shell profile files.

**Platforms**: Mac, Linux (bash script)

**Usage**:
```bash
./setupEnvironment
```

**Description**:
- Sets `TIGHTENER_SCRIPTS` and `TIGHTENER_RELEASE_ROOT` environment variables
- Updates `~/.zshenv` and `~/.profile` on Mac
- Updates `~/.bashrc` and `~/.profile` on Linux
- Creates default `editFile` script if missing
- Copies default `config.ini` if needed
- Platform-aware binary path setup (Mac/Linux/Linux_ARM64)

---

### `clearEnvironment` - Remove Tightener Environment

**Purpose**: Remove Tightener environment setup from shell profile files.

**Platforms**: Mac, Linux (bash script)

**Usage**:
```bash
./clearEnvironment
```

**Description**: Calls `clearEnvironmentInProfile` to remove Tightener-related entries from:
- `~/.zshenv` and `~/.profile` on Mac
- `~/.bashrc` and `~/.profile` on Linux

---

### `clearEnvironmentInProfile` - Clear Profile Helper

**Purpose**: Remove Tightener entries from a specific profile file.

**Platforms**: Mac, Linux (bash script)

**Usage**:
```bash
clearEnvironmentInProfile profileFile
```

**Description**: Internal helper script used by `clearEnvironment` to clean individual profile files.

---

### `updateEnvironmentInProfile` - Update Profile Helper

**Purpose**: Update a specific profile file with Tightener environment setup.

**Platforms**: Mac, Linux (bash script)

**Usage**:
```bash
updateEnvironmentInProfile profileFile releaseRoot
```

**Description**: Internal helper script used by `setupEnvironment` to update individual profile files.

---

### `setPath` - Set PATH Environment

**Purpose**: Configure PATH for Tightener binaries.

**Platforms**: Mac, Linux (bash script wrapper)

**Usage**:
```bash
. ./setPath
```
(Note: Must be sourced)

**Description**: Platform-aware wrapper that sources `setPathMac` or `setPathLinux`.

---

### `setPathMac` - Set Mac PATH

**Purpose**: Configure Mac-specific PATH and environment variables.

**Platforms**: Mac (bash script)

**Description**: Sets up Mac-specific environment including `TIGHTENER_BINARIES`, `TIGHTENER_SYSCONFIG_ROOT`, `TIGHTENER_LOCAL_DATA_ROOT`, and PATH.

---

### `setPathLinux` - Set Linux PATH

**Purpose**: Configure Linux-specific PATH and environment variables.

**Platforms**: Linux (bash script)

**Description**: Sets up Linux-specific environment with architecture detection (ARM64 vs x86_64) and appropriate binary paths.

---

## Configuration Tools

### `editConfig` - Edit Configuration File

**Purpose**: Open the Tightener configuration file in the user's preferred editor.

**Platforms**: Mac, Linux (bash script wrapper)

**Usage**:
```bash
editConfig
```

**Description**: Platform-aware wrapper that calls `editConfigMac` or `editConfigLinux` to edit `${TIGHTENER_SYSCONFIG_ROOT}config.ini`.

---

### `editConfigMac` - Edit Config (Mac)

**Purpose**: Open configuration file using Mac editor.

**Platforms**: Mac (bash script)

**Description**: Internal script called by `editConfig` on macOS.

---

### `editConfigLinux` - Edit Config (Linux)

**Purpose**: Open configuration file using Linux editor.

**Platforms**: Linux (bash script)

**Description**: Internal script called by `editConfig` on Linux.

---

### `copyConfig` - Copy Default Configuration

**Purpose**: Copy the default configuration template to the active configuration location.

**Platforms**: Mac, Linux (bash script wrapper)

**Usage**:
```bash
copyConfig
```

**Description**: Platform-aware wrapper that calls `copyConfigMac` or `copyConfigLinux` to copy `Release/Config/config.ini` template.

---

### `copyConfigMac` - Copy Config (Mac)

**Purpose**: Copy default configuration template on Mac.

**Platforms**: Mac (bash script)

**Description**: Internal script called by `copyConfig` on macOS.

---

### `copyConfigLinux` - Copy Config (Linux)

**Purpose**: Copy default configuration template on Linux.

**Platforms**: Linux (bash script)

**Description**: Internal script called by `copyConfig` on Linux.

---

### `editFile` - Edit File with Preferred Editor

**Purpose**: Open a file in the user's configured text editor.

**Platforms**: Mac, Linux (bash script wrapper)

**Usage**:
```bash
editFile filePath
```

**Description**: Platform-aware wrapper that calls `editFileMac` or `editFileLinux` based on the current OS.

---

### `editFileMac` - Edit File (Mac)

**Purpose**: Open file using Mac-configured editor.

**Platforms**: Mac (bash script)

**Description**: Internal script that uses the editor defined in `${TIGHTENER_SYSCONFIG_ROOT}editFile`.

---

### `editFileMacDefault` - Default Mac Editor Template

**Purpose**: Default template for Mac file editing configuration.

**Platforms**: Mac (bash script)

**Description**: Template copied to `${TIGHTENER_SYSCONFIG_ROOT}editFile` if no custom editor is configured.

---

### `editFileLinux` - Edit File (Linux)

**Purpose**: Open file using Linux-configured editor.

**Platforms**: Linux (bash script)

**Description**: Internal script that uses the editor defined in `${TIGHTENER_SYSCONFIG_ROOT}editFile`.

---

### `editFileLinuxDefault` - Default Linux Editor Template

**Purpose**: Default template for Linux file editing configuration.

**Platforms**: Linux (bash script)

**Description**: Template copied to `${TIGHTENER_SYSCONFIG_ROOT}editFile` if no custom editor is configured.

---

## Navigation Shortcuts (Windows)

### `cd_id` - Navigate to InDesign Folder

**Purpose**: Change directory to the InDesign application folder.

**Platforms**: Windows (batch script)

**Usage**:
```bat
cd_id
```

**Description**: Uses `idSetEnv.bat` configuration to navigate to `%INDESIGN_APP_ROOT%`.

---

### `cd_samples` - Navigate to Sample Scripts

**Purpose**: Change directory to the SampleScripts folder.

**Platforms**: Windows (batch script)

**Usage**:
```bat
cd_samples
```

**Description**: Navigates to `%TIGHTENER_RELEASE_ROOT%\SampleScripts`.

---

### `cd_scripts` - Navigate to Scripts Folder

**Purpose**: Change directory to the command line scripts folder.

**Platforms**: Windows (batch script)

**Usage**:
```bat
cd_scripts
```

**Description**: Navigates to the CommandLine/Scripts directory.

---

### `cd_settings` - Navigate to Settings Folder

**Purpose**: Change directory to the Tightener settings/config folder.

**Platforms**: Windows (batch script)

**Usage**:
```bat
cd_settings
```

**Description**: Navigates to the Tightener configuration directory.

---

### `cd_tightener` - Navigate to Tightener Root

**Purpose**: Change directory to the Tightener release root.

**Platforms**: Windows (batch script)

**Usage**:
```bat
cd_tightener
```

**Description**: Navigates to `%TIGHTENER_RELEASE_ROOT%`.

---

### `view_id` - View InDesign Folder

**Purpose**: Open Windows Explorer at the InDesign application folder.

**Platforms**: Windows (batch script)

**Usage**:
```bat
view_id
```

**Description**: Opens `%INDESIGN_APP_ROOT%` in Windows Explorer.

---

### `view_samples` - View Sample Scripts

**Purpose**: Open Windows Explorer at the SampleScripts folder.

**Platforms**: Windows (batch script)

**Usage**:
```bat
view_samples
```

**Description**: Opens the SampleScripts directory in Windows Explorer.

---

### `view_scripts` - View Scripts Folder

**Purpose**: Open Windows Explorer at the command line scripts folder.

**Platforms**: Windows (batch script)

**Usage**:
```bat
view_scripts
```

**Description**: Opens the CommandLine/Scripts directory in Windows Explorer.

---

### `view_settings` - View Settings Folder

**Purpose**: Open Windows Explorer at the settings/config folder.

**Platforms**: Windows (batch script)

**Usage**:
```bat
view_settings
```

**Description**: Opens the Tightener configuration directory in Windows Explorer.

---

### `view_tightener` - View Tightener Root

**Purpose**: Open Windows Explorer at the Tightener release root.

**Platforms**: Windows (batch script)

**Usage**:
```bat
view_tightener
```

**Description**: Opens `%TIGHTENER_RELEASE_ROOT%` in Windows Explorer.

---

## Utility Tools

### `fetchTPKGHeader` - Fetch TPKG File Header

**Purpose**: Fetch and display the header information from a TPKG file.

**Platforms**: Mac, Linux (bash script)

**Usage**:
```bash
fetchTPKGHeader url
```

**Parameters**:
- `url`: URL of the TPKG file (required)

**Description**: Uses `curl` to fetch the first 1024 bytes of a TPKG file, converts line endings, and displays the header information.

---

### `killApps` - Kill Tightener Processes

**Purpose**: Terminate all running Tightener-related processes and clean up session data.

**Platforms**: Mac, Linux (bash script)

**Usage**:
```bash
killApps
```

**Description**:
- Kills: `Tightener`, `XojoTightener`, `TightenerGW`, `TightenerGW_Cpp`
- Removes named pipes from `~/Library/Application Support/net.tightener/NamedPipes/` (Mac)
- Removes session data from `~/Library/Application Support/net.tightener/SessionData/` (Mac)
- Uses `~/.net.tightener/` on Linux

---

### `pluginInstaller` - Launch Plugin Installer

**Purpose**: Launch the Tightener Plugin Installer TQL script.

**Platforms**: Mac, Linux (bash script)

**Usage**:
```bash
pluginInstaller
```

**Description**: Sources `idSetEnv`, navigates to release root, and executes `CommandLine/Scripts/pluginInstaller.tql` using `rt`.

---

### `whatIsRunning` - Show Running Tightener Processes

**Purpose**: Display all running Tightener processes and active named pipes.

**Platforms**: Mac, Linux (bash script wrapper)

**Usage**:
```bash
whatIsRunning
```

**Description**: Platform-aware wrapper that calls `whatIsRunning.command` on Mac or `whatIsRunningLinux` on Linux.

---

### `whatIsRunning.command` - Show Running Processes (Mac)

**Purpose**: Display running Tightener processes and named pipes on Mac.

**Platforms**: Mac (bash script)

**Usage**:
```bash
./whatIsRunning.command
```

**Description**:
- Cleans up stale named pipes
- Shows core Tightener processes from `ps` output
- Lists active named pipes in `${TIGHTENER_LOCAL_DATA_ROOT}NamedPipes/`

---

### `whatIsRunningLinux` - Show Running Processes (Linux)

**Purpose**: Display running Tightener processes and named pipes on Linux.

**Platforms**: Linux (bash script)

**Description**: Linux-specific implementation of `whatIsRunning`.

---

## Platform-Specific Wrappers

The following are platform detection wrappers that call OS-specific implementations:

### `gwuiMac` - Gateway UI (Mac)
Internal script for launching GUI gateway on macOS.

### `gwuiLinux` - Gateway UI (Linux)
Internal script for launching GUI gateway on Linux.

### `gwConsoleXojoMac` - Xojo Console Gateway (Mac)
Internal script for launching Xojo console gateway on macOS.

### `gwConsoleXojoLinux` - Xojo Console Gateway (Linux)
Internal script for launching Xojo console gateway on Linux.

---

## Windows Batch Script Equivalents

All Unix shell scripts have Windows batch script equivalents with `.bat` extension:

- `rt.bat`
- `rrt.bat`
- `rre.bat`
- `rru.bat`
- `evalTQL.bat`
- `rrt_REPL.bat`
- `rre_REPL.bat`
- `rru_REPL.bat`
- `rrt_Jupyter.bat`
- `rre_Jupyter.bat`
- `rru_Jupyter.bat`
- `gw.bat`
- `gwui.bat`
- `pluginInstaller.bat`
- `whatIsRunning.bat`
- `killApps.bat`
- `startConsole.bat`
- `startServer.bat`
- `setupEnvironment.bat`
- `clearEnvironment.bat`
- `editConfig.bat`
- `copyConfig.bat`
- `editFile.bat`
- `editFileDefault.bat`
- `idLaunch.bat`
- `idPoke.bat`
- `idPluginInstall.bat`
- `idPluginRemove.bat`
- `idPluginRemoveAll.bat`
- `idSetEnv.bat`

---

## Environment Variables

Key environment variables used by these scripts:

- `TIGHTENER_SCRIPTS`: Path to the CommandLine/Scripts directory
- `TIGHTENER_RELEASE_ROOT`: Path to the Tightener release root
- `TIGHTENER_BINARIES`: Path to platform-specific binaries
- `TIGHTENER_SYSCONFIG_ROOT`: Path to system configuration directory
- `TIGHTENER_LOCAL_DATA_ROOT`: Path to local data directory
- `TIGHTENER_DEFAULT_RR_TIMEOUT_MS`: Default remote execution timeout
- `TIGHTENER_DEFAULT_RR_QUIT_DELAY_MS`: Default quit delay for remote execution
- `TIGHTENER_DEFAULT_REPL_TIMEOUT_MS`: Default REPL timeout
- `TIGHTENER_DEFAULT_REPL_QUIT_DELAY_MS`: Default REPL quit delay
- `INDESIGN_TIGHTENER_VERSION`: InDesign version (e.g., "2025")
- `INDESIGN_TIGHTENER_SDK_VERSION`: InDesign SDK version (e.g., "20.0")
- `INDESIGN_TIGHTENER_IS_SERVER`: "1" for InDesign Server, "0" for client
- `INDESIGN_APP_ROOT`: Path to InDesign application root
- `INDESIGN_APP_PLUGIN_FOLDER`: Path to plugin folder
- `INDESIGN_APP_ROROHIKO_PLUGIN_FOLDER`: Path to Rorohiko plugin folder
- `INDESIGN_TIGHTENER_CS_VERSION`: Version of InDesign in CS format (e.g. 2026 = 21.0 = CS19)

---

## TQL Script Helpers

### `pluginInstaller.tql`
TQL script that provides the backend logic for the `pluginInstaller` command.

### `rre.tql`
TQL script that provides the backend logic for remote ExtendScript execution.

### `rru.tql`
TQL script that provides the backend logic for remote UXP Script execution.

### `rrt_REPL.tql`
TQL script that implements the remote TQL REPL backend.

### `rre_REPL.tql`
TQL script that implements the remote ExtendScript REPL backend.

### `rru_REPL.tql`
TQL script that implements the remote UXP Script REPL backend.

### `idSetEnvWindows.tql`
TQL script for Windows-specific InDesign environment setup.

---

## Installation Scripts

### `install.command` (Mac/Linux)
**Location**: `TightenerDocs/CurrentRelease/`

**Purpose**: Install Tightener by running `setupEnvironment`.

**Usage**:
```bash
./install.command
```

---

### `install.bat` (Windows)
**Location**: `TightenerDocs/CurrentRelease/`

**Purpose**: Install Tightener on Windows by calling `setupEnvironment.bat`.

**Usage**:
```bat
install.bat
```

---

### `uninstall.command` (Mac/Linux)
**Location**: `TightenerDocs/CurrentRelease/`

**Purpose**: Uninstall Tightener by running `clearEnvironment`.

**Usage**:
```bash
./uninstall.command
```

---

### `uninstall.bat` (Windows)
**Location**: `TightenerDocs/CurrentRelease/`

**Purpose**: Uninstall Tightener on Windows by calling `clearEnvironment.bat`.

**Usage**:
```bat
uninstall.bat
```

---

## Quick Start Guide

### Initial Setup

1. **Install Tightener**:
   ```bash
   # Mac/Linux
   cd TightenerDocs/CurrentRelease
   ./install.command

   # Windows
   install.bat
   ```

2. **Configure your editor** (optional):
   ```bash
   # Edit the editFile script to use your preferred editor
   vi "${TIGHTENER_SYSCONFIG_ROOT}editFile"
   ```

3. **Edit configuration**:
   ```bash
   editConfig
   ```

### Common Workflows

#### Run a local TQL script:
```bash
rt myScript.tql
```

#### Run a TQL script on remote InDesign:
```bash
rrt indesign myScript.tql 5000
```

#### Run ExtendScript on InDesign:
```bash
rre indesign myScript.jsx
```

#### Start interactive ExtendScript REPL:
```bash
rre_REPL indesign
```

#### Install Tightener plugin in InDesign:
```bash
idPluginInstall
idLaunch
```

#### Check what's running:
```bash
whatIsRunning
```

#### Kill all Tightener processes:
```bash
killApps
```

---

## Troubleshooting

### Script not found
Ensure environment is set up correctly:
```bash
echo $TIGHTENER_SCRIPTS
echo $TIGHTENER_RELEASE_ROOT
```

### Permission denied
Some scripts require execution permission:
```bash
chmod +x scriptName
```

### InDesign plugin not working
1. Check plugin installation: `idPluginRemove` then `idPluginInstall`
2. Verify InDesign version in config: `editConfig`
3. Check running processes: `whatIsRunning`

### Remote execution fails
1. Verify target is running: `whatIsRunning`
2. Increase timeout: Add higher millisecond value as parameter
3. Check network connectivity for remote hosts

---

## Notes on Potentially Outdated Scripts

Based on my analysis, the following observations should be noted:

### Xojo-based Tools
The `gwConsoleXojo` script and related platform-specific variants reference XojoTightener. These may be legacy tools if the current gateway is primarily `TightenerGW_Cpp`. These should be verified:
- `gwConsoleXojo`
- `gwConsoleXojoMac`
- `gwConsoleXojoLinux`

**Status**: Verify if XojoTightener is still actively maintained or if these scripts should be deprecated.

### Platform-Specific Template Files
The following "Default" template files are internal helpers and not typically invoked directly:
- `editFileMacDefault`
- `editFileLinuxDefault`
- `editFileDefault.bat`

**Status**: These are working as designed (templates, not standalone tools).

---

## See Also

- [Tightener Overview](Tightener_Overview.md)
- [Tightener Coding Conventions](Tightener_CodingConventions.md)
- [TightenerDocs README](CurrentRelease/README.md)
- [Script Development Workflow](../Tightener/Docs/SCRIPT_DEV_WORKFLOW.md)

---

**Document Version**: 1.0
**Last Updated**: January 31, 2026
**Maintainer**: Tightener Documentation Team
