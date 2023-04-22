@ECHO off

SETLOCAL EnableDelayedExpansion

REM
REM Remotely run a locally stored UXPScript
REM
REM rru <target> <script> [ <quit_delay_ms> ]
REM
REM e.g.
REM
REM rru indesign hello.idjs 10000
REM rru tgh://freddy/indesign/main hello.idjs
REM rru tgh://sandy.rorohiko.com/net.tightener.coordinator.indesign.17.0/main hello.idjs
REM rru tgh://sandy.rorohiko.com/net.tightener.coordinator.indesign.17.0.configuration_noport/main hello.idjs
REM

IF "%1" == "" (
    ECHO Usage:
    ECHO   rru target extendScriptPath [ quitDelayMilliseconds ]
    ECHO.
    GOTO DONE
)

SET TIMEOUT_MS=%TIGHTENER_DEFAULT_RR_TIMEOUT_MS%

REM
REM If responses are expected, we need to wait a bit to receive them
REM If we quit too soon, the response will vanish into the bit bucket
REM

IF "%3" == "" (
    SET QUIT_DELAY_MS=%TIGHTENER_DEFAULT_RR_QUIT_DELAY_MS%
) ELSE (
    SET QUIT_DELAY_MS=%3
)

FOR %%A in ("%2") DO SET SCRIPT_FILENAME=%%~nxA
FOR %%A IN ("%2") DO SET SCRIPT_PARENT_FOLDER=%%~dpA
IF "!SCRIPT_PARENT_FOLDER!" == "" (
    PUSHD "!SCRIPT_PARENT_FOLDER!"
    SET SCRIPT_PARENT_FOLDER=%cd%\
    POPD
)

SET RRU_SCRIPT_PATH=!SCRIPT_PARENT_FOLDER!!SCRIPT_FILENAME!
SET RRU_REMOTE_URL=%1

IF NOT EXIST "!RRU_SCRIPT_PATH!" (
    ECHO Script file !RRU_SCRIPT_PATH! does not exist
    GOTO DONE
)

FOR /f "usebackq tokens=*" %%A in (`powershell -Command "[guid]::NewGuid().ToString()"`) DO SET RRU_SESSION_ID_RAW=%%A
SET RRU_SESSION_ID=%RRU_SESSION_ID_RAW:-=%
SET COORDINATOR_NAME=net.tightener.coordinator.scriptrunner.RRU.%RRU_SESSION_ID%

Tightener -n %COORDINATOR_NAME% -o %TIMEOUT_MS% -w !QUIT_DELAY_MS! -t n -f "%TIGHTENER_SCRIPTS%rru.tql"

:DONE


