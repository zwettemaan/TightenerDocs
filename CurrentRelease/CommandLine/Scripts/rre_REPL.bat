@ECHO off

SETLOCAL EnableDelayedExpansion

REM
REM Interactively run ExtendScript commands
REM
REM rre_REPL <target> [ <JSXCommand> [quitDelayMS] ]
REM
REM e.g.
REM
REM rre_REPL indesign 
REM rre_REPL tgh://freddy/indesign/main
REM rre_REPL tgh://sandy.rorohiko.com/net.tightener.coordinator.indesign.17.0/main
REM rre_REPL tgh://sandy.rorohiko.com/net.tightener.coordinator.indesign.17.0.configuration_noport/main
REM

IF "%1" == "" (
    ECHO Usage:
    ECHO   rre_REPL target [ jsxCommand [ quitDelayMS] ]
    ECHO.
    GOTO DONE
)

IF "%2" == "" (
    ECHO Starting rre_REPL.tql. Enter 'quit' to terminate the REPL loop.
    SET SWITCH_STDIN="-I"
    SET RRE_1LINE=
    SET TIMEOUT_MS=%TIGHTENER_DEFAULT_REPL_TIMEOUT_MS%
    SET QUIT_DELAY_MS=%TIGHTENER_DEFAULT_REPL_QUIT_DELAY_MS%
) ELSE (
    SET SWITCH_STDIN=""
    SET RRE_1LINE=%2
    SET TIMEOUT_MS=%TIGHTENER_DEFAULT_RR_TIMEOUT_MS%
    IF "%3" == "" (
        SET QUIT_DELAY_MS=%TIGHTENER_DEFAULT_RR_QUIT_DELAY_MS%
    ) ELSE (
        SET QUIT_DELAY_MS=%3
    )
)

SET RRE_REMOTE_URL=%1

FOR /f "usebackq tokens=*" %%A in (`powershell -Command "[guid]::NewGuid().ToString()"`) DO SET RRE_REPL_SESSION_ID=%%A
SET RRE_REPL_SESSION_ID=%RRE_REPL_SESSION_ID:-=%
SET COORDINATOR_NAME=net.tightener.coordinator.console.%RRE_REPL_SESSION_ID%

REM -n <long>  : long coordinator name
REM -I         : read standard stdin 
REM -t n       : no tests to be run
REM -f <path>  : process script

Tightener -n %COORDINATOR_NAME% -o %TIMEOUT_MS% -w %QUIT_DELAY_MS% %SWITCH_STDIN% -t n -f "%TIGHTENER_SCRIPTS%rre_REPL.tql"

IF "%RRE_1LINE%" == "" (
    ECHO Done.
)

:DONE


