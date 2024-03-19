# PluginInstaller

PluginInstaller is a standalone app, which allows a user to manage accounts, licenses and activations

The app has two 'modes' - a standard (user) mode, and a developer mode. 

Accounts registered in standard mode are unrelated to accounts registered in developer mode.

PluginInstaller also embeds a copy of the Tightener command-line app, to serve as a daemon when
other tools (e.g. UXP) need to access Tightener features.

Launching PluginInstaller will automatically start the daemon.