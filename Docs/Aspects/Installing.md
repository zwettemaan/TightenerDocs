# Installing

There are two common approaches to installing Tightener: a 'light' version for end-users,
and a 'full' version for developers.

End-users would install just the PluginInstaller, which has an embedded copy of the light
version of Tightener

Developers would install the full version of Tightener, which provides an extensive range of 
command-line tools for using, developing, monitoring, testing, configuring...

## Installing the PluginInstaller

To install the PluginInstaller, visit

https://PluginInstaller.com

and download the latest version. There is no installer - you simply 'unzip' the download, and move the downloaded folder
to some convenient location, then double-click the PluginInstaller.app or PluginInstaller.exe file.

The user would create and register at least one account, then download catalog entries from one or more software developers.

Once the catalog entries have been loaded, the user can then order a license file from a supplier, and when the order is fulfilled,
they can activate the software.

## Installing a full version

Download a copy of a Tightener release from the [Releases](https://github.com/zwettemaan/TightenerDocs/tree/main/Releases) folder

Decompress and move to a convenient spot.

Start a command line window into the Tightener folder and run the install script (`install.command` for Mac/Linux, `install.bat` for Windows)

Uninstalling is done by running the `uninstall.command` or `uninstall.bat` script.

You can also install a copy of the PluginInstaller. Make sure to switch PluginInstaller to developer mode in order to create a developer account.

## Human Readable

A lot of aspects in Tightener are driven by way of command line scripts, `.tql` scripts, and the `config.ini` file. 

Care has been taken to make all of these files human-readable. Feel free to browse the release version and inspect the many
scripts and samples that have been provided.
