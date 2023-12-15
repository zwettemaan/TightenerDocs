//@include "TightenerESDLLLoader.jsx"

TIGHTENER.init();

TIGHTENER.lib.tghInit('ESDLLSampleCoordinator');

alert(TIGHTENER.lib.getMachineGUID());

var e = TIGHTENER.lib.encryptStr("Hello World", "mykey");
alert(e);

var d = TIGHTENER.lib.decryptStr(e, "mykey");
alert(d);

var c = TIGHTENER.lib.getCapability("c09f0226c1b21909b7415341c1d55a07", "p2", "password");
alert(">" + c + "<");