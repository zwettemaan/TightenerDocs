//@include "lib/TightenerESDLLLoader.jsx"

TIGHTENER.lib.tghInit("ESDLLCommunicationRegression");

var tqlScript = [
    "result = '';",
    "timeout = 5000;",
    "selfTarget = 'tgh:///' + sysInfo().coordinatorName + '/default';",
    "mainTarget = 'tgh:///net.tightener.coordinator.main/default';",
    "reflectorTarget = 'tgh:///net.tightener.coordinator.reflector/default';",
    "if (eval('13*13', selfTarget, timeout) != 169) { result += ' self'; }",
    "if (eval('12*12', mainTarget, timeout) != 144) { result += ' main'; }",
    "reflectorResult = eval('12*12', reflectorTarget, timeout);",
    "if (reflectorResult != 144) { result += ' reflector'; }",
    "if (reflectorResult == 144) { eval('quit();', reflectorTarget, timeout); }",
    "if (result == '') { result = 'success'; }",
    "result;"
].join("\n");

var result = TIGHTENER.lib.evalTQL(tqlScript);

$.writeln("testCommunication.jsx: " + result);

result;
