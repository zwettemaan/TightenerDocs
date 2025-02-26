//@include "lib/TightenerESDLLLoader.jsx"

TIGHTENER.init();

TIGHTENER.lib.tghInit('ESDLLSampleCoordinator');

var WASTE_TIME_LOOPS = 500;
var PROBE_LOOPS = 1000;

var timeLog = [];
var loopIdx = 0;

var cumulativeTime = 0;

// Use globals to reduce memory pressure
var x;
var y;
var idx;
var entry;
var curSample;
var f;
var computationChecksum = 0;

var prv = 0;
function hiresTimer() {
    var clock =TIGHTENER.lib.tghHiresClock();
    var retVal = clock - prv;
    prv = clock;
    return retVal;
}

function sampleTime() {

    curSample = hiresTimer();
    cumulativeTime += curSample;
    entry = timeLog[loopIdx];
    entry.timeStamp = cumulativeTime;
    entry.timeSpent =  curSample;
    entry.computationChecksum = computationChecksum;


}

function wasteTime() {

    var localComputationChecksum = 0;
    x = 1;
    for (wasteIdx = 0; wasteIdx < WASTE_TIME_LOOPS; wasteIdx++) {
        x = Math.sin(Math.cos(x));
        y = Math.abs(x * x * x);
        while (y < 1.0) {
            y += y;         
        }
        x = y;
        localComputationChecksum += x;
    }

    computationChecksum = localComputationChecksum;

    sampleTime();
}

alert("Pre-allocating logging table");

// Pre-allocate the logging data structure
for (loopIdx = 0; loopIdx < PROBE_LOOPS; loopIdx++) {
    timeLog.push({
        timeStamp: -1,
        timeSpent: -1,
        computationChecksum: -1
    });
}

$.gc();

alert("Logging table allocated");

hiresTimer(); // Reset timer


for (loopIdx = 0; loopIdx < PROBE_LOOPS; loopIdx++) {
    wasteTime();
}

var f = File("C:\\Users\\Administrator\\Desktop\\timeLog.txt");
f.open("w");
for (loopIdx = 0; loopIdx < PROBE_LOOPS; loopIdx++) {
    entry = timeLog[loopIdx];  
    f.writeln(entry.timeStamp + "\t" + entry.timeSpent + "\t" + entry.computationChecksum);
}
f.close();