# TQL Master Document

TQL is the Tightener Query Language, pronounced "Tickle". It is the small language embedded in Tightener for asking another Tightener node to do work close to the data and object model it owns.

This document is the working master for TQL: philosophy, syntax, runtime model, deliberate omissions, and compatibility promises. It should stay practical. TQL is not trying to win language-design arguments; it is trying to make creative-app automation reliable for people who should not have to become systems programmers before they can ship a workflow.

## Why TQL Exists

Tightener is built around nodes interacting and exchanging data. A node can live inside InDesign, a command-line process, a Python process, a future Scribus integration, or another host. TQL lets one node send a compact script/query to another node, run it near the target object model, and return data without constant network ping-pong.

The first concrete pressure is Adobe automation. ExtendScript has been useful for a long time, but when issues crop up and Adobe does not fix them, Tightener needs an escape route that does not depend on a dormant external runtime. TQL is that route: a built-in, C++-implemented language for orchestration, queries, and host object model access.

The larger goal is to replace BridgeTalk-style creative-app messaging with a Tightener network where multiple nodes cooperate. InDesign should be able to talk to other InDesign nodes, Python, command-line helpers, and other publishing/creative applications such as Scribus through the same conceptual model.

## Design Philosophy

TQL is simple on purpose. The primary user may be a production artist, prepress operator, layout automation specialist, or technical designer rather than a full-time developer. The language should make common automation tasks readable and debuggable.

TQL has no external language runtime dependency. A Tightener node should not need JavaScriptCore, Node, Python, Lua, or another engine just to evaluate TQL. This keeps node behavior predictable and reduces the chance that outside libraries change the meaning, security surface, or deployability of a workflow.

TQL is cooperative. Long-running work is split into tasks and explicit yield points so hosts such as InDesign can remain responsive and can enforce their threading restrictions. Code yields at known points instead of being interrupted unpredictably.

TQL avoids exceptions as a user-facing control-flow mechanism. Errors should be values that can be returned, logged, inspected, or propagated through ordinary code paths. There is no `try`/`catch` alternate universe hidden beside the main flow.

TQL is expression-oriented. Many constructs parse down into expressions and expression sequences. Blocks, loops, returns, function calls, and object model access are represented in the same object model machinery rather than as a large separate statement runtime.

TQL is not JavaScript. It borrows familiar surface syntax because that lowers the learning curve, but it deliberately avoids JavaScript's more surprising machinery.

## Deliberate Non-Goals

TQL should not grow prototypes, prototype inheritance, `this` binding tricks, hoisting puzzles, dynamic module systems, or ambient package loading.

TQL should not allow arbitrary external code to redefine the language. Host integrations may expose object model nodes and built-ins, but the language core should remain under Tightener control.

TQL should not require thread synchronization concepts from script authors. Users should not have to reason about locks, mutexes, races, or which OS thread is currently executing a timeslice.

TQL should not use `try`/`catch`. A missing host property, failed file access, invalid selector, or unavailable remote node should result in an error value or ordinary failure return rather than a second hidden execution path.

TQL should not become a general replacement for Python or C++. It is an orchestration and query language for creative automation networks.

## Runtime Model

A TQL script runs inside a Tightener node. The node provides a scope, built-in functions, and optionally a host object model. InDesign nodes expose InDesign objects; other nodes can expose their own data and capabilities.

Evaluation is task-based and yielding. The implementation uses yielding parser/evaluator functions and Tightener tasks so a script can suspend and resume across timeslices.

Only one Tightener timeslice should be executing in a protected host context at a time, but the hosting thread may change between timeslices. This is important for InDesign and other hosts with thread-sensitive APIs.

Remote orchestration should prefer sending compact TQL work to the node that owns the object model, then returning values. This avoids slow back-and-forth access patterns such as "get object, ask for property, ask for child, ask for property".

## Data Model

The core object model currently includes these value categories:

- `undefined`
- `null`
- booleans
- integers
- floating-point numbers
- strings
- arrays
- maps/objects
- expressions
- functions
- error values
- `NaN`
- GUID values
- host object model nodes whose type may not be knowable cheaply

Arrays use square brackets:

```tql
[1, 2, "three"]
```

Maps/objects use curly braces and colon-separated properties:

```tql
{
    name: "Cover",
    page: 1,
    visible: true
}
```

Property names may be bare identifiers or quoted strings:

```tql
{
    title: "Catalog",
    "trim size": "A4"
}
```

`{}` has a contextual quirk: where the parser is expecting an expression list or block, an empty pair of braces may be interpreted as an empty scope/expression list; where it is expecting a value, it is an empty map. This is a consequence of TQL using JavaScript-like syntax while keeping parsing compact.

## Comments and Whitespace

Whitespace is generally insignificant.

Line comments and block comments are supported:

```tql
// line comment

/*
    block comment
*/
```

In console-style input, a newline can terminate a complete top-level expression.

## Strings and Here Documents

Single-quoted and double-quoted strings are supported:

```tql
'single quoted'
"double quoted"
```

Backslash escapes are collected and decoded by Tightener string utilities.

Here documents are supported with a `<<` introducer and an identifier terminator:

```tql
<< END
This is a multi-line string.
END
```

The terminator must appear at the start of a line. This is useful for embedding longer snippets, messages, or template data without heavy escaping.

## Expressions and Operators

TQL supports familiar expression operators:

- indexing: `value[index]`
- member access: `value.property`
- function calls: `name(arg1, arg2)`
- unary `+`, `-`, `!`, `~`, `typeof`, pre/post increment and decrement
- arithmetic `*`, `/`, `%`, `+`, `-`
- shifts `<<`, `>>`
- comparisons `<`, `<=`, `>`, `>=`
- equality `==`, `!=`, `===`, `!==`
- bitwise `&`, `^`, `|`
- boolean `&&`, `||`
- conditional `condition ? a : b`
- assignment `=`
- comma and semicolon expression sequencing

Assignment is right-to-left. Most other binary operators are left-to-right according to the implementation's precedence order.

TQL has an expression sequence concept. Semicolons generally mean "do this, then that". Commas can also sequence expressions in contexts where the parser allows it.

## Variables and Scope

`var` declares local variables:

```tql
var count = 0;
```

Functions scan their bodies for local variables so locals can be known as part of the function signature/expression. This is another place where TQL resembles JavaScript on the surface but keeps its own implementation model underneath.

`this` and `arguments` exist as reserved/special names in the object model. Their exact behavior depends on evaluation context and host integration.

## Control Flow

`if`/`else` is supported:

```tql
if (condition) {
    output("yes");
} else {
    output("no");
}
```

`while`, `do`/`while`, and `for` are supported:

```tql
while (keepGoing) {
    yield();
}

do {
    count = count + 1;
} while (count < 10)

for (var i = 0; i < items.length; i = i + 1) {
    output(items[i]);
}
```

`break` is supported. `return` wraps a function return value rather than throwing or unwinding through exception machinery:

```tql
function label(x) {
    return "Item " + x;
}
```

## Functions

Named and anonymous functions are supported:

```tql
function add(a, b) {
    return a + b;
}

var double = function(x) {
    return x * 2;
};
```

Functions are values in the object model. They are intentionally simpler than JavaScript functions: no prototypes, no constructor pattern, and no external module loader.

## Object Model Access

TQL lvalues can access object properties, array indices, dynamic indices, and calls:

```tql
document.pages[0].textFrames.item(0)
```

Host integrations decide what a property or method means. For example, the InDesign integration can expose InDesign collections and support collection-style access such as `length`, `item`, `itemByName`, and `itemByID`.

Some host object model nodes cannot determine their type without actually touching the host API. TQL has a `CannotDetermineQuickly` type for that situation so traversal can defer expensive or unsafe access until needed.

## Built-In Functions

Core built-ins include:

- math and conversion: `abs`, `sqr`, `sqrt`, `parseInt`, `parseFloat`, `isNaN`, `toString`
- strings: `substr`, `indexOf`, `toLowerCase`, `toUpperCase`, `enquote`
- arrays/maps: `push`, `pop`, `keys`, `length`, `size`, `stringify`
- files and directories: `readFile`, `writeFile`, `fileOpen`, `fileRead`, `fileWrite`, `fileClose`, `fileExists`, `fileCopy`, `fileDelete`, `dirExists`, `dirCreate`, `dirDelete`, `dirScan`
- paths and environment: `parentPath`, `pathSegmentFromLeft`, `pathSegmentFromRight`, `getEnv`, `scriptFilePath`, `sysInfo`
- evaluation: `eval`, `evalGlobal`, `evalScript`, `parseScript`
- streams/logging: `stdIn`, `stdOut`, `stdErr`, `output`, `logTrace`, `logNote`, `logWarning`, `logError`, `logMessage`
- orchestration/data: `yield`, `sendData`, `setDataRequestCallBack`, `makeLocalFileDataPayload`, `resolveDataPayload`, `reference`
- process/control: `exit`, `quit`

Some builds add plugin-installer or licensing-related built-ins such as encryption, persistence, capability, sublicensing, machine GUID, and certificate helpers. Those should be documented as build-specific extensions, not assumed to be universal TQL.

## Errors

TQL prefers error values over exceptions. The object model has an `Error` type, and host integrations can return error nodes for unknown properties, failed calls, unavailable data, or invalid requests.

This keeps execution visible. A script can return an error, serialize it, log it, pass it to a caller, or branch on it using normal language constructs. There is no `try`/`catch`.

Guideline for implementers: if a user script can reasonably recover, return an error value. Reserve parser failure or task failure for malformed code or internal conditions where evaluation cannot continue.

## Cooperative Multitasking

`yield()` is a first-class idea in TQL because creative applications must stay responsive and often require all object-model access to happen at controlled points.

Script authors should use `yield()` in loops that may run for a long time:

```tql
for (var i = 0; i < pages.length; i = i + 1) {
    processPage(pages[i]);
    yield();
}
```

The user-level promise is simple: scripts cooperate so the host application and other Tightener tasks get time to run. The implementation-level promise is stricter: yielding happens at known safe points, avoiding the unpredictability of preemptive script interruption.

## Networking and Node Orchestration

TQL should be the language for asking another node to do a meaningful chunk of work. A caller should send intent, not a hundred tiny property requests.

Good remote pattern:

```tql
var frames = app.activeDocument.textFrames;
var result = [];
for (var i = 0; i < frames.length; i = i + 1) {
    result.push(frames[i].contents);
}
result
```

Poor remote pattern:

```text
caller asks for textFrames
caller asks for length
caller asks for frame 0
caller asks for contents
caller asks for frame 1
...
```

The first pattern lets the host node use local object model access and send back a compact result. This is the core replacement idea for BridgeTalk-style orchestration.

## Quirks To Preserve Or Document Carefully

TQL is JavaScript-like, not JavaScript-compatible. Avoid documenting syntax by saying "same as JavaScript" unless it has been verified in the parser and evaluator.

Curly braces are contextual: block/scope and map/object syntax overlap.

Newlines can terminate console input when the parser has a complete top-level expression.

Errors are values, but parse failures are still failures. This distinction matters for tooling.

Host object model access can be lazy or expensive. Some types are unknowable without access.

Build-specific built-ins exist. Documentation should separate core TQL from optional extension sets.

No external dependency should be able to redefine TQL semantics.

No `try`/`catch`, prototypes, classes, imports, `new`, promises, async/await, or user-visible thread synchronization should be added without a deliberate design review.

## Documentation TODO

- Verify every operator with parser tests and add examples.
- Document truthiness and conversion rules.
- Document exact string escape behavior from `Utils::decodeString`.
- Document the shape of error values and recommended inspection helpers.
- Document built-in signatures and return values.
- Split core built-ins from plugin-installer build extensions.
- Add InDesign object model examples: collections, `item`, `itemByName`, `itemByID`, `length`, and error-return behavior.
- Add remote-node examples using `sendData`, callbacks, and local file data payloads.
- Add examples for replacing common ExtendScript and BridgeTalk patterns.
- Decide whether this file should replace or feed `TightenerDocs.wiki/TQL.md`.

