@ECHO off

SETLOCAL EnableDelayedExpansion

REM
REM Remotely run a locally stored ExtendScript
REM
REM rre <target> <script> [ <quit_delay_ms> ]
REM
REM e.g.
REM
REM rre indesign hello.jsx 10000
REM rre tgh://freddy/indesign/main hello.jsx
REM rre tgh://sandy.rorohiko.com/net.tightener.coordinator.indesign.17.0/main hello.jsx
REM rre tgh://sandy.rorohiko.com/net.tightener.coordinator.indesign.17.0.configuration_noport/main hello.jsx
REM

IF "%1" == "" (
    ECHO Usage:
    ECHO   rre target extendScriptPath [ quitDelayMilliseconds ]
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

SET RRE_SCRIPT_PATH=!SCRIPT_PARENT_FOLDER!!SCRIPT_FILENAME!
SET RRE_REMOTE_URL=%1

IF NOT EXIST "!RRE_SCRIPT_PATH!" (
    ECHO Script file !RRE_SCRIPT_PATH! does not exist
    GOTO DONE
)

FOR /f "usebackq tokens=*" %%A in (`powershell -Command "[guid]::NewGuid().ToString()"`) DO SET RRU_SESSION_ID_RAW=%%A
SET RRU_SESSION_ID=%RRU_SESSION_ID_RAW:-=%
SET COORDINATOR_NAME=net.tightener.coordinator.scriptrunner.RRU.%RRU_SESSION_ID%

Tightener -n %COORDINATOR_NAME% -o %TIMEOUT_MS% -w !QUIT_DELAY_MS! -t n -f "%TIGHTENER_SCRIPTS%rre.tql"

:DONE


