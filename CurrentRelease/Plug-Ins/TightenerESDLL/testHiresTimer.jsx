//@include "lib/TightenerESDLLLoader.jsx"

TIGHTENER.init();

TIGHTENER.lib.tghInit('ESDLLSampleCoordinator');

var PROBE_LOOPS = 1000;

var loopIdx;

var prv = 0;
function hiresTimer2() {
    var clock =TIGHTENER.lib.tghHiresClock();
    var retVal = clock - prv;
    prv = clock;
    return retVal;
}

alert("Pre-allocating logging table");

timeLog = [ ];
// Pre-allocate the logging data structure, by doubling in size until enough
for (loopIdx = 0; loopIdx < PROBE_LOOPS; loopIdx++) {
    timeLog.push( { hr: -1,  hr2: -1} );
}

alert("Logging table allocated");

for (loopIdx = 0; loopIdx < PROBE_LOOPS; loopIdx++) {
    $.hiresTimer; // Reset
    hiresTimer2();
    var hr = $.hiresTimer;
    var hr2 = hiresTimer2();
    timeLog[loopIdx] = {
        hr: hr,
        hr2: hr2
     }
}

var f = File("C:\\Users\\Administrator\\Desktop\\testHiresTimer.txt");
f.open("w");
for (loopIdx = 0; loopIdx < PROBE_LOOPS; loopIdx++) {
    entry = timeLog[loopIdx];  
    f.writeln(entry.hr + "\t" + entry.hr2);
}
f.close();
