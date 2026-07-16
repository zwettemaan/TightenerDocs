//@include "lib/TightenerESDLLLoader.jsx"

TIGHTENER.init();

TIGHTENER.lib.tghInit('ESDLLSampleCoordinator');

var tqlResult = TIGHTENER.lib.evalTQL("sysInfo().APP_DIR");
alert("sysInfo().APP_DIR = " + tqlResult);

alert("Machine GUID = " + TIGHTENER.lib.machineGUID());

var e = TIGHTENER.lib.encryptStr("Hello World", "mykey");
alert("Encrypted string = " + e);

var d = TIGHTENER.lib.decryptStr(e, "mykey");
alert("Decrypted string = " + d);

var c = TIGHTENER.lib.hiresClock();
alert(c);
//var c = TIGHTENER.lib.getCapability("c09f0226c1b21909b7415341c1d55a07", "code", "password");
//alert(">" + c + "<");