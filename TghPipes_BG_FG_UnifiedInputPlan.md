# TghPipes BG/FG Unified Input Refactor Plan

## Summary

This document defines the `TghPipes` refactor that makes all pipe input follow one receive model:

- BG wakes when data arrives
- BG reads full packets into memory in all cases
- BG classifies buffered packets after ingest
- BG forwards passthrough traffic through BG-managed buffering
- FG only drains locally targeted packets from shared queues and assembles messages

The goal is to eliminate the current split where passthrough traffic can bypass the normal buffered receive path while preserving explicit failure behavior, cross-platform parity, and the existing FG message assembly contract.

## Current State

The current implementation already separates blocking pipe I/O from cooperative event-loop work, but the split is incomplete.

- BG owns the OS read handles and blocks on the source pipe plus the wake pipe.
- FG owns message assembly, message dequeue, and coordinator-facing consumption.
- Local-target traffic is queued into shared packet buffers and later assembled by FG.
- Passthrough traffic still has special BG receive logic that can stream directly from source pipe to destination pipe during receive.

That last point is the main inconsistency. It means packet handling differs depending on destination, and receive logic currently mixes:

- packet ingestion
- route classification
- passthrough transport behavior

inside the low-level platform-specific read path.

## Target Architecture

### Receive Pipeline

All incoming pipe traffic must follow this pipeline:

1. Data arrives on a read pipe and wakes the sleeping BG thread.
2. BG reads a complete packet into memory.
3. BG classifies the buffered packet.
4. BG sends the packet to one of two buffered destinations:
   - local-target packet queue shared with FG
   - BG-managed passthrough forwarding queue/path
5. FG later drains only the local-target queue, assembles strings, and hands completed messages to the coordinator event loop.

No packet type may bypass BG buffering.

### Thread Ownership

- BG owns all blocking pipe read/write activity, wake handling, packet ingest, route classification, and passthrough forwarding.
- FG owns only shared local-consumption queues, packet-to-message assembly, delimiter handling, and coordinator-facing message delivery.

### Platform Parity

Windows and POSIX may keep different low-level read primitives:

- Windows overlapped I/O
- POSIX `poll()` plus `read()`

But both platforms must expose the same post-ingest behavior:

- full packet buffered first
- route classification second
- BG-local forward or FG queue handoff third

## Required Code Changes

### `TghPipes` Receive Path

Refactor the BG receive implementations so their only receive responsibility is:

- wait for wake or source-pipe readiness
- read a complete packet into memory
- pass that packet into one shared BG routing step

Both `threadedReadPacketWindows()` and `threadedReadPacketPosix()` should converge on the same post-read helper, for example a `routeBufferedPacket_BG()` style function.

### Remove Special Receive-Time Passthrough Streaming

Eliminate the direct source-to-destination streaming behavior during receive.

Specifically, the refactor should remove the current model where:

- a continuation passthrough packet body can be streamed while still being read from the source pipe
- passthrough logic changes how the source packet is ingested

Passthrough should operate only on already buffered packet data.

### BG Passthrough Buffering

Introduce or formalize a BG-managed passthrough buffering path.

The implementation must:

- accept complete buffered packets from the receive path
- preserve ordering per source string
- reuse BG destination-handle management
- forward buffered packets to destination pipes without involving FG

Immediate BG forwarding after buffering is acceptable, but it must still conceptually operate on a fully buffered packet and fit the same queueable model used for stalled destinations.

### FG Local Queueing

Keep the current FG-local packet assembly contract intact.

The local-target path should continue to use shared packet queues and the existing FG assembly flow:

- queue packet from BG
- drain pending packets in FG
- assemble per-process/per-string message buffers
- expose completed strings to `InternalCoordinator`

### Routing Cache Touchpoints

Keep the routing cache as the route lookup mechanism unless it can be simplified without changing external behavior.

The refactor may tighten how route state is represented, but it must preserve the current external role:

- map source process plus destination coordinator to a destination pipe path
- allow BG to decide whether a packet is a local-consumption packet or a passthrough packet

Any arming/disarming or pending-data state that only exists to support the old mixed receive path should be reevaluated and removed or simplified if no longer necessary.

## Invariants And Failure Behavior

The refactor must preserve these invariants:

- BG is the only code that touches OS read handles.
- FG never blocks on OS pipe I/O.
- No packet bypasses BG buffering.
- Ordering is preserved per source string.
- Local delivery semantics remain unchanged from the current public behavior.
- Shutdown still wakes blocked BG readers promptly.

Failure handling must remain explicit:

- no silent fallback behavior
- explicit error state transitions
- explicit logging on read, route, or write failure
- explicit backlog policy behavior

If passthrough forwarding fails, the failure path must be deliberate and visible rather than falling back silently to some alternate transport mode.

## Backlog And Buffering Policy

The refactor must treat local-target buffering and passthrough buffering as separate concerns.

- FG local backlog remains governed by the existing read-pipe buffering policy.
- BG passthrough buffering must have a defined behavior under stalled destination conditions.

At minimum, the implementation must make a deliberate decision for BG passthrough backlog behavior rather than inheriting FG backlog behavior accidentally.

The accepted minimum for the refactor is:

- document the BG passthrough buffering policy explicitly
- ensure stalled FG local consumption does not break BG passthrough behavior
- ensure stalled passthrough destinations do not corrupt ordering or shutdown behavior

## Acceptance Criteria

The refactor is complete when all of the following are true:

- every incoming packet is fully ingested by BG before routing
- passthrough still works for single- and multi-packet payloads
- local delivery semantics are unchanged
- BG remains the only owner of pipe I/O
- FG only consumes locally targeted queued packets
- shutdown still wakes blocked BG readers promptly
- ordering is preserved per source string for both local delivery and passthrough
- Windows and POSIX conform to the same post-ingest routing model

## Test Plan

Add or update tests to cover:

- local basic send/receive
- multi-packet local assembly
- passthrough of single-packet payloads
- passthrough of multi-packet payloads
- mixed local and passthrough traffic ordering
- stalled FG backlog without breaking BG passthrough behavior
- stalled passthrough destination buffering behavior
- close/shutdown while BG is blocked
- reconnect/reopen after peer disappearance

Verification must cover both platform paths:

- Windows overlapped read path
- POSIX `poll()`/`read()` path

## Assumptions And Defaults

- This plan lives in `TightenerDocs` because it is a cross-cutting refactor plan rather than a component-local implementation note.
- Completed plans and their completed planning outputs in `TightenerDocs` are removable when they are clearly obsolete and superseded.
- Cleanup for this work is limited to the regression-planning docs already identified with completed status.
