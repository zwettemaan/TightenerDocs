@ECHO off

SETLOCAL EnableDelayedExpansion

REM
REM Interactively run ExtendScript commands for a Jupyter Notebook Kernel
REM

IF "%1" == "" (
    ECHO Usage:
    ECHO   rru_Jupyter target prompt continuationPrompt
    ECHO.
    GOTO DONE
)

SET RRU_REMOTE_URL=%1
SET RRU_PROMPT=%2
SET RRU_PROMPT_CONTINUATION=%3

FOR /f "usebackq tokens=*" %%A in (`powershell -Command "[guid]::NewGuid().ToString()"`) DO SET RRU_JUPYTER_SESSION_ID_RAW=%%A
SET RRU_JUPYTER_SESSION_ID=%RRU_JUPYTER_SESSION_ID_RAW:-=%
SET COORDINATOR_NAME=net.tightener.coordinator.kernelconsole.RRU.%RRU_JUPYTER_SESSION_ID%
SET RRU_1LINE=

SET TIMEOUT_MS=%TIGHTENER_DEFAULT_REPL_TIMEOUT_MS%
SET QUIT_DELAY_MS=%TIGHTENER_DEFAULT_REPL_QUIT_DELAY_MS%

REM -n <long>  : long coordinator name
REM -I         : read standard stdin 
REM -t n       : no tests to be run
REM -z         : ignore SIGINT signals
REM -f <path>  : process script

Tightener -n %COORDINATOR_NAME% -I -t n -z -o %TIMEOUT_MS% -w %QUIT_DELAY_MS% -f "%TIGHTENER_SCRIPTS%rru_REPL.tql"

ECHO Done.

:DONE


