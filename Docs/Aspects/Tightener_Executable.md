# Tightener Executable

Tightener has an executable, which is written in C++. It fulfills multiple roles - when a developer installs a full version
of Tightener the same executable can be launched multiple times in concurrent fashion, to play multiple roles:

- The core (main) coordinator
- The console 
- The reflector (for testing message passing on the Tightener bus)
- The daemon (for use from environments that have no callable API, but support HTTPS)

This executable is part of a full Tightener release. It is also embedded into the License Manager, where it is used
for a daemon on computers that don't have a full Tightener installed.

## Target Platforms

Tightener is provided for multiple target plaforms:

- Mac (Universal Binary: M1/x86)
- Windows (x64)
- Windows (ARM64)
- Linux (x64)
- Linux (ARM64)