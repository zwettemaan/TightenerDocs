@ECHO off

SETLOCAL EnableDelayedExpansion

REM
REM Interactively run ExtendScript commands for a Jupyter Notebook Kernel
REM

IF "%1" == "" (
    ECHO Usage:
    ECHO   rre_Jupyter target prompt continuationPrompt
    ECHO.
    GOTO DONE
)

SET RRE_REMOTE_URL=%1
SET RRE_PROMPT=%2
SET RRE_PROMPT_CONTINUATION=%3

FOR /f "usebackq tokens=*" %%A in (`powershell -Command "[guid]::NewGuid().ToString()"`) DO SET RRE_JUPYTER_SESSION_ID_RAW=%%A
SET RRE_JUPYTER_SESSION_ID=%RRE_JUPYTER_SESSION_ID_RAW:-=%
SET COORDINATOR_NAME=net.tightener.coordinator.kernelconsole.RRE.%RRE_JUPYTER_SESSION_ID%
SET RRE_1LINE=

SET TIMEOUT_MS=%TIGHTENER_DEFAULT_REPL_TIMEOUT_MS%
SET QUIT_DELAY_MS=%TIGHTENER_DEFAULT_REPL_QUIT_DELAY_MS%

REM -n <long>  : long coordinator name
REM -I         : read standard stdin 
REM -t n       : no tests to be run
REM -z         : ignore SIGINT signals
REM -f <path>  : process script

Tightener -n %COORDINATOR_NAME% -I -t n -z -o %TIMEOUT_MS% -w %QUIT_DELAY_MS% -f "%TIGHTENER_SCRIPTS%rre_REPL.tql"

ECHO Done.

:DONE


