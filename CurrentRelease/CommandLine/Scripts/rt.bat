@ECHO off

REM Locally run TQL script

SETLOCAL EnableDelayedExpansion

IF "%1" == "" (
    ECHO Usage:
    ECHO   rt scriptPath [ quitDelayMilliseconds ]
    ECHO.
    GOTO DONE
)

IF NOT EXIST "%1" (
    ECHO Script file %1 does not exist
    GOTO DONE
)

REM
REM If responses are expected, we need to wait a bit to receive them
REM If we quit too soon, the response will vanish into the bit bucket
REM

IF "%2" == "" (
    SET QUIT_DELAY_MS=500
) ELSE (
    SET QUIT_DELAY_MS=%2
)

FOR /f "usebackq tokens=*" %%A in (`powershell -Command "[guid]::NewGuid().ToString()"`) DO SET RT_SESSION_ID_RAW=%%A
SET RT_SESSION_ID=%RT_SESSION_ID_RAW:-=%
SET COORDINATOR_NAME=net.tightener.coordinator.scriptrunner.RT.%RT_SESSION_ID%

Tightener -n %COORDINATOR_NAME% -t n -w !QUIT_DELAY_MS! -f "%1"

:DONE