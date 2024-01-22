# InDesign Integration

## Integration

Tightener is integrated into InDesign in two ways:

- via an InDesign C++ plugin
- via ExtendScript as an ExtendScript DLL

The plugin version is the most tightly integrated: it opens the whole InDesign DOM and makes it accessible from TQL.

TQL is the internal language of Tightener, which is similar to JavaScript, but a lot simpler.

TQL is mostly intended to handle small automation tasks (e.g. related to licensing, metrics, activation, installation,...) - 

## Command-line integration

A default version of InDesign can be targeted by way of the Tightener [config.ini](config.ini.md).

This default version can either be a desktop version, or a server version of InDesign

Once this configuration is made, InDesign or InDesign Server can be managed from the command line by way
of commands like
```
idPluginInstall
idPluginRemove
idPluginRemoveAll
idLaunch
idPoke
```