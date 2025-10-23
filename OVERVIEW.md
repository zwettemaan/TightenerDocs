# Repositories Overview

TightenerComponents is a comprehensive ecosystem of 25+ software projects primarily for Adobe Creative Suite applications. The main component is **Tightener**, a distributed computing framework with a custom scripting language (TQL), orchestrated via multi-VM automated builds.

## Automated Build System (Cross-Platform Orchestration)

### Overview
The build system is orchestrated from **Mac** and coordinates builds across **three platforms** using SSH:
- **Mac**: Build coordinator + Mac native builds
- **Linux VM**: Linux library and application builds
- **Windows VM**: Windows library and application builds

### Entry Points
```bash
# Main automated build (Mac orchestrator)
cd "${TIGHTENER_GIT_ROOT}BuildScripts"
./build [release]          # Main entry point - calls buildMac on Mac

# Platform-specific builds (called by ./build -> buildMac)
# buildMac [release]       # Mac build process (calls others via SSH)
# buildLinux [release]     # Linux build process (called via SSH from Mac)
# build.bat [release]      # Windows build process (called via SSH from Mac)
```

### Build Process Flow (./build -> buildMac)
1. **Version Injection**: Update build number (e.g., to 700), commit to Git
2. **Git Synchronization**: Sync multiple repos (Tightener, TightenerDocs, XojoTightener, PluginInstaller)
3. **Linux Build**: SSH to Linux VM, execute platform-specific builds:
   - `buildCmdLineAppLinux`, `buildXojoDLLLinux`, `buildDLLLinux`, `buildGWAppLinux`
   - Support for x86_64, aarch64, i386 architectures
4. **Windows Build**: SSH to Windows VM, execute `build.bat`
5. **Binary Collection**: SCP transfer of .tgz archives (20-30MB) at 75-128 MB/s:
   - `CurrentRelease.tgz`, `XojoRelease.tgz` from Linux/Windows to Mac
6. **Mac Native Builds**: Universal binaries (x86_64 + arm64):
   - `buildCmdLineAppMac`, `buildXojoDLLMac`, `buildDLLMac`
   - `buildInDesignPluginsMac`, `buildGWAppMac`, `buildXojoApps`
7. **Code Signing/Notarization**: Apple Developer certificate-based signing
   - Certificate: B63A2172BE944320D515E221763F5BC660717257
8. **Release Integration**: Create final deliverable (e.g., `Tightener.0.2.5.700.zip` - 895MB)
9. **Distribution**: Multi-platform git push and server deployment

### VM Configuration
Configure in `TightenerSecrets_glueco.de/secrets/setEnvLocal` (after mounting secrets):
```bash
# Xojo IDE path (update when Xojo is upgraded)
export XOJO_ROOT="/Applications/Xojo 2025 Release 2.1/"

# Linux VM connection (typically tightenerlinux on Parallels)
export UBUNTU_PORT=22
export UBUNTU_DESKTOP=<hostname>
export UBUNTU_USER_PREFIX=<user@>

# Windows VM connection (typically tightenerwindows on Parallels)
export WINDOWS_PORT=22
export WINDOWS_DESKTOP=<hostname>
export WINDOWS_USER_PREFIX=<user@>

# Code signing certificates
export ROROHIKO_DEV_ID_APPLE="Developer ID Application: ..."
export ROROHIKO_NOTARY_PASSWORD="..."
```

### Secrets Management
Mount the secrets volume before building:
```bash
cd TightenerSecrets_glueco.de
./secrets_manager.sh mount  # Password in 1Password if needed
```
Build scripts will auto-mount this and rely on the password being in the keychain.

## All Subprojects by Build System

### AUTOMATED BUILD PROJECTS (Part of main build)

#### Core C++ Projects (CMake)
- **Tightener**: Main distributed computing framework, C++11, multi-platform
- **TightenerDLL**: ExtendScript integration library
- **TightenerGW**: Gateway application for Tightener network
- **InDesignTightener**: Native InDesign plugin with Adobe SDK integration

#### External Dependencies
- **TightenerExternalLibs**: OpenSSL, cURL, zlib, Boost, JDK compilation
  - Requires: `buildLibs.command/.bat/.linux.sh` before main build
  - Universal binaries, cross-compilation support

#### Cross-Platform Applications (Xojo)
- **PluginInstaller**: Cross-platform installer/package manager
- **XojoTightener**: Xojo bindings, UI, and command-line apps
  - Multiple retry logic for Xojo IDE automation reliability
  - Requires MBS plugins and XojoTightener.xojo_plugin installed in Xojo
  - Update RBProjectVersion in .xojo_project files when Xojo is upgraded

#### JavaScript/Web Projects (Node.js)
- **CRDT_ES**: ExtendScript development tools, JSDoc-based
- **CRDT_UXP**: UXP development tools with jsdoc-to-markdown
- **JSXGetURL**: URL fetching utility for ExtendScript
- **TightenerMainSite**: Express.js website backend
- **TightenerRegistry**: Docker + MySQL backend registry service

#### Infrastructure
- **TightenerSecrets_glueco.de**: Secure mount for certificates/credentials
  - Use `secrets_manager.sh mount/unmount` to manage secrets volume
  - Auto-mounted by build scripts, password stored in keychain
- **TightenerDocs**: Release management and documentation

### MANUAL BUILD PROJECTS (Individual builds)

#### Native Plugins (C++ + Scripts)
- **ActivePageItems**: InDesign Plug-in. ExtendScript enhancements. Adds various scriptable features to InDesign DOM.
  - Build: `buildAPIDMac.command`, `buildAPIDWin.bat`
  - Version: `ActivePageItemVersionInfo.h`, `ReadMe.txt`

- **Color2Gray**: InDesign Plug-in. Color conversion tool. Allows rendering images as B&W while leaving original image untouched.
  - Build: `buildColor2GrayMac.command`, `buildColor2GrayWin.bat`, `CreateZip.ps1`
  - Version: `C2GVersionInfo.h`

- **Sudoku**: InDesign Plug-in. Puzzle generator.
  - Build: `buildSudokuMac.command`, `buildSudokuWin.bat`, `CreateZip.ps1`
  - Version: `SudokuVersionInfo.h`

#### ExtendScript Packages (PluginInstaller .tpkg format)
- **SizeLabels**: Size labeling script, `manifest.json` versioning
- **SmokeWordStacks**: Text effects script
- **StringsAttached**: Musical chord diagram generator
- **Swimmer**: Layout automation script
- **TableAxe**: Table manipulation tools (manual reference in README)

Upload via: `copyToolToRorohikoDownloads <project> tpkg manifest.json`

#### Modern Adobe Extensions
- **TextExporter5**: CEP (Common Extensibility Platform) extension
  - Build: Node.js + CEP tools, `package.json` + `CRDT_manifest.json`
  - Platform: Legacy ExtendScript/CEP
  - Current release version

- **TextExporter6**: UXP (Unified Extensibility Platform) version
  - Build: Node.js/UXP, `package.json` + `manifest.json`
  - Platform: Modern Adobe UXP
  - Unfinished

#### Web Applications (Node.js/Express)
- **Store**: E-commerce web application
  - Build: `npm install`, `npm start`
  - Dependencies: Express, Pug, standard web stack

#### Development Tools
- **easyScript**: CEP development framework with GUI configuration
  - Build: Platform-specific scripts + Xojo configuration apps
  - Features: Template generation, CEP packaging, code signing

- **ucf**: Universal Cross-platform Framework
  - Build: Python + shell scripts, `makerelease.command`
  - Purpose: JRE packaging and JAR conversion via `fetchJRE.py`
  - Created by Macromedia, maintained for our own use

## Build Commands by Project Type

### External Libraries (Required First)
```bash
cd TightenerExternalLibs
./resetLibs.command/.bat/.linux.sh     # Clean
./buildLibs.command/.bat/.linux.sh     # Build all platforms
```

### Automated Build (Mac Orchestrator)
```bash
cd Tightener/BuildScripts
./build release              # Full multi-platform build
```

### Manual C++ Projects
```bash
# ActivePageItems
./ActivePageItems/buildAPIDMac.command
./ActivePageItems/buildAPIDWin.bat

# Color2Gray
./Color2Gray/buildColor2GrayMac.command
./Color2Gray/buildColor2GrayWin.bat

# Sudoku
./Sudoku/buildSudokuMac.command
./Sudoku/buildSudokuWin.bat
```

### ExtendScript .tpkg Projects
```bash
# Update version in manifest.json, then:
copyToolToRorohikoDownloads SizeLabels tpkg manifest.json
copyToolToRorohikoDownloads SmokeWordStacks tpkg manifest.json
copyToolToRorohikoDownloads StringsAttached tpkg manifest.json
copyToolToRorohikoDownloads Swimmer tpkg manifest.json
```

### Node.js Projects
```bash
# CRDT_UXP
cd CRDT_UXP && npm install
./makerelease.command

# TextExporter5 (CEP)
cd TextExporter5 && npm install

# TextExporter6 (UXP)
cd TextExporter6 && npm install

# Store
cd Store && npm install && npm start
```

### Specialized Tools
```bash
# ucf (JRE packaging)
cd ucf && ./makerelease.command

# easyScript (CEP framework)
cd easyScript
# Platform-specific build scripts in Mac/ Windows/ directories
```

## Deliverables and Distribution

### Main Releases
- **Tightener Release**: `Tightener.${VERSION}.zip` - Complete Tightener distribution
- **PluginInstaller**: Cross-platform app for managing .tpkg packages
- **Release Distribution**: Automated upload to ownCloud, servers

### Distribution Channels
```bash
# Automated (after build)
copyPluginInstallerToServers      # Updates Store + CRDT WordPress
pushRelease                       # Distributes to all build machines
copyToolsToCRDTWordPress          # CRDT_ES/UXP to WordPress

# Manual uploads
copyToolToRorohikoDownloads <tool> <format> <manifest>
# Uploads to rorohiko.com/downloads/ with versioned symlinks
```

### Package Formats
- **Native Apps**: .app (Mac), .exe (Windows), ELF (Linux)
- **InDesign Plugins**: .InDesignPlugin
- **ExtendScript Packages**: .tpkg (encrypted, signed via PluginInstaller)
- **Web Extensions**: .zip (CEP), .zip (UXP)
- **Archives**: .zip, .tgz for distribution

## Development Environment Setup

### Prerequisites by Platform

#### Mac (Build Orchestrator)
- Xcode + Command Line Tools
- Xojo IDE (currently 2025 Release 2.1) + IDECommunicator v2 (in ~/bin)
- Required Xojo plugins:
  - MBS Xojo Compression Plugin.xojo_plugin
  - MBS Xojo CURL Plugin.xojo_plugin
  - MBS Xojo Encryption Plugin.xojo_plugin
  - MBS Xojo MacCF Plugin.xojo_plugin
  - MBS Xojo MacOSX Plugin.xojo_plugin
  - MBS Xojo Main Plugin.xojo_plugin
  - MBS Xojo Tools Plugin.xojo_plugin
  - MBS Xojo Util Plugin.xojo_plugin
  - MBS Xojo Win Plugin.xojo_plugin
  - XojoTightener.xojo_plugin
- InDesign SDKs in `~/Documents/SDKs/Adobe/InDesign`
- SSH keys for VM access to Linux/Windows VMs
- Code signing certificates (Developer ID)
- Node.js, Python, Git

#### Linux VM
- GCC, CMake, SSH server
- Cross-compilation tools (x86_64, arm64, i686)
- Git Credential Manager with plaintext store
- SmartGit, CLion IDE

#### Windows VM
- Visual Studio 2017/2019/2022
- Python 3.x
- InDesign SDKs in `C:\SDKs\Adobe\InDesign`
- OpenSSH server enabled
- Git with dpapi credential store
- VC Runtime redistributables

### Architecture Support
- **Mac**: Universal binaries (x86_64 + arm64), macOS 10.13/10.14+ target, Xcode 16.4+
- **Windows**: x86_64 (via Visual Studio)
- **Linux**: x86_64, aarch64, i386 (CMake cross-compilation)

## Version Management

### Centralized Versions (Automated)
- `Tightener/BuildScripts/version.txt`: 0.2.5 (current)
- Build numbers auto-increment (e.g., build 700 for v0.2.5.700)
- `JSXGetURL/Version.txt`
- `CRDT_ES/Version.txt`
- `CRDT_UXP/Version.txt`

### Manual Versions (Update before building)
- `manifest.json`: ExtendScript packages
- Header files: `*VersionInfo.h` for C++ projects
- `package.json`: Node.js projects

## Testing and Verification

### Post-Build Testing
```bash
# Basic functionality
rt hello.tql                        # Local TQL test
rrt tgh://remote/... hello.tql     # Remote TQL test
killApps                            # Reset Tightener processes

# Release verification
verifyXojoApps                      # Verify Xojo builds
verifyPluginInstaller               # Verify installer integrity
```

### Build Dependencies
1. **TightenerExternalLibs** must be built on all platforms first (`resetLibs` + `buildLibs`)
2. **TightenerSecrets** volume (`TightenerSecrets_glueco.de/secrets/`) must be mounted for code signing
3. **All parallel repos** must exist and be synced across all build machines
4. **VM connectivity** via SSH must be working (Linux/Windows VMs running on Parallels)
5. **Code signing certificates** must be valid and accessible
6. **Xojo IDE setup** with correct version path and all required plugins installed
7. **Xojo project versions** updated (`RBProjectVersion=2025.021` or current version)
8. **MBS secret file** updated when MBS plugins are upgraded

## Build Process Workflow

### Pre-Build Checklist
1. Start Linux and Windows VMs (typically `tightenerlinux`, `tightenerwindows` on Parallels)
2. Mount secrets: `cd TightenerSecrets_glueco.de && ./secrets_manager.sh mount`
3. Verify Xojo IDE path and plugins are current
4. Update Xojo project versions if Xojo was upgraded
5. Ensure all parallel repos exist and TightenerExternalLibs are built

### Execute Build
```bash
cd "${TIGHTENER_GIT_ROOT}BuildScripts"
build [release]  # Triggers full multi-platform build sequence
```

The build process follows: **sync git → build Linux → build Windows → build Mac → package → code sign → distribute**

### Build Output & Performance
- **Main deliverable**: `Tightener.${VERSION}.${BUILD}.zip` (e.g., 895MB for v0.2.5.700)
- **Additional packages**: CreativeDeveloperTools_UXP, CreativeDeveloperTools_ES, JSXGetURL
- **Transfer performance**: 75-128 MB/s for 20-30MB .tgz archives between VMs
- **Build success indicators**: Multiple "BUILD SUCCEEDED" confirmations, successful code signing
- **Error handling**: Build continues despite individual component failures (e.g., InDesign plugins)

## Important Notes
- **Proprietary codebase** for Rorohiko Ltd
- **Multi-VM orchestration**: Mac orchestrator manages Linux/Windows VMs via SSH
- **High-performance builds**: 75-128 MB/s inter-VM transfers, 895MB final deliverables
- **Robust error handling**: Build continues despite individual component failures
- **Professional code signing**: Full Apple notarization with Developer ID certificates
- **Multi-architecture support**: 6+ platform/architecture combinations
- **Automated git coordination**: Synchronizes multiple repos across all build machines
- **Cross-platform complexity** with 3 build environments coordinated via SSH
- **Complete technical documentation** in `Tightener/README.md`