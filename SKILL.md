# Tightener Ecosystem Agent Skills

This document serves as the entry point for AI agents working with the Tightener ecosystem. It organizes all relevant knowledge and documentation into categorized skill areas.

## Core Skills

### 1. Ecosystem Overview & Architecture
**Purpose**: Understand the overall structure, philosophy, and interconnections of the Tightener ecosystem.

- [Tightener_Overview.md](Tightener_Overview.md) - High-level ecosystem map and introduction
- Key Concepts: TQL, TPKG format, distributed computing, build orchestration

### 2. Coding Standards & Conventions
**Purpose**: Follow established coding patterns and style guidelines across all Tightener components.

- [Tightener_CodingConventions.md](Tightener_CodingConventions.md) - Complete coding standards
- Key Topics:
  - Formatting (indentation, braces, line endings)
  - Naming conventions (classes, functions, variables)
  - Control flow macros (BEGIN_FUNCTION, SANITY_CHECK, etc.)
  - Error handling patterns
  - Platform-specific considerations
- **Implementation Notes**:
  - C++ plugins use Tightener control flow macros extensively (BEGIN_FUNCTION, END_FUNCTION, SANITY_CHECK)
  - ActivePageItems represents newer compact style; older projects being migrated
  - "If-Break" pattern preferred over deep nesting
  - JavaScript/ExtendScript uses K&R brace style (opening brace same line)
  - C/C++ uses Allman style (braces on own lines)

### 3. Licensing & Distribution
**Purpose**: Understand the Capability-based licensing system and secure distribution mechanisms.

- [Tightener_LicenseTracking.md](Tightener_LicenseTracking.md) - License system architecture
- Key Topics:
  - Registry (`tgrg.net`) concepts
  - Capability Wrapper Files
  - TPKG package format
  - Machine registration and linking
  - Privacy-centric design principles
- **Discount Code Management** (IMPORTANT - FREQUENTLY NEEDED):
  - **Location**: Database on `moth` server
  - **Access**: `ssh moth` → `sudo -s` → `db_crdt` → `mariadb -u root -p[passwordFromMothScripts]` → `use crdt;`
  - **Create Code**: `insert into discountCodes (discountCode, issuerGUID, productCode, useSandbox, discountPercent, isPerCustomer, maxUseCount) values ('CODE_NAME', '1186cb863f80e0c2d5ee377c49d7eade', 'ProductCode', 0, 100, 1, 100);`
  - **Parameters**:
    - `discountCode`: The code users enter (e.g., 'APID_KRIS_TEST_123')
    - `issuerGUID`: Rorohiko GUID = '1186cb863f80e0c2d5ee377c49d7eade'
    - `productCode`: Product identifier (e.g., 'APIDToolAssistant', 'TextExporter')
    - `useSandbox`: 0 for production, 1 for testing
    - `discountPercent`: Percentage off (0-100)
    - `isPerCustomer`: 1 = one use per customer, 0 = multiple uses
    - `maxUseCount`: Total number of times code can be used
  - **Common Examples**:
    ```sql
    -- 100% off, one per customer, max 100 uses
    insert into discountCodes (discountCode, issuerGUID, productCode, useSandbox, discountPercent, isPerCustomer, maxUseCount) 
    values ('PROMO_CODE', '1186cb863f80e0c2d5ee377c49d7eade', 'APIDToolAssistant', 0, 100, 1, 100);
    
    -- 50% off, unlimited uses per customer, max 500 total
    insert into discountCodes (discountCode, issuerGUID, productCode, useSandbox, discountPercent, isPerCustomer, maxUseCount) 
    values ('SALE50', '1186cb863f80e0c2d5ee377c49d7eade', 'TextExporter', 0, 50, 0, 500);
    ```

## Infrastructure Skills

### 4. Core Framework Components
**Purpose**: Work with the foundational C++ infrastructure.

- [../Tightener/Tightener_Overview_Tightener.md](../Tightener/Tightener_Overview_Tightener.md) - Main distributed computing framework
- [../TightenerDLL/Tightener_Overview_TightenerDLL.md](../TightenerDLL/Tightener_Overview_TightenerDLL.md) - ExtendScript integration library
- [../TightenerGW/Tightener_Overview_TightenerGW.md](../TightenerGW/Tightener_Overview_TightenerGW.md) - Gateway application
- [../TightenerRegistry/Tightener_Overview_TightenerRegistry.md](../TightenerRegistry/Tightener_Overview_TightenerRegistry.md) - Registry service
- [../InDesignTightener/Tightener_Overview_InDesignTightener.md](../InDesignTightener/Tightener_Overview_InDesignTightener.md) - InDesign integration

### 5. Build System & Packaging
**Purpose**: Understand and work with the multi-platform automated build system.

- [../ucf/Tightener_Overview_ucf.md](../ucf/Tightener_Overview_ucf.md) - Universal Container Format tools
- Key Topics:
  - Mac/Linux/Windows VM orchestration
  - Cross-platform compilation
  - Code signing and notarization
  - TPKG creation and distribution
- **Build VM Details** (IMPORTANT - Avoid common path errors):
  - **Windows VM** (`tightenerwindows`):
    - User: `kris` (NOT `Administrator`)
    - TightenerComponents path: `C:\Users\kris\Documents\Controlled\Rorohiko\TightenerComponents`
    - Use PowerShell for complex commands: `ssh tightenerwindows 'powershell "command"'`
    - Python libs location: `TightenerPython\python\VS2022\{arm64,x64,x86}\python314.lib`
  - **Verifying Windows Library Architectures**:
    - Find dumpbin: `Get-ChildItem "C:\Program Files\Microsoft Visual Studio\2022" -Recurse -Filter dumpbin.exe | Select-Object -First 1 FullName`
    - Check architecture: `dumpbin /headers file.lib | findstr machine`
    - Expected output: `AA64 machine (ARM64)` or `8664 machine (x64)`
    - Note: Hash comparison is NOT proof of different architectures (compile timestamps differ)
- **Build Orchestration Techniques**:
  - **Multi-stage build process**: Mac coordinator triggers Linux and Windows builds via SSH
  - **Version extraction**: Uses gcc preprocessor to extract version from header files (e.g., `gcc -E src/ExtractVersionData.h`)
  - **Universal binaries**: Mac builds for both x86_64 and arm64 architectures (`xcodebuild ONLY_ACTIVE_ARCH=NO -arch x86_64 -arch arm64`)
  - **Donor pattern**: Reuses previous release archives as "donor" files, updating only changed binaries
  - **Automatic notarization**: Mac builds use `xcrun notarytool` for automated code notarization
  - **Git synchronization**: `syncGit` command ensures all build machines have identical repo state before building
  - **Build environment variables**: Extensive use of environment variables for paths and configuration (see `setEnv` scripts)
  - **InDesign SDK versioning**: Builds target multiple InDesign versions (e.g., CS18_20.0, CS19_21.0) with version-specific projects
  - **Xojo integration**: Xojo apps built on Mac, with automatic retry logic for build failures
  - **Secrets management**: Codesigning credentials stored in mounted TightenerSecrets volume

## Development Tools Skills

### 6. Developer Tools & SDKs
**Purpose**: Use and extend the development tools for Tightener-based applications.

- [../CRDT_ES/Tightener_Overview_CRDT_ES.md](../CRDT_ES/Tightener_Overview_CRDT_ES.md) - Creative Developer Tools for ExtendScript
- [../CRDT_UXP/Tightener_Overview_CRDT_UXP.md](../CRDT_UXP/Tightener_Overview_CRDT_UXP.md) - Creative Developer Tools for UXP
- [../easyScript/Tightener_Overview_easyScript.md](../easyScript/Tightener_Overview_easyScript.md) - Simplified scripting environment
- [../JSXGetURL/Tightener_Overview_JSXGetURL.md](../JSXGetURL/Tightener_Overview_JSXGetURL.md) - URL fetching utility
- [../XojoTightener/Tightener_Overview_XojoTightener.md](../XojoTightener/Tightener_Overview_XojoTightener.md) - Xojo bindings
- [../ExtendPyScript/Tightener_Overview_ExtendPyScript.md](../ExtendPyScript/Tightener_Overview_ExtendPyScript.md) - Python integration
- **Documentation Generation**:
  - **JSDoc-based**: CRDT_ES and CRDT_UXP use JSDoc for API documentation
  - **Custom template**: Uses modified Minami theme for consistent documentation style
  - **npm integration**: Package.json defines build scripts and dependencies (jsdoc, minami, taffydb)

### 7. Distribution & Installation
**Purpose**: Manage package installation and user-facing tools.

- [../PluginInstaller/Tightener_Overview_PluginInstaller.md](../PluginInstaller/Tightener_Overview_PluginInstaller.md) - Cross-platform package installer
- [../Store/Tightener_Overview_Store.md](../Store/Tightener_Overview_Store.md) - Online store/catalog service
- **TPKG Packaging Workflow**:
  - **Manifest structure**: JSON-based with support for comments, defines productCode, version, targets, and filters
  - **Installation methods**: `STUB_SCRIPT_IN_INDESIGN_SCRIPTS_PANEL`, `COPY_TO_DESKTOP`, `COPY_TO_DOCUMENTS`, `PLUG_IN`
  - **Filter system**: RegExp-based filters control signing, encryption, and file omission
  - **Selective encryption**: Stub scripts signed but not encrypted (must be user-executable); internal scripts encrypted for IP protection
  - **Archive formats**: Uses .nzip (native zip) for Mac-specific attributes preservation
  - **Version injection**: Build scripts auto-generate manifest.json with version info extracted from headers
  - **Multi-target support**: Single manifest can define multiple installation targets (different InDesign versions, platforms)
- **Discount Code Management** (Also see SKILL 3 for detailed info):
  - Quick access: `ssh moth` → `sudo -s` → `db_crdt` → `mariadb -u root -p[passwordFromMothScripts]` → `use crdt;`
  - Example: `insert into discountCodes (discountCode, issuerGUID, productCode, useSandbox, discountPercent, isPerCustomer, maxUseCount) values ('CODE_NAME', '1186cb863f80e0c2d5ee377c49d7eade', 'ProductCode', 0, 100, 1, 100);`

## Application & Plugin Skills

### 8. InDesign Native Plugins (C++)
**Purpose**: Develop and maintain native InDesign plugins.

- [../ActivePageItems/Tightener_Overview_ActivePageItems.md](../ActivePageItems/Tightener_Overview_ActivePageItems.md) - DOM enhancement plugin
- [../Color2Gray/Tightener_Overview_Color2Gray.md](../Color2Gray/Tightener_Overview_Color2Gray.md) - Color conversion plugin
- [../Sudoku/Tightener_Overview_Sudoku.md](../Sudoku/Tightener_Overview_Sudoku.md) - Puzzle generation plugin
- **InDesign SDK Integration Patterns**:
  - **Multi-version builds**: Separate Xcode projects per InDesign version (e.g., CS18_20.0, CS19_21.0)
  - **Build script parameterization**: `buildForTarget` scripts accept InDesign version as parameter, compute CS version and year
  - **SDK location conventions**: SDKs stored under `~/Documents/SDKs/Adobe/InDesign/InDesignCS##_##.#/`
  - **Universal binaries**: Both x86_64 and arm64 architectures built in single pass (`ONLY_ACTIVE_ARCH=NO`)
  - **Version extraction formula**: `IDSN_CS_VERSION = IDSN_MAJOR_VERSION - 2`, `IDSN_YEAR_VERSION = IDSN_MAJOR_VERSION + 2005`
  - **Release directory structure**: Organized by InDesign major version (e.g., `IDSN.20/`, `IDSN.21/`)
  - **Archive naming**: Includes platform, year, and product version (e.g., `APIDToolAssistant_Mac_2025.3.1.2`)
  - **Plugin folder conventions**: Installed to `Plug-Ins/Rorohiko` subfolder by default
  - **Capability integration**: Modern plugins (ActivePageItems) use `LicenseData` class for licensing via TightenerRegistry

### 9. InDesign Script-Based Tools
**Purpose**: Create and maintain scripted InDesign automation tools.

- [../TextExporter5/Tightener_Overview_TextExporter5.md](../TextExporter5/Tightener_Overview_TextExporter5.md) - Text export tool (version 5)
- [../TextExporter6/Tightener_Overview_TextExporter6.md](../TextExporter6/Tightener_Overview_TextExporter6.md) - Text export tool (version 6)
- [../SizeLabels/Tightener_Overview_SizeLabels.md](../SizeLabels/Tightener_Overview_SizeLabels.md) - Dimension labeling tool
- [../SmokeWordStacks/Tightener_Overview_SmokeWordStacks.md](../SmokeWordStacks/Tightener_Overview_SmokeWordStacks.md) - Automation tool
- [../StringsAttached/Tightener_Overview_StringsAttached.md](../StringsAttached/Tightener_Overview_StringsAttached.md) - Text frame management
- [../Swimmer/Tightener_Overview_Swimmer.md](../Swimmer/Tightener_Overview_Swimmer.md) - Scripted plugin
- **ExtendScript Packaging Patterns**:
  - **Wrapper script pattern**: Main user-facing .jsx loads CRDT_ES, then invokes actual logic script via `crdtes.evalScript()`
  - **Stub vs. internal scripts**: Stub scripts (.jsx in Scripts Panel) remain unencrypted; internal logic scripts are encrypted
  - **CRDT_ES integration**: Include `CreativeDeveloperTools_ES.nzip` in package, uncompressed folder omitted from final .tpkg
  - **Multi-file manifests**: Can specify multiple stub scripts for Scripts Panel in single manifest
  - **Catalog entries (.cate)**: JSON files defining product metadata for Store integration (issuer, productCode, URLs, description)
  - **Product files (.prod)**: Server-side encrypted product definitions with licensing details
  - **Demo limitations**: Licensing system enables demo modes (e.g., "first 50 replacements" in GryperLink)

## How to Use This Document

### For AI Agents
1. **Initial Context**: Start with [Ecosystem Overview](#1-ecosystem-overview--architecture) to understand the big picture
2. **Coding Work**: Review [Coding Standards](#2-coding-standards--conventions) before writing any code
3. **Specific Tasks**: Navigate to the relevant skill category based on the task at hand
4. **Cross-References**: Many components interact - follow references between documents

### For New Developers
1. Read [Tightener_Overview.md](Tightener_Overview.md) first
2. Study [Tightener_CodingConventions.md](Tightener_CodingConventions.md) to understand code style
3. Explore component-specific overviews based on your area of work

### For Maintenance Work
- Use the skill categories to quickly locate relevant documentation
- Cross-reference with [Tightener_LicenseTracking.md](Tightener_LicenseTracking.md) for licensing-related changes
- Consult coding conventions for refactoring guidance

## Skill Dependencies

```
Ecosystem Overview (SKILL 1)
    └─→ All other skills depend on this foundation

Coding Standards (SKILL 2)
    └─→ Required for all code-writing tasks

Licensing System (SKILL 3)
    ├─→ Infrastructure Components (SKILL 4)
    ├─→ Distribution Tools (SKILL 7)
    └─→ Applications (SKILL 8, 9)

Infrastructure (SKILL 4)
    ├─→ Build System (SKILL 5)
    ├─→ Developer Tools (SKILL 6)
    └─→ Applications (SKILL 8, 9)

Build System (SKILL 5)
    └─→ All compiled components

Developer Tools (SKILL 6)
    └─→ Application Development (SKILL 8, 9)

Distribution (SKILL 7)
    └─→ All end-user components
```

## Quick Reference

| Task Type | Primary Skills | Supporting Skills |
|-----------|---------------|-------------------|
| Fix a bug in ActivePageItems | 1, 2, 8 | 4, 5 |
| Create new InDesign script | 1, 2, 6, 9 | 3, 7 |
| Modify build system | 1, 2, 5 | 4 |
| Update licensing logic | 1, 2, 3 | 4, 7 |
| Port to new platform | 1, 2, 4, 5 | All |
| Package for release | 5, 7 | 3 |
| Develop UXP extension | 1, 2, 6 | 7 |

---

**Note**: This skill structure is designed to be consumed by AI agents and human developers alike. Each referenced document contains detailed technical information specific to its domain.
