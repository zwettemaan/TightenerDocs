# TightenerComponents TODO Checklist

> Pointers include file paths and brief context for where changes are needed.

## Core Runtime / IPC
- [ ] Improve cooperative multitasking + IPC pipe efficiency: replace/augment polling with event-driven wakeups (semaphores/OS signals) **inside `TghPipes` only** (higher layers must remain unaware).
      - `Tightener/TghUtils/TghPipes.h` (poll-centric API surface)
      - `Tightener/TghUtils/TghPipes.cpp` (`ReadPipe::poll`, `WritePipe::poll`, `ReadPipeHandleBuffer::poll`, etc.)
      - `Tightener/TghCoordinator/TghInternalCoordinator.cpp` (pipe lifecycle + idle/termination checks)
      - `Tightener/TghCoordinator/TghSiblingCoordinator.cpp` (pipe discovery/send state machine)
      - Design target: TghPipes owns an internal “data-available” task/wait mechanism and buffers all incoming pipe data so higher layers only consume buffered data (no blocking I/O above TghPipes).

## InDesignTightener
- [ ] Implement missing blocking/timeouts in OM IDSN scope handling.
      - `InDesignTightener/src/TghOMIDSNScope.cpp` ("not implemented yet" flags)
- [ ] Fix startup/shutdown behavior that "does not work yet".
      - `InDesignTightener/src/TghIDSNStartupShutdown.cpp`

## ActivePageItems
- [ ] Complete CSXS event sender mapping for UIDRef → JS usable reference.
      - `ActivePageItems/src/ActivePageItemCSXSEventSender.cpp`
- [ ] Pass document closing status to script monitor.
      - `ActivePageItems/src/ActivePageItemCommandInterceptor.cpp`
- [ ] Resolve licensing TODOs / modal wait for termination.
      - `ActivePageItems/src/ActivePageItemUtilities.cpp`
      - `ActivePageItems/src/ActivePageItemPublics.cpp`
      - `ActivePageItems/src/LicenseData.cpp`
- [ ] Finish script provider TODO blocks.
      - `ActivePageItems/src/ActivePageItemScriptProvider.cpp`
- [ ] Register script elements with Adobe.
      - `ActivePageItems/src/Public/ActivePageItemID.h`
- [ ] Handle selection in SPLN list box observer.
      - `ActivePageItems/src/ActivePageItemSPLNListBoxObserver.cpp`
- [ ] Resolve remaining UI resource TODO.
      - `ActivePageItems/src/ActivePageItemUI.fr`
- [ ] Startup/shutdown TODO that "does not work yet".
      - `ActivePageItems/src/ActivePageItemStartupShutdown.cpp`

## TightenerRegistry
- [ ] Implement missing API helpers (marked `IMPLEMENTATION_MISSING`).
      - `TightenerRegistry/serverApps/api/registry.js`
      - `TightenerRegistry/TightenerRegistry_helpers/node/api/registry.js`
      - `TightenerRegistry/TightenerRegistry_helpers/node/api/hashGUID.js`
      - `TightenerRegistry/TightenerRegistry_helpers/api/utils.js`
      - `TightenerRegistry/TightenerRegistry_helpers/api/path.js`
      - `TightenerRegistry/TightenerRegistry_helpers/api/fileio.js`
      - `TightenerRegistry/TightenerRegistry_helpers/api/compat.js`

## easyScript
- [ ] Add async native file I/O support (currently TBD).
      - `easyScript/CEP_js/CEPEngine_extensions.js`

## CRDT_UXP Docs Tooling
- [ ] Move tutorial functions into `templateHelper.js` as noted.
      - `CRDT_UXP/custom_minami/publish.js`

## PluginInstaller
- [ ] Resolve TODO block in Xojo code.
      - `PluginInstaller/App.xojo_code`

## TextExporter6
- [ ] Replace placeholder README.
      - `TextExporter6/README.md`

## Pause State (Resume Notes)
- Current work branch: `Tightener` repo on `pipes-event-driven`.
- Event-driven pipe handling must be **encapsulated in `TghPipes`**, higher layers stay unaware.
- Design notes folded into `TightenerDocs/Tightener_CooperativeMultiThreading.md` under “Event-Driven Pipe Handling (Draft)”.
