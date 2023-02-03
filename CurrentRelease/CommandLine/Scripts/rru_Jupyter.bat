@ECHO off

SETLOCAL EnableDelayedExpansion

REM
REM Interactively run ExtendScript commands for a Jupyter Notebook Kernel
REM

IF "%1" == "" (
    ECHO Usage:
    ECHO   rru_Jupyter target 
    ECHO.
    GOTO DONE
)

SET RRU_REMOTE_URL=%1

FOR /f "usebackq tokens=*" %%A in (`powershell -Command "[guid]::NewGuid().ToString()"`) DO SET RRU_JUPYTER_SESSION_ID=%%A
SET RRU_JUPYTER_SESSION_ID=%RRE_JUPYTER_SESSION_ID:-=%
SET COORDINATOR_NAME=net.tightener.coordinator.kernelconsole.%RRU_JUPYTER_SESSION_ID%

REM -n <long>  : long coordinator name
REM -I         : read standard stdin 
REM -t n       : no tests to be run
REM -z         : ignore SIGINT signals
REM -f <path>  : process script

Tightener -N %COORDINATOR_NAME% -I -t n -z -f "%TIGHTENER_SCRIPTS%rru_REPL.tql"

ECHO Done.

:DONE


