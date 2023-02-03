@ECHO off

SETLOCAL EnableDelayedExpansion

REM
REM Interactively run UXPScript commands
REM
REM rru_REPL <target> 
REM
REM e.g.
REM
REM rru_REPL indesign 
REM rru_REPL tgh://freddy/indesign/main
REM rru_REPL tgh://sandy.rorohiko.com/net.tightener.coordinator.indesign.17.0/main
REM rru_REPL tgh://sandy.rorohiko.com/net.tightener.coordinator.indesign.17.0.configuration_noport/main
REM

IF "%1" == "" (
    ECHO Usage:
    ECHO   rru_REPL target 
    ECHO.
    GOTO DONE
)

SET RRU_REMOTE_URL=%1
SET TIMEOUT_MS=%TIGHTENER_DEFAULT_REPL_TIMEOUT_MS%
SET QUIT_DELAY_MS=%TIGHTENER_DEFAULT_REPL_QUIT_DELAY_MS%

FOR /f "usebackq tokens=*" %%A in (`powershell -Command "[guid]::NewGuid().ToString()"`) DO SET RRU_REPL_SESSION_ID=%%A
SET RRU_REPL_SESSION_ID=%RRU_REPL_SESSION_ID:-=%
SET COORDINATOR_NAME=net.tightener.coordinator.console.%RRU_REPL_SESSION_ID%

ECHO Starting rru_REPL.tql. Enter 'quit()' to terminate the REPL loop.

REM -n <long>  : long coordinator name
REM -I         : read standard stdin 
REM -t n       : no tests to be run
REM -f <path>  : process script

Tightener -n %COORDINATOR_NAME% -o %TIMEOUT_MS% -w %QUIT_DELAY_MS% -I -t n -f "%TIGHTENER_SCRIPTS%rru_REPL.tql"

ECHO Done.

:DONE


