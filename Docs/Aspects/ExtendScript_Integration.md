# ExtendScript Integration

Tightener is available as an ExtendScript DLL, which makes it very easy to integrate Tightener with any Adobe Creative Cloud
application that supports ExtendScript.

All that is needed is to copy a `lib` folder next to a `.jsx` script file and add a line
```
//@include "lib/TightenerESDLLLoader.jsx"
```
in the script. After that, the Tightener API is available on the `TIGHTENER.lib` object.

For example, you can easily encrypt and decrypt strings using AES by calling functions like 
```
var e = TIGHTENER.lib.encryptStr("Hello World", "mykey");
alert("Encrypted string = " + e);

var d = TIGHTENER.lib.decryptStr(e, "mykey");
alert("Decrypted string = " + d);
```
or access a stable GUID identifier for the current workstation by accessing `TIGHTENER.lib.machineGUID()`
```
alert("Machine GUID = " + TIGHTENER.lib.machineGUID());
```
