# Unstable, variable release

# Alpha Releases

## Version 0.1.8

Twelfth alpha release, 21-Feb-2024, build 428

https://cloud.rorohiko.com/index.php/s/BQJ7nDym6awTWGj

Fix issues with auto-transfer of embedded or sidecar activations.

## Version 0.1.7

Twelfth alpha release, 20-Feb-2024, build 417

Fix issues with auto-transfer of embedded or sidecar activations.

## Version 0.1.6

Twelfth alpha release, 19-Feb-2024, build 406

Fix issues with License Manager. 
Add support for 'sidecar' sublicensing activation files, so sublicenses can be bundled without source code embedding.

## Version 0.1.5

Eleventh alpha release, 10-Feb-2024, build 336

Added new APIs that give access to additional licensing data: remaining lifetime, order GUID...
Tweaks and bug fixes for issues found while creating some 'real' products (JSXGetURL, Creative Developer Tools).

## Version 0.1.4

Tenth alpha release, 5-Feb-2024, build 319

This version adds support for sublicensing: a developer can now purchase activations and embed them in their own source code, so the end-user can remain oblivious of any license management.

## Version 0.1.3

Ninth alpha release, 1-Jan-2024, build 291

This version adds support for UXP and UXPScript by way of a 'daemon' mode.

Tightener can run as a daemon and run a little local HTTPS server on 
```
https://localhost.tgrg.net:18888
```
This resolves to 127.0.0.1 and can be accessed by the `fetch` API in UXP.

## Version 0.1.2

Eighth alpha release, 1-Jan-2024, build 284

This version adds support for activation and licensing. There is a new app
called 'LicenseManager' in the Apps subfolder. This app has two modes:
- Standard mode: allow users to register, send purchase orders to suppliers, and
  handle activations of softwares on their computers.
- Developer/Supplier mode: allow developers to register, add products to their
  catalog and sell their software. I still need to document all this, but essentially,
  the scripting languages like TQL and ExtendScript gain two new functions: `machineGUID()` and
  `getCapability()`.

You can also download the License Manager here:

https://store.tgrg.net/

## Version 0.1.1

Seventh alpha release, 6-Nov-2023

Much debugging and fixing. The ESDLL and Xojo versions (ExtendScript DLL/Xojo plugin) 
now use a separate C++ thread to run the main Tightener core, so it remains responsive even 
when the host app is not paying attention (e.g. running a script). This makes the Tightener 
communications a fair bit faster, and the host app remains responsive for Tightener nodes 
even when the TightenerDaemon panel is not active. The main effect of having the daemon 
inactive is that you cannot launch ExtendScripts remotely, but you can still run TQL scripts.

## Version 0.1.0

Sixth alpha release, 23-Apr-2023

This version adds support for ARM64 on Windows and Linux.
The reason for that is that I've got a new M2 MacBook Pro, 
and I wanted to be able to build and test Tightener on it.

I've made new build scripts which can cross-compile to ARM64 
on x64 systems and also cross-compile to x64 on ARM64 systems.
This is what I am now using on my M2 Mac - the Mac build is
done on the machine itself, and the Linux and Windows builds are 
done on ARM64 virtual machines (Ubuntu Linux and Windows 11)
which then also compile the x64 components for Tightener 
(including InDesign plug-ins)

## Version 0.0.9

Fifth alpha release, 21-Feb-2023

## Version 0.0.8

Fourth alpha release, 6-Feb-2023

## Version 0.0.7

Third alpha release, 3-Feb-2023

## Version 0.0.6

Second alpha release, 14-Sep-2022

## Version 0.0.5

First alpha release, 13-Aug-2022
