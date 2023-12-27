@ECHO off

ECHO View the InDesign application folder

CALL "%TIGHTENER_SCRIPTS%idSetEnv.bat"

explorer "%INDESIGN_APP_ROOT%" > NUL

