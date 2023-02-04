@ECHO off

SETLOCAL EnableDelayedExpansion

SET TIGHTENER_TEST_SCRIPTS=%~dp0

Tightener -c "%TIGHTENER_TEST_SCRIPTS%reflectorConfig.ini" -N scriptrunner -t n -w 10000 -f reflector.tql &
Tightener -c "%TIGHTENER_TEST_SCRIPTS%reflectorConfig.ini" -N scriptrunner2 -t n -w 10000 -f reflector2.tql &
Tightener -c "%TIGHTENER_TEST_SCRIPTS%reflectorConfig.ini" -N scriptrunner3 -t n -w 10000 -f reflector3.tql &
