# InDesign Integration

Tightener is integrated into InDesign in two ways:

- via an InDesign C++ plugin
- via ExtendScript as an ExtendScript DLL

The plugin version is the most tightly integrated: it opens the whole InDesign DOM and makes it accessible from TQL.

TQL is the internal language of Tightener, which is similar to JavaScript, but a lot simpler.

TQL is mostly intended to handle small automation tasks (e.g. related to licensing, metrics, activation, installation,...) - 
