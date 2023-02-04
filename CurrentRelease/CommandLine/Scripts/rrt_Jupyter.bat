@ECHO off

SETLOCAL EnableDelayedExpansion

REM
REM Interactively run ExtendScript commands for a Jupyter Notebook Kernel
REM

IF "%1" == "" (
    ECHO Usage:
    ECHO   rrt_Jupyter target prompt continuationPrompt
    ECHO.
    GOTO DONE
)

SET RRT_REMOTE_URL=%1
SET RRT_PROMPT=%2
SET RRT_PROMPT_CONTINUATION=%3

FOR /f "usebackq tokens=*" %%A in (`powershell -Command "[guid]::NewGuid().ToString()"`) DO SET RRT_JUPYTER_SESSION_ID=%%A
SET RRT_JUPYTER_SESSION_ID=%RRE_JUPYTER_SESSION_ID:-=%
SET COORDINATOR_NAME=net.tightener.coordinator.kernelconsole.%RRT_JUPYTER_SESSION_ID%
SET RRT_1LINE=

REM -n <long>  : long coordinator name
REM -I         : read standard stdin 
REM -t n       : no tests to be run
REM -z         : ignore SIGINT signals
REM -f <path>  : process script

Tightener -N %COORDINATOR_NAME% -I -t n -z -f "%TIGHTENER_SCRIPTS%rrt_REPL.tql"

ECHO Done.

:DONE


