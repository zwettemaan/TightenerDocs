@ECHO off

SETLOCAL EnableDelayedExpansion

REM
REM Interactively run UXPScript commands
REM
REM rru_REPL <target> [ "<UXPScriptCommand>" [quitDelayMS] ]
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
    ECHO   rru_REPL target [ "uxpCommand" [ quitDelayMS] ]
    ECHO.
    GOTO DONE
)

IF "%~2" == "" (
    ECHO Starting rru_REPL.tql. Enter 'quit' to terminate the REPL loop.
    SET SWITCH_STDIN=-I
    SET RRU_1LINE=
    SET TIMEOUT_MS=%TIGHTENER_DEFAULT_REPL_TIMEOUT_MS%
    SET QUIT_DELAY_MS=%TIGHTENER_DEFAULT_REPL_QUIT_DELAY_MS%
) ELSE (
    SET SWITCH_STDIN=
    SET RRU_1LINE=%~2
    SET TIMEOUT_MS=%TIGHTENER_DEFAULT_RR_TIMEOUT_MS%
    IF "%3" == "" (
        SET QUIT_DELAY_MS=%TIGHTENER_DEFAULT_RR_QUIT_DELAY_MS%
    ) ELSE (
        SET QUIT_DELAY_MS=%3
    )
)

SET RRU_REMOTE_URL=%1
SET TIMEOUT_MS=%TIGHTENER_DEFAULT_REPL_TIMEOUT_MS%
SET QUIT_DELAY_MS=%TIGHTENER_DEFAULT_RR_QUIT_DELAY_MS%

FOR /f "usebackq tokens=*" %%A in (`powershell -Command "[guid]::NewGuid().ToString()"`) DO SET RRU_REPL_SESSION_ID=%%A
SET RRU_REPL_SESSION_ID=%RRU_REPL_SESSION_ID:-=%
SET COORDINATOR_NAME=net.tightener.coordinator.console.%RRU_REPL_SESSION_ID%

REM -n <long>  : long coordinator name
REM -I         : read standard stdin 
REM -t n       : no tests to be run
REM -f <path>  : process script

Tightener -n %COORDINATOR_NAME% -o %TIMEOUT_MS% -w %QUIT_DELAY_MS% %SWITCH_STDIN% -t n -f "%TIGHTENER_SCRIPTS%rru_REPL.tql"

IF "%~2" == "" (
    ECHO Done.
)

:DONE


