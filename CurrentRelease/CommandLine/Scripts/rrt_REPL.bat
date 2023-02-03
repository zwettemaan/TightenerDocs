@ECHO off

SETLOCAL EnableDelayedExpansion

REM
REM Interactively run TQL commands
REM
REM rrt_REPL <target> 
REM
REM e.g.
REM
REM rrt_REPL indesign 
REM rrt_REPL tgh://freddy/indesign/main
REM rrt_REPL tgh://sandy.rorohiko.com/net.tightener.coordinator.indesign.17.0/main
REM rrt_REPL tgh://sandy.rorohiko.com/net.tightener.coordinator.indesign.17.0.configuration_noport/main
REM

IF "%1" == "" (
    ECHO Usage:
    ECHO   rrt_REPL target 
    ECHO.
    GOTO DONE
)

SET RRT_REMOTE_URL=%1
SET TIMEOUT_MS=%TIGHTENER_DEFAULT_REPL_TIMEOUT_MS%
SET QUIT_DELAY_MS=%TIGHTENER_DEFAULT_RR_QUIT_DELAY_MS%

FOR /f "usebackq tokens=*" %%A in (`powershell -Command "[guid]::NewGuid().ToString()"`) DO SET RRT_REPL_SESSION_ID=%%A
SET RRT_REPL_SESSION_ID=%RRT_REPL_SESSION_ID:-=%
SET COORDINATOR_NAME=net.tightener.coordinator.console.%RRT_REPL_SESSION_ID%

ECHO Starting rrt_REPL.tql. Enter 'quit()' to terminate the REPL loop.

REM -n <long>  : long coordinator name
REM -I         : read standard stdin 
REM -t n       : no tests to be run
REM -f <path>  : process script

Tightener -n %COORDINATOR_NAME% -o %TIMEOUT_MS% -w %QUIT_DELAY_MS% -I -t n -f "%TIGHTENER_SCRIPTS%rrt_REPL.tql"

ECHO Done.

:DONE


