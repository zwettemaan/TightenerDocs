# eval

`eval(tqlScript [, target [ , callbackFtn [, timeoutMS]]])`

Evaluate a TQL script. If no target is provided, the script is evaluated locally.

If a target is provided (e.g. a remote coordinator), the script is sent there and evaluated there, and the result is received by the callback function.

Example:

```
target = "tgh:///net.tightener.coordinator.reflector/default";
timeOut = 5000;
eval(
    "12*12", 
    target, 
    function(callBackResult) 
    { 
        stdOut(callBackResult); 
    }, 
    timeOut);
```

launches the reflector, evaluates the expression and sends it back to the caller.

Eval can also be used as a method on a scope. 
```
scopeObject.eval(tqlScript[, target [ , callbackFtn [, timeoutMS]]]);
```
Example:
```
{xyz:2}.eval("xyz+2")
```
returns 4. 

The `{xyz:2}` is injected into a new scope (so xyz becomes defined) and then the script is evaluated in that scope.