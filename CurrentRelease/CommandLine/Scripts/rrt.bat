@ECHO off

SETLOCAL EnableDelayedExpansion

REM
REM Remotely run a locally stored TQL script.
REM
REM e.g.
REM
REM rrt tgh://127.0.0.1/net.tightener.coordinator.reflector/default hello.tql
REM rrt tgh://sandy.rorohiko.com/net.tightener.coordinator.indesign.17.0/main hello.tql
REM

IF "%1" == "" (
    ECHO Usage:
    ECHO   rrt target scriptPath [ quitDelayMilliseconds ]
    ECHO.
    GOTO DONE
)

SET TIMEOUT_MS=%TIGHTENER_DEFAULT_RR_TIMEOUT_MS%

REM
REM If responses are expected, we need to wait a bit to receive them
REM If we quit too soon, the response will vanish into the bit bucket
REM

IF "%3" == "" (
    SET QUIT_DELAY_MS=%TIGHTENER_DEFAULT_RR_QUIT_DELAY_MS%%
) ELSE (
    SET QUIT_DELAY_MS=%3
)


IF NOT EXIST "%2" (
    ECHO Script file %2 does not exist
    GOTO DONE
)

Tightener -N scriptrunner -r "%1" -o %TIMEOUT_MS% -w !QUIT_DELAY_MS! -t n -f "%2"

:DONE