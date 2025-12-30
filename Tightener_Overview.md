# Tightener Ecosystem Overview

## Introduction
**Tightener** is a comprehensive distributed computing framework designed primarily for automating workflows involving Adobe Creative Suite applications. It features a custom scripting language called **TQL (Tightener Query Language)** and is orchestrated via a sophisticated multi-VM automated build system.

The ecosystem consists of over 25 interconnected software projects, ranging from the core C++ infrastructure to cross-platform applications, native plugins, and web services.

## Ecosystem Map

### 1. Core Infrastructure
The foundation of the ecosystem, built primarily in C++11.
- **[Tightener](file:///Users/kris/Documents/Controlled/Rorohiko/TightenerComponents/Tightener/Tightener_Overview_Tightener.md)**: The main distributed computing framework. It runs on Mac, Windows, and Linux and executes TQL scripts.
- **[TightenerDLL](file:///Users/kris/Documents/Controlled/Rorohiko/TightenerComponents/TightenerDLL/Tightener_Overview_TightenerDLL.md)**: A library for integrating Tightener with Adobe's ExtendScript environment.
- **[TightenerGW](file:///Users/kris/Documents/Controlled/Rorohiko/TightenerComponents/TightenerGW/Tightener_Overview_TightenerGW.md)**: The Gateway application that facilitates communication within the Tightener network.
- **[TightenerRegistry](file:///Users/kris/Documents/Controlled/Rorohiko/TightenerComponents/TightenerRegistry/Tightener_Overview_TightenerRegistry.md)**: A Docker-based registry service (backed by MySQL) for managing services and nodes.
- **[InDesignTightener](file:///Users/kris/Documents/Controlled/Rorohiko/TightenerComponents/InDesignTightener/Tightener_Overview_InDesignTightener.md)**: The core integration component that embeds Tightener into Adobe InDesign.

### 2. Build System & Orchestration
A key feature of Tightener is its automated build system, which coordinates builds across three platforms simultaneously.
- **Orchestrator**: Runs on **Mac**.
- **Nodes**:
    - **Mac**: Builds native Mac binaries and coordinates the process.
    - **Linux VM**: Builds Linux binaries and cross-compiles for various architectures via SSH.
    - **Windows VM**: Builds Windows binaries via SSH.
- **Process**: The system synchronizes git repositories across all machines, triggers platform-specific builds, collects artifacts (via SCP), creates universal binaries, signs/notarizes code, and packages the final release.
- **[ucf](file:///Users/kris/Documents/Controlled/Rorohiko/TightenerComponents/ucf/Tightener_Overview_ucf.md)**: Tools for handling Universal Container Format files, used in the build process.

### 3. Development Tools
Tools for developers building on top of Tightener.
- **[PluginInstaller](file:///Users/kris/Documents/Controlled/Rorohiko/TightenerComponents/PluginInstaller/Tightener_Overview_PluginInstaller.md)**: A cross-platform application (built with Xojo) for installing and managing Tightener packages (`.tpkg`).
- **[CRDT_ES](file:///Users/kris/Documents/Controlled/Rorohiko/TightenerComponents/CRDT_ES/Tightener_Overview_CRDT_ES.md)**: Creative Developer Tools for ExtendScript (JSDoc-based).
- **[CRDT_UXP](file:///Users/kris/Documents/Controlled/Rorohiko/TightenerComponents/CRDT_UXP/Tightener_Overview_CRDT_UXP.md)**: Creative Developer Tools for UXP (Unified Extensibility Platform).
- **[JSXGetURL](file:///Users/kris/Documents/Controlled/Rorohiko/TightenerComponents/JSXGetURL/Tightener_Overview_JSXGetURL.md)**: A utility for fetching URLs from within ExtendScript.
- **[XojoTightener](file:///Users/kris/Documents/Controlled/Rorohiko/TightenerComponents/XojoTightener/Tightener_Overview_XojoTightener.md)**: Bindings for using Tightener within Xojo applications.
- **[easyScript](file:///Users/kris/Documents/Controlled/Rorohiko/TightenerComponents/easyScript/Tightener_Overview_easyScript.md)**: A simplified scripting environment/template system.

### 4. Applications & Plugins
End-user products and examples built using the framework.
- **[ActivePageItems](file:///Users/kris/Documents/Controlled/Rorohiko/TightenerComponents/ActivePageItems/Tightener_Overview_ActivePageItems.md)**: An InDesign plug-in that enhances the DOM with additional scriptable features.
- **[Color2Gray](file:///Users/kris/Documents/Controlled/Rorohiko/TightenerComponents/Color2Gray/Tightener_Overview_Color2Gray.md)**: An InDesign plug-in for non-destructive color-to-grayscale conversion.
- **[Sudoku](file:///Users/kris/Documents/Controlled/Rorohiko/TightenerComponents/Sudoku/Tightener_Overview_Sudoku.md)**: An InDesign plug-in for generating Sudoku puzzles.
- **[TextExporter5](file:///Users/kris/Documents/Controlled/Rorohiko/TightenerComponents/TextExporter5/Tightener_Overview_TextExporter5.md)** / **[TextExporter6](file:///Users/kris/Documents/Controlled/Rorohiko/TightenerComponents/TextExporter6/Tightener_Overview_TextExporter6.md)**: Tools for exporting text from InDesign.
- **[SizeLabels](file:///Users/kris/Documents/Controlled/Rorohiko/TightenerComponents/SizeLabels/Tightener_Overview_SizeLabels.md)**: A scripted plugin for adding dimension labels to page items.
- **[SmokeWordStacks](file:///Users/kris/Documents/Controlled/Rorohiko/TightenerComponents/SmokeWordStacks/Tightener_Overview_SmokeWordStacks.md)**: An InDesign automation tool.
- **[StringsAttached](file:///Users/kris/Documents/Controlled/Rorohiko/TightenerComponents/StringsAttached/Tightener_Overview_StringsAttached.md)**: A scripted plugin for text frame management.
- **[Swimmer](file:///Users/kris/Documents/Controlled/Rorohiko/TightenerComponents/Swimmer/Tightener_Overview_Swimmer.md)**: An InDesign scripted plugin.

### 5. Services
- **[Store](file:///Users/kris/Documents/Controlled/Rorohiko/TightenerComponents/Store/Tightener_Overview_Store.md)**: The online store/catalog service.

## Key Concepts

### TQL (Tightener Query Language)
A custom scripting language used to control the Tightener framework. It allows for distributed execution of tasks across the network.

### TPKG Format
A secure package format (`.tpkg`) used for distributing scripts and plugins.
- **Structure**: Contains a mini-manifest, catalog entry, and an encrypted ZIP file.
- **Security**: Supports encryption (protecting source code) and signing (verifying publisher identity).
- **Installation**: Handled by the **PluginInstaller**, which decrypts and installs files to the appropriate locations (e.g., InDesign Scripts panel).

### Secrets Management
- **[TightenerSecrets](file:///Users/kris/Documents/Controlled/Rorohiko/TightenerComponents/TightenerSecrets_glueco.de)**: A secure volume containing certificates and credentials.
- **Integration**: The build system automatically mounts this volume to access code signing certificates (Apple Developer ID) and other secrets.

## Getting Started

- **For Contributors**: Start by reading the [TightenerDocs Overview](file:///Users/kris/Documents/Controlled/Rorohiko/TightenerComponents/TightenerDocs/OVERVIEW.md) to understand the build environment setup.
- **For Script Developers**: Check the [Script Dev Workflow](file:///Users/kris/Documents/Controlled/Rorohiko/TightenerComponents/Tightener/Docs/SCRIPT_DEV_WORKFLOW.md) to learn about creating and packaging scripts.
