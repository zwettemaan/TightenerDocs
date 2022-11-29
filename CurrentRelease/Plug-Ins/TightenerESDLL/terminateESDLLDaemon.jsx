//
// terminateESDLLDaemon.jsx
//
// This script tells the ESDLL daemon to stop looping
//
// Run with rre using the local scriptrunner, or run it 
// with evalExtendScript from a TQL script
//
/****

rre Illustrator terminateDaemon.jsx
rre ExtendScriptToolkit terminateDaemon.jsx
      
*****/

TIGHTENER.exitRunLoop = true;