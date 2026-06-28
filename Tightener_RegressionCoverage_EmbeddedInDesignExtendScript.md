# Tightener Embedded InDesign and ExtendScript Communication Coverage

## Purpose

This document records the current regression surface for Tightener when it is embedded inside:

- the `InDesignTightener` plug-in
- the ExtendScript DLL host loop

It focuses on the communication paths requested for Session F:

- in-app coordinator -> self
- in-app coordinator -> main
- in-app coordinator -> reflector

## Current Embedded Smoke Assets

### InDesignTightener scripts

The embedded InDesign smoke set now lives in `InDesignTightener/TestScripts/`:

- `pingSelf.tql`
  - targets `tgh:///<sysInfo().coordinatorName>/$.engineName`
  - verifies that the in-app coordinator can route back to itself
- `pingMain.tql`
  - existing script reused as-is
  - verifies in-app coordinator -> local `main`
- `pingReflector.tql`
  - existing script reused as-is
  - verifies in-app coordinator -> local `reflector`
  - also sends `quit();` to clean up the helper reflector
- `runEmbeddedCommunicationRegression.tql`
  - wrapper that runs the three scripts above from the same folder and returns one combined pass/fail result

### ExtendScript host-loop visibility

The ExtendScript loader previously drained queued host messages without telling the operator what happened.

There is now also one checked-in same-machine ExtendScript smoke script:

- `TightenerDocs/CurrentRelease/Plug-Ins/TightenerESDLL/testCommunication.jsx`
  - initializes an embedded ExtendScript coordinator
  - verifies ExtendScript coordinator -> self
  - verifies ExtendScript coordinator -> local `main`
  - verifies ExtendScript coordinator -> local `reflector`
  - shuts the helper reflector down after the reflector check succeeds

That behavior is now made explicit in:

- `Tightener/TightenerDaemon/jsx/TightenerESDLLLoader.jsx`
- `TightenerDocs/CurrentRelease/Plug-Ins/TightenerESDLL/lib/TightenerESDLLLoader.jsx`

When the ExtendScript host loop sees queued host messages, it now:

- fetches the target host and message text
- writes an explicit warning
- records the warning in `TIGHTENER.lastUnsupportedGatewayMessage`
- still discards the message because gateway forwarding is not implemented in this host

## How To Run

### InDesign embedded path

Run the wrapper from inside the embedded InDesign TQL environment:

```text
InDesignTightener/TestScripts/runEmbeddedCommunicationRegression.tql
```

Expected result:

- script return value: `success`
- console output from:
  - `pingSelf.tql`
  - `pingMain.tql`
  - `pingReflector.tql`

### Individual scenarios

Run these separately when isolating failures:

- `InDesignTightener/TestScripts/pingSelf.tql`
- `InDesignTightener/TestScripts/pingMain.tql`
- `InDesignTightener/TestScripts/pingReflector.tql`

### ExtendScript DLL path

Run:

```text
TightenerDocs/CurrentRelease/Plug-Ins/TightenerESDLL/testCommunication.jsx
```

Expected result:

- ExtendScript console output contains `testCommunication.jsx: success`
- no gateway warning is emitted unless unsupported host-forwarding traffic is attempted

## Limitations

### ExtendScript gateway behavior

The ExtendScript DLL host loop is **not** a gateway implementation.

Supported:

- hosting a local embedded coordinator
- same-machine coordinator traffic that does not require host-level gateway forwarding

Unsupported:

- acting as a forwarding gateway for host messages destined for another host
- silently "making gateway traffic work" through fallback behavior

If that unsupported path is exercised, the loader now emits an explicit warning instead of hiding it.

## Practical status

- InDesign embedded `self`, `main`, and `reflector` smoke coverage is now checked in and reusable.
- ExtendScript DLL same-machine `self`, `main`, and `reflector` smoke coverage is now checked in.
- ExtendScript host-loop gateway behavior is now documented and surfaced explicitly at runtime.
- There is still no real cross-host gateway coverage from the ExtendScript host. That remains out of scope until a real gateway implementation exists there.
