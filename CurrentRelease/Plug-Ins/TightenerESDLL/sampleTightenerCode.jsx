//@include "lib/TightenerESDLLLoader.jsx"

TIGHTENER.init();

TIGHTENER.lib.tghInit('ESDLLSampleCoordinator');

alert("Machine GUID = " + TIGHTENER.lib.getMachineGUID());

var e = TIGHTENER.lib.encryptStr("Hello World", "mykey");
alert("Encrypted string = " + e);

var d = TIGHTENER.lib.decryptStr(e, "mykey");
alert("Decrypted string = " + d);

//var c = TIGHTENER.lib.getCapability("c09f0226c1b21909b7415341c1d55a07", "code", "password");
//alert(">" + c + "<");