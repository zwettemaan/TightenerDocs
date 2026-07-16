# Python ↔ Tightener Integration

## Goal

Connect directly from a Python script to a sibling Tightener node (e.g. InDesign with the native plug-in installed) without going through the `pexpect.replwrap` subprocess REPL layer used by the Jupyter kernels.

---

## Current architecture (for context)

The existing Jupyter kernels wrap the `rre_Jupyter` / `rru_Jupyter` shell scripts via `pexpect.replwrap`. Each shell script spawns a fresh `Tightener` process per kernel session; that process runs an interactive REPL TQL script (`rre_REPL.tql`) which calls `sendData()` to forward every cell to InDesign and reads the reply. The round-trip path is:

```
Python pexpect  →  shell script  →  Tightener (TQL REPL)  →  TightenerGW  →  InDesign
```

Every cell pays:
- pexpect prompt detection overhead (~1–5 ms)
- Tightener's cooperative multitasking cycle time (~5–30 ms)
- InDesign script execution time

The Tightener process starts once per kernel session, so per-cell overhead is low. The real problem is the protocol is opaque: errors are plain text, timeouts are global, and there is no way to stream partial output.

---

## The Tightener wire protocol

Understanding the protocol is required before choosing an integration strategy.

### Transports

Tightener uses **two transports**:

1. **Named pipes** (local) — sibling coordinators on the same machine write *directly into each other's named pipes*. No TightenerGW involvement. This is how the command-line `Tightener` talks to the InDesign plug-in locally.
2. **TCP port 9888** (remote) — TightenerGW listens on `APP_PORT_TIGHTENER` and routes messages between machines. Local nodes forward remote-addressed messages to GW via its named pipe; GW carries them over TCP.

For a Python-to-local-InDesign connector, the named-pipe transport is the relevant one — it works even when TightenerGW is not running. See Strategy 3 below.

### Message framing (TCP / TightenerGW)

Each message on the TCP wire is:

```
IPC_escape(serialized_message_bytes) + CR
```

Where:
- `CR` = `\x0D` (`MESSAGE_SEPARATOR_CHAR`)
- `LF` = `\x0A` bytes in the stream are silently ignored (`MESSAGE_SEPARATOR_IGNORE_CHAR`)
- **IPC escape character** = `-`
  - `-` → `--`
  - `LF` (`\x0A`) → `-n`
  - `NUL` (`\x00`) → `-z`

(The named-pipe transport carries the same IPC-escaped serialized message, but framed in length-prefixed packets instead of CR-terminated lines — see below.)

### Message structure (SimpleSerializer)

The unescaped payload is a sequence of **LF-terminated, backslash-escaped fields**:

```
serializer_escape(field_1) + LF
serializer_escape(field_2) + LF
...
```

`serializer_escape` uses `\` as the escape character and escapes many control characters. Notable entries:

| Raw byte | Escaped form |
|---|---|
| `\x00` | `\z` |
| `\x09` (tab) | `\t` |
| `\x0A` (LF) | `\n` |
| `\x0D` (CR) | `\r` |
| `"` | `\"` |
| `'` | `\'` |
| `\` | `\\` |

### Message fields (in order)

A Tightener IPC message is a type-prefixed serialized `Message` object — the first field is the literal type name `Message`, followed by the object's own fields:

| # | Field | Content |
|---|---|---|
| 1 | Type name | The literal string `Message` |
| 2 | Sender address | Type-prefixed serialized address object |
| 3 | Receiver address | Type-prefixed serialized address object |
| 4 | OpCode | Integer as decimal string |
| 5 | Payload | TQL `stringify()` output |

(The pipe reader in `TghPipes.cpp` `getForwardCoordinatorFromStartPacket()` verifies `fields[0] == "Message"` before routing.)

**Type-prefixed serialization** means the object's type name is emitted as the first field, followed by the object's own fields. For example, a `LocalUnresolvedAddress` for coordinator `net.tightener.coordinator.indesign.18.0` index `main`:

```
LocalUnresolvedAddress\n
net.tightener.coordinator.indesign.18.0\n
main\n
```

### OpCode enum values

```
NONE         = 0
TERMINATE    = 1
PING         = 2
PING_REPLY   = 3
LOG_TRACE    = 4
LOG_NOTE     = 5
LOG_WARNING  = 6
LOG_ERROR    = 7
STD_OUT      = 8
STD_ERR      = 9
OPEN_SESSION = 10
CLOSE_SESSION= 11
EVAL         = 12
EVAL_FILE    = 13
EVAL_RESULT  = 14
DATA_REQUEST = 15
DATA_REPLY   = 16
```

### DATA_REQUEST payload

The payload is the TQL `stringify()` output of a map with these keys:

| Key | Type | Description |
|---|---|---|
| `callBackID` | string | Which handler to invoke on the receiver |
| `clientSequenceNr` | int | Monotonically increasing counter for matching replies |
| `data` | string | The script or data to send |

**Callback IDs** (defined in `startupScript.tql`):

| ID | Language |
|---|---|
| `net.tightener.callbackid.commandline.extendscript` | ExtendScript |
| `net.tightener.callbackid.commandline.uxpscript` | UXP Script |
| `net.tightener.callbackid.commandline.tql` | TQL |
| `net.tightener.callbackid.commandline.default` | Default |

Example payload string (before serializer escaping):

```
{"callBackID":"net.tightener.callbackid.commandline.extendscript", "clientSequenceNr":1, "data":"app.name\n"}
```

(Note: inside the string value the `\n` is two characters — backslash and n — as produced by TQL's `enquoteString`. It is **not** a raw LF byte.)

### DATA_REPLY payload

```
{"clientSequenceNr":1, "data":"Adobe InDesign\n"}
```

The `clientSequenceNr` matches the request. `data` is the result string, again with embedded newlines quoted as `\n`.

---

## Four integration strategies

### Strategy 1 — Subprocess per call (works today, zero new code)

The `rre_REPL` script already supports a one-shot mode: pass the code as the second argument (the `RRE_1LINE` path in `rre_REPL.tql`). Python spawns a fresh `Tightener` process per call.

```python
import subprocess, os, shutil

SCRIPTS = os.environ.get("TIGHTENER_SCRIPTS", "")
TIMEOUT_MS = int(os.environ.get("TIGHTENER_DEFAULT_REPL_TIMEOUT_MS", "20000"))
QUIT_MS    = int(os.environ.get("TIGHTENER_DEFAULT_RR_QUIT_DELAY_MS", "2000"))

def eval_extendscript(code: str, target: str = "InDesign") -> str:
    script = shutil.which(f"{SCRIPTS}rre_REPL") or f"{SCRIPTS}rre_REPL"
    env = {
        **os.environ,
        "RRE_REMOTE_URL": target,
        "TIMEOUT_MS": str(TIMEOUT_MS),
        "QUIT_DELAY_MS": str(QUIT_MS),
        "RRE_1LINE": code,
    }
    result = subprocess.run(
        [script, target, code],
        env=env, capture_output=True, text=True,
        timeout=(TIMEOUT_MS + QUIT_MS) / 1000 + 5
    )
    return result.stdout.strip()

# Usage
print(eval_extendscript("app.name"))
print(eval_extendscript("app.documents.length"))
```

**Overhead**: ~200–500 ms per call (Tightener startup + GW connection). Acceptable for automation scripts; too slow for interactive use inside a notebook.

**Pros**: no new infrastructure, works on Mac/Windows/Linux.
**Cons**: per-call process spawn; no streaming; errors are plain text.

---

### Strategy 2 — Persistent TQL bridge subprocess (recommended next step)

Create a small TQL script that reads JSON command lines from stdin, executes them, and writes JSON result lines to stdout. Python spawns this once and communicates via `subprocess.stdin` / `subprocess.stdout`.

**New TQL file** (`python_bridge.tql`):

```tql
// python_bridge.tql
// Reads one JSON line per command from stdin, executes, writes result to stdout.
G = {}; evalScript(parentPath(scriptFilePath()) + "util.mtql");
G.UTIL.include("log.mtql");

G.CALL_BACK_ID_EXTENDSCRIPT = "net.tightener.callbackid.commandline.extendscript";
G.CALL_BACK_ID_UXPSCRIPT    = "net.tightener.callbackid.commandline.uxpscript";
G.CALL_BACK_ID_TQL          = "net.tightener.callbackid.commandline.tql";

var timeoutMs = parseInt(getEnv("TIMEOUT_MS"));
if (isNaN(timeoutMs)) { timeoutMs = 20000; }

var line;
while ((line = stdIn()) !== undefined) {
    line = G.UTIL.trim(line);
    if (! line) { continue; }

    var cmd;
    try { cmd = JSON.parse(line); } catch(e) {
        stdOut(JSON.stringify({error: "bad JSON: " + e}) + "\n");
        continue;
    }

    var target   = cmd.target   || "InDesign";
    var callBack = cmd.callBack || G.CALL_BACK_ID_EXTENDSCRIPT;
    var id       = cmd.id       || 0;
    var code     = cmd.code     || "";

    var resultStr = "error: timeout";
    sendData(
        code + "\n",
        target,
        callBack,
        function(r) { resultStr = r; },
        timeoutMs
    );

    stdOut(JSON.stringify({id: id, result: resultStr}) + "\n");
}
```

**Python wrapper** (`tightener.py`):

```python
import subprocess, json, os, threading, queue, shutil

class TightenerBridge:
    """Persistent Tightener subprocess bridge."""

    def __init__(self, target="InDesign", timeout_ms=20000):
        self.target = target
        self.timeout_ms = timeout_ms
        scripts = os.environ.get("TIGHTENER_SCRIPTS", "")
        bridge  = os.path.join(scripts, "python_bridge.tql")
        session = __import__("uuid").uuid4().hex
        coord   = f"net.tightener.coordinator.python.{session}"
        env = {**os.environ, "TIMEOUT_MS": str(timeout_ms)}
        tightener = shutil.which("Tightener") or "Tightener"
        self._proc = subprocess.Popen(
            [tightener, "-n", coord, "-I", "-t", "n", "-z",
             "-f", bridge],
            stdin=subprocess.PIPE, stdout=subprocess.PIPE,
            text=True, env=env, bufsize=1)
        self._q   = queue.SimpleQueue()
        self._seq = 0
        self._reader = threading.Thread(target=self._read_loop, daemon=True)
        self._reader.start()

    def _read_loop(self):
        for line in self._proc.stdout:
            try:
                self._q.put(json.loads(line))
            except json.JSONDecodeError:
                pass

    def eval(self, code: str, callback: str = "extendscript") -> str:
        cb_id = {
            "extendscript": "net.tightener.callbackid.commandline.extendscript",
            "uxpscript":    "net.tightener.callbackid.commandline.uxpscript",
            "tql":          "net.tightener.callbackid.commandline.tql",
        }.get(callback, callback)
        self._seq += 1
        cmd = {"target": self.target, "callBack": cb_id,
               "id": self._seq, "code": code}
        self._proc.stdin.write(json.dumps(cmd) + "\n")
        self._proc.stdin.flush()
        reply = self._q.get(timeout=self.timeout_ms / 1000 + 5)
        return reply.get("result", reply.get("error", ""))

    def close(self):
        try:
            self._proc.stdin.close()
            self._proc.wait(timeout=5)
        except Exception:
            self._proc.kill()

# Usage
with TightenerBridge() as t:
    print(t.eval("app.name"))
    print(t.eval("app.documents.length"))
```

**Overhead**: ~200–500 ms for startup (once), then ~10–50 ms per call (just the round-trip through TightenerGW to InDesign).

**Pros**: persistent connection, structured JSON errors, per-call timeout configurable, works with any language via any callBackID, easy to extend.
**Cons**: requires the new `python_bridge.tql` script to be deployed with the Tightener release.

---

### Strategy 3 — Pure-Python named-pipe connector (no subprocess, no C++)

Locally, sibling Tightener coordinators do **not** go through TightenerGW — they write packets directly into each other's named pipes. Python can speak this transport natively: `os.mkfifo` / `os.open` / `struct.pack` on Mac and Linux, `ctypes`/`pywin32` named pipes on Windows. No Tightener subprocess, no C++ build, no GW required.

#### Pipe location and naming

Each coordinator owns one read pipe:

- **Mac/Linux**: a FIFO at `~/Library/Application Support/net.tightener/NamedPipes/<coordinatorName>` (Linux: the equivalent user-data dir), created with `mkfifo`.
- **Windows**: a message-mode named pipe `\\.\pipe\<full-pipe-folder-path><coordinatorName>` (the raw name embeds the filesystem-style path; see `TghPipes.h` line 84). A small "proxy INI file" is written at the filesystem path recording `namedPipeProxyPath` and `processId`.

To send to InDesign, open its pipe for writing (e.g. `.../NamedPipes/net.tightener.coordinator.indesign.18.0`). To receive the reply, create your own FIFO named after your coordinator name **before** sending — InDesign's reply is written into it.

#### Packet format

Every write is one packet of at most `PIPE_PACKET_SIZE` bytes (= `PIPE_BUF`: **512 on macOS**, 4096 on Linux/Windows). Packets ≤ `PIPE_BUF` are atomic on POSIX FIFOs, which is what allows multiple writer processes to share one FIFO — the reader demultiplexes by process id + sequence numbers.

```
Offset  Size  Field                  (native byte order, little-endian in practice)
0       8     fStringSequenceNumber  per-writer counter, same for all packets of one message
8       8     fPacketSequenceNumber  0, 1, 2, ... within the message
16      4     fProcessId             sender pid
20      2     fDataSize              number of data bytes in this packet
22      2     fFiller                padding
24      ...   fData                  payload bytes
```

The **first packet** of a message (packetSequenceNumber == 0) begins its data area with a `uint64` giving the total message string length; the message bytes follow. Subsequent packets carry raw continuation bytes.

The message string itself is `IPC_escape(type-prefixed serialized Message)` — the same five-field structure described above (`Message`, sender address, receiver address, opCode, payload). Because IPC escaping replaces every LF with `-n`, the message string contains no raw LF bytes.

#### Python sketch (Mac/Linux)

```python
import os, struct, uuid

PIPE_DIR = os.path.expanduser(
    "~/Library/Application Support/net.tightener/NamedPipes/")
PIPE_BUF = 512          # macOS; use 4096 on Linux
HEADER   = struct.Struct("<QQiHH")   # stringSeq, packetSeq, pid, dataSize, filler

def send_message(target_coordinator: str, message_str: str, string_seq: int):
    """Split an IPC-escaped message string into packets and write them."""
    data = struct.pack("<Q", len(message_str)) + message_str.encode("utf-8")
    fd = os.open(PIPE_DIR + target_coordinator, os.O_WRONLY)
    try:
        max_data = PIPE_BUF - HEADER.size
        packet_seq = 0
        for off in range(0, len(data), max_data):
            chunk = data[off:off + max_data]
            header = HEADER.pack(string_seq, packet_seq, os.getpid(),
                                 len(chunk), 0)
            os.write(fd, header + chunk)     # atomic: len <= PIPE_BUF
            packet_seq += 1
    finally:
        os.close(fd)

def open_reply_pipe(my_coordinator: str) -> int:
    path = PIPE_DIR + my_coordinator
    if not os.path.exists(path):
        os.mkfifo(path, 0o600)
    # O_RDWR keeps the FIFO open even with no other writer yet
    return os.open(path, os.O_RDWR | os.O_NONBLOCK)
```

Receiving is the mirror image: read `PIPE_BUF`-sized chunks, parse headers, group packets by `(pid, stringSequenceNumber)`, concatenate data in `packetSequenceNumber` order, strip the leading `uint64` length, `ipc_unescape`, then split into serializer fields.

A complete `eval_extendscript()` needs the message-building helpers from the [wire protocol details](#wire-protocol-details-for-direct-protocol-implementors) section: build the DATA_REQUEST payload, wrap it in a serialized `Message` with your coordinator as sender and `net.tightener.coordinator.indesign.<version>` as receiver, send it, then wait for the DATA_REPLY packet stream on your own FIFO and match `clientSequenceNr`.

**Overhead**: ~1–5 ms per call. No processes spawned at all.

**Pros**: fastest option short of a C extension; pure Python standard library on Mac/Linux; no Tightener installation needed beyond the running InDesign plug-in; structured matching by sequence number.
**Cons**: reimplements the wire protocol, so it can break if the protocol changes between Tightener releases; Windows needs `pywin32`/ctypes and the proxy-INI dance; you must handle stale FIFOs and cleanup; the protocol details below are reverse-engineered from source and should be validated against live IPC logs (`logIPC = 1`).

> **Validation tip**: run a normal `rre_REPL InDesign` session with `logIPC = 1` in `config.ini` and compare the logged messages byte-for-byte with what your Python connector produces.

---

### Strategy 4 — Native Python C extension (lowest overhead, most effort)

> **Direction chosen (2026-07)**: rather than shipping an extension users must match to their Python version, each Tightener release will bundle a complete per-platform Python distribution with the `tightener` module compiled in. See [TightenerPy_Plan.md](TightenerPy_Plan.md) for the full plan; the notes below remain valid as the technical basis for the module itself.

Wrap `TghInternalCoordinator` in a CPython extension module using [pybind11](https://pybind11.readthedocs.io/en/stable/). The module links Tightener as a static library and exposes the coordinator API as Python objects.

The `TightenerDLL` repo is the best starting point — it already wraps `TghInternalCoordinator` in a C API (the `OP_CODE_*` dispatch loop in `library.cpp`). A pybind11 wrapper would sit at the same level, exposing:

```python
import tightener

coord = tightener.Coordinator("net.tightener.coordinator.python.demo")
coord.connect()                # connects to TightenerGW on port 9888

result = coord.send_data(
    code="app.name\n",
    target="InDesign",
    callback_id="net.tightener.callbackid.commandline.extendscript",
    timeout_ms=20000
)
print(result)   # "Adobe InDesign\n"

coord.disconnect()
```

**Overhead**: sub-millisecond dispatch; no extra process; no subprocess I/O.

**Pros**: fastest possible, full access to Tightener features, natural Python objects.
**Cons**: requires C++ build infrastructure (CMake + pybind11), platform-specific (.so/.pyd), must be rebuilt for each Python version and platform.

#### Build skeleton (macOS/Linux)

```cmake
# CMakeLists.txt (simplified)
find_package(pybind11 REQUIRED)

pybind11_add_module(tightener tightener_py.cpp)
target_link_libraries(tightener PRIVATE TightenerStatic)
```

```cpp
// tightener_py.cpp
#include <pybind11/pybind11.h>
#include "TghCoordinator/TghInternalCoordinator.h"

namespace py = pybind11;

PYBIND11_MODULE(tightener, m) {
    py::class_<TGH::InternalCoordinator>(m, "Coordinator")
        // ... bind sendDataToRemote, connect, disconnect
        ;
}
```

The primary build challenge is that `TghInternalCoordinator` uses internal headers, cooperative multitasking, and has extensive macro machinery. The cleanest path is to expose a thin C API (similar to what `TightenerDLL/library.cpp` does) and then bind that C API to Python.

---

## Comparison

| | Strategy 1 (subprocess/call) | Strategy 2 (bridge process) | Strategy 3 (named pipes) | Strategy 4 (C extension) |
|---|---|---|---|---|
| Per-call overhead | ~300 ms | ~15 ms | ~1–5 ms | <1 ms |
| New code required | none | 1 TQL file + 50 lines Python | ~300 lines Python | C++ binding module |
| Protocol knowledge needed | none | none | deep | deep |
| Structured errors | no | yes (JSON) | yes | yes |
| Per-call timeout | no | yes | yes | yes |
| Streaming output | no | possible | yes | yes |
| Platform build step | no | no | no (Mac/Linux) | yes |
| Works on Windows | yes | yes | yes (pywin32/ctypes) | yes (with MSVC) |
| Survives protocol changes | yes | yes | no | recompile |

**Recommended path**: implement Strategy 2 first. It is almost entirely Python, requires only one small TQL file, uses only supported public behaviour, and the per-call latency is acceptable for all scripting use cases. Strategy 3 (pure-Python named pipes) is the most attractive long-term "native connector" — no build step, lowest practical latency — but it couples the connector to the internal wire protocol, so it should be built alongside a protocol conformance test (compare against `logIPC = 1` output) and treated as release-version-specific until the protocol is declared stable. Strategy 4 is worth pursuing only if sub-millisecond dispatch or asynchronous Tightener event delivery into Python is required.

---

## Wire protocol details (for direct-protocol implementors)

### Address type structure

`LocalUnresolvedAddress` serializes as three SimpleSerializer fields:

```
"LocalUnresolvedAddress"  (type name)
"net.tightener.coordinator.indesign.18.0"  (coordinatorName)
"main"  (indices / engine name)
```

### Complete DATA_REQUEST message on the wire

For Python coordinator `net.tightener.coordinator.python.abc123` sending ExtendScript `app.name\n` to InDesign with `clientSequenceNr=1`, the serialized message (before IPC escaping) is:

```
"Message\n"
"LocalUnresolvedAddress\n"
"net.tightener.coordinator.python.abc123\n"
"main\n"
"LocalUnresolvedAddress\n"
"net.tightener.coordinator.indesign.18.0\n"
"main\n"
"15\n"
ser_escape({"callBackID":"net.tightener.callbackid.commandline.extendscript", "clientSequenceNr":1, "data":"app.name\n"}) + "\n"
```

Where `ser_escape` means backslash-escaping `"` → `\"`, `\` → `\\`, LF → `\n`, etc. (Every field, including the fixed ones, passes through `ser_escape`; the ones shown literal contain no escapable characters.)

The IPC-escaped form of this string then goes onto the transport:

- **TCP (via GW)**: `ipc_escape(serialized) + "\r"`
- **Named pipe**: `uint64 length + ipc_escape(serialized)`, split into header-prefixed packets (see Strategy 3)

### Escaping helper (Python reference implementation)

```python
def ipc_escape(s: str) -> str:
    return s.replace('-', '--').replace('\n', '-n').replace('\x00', '-z')

def ipc_unescape(s: str) -> str:
    out, i = [], 0
    while i < len(s):
        if s[i] == '-' and i + 1 < len(s):
            c = s[i+1]
            if   c == '-': out.append('-');   i += 2
            elif c == 'n': out.append('\n');  i += 2
            elif c == 'z': out.append('\x00'); i += 2
            else:          out.append(s[i]);  i += 1
        else:
            out.append(s[i]); i += 1
    return ''.join(out)

_SER_ESCAPE = {
    '\x00': '\\z', '\x01': '\\S', '\x02': '\\s', '\x03': '\\e',
    '\x04': '\\E', '\x05': '\\T', '\x06': '\\A', '\x07': '\\b',
    '\x08': '\\<', '\x09': '\\t', '\x0A': '\\n', '\x0B': '\\V',
    '\x0C': '\\f', '\x0D': '\\r', '\x0E': '\\O', '\x0F': '\\I',
    '\x10': '\\L', '\x11': '\\1', '\x12': '\\2', '\x13': '\\3',
    '\x14': '\\4', '\x15': '\\K', '\x16': '\\Y', '\x17': '\\P',
    '\x18': '\\D', '\x19': '\\R', '\x1A': '\\C', '\x1B': '\\!',
    '\x1C': '\\U', '\x1D': '\\F', '\x1E': '\\W', '\x1F': '\\X',
    '"':  '\\"', "'": "\\'", '\\': '\\\\',
}

def ser_escape(s: str) -> str:
    return ''.join(_SER_ESCAPE.get(c, c) for c in s)

def ser_unescape(s: str) -> str:
    _REV = {v[1]: k for k, v in _SER_ESCAPE.items() if len(v) == 2}
    out, i = [], 0
    while i < len(s):
        if s[i] == '\\' and i + 1 < len(s):
            out.append(_REV.get(s[i+1], s[i+1])); i += 2
        else:
            out.append(s[i]); i += 1
    return ''.join(out)

def ser_put_string(s: str) -> bytes:
    return (ser_escape(s) + '\n').encode('utf-8')

def make_message(sender_coord: str, receiver_coord: str,
                 opcode: int, payload: str,
                 sender_index: str = "main",
                 receiver_index: str = "main") -> str:
    """Build the IPC-escaped serialized Message string.

    For TCP transport append '\r'; for the named-pipe transport prepend the
    uint64 length and packetize (see Strategy 3).
    """
    body = (
        ser_put_string("Message") +
        ser_put_string("LocalUnresolvedAddress") +
        ser_put_string(sender_coord) +
        ser_put_string(sender_index) +
        ser_put_string("LocalUnresolvedAddress") +
        ser_put_string(receiver_coord) +
        ser_put_string(receiver_index) +
        ser_put_string(str(opcode)) +
        ser_put_string(payload)
    )
    return ipc_escape(body.decode('utf-8'))
```

### TQL stringify format for DATA_REQUEST payload

TQL's `stringify()` for a map produces JSON-compatible output: `{"key":"value", "key2":42}`. String values use `\"` inside double quotes; embedded LF in the data is `\n` (two chars). The payload for ExtendScript code `code` is:

```python
import json

def make_data_request_payload(code: str, seq: int,
    callback_id: str = "net.tightener.callbackid.commandline.extendscript") -> str:
    # TQL stringify produces JSON-compatible output for basic types
    return json.dumps({"callBackID": callback_id,
                       "clientSequenceNr": seq,
                       "data": code + "\n"},
                      separators=(", ", ":"))
```

> **Note**: TQL `stringify()` uses `", "` (comma-space) between entries and no space around `:`. Confirm against live IPC logs before relying on this in a production connector.
