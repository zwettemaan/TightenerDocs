# Tightener

When Tightener is used, it establishes an internal constellation of Tightener nodes - some nodes are embedded in native apps (e.g. Adobe InDesign), some nodes are embedded in C++ programs or in an ExtendScript engine, some nodes are embedded in Xojo programs...

In all constellations, there is always a single 'main' node, which is used as the go-between between the other nodes on the same computer.

There are a number of Tightener programs that are able to pick up the role of being the main node. 

xWhich of these programs is used depends on the config.ini and/or on what program is manually launched by the user.

## Tightener

The Tightener or Tightener.exe command-line program is the 'core' Tightener. It does not have gateway functionality (i.e. this copy of Tightener cannot listen for connections or reach out to other Tightener nodes).

However, it does have the activation/licensing infrastructure and can contact the Tightener Registry to register or confirm machineGUIDs and user GUIDs.

The same executable is used with different command line parameters to run different types of Tightener nodes. 

For example, the `startConsole` command will launch Tightener with a `-N console` command line parameter.

## TightenerGW_Cpp

There is an alternate, enhanced version of this command-line program, `TightenerGW_Cpp` or `TightenerGW_Cpp.exe`. This version will use TCP/IP sockets and listen for connections from other nodes on different machines.

Using this version will establish a constellation of nodes that is able to communicate Tightener nodes running on another computer

## TightenerGW

TightenerGW is a command-line Xojo equivalent of TightenerGW_Cpp; it is an older, slower and less capable version, mainly used for debugging and testing.

## XojoTightener

XojoTightener has a GUI and is another Xojo equivalent of TightenerGW_Cpp; it is an older, slower and less capable version, mainly used for debugging and testing.


