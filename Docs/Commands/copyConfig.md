# copyConfig

This script will overwrite the Tightener config file in the settings directory. Any changes made to the `config.ini` will be obliterated.

Also see [`editConfig`](editConfig.md) and [`cd_settings`](cd_settings.md)

The 'active' config file is overwritten by a concatenation of some local settings, and a copy of the `config.ini` file in the `<root>/Config/config.ini`

Note that the active `config.ini` file differs from the `<root>/Config/config.ini`. 

One should never copy the active `config.ini` back on top of the `<root>/Config/config.ini` without stripping the first `[placeholders]` section away.



