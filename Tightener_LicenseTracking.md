# Tightener License Tracking System

## Overview

The Tightener ecosystem uses a privacy-centric, distributed licensing system based on **Capabilities**. Unlike traditional licensing servers that track "seats" directly against user data, Tightener uses a central **Registry** (`tgrg.net`) that manages anonymous **Capability Slots**.

The system is designed to:
1.  **Protect Privacy**: The central registry holds no identifiable user data (only GUIDs and public keys).
2.  **Decentralize Verification**: The "truth" about what a license entails (features, expiry, etc.) is embedded in an encrypted **Capability Wrapper File** held by the user, not the server.
3.  **Prevent Abuse**: The registry ensures that a specific "Capability Slot" is only active on one registered machine at a time.

## Core Concepts

### 1. The Registry (`tgrg.net`)
The central server. It is a "dumb" store of GUIDs and timestamps.
-   **Entities**: Users and Developers are registered as anonymous Entities (identified by `entityGUID` and Public Key).
-   **Capability Slots**: Represents a "seat". A developer registers a set of slots for a given Capability.
-   **Machine Registrations**: Machines are identified by a `registryMachineGUID` (internal to registry) and `machineLinkGUID` (shared with machine).
-   **Function**: It maps **Machine Registrations** to **Capability Slots**. It does *not* know what the capability is.

### 2. The Tightener Registry Node (`TghRegistry`)
The local component running on the user's machine (part of the Tightener Daemon/Gateway).
-   **Role**: Acts as the intermediary between local software (Tightener Nodes) and the central Registry.
-   **Responsibilities**:
    -   Manages the local "wallet" of Capability Wrapper Files.
    -   Handles cryptographic operations (decrypting capabilities using the user's private key).
    -   Communicates with `tgrg.net` to "claim" or "verify" a slot for the local machine.

### 3. Capability Wrapper File (The "License")
A file provided by the developer to the user (e.g., via email or download).
-   **Content**: Contains the actual "License" data (product code, features, time limits) encrypted specifically for the user (Grantee).
-   **Privacy**: The Registry never sees this file. It only sees a hash of it (`capabilityGUID`).
-   **Distinction**: This is **NOT** the same as a `.tpkg` file.

### 4. Tightener Package (`.tpkg`)
A software distribution package.
-   **Content**: Contains the software binaries, scripts, and resources (e.g., the `TextExporter` plugin).
-   **Role**: Used solely for installation. It does **not** contain license information.

### 5. Tightener Nodes
Individual software components (Plugins, Scripts, Apps like `TextExporter`) running on the machine.
-   **Interaction**: They do *not* talk to the Registry directly. They ask the local **Tightener Registry Node** "Do I have the capability for Product X?".
-   **Result**: If valid, they receive the decrypted capability data to enable features.

## Licensing Workflow

1.  **Registration**:
    -   A user registers an account (Entity) via the `PluginInstaller`. This creates a key pair locally and registers the Public Key with the Registry.

2.  **Software Installation**:
    -   The User installs the software (e.g., `TextExporter`) using a **`.tpkg`** file via the `PluginInstaller`.
    -   At this stage, the software is installed but may be in "Demo" mode or unlicensed.

3.  **Integrated Payment & Ordering (Rorohiko Standard Flow)**:
    -   *Note: This is the standard workflow for Rorohiko products. Other developers may implement their own payment and delivery systems.*
    -   The user browses the **Store** within `PluginInstaller`.
    -   Selecting a product downloads a **Catalog Entry** (e.g., `.cate`) and opens the Ordering window.
    -   The user confirms the order (seats, etc.) and proceeds to payment (via web).
    -   The `PluginInstaller` **polls** the commerce server for payment confirmation.
    -   Once paid, the system *automatically* fetches the **Capability Wrapper File** and activates it.

4.  **Manual License Request (Optional Fallback)**:
    -   If the integrated store is not used, the User generates a **License Request** (often a `.lirq` file) via the `PluginInstaller` (e.g., by clicking "Export").
    -   The User sends this request to the Developer (e.g., via email).
    -   The Developer creates a **Capability Wrapper File** encrypted for the User's Public Key and registers it.
    -   The User receives the file and imports it manually.

5.  **Verification (The "Check")**:
    -   **Step A (Local)**: A plugin (e.g., `TextExporter`) asks the local `TghRegistry`: "Unlock capability for ProductCode X".
    -   **Step B (Registry)**: The `TghRegistry` contacts `tgrg.net` to verify if the local machine is assigned to a valid **Capability Slot** for that capability.
    -   **Step C (Decryption)**:
        -   If the Registry confirms the slot is assigned to *this* machine:
        -   The `TghRegistry` uses the User's Private Key to decrypt the wrapper.
        -   It then uses the Developer's Public Key to verify the signature.
        -   The decrypted data (the "License") is returned to the plugin.

6.  **Machine Linking**:
    -   Machines have a `machineLinkGUID`. If a machine is cloned, the Registry detects the duplicate usage and forces a re-registration, invalidating the clone's link to the capability slot.

## Integration in Subprojects

### ActivePageItems (`LicenseData`)
While the Registry handles the *delivery* and *locking* of the capability, the **content** of that capability is often mapped to the `LicenseData` C++ class.
-   **`LicenseData`**: Represents the *decrypted* payload. It tracks state like `kDemo`, `kAPIDLicensed`, etc., based on what was inside the encrypted capability blob.
-   **Persistence**: `ActivePageItemLicenseDataPersist` caches the *result* of the verification to avoid constant network calls, but the `TghRegistry` is the authority.

### PluginInstaller
The user-facing tool to:
-   Create/Manage the User Entity.
-   Install Software (via **`.tpkg`** files).
-   Import Licenses (via **Capability Wrapper Files**).
-   Trigger the "Update Machine" or "Verify Machine" flows if the hardware environment changes.
