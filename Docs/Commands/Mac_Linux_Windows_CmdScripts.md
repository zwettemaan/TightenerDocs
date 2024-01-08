# Mac/Linux vs Windows scripts

Most of the command line scripts work the same on Mac, Linux and Windows.

On Windows, the scripts are nearly all contained in .bat files

On Mac and Linux these are command line scripts (`chmod +x`).

For some commands, we used command line aliases on Mac and Linux. As this concept does not exist on Windows, the corresponding Windows versions are just .bat files.

See `setPathLinux`, `setPathMac`.

The one-time initial setup (install/remove) is handled by scripts `install.bat`, `install.command` and `uninstall.bat`, `uninstall.command` located in the root of the
release directory.

When one starts a command line shell, the Mac and Linux environments are set via the .profile/.zshenv... whereas for Windows these are set via Windows environment variables.

