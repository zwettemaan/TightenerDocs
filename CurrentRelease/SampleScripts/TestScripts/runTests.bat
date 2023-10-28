@ECHO off

SETLOCAL EnableDelayedExpansion

killApps

CALL "%TIGHTENER_RELEASE_ROOT%SampleScripts\TestScripts\copyDebugConfig.bat"

SET TIGHTENER_TEST_SCRIPTS=%~dp0

START Tightener -N scriptrunner -t n -w 10000 -f reflector.tql

REM Sleep for 1 seconds
ping -n 1 127.0.0.1 > NUL

START Tightener -N scriptrunner2 -t n -w 10000 -f reflector2.tql
START Tightener -N scriptrunner3 -t n -w 10000 -f reflector3.tql
