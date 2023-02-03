@ECHO off

SETLOCAL EnableDelayedExpansion

REM
REM Interactively run ExtendScript commands for a Jupyter Notebook Kernel
REM

IF "%1" == "" (
    ECHO Usage:
    ECHO   rre_Jupyter target 
    ECHO.
    GOTO DONE
)

SET RRE_REMOTE_URL=%1

FOR /f "usebackq tokens=*" %%A in (`powershell -Command "[guid]::NewGuid().ToString()"`) DO SET RRE_JUPYTER_SESSION_ID=%%A
SET RRE_JUPYTER_SESSION_ID=%RRE_JUPYTER_SESSION_ID:-=%
SET COORDINATOR_NAME=net.tightener.coordinator.kernelconsole.%RRE_JUPYTER_SESSION_ID%

REM -n <long>  : long coordinator name
REM -I         : read standard stdin 
REM -t n       : no tests to be run
REM -z         : ignore SIGINT signals
REM -f <path>  : process script

Tightener -n %COORDINATOR_NAME% -I -t n -z -f "%TIGHTENER_SCRIPTS%rre_REPL.tql"

ECHO Done.

:DONE


