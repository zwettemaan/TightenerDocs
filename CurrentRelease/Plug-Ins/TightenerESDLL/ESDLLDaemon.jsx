//@include "TightenerESDLLLoader.jsx"

var coordinatorSuffix = app.name.replace(/ /g,"").toLowerCase();

TIGHTENER.init("net.tightener.coordinator." + coordinatorSuffix);
TIGHTENER.run(TIMESLICE_RUN_TO_COMPLETION);