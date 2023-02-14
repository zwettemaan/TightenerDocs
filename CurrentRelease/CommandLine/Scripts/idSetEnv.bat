@ECHO off

REM
REM Read the InDesign information from the active config.ini file
REM
REM To edit the config.ini, use `editConfig`
REM
REM To (re)initialize the active config.ini with a copy of the template file Release/Config/config.ini, 
REM use `copyConfig`
REM

FOR /f "usebackq tokens=*" %%A in (`powershell -Command "[guid]::NewGuid().ToString()"`) DO SET ID_SET_ENV_SESSION_ID_RAW=%%A
SET ID_SET_ENV_SESSION_ID=%ID_SET_ENV_SESSION_ID_RAW:-=%
SET COORDINATOR_NAME=net.tightener.coordinator.scriptrunner.IDSETENV.%ID_SET_ENV_SESSION_ID%

Tightener -n %COORDINATOR_NAME% -t n -w 0 -f "%TIGHTENER_RELEASE_ROOT%CommandLine\Scripts\idSetEnvWindows.tql" > "%TEMP%\idSetEnvConfig.bat"
CALL "%TEMP%\idSetEnvConfig.bat"
DEL "%TEMP%\idSetEnvConfig.bat"

SET TIGHTENER_PLUGINS_RELEASE_ROOT=%TIGHTENER_RELEASE_ROOT%Plug-Ins\

IF "%INDESIGN_TIGHTENER_IS_SERVER%" == "1" (
SET INDESIGN_TIGHTENER_HOSTAPP=InDesign Server %INDESIGN_TIGHTENER_VERSION%
SET INDESIGN_APP_FILE=InDesignServer.exe
) ELSE (
SET INDESIGN_TIGHTENER_HOSTAPP=InDesign %INDESIGN_TIGHTENER_VERSION%
SET INDESIGN_APP_FILE=InDesign.exe
)

SET INDESIGN_APP_ROOT=C:\Program Files\Adobe\Adobe %INDESIGN_TIGHTENER_HOSTAPP%\
SET INDESIGN_RELEASE_PLUGIN_FOLDER=%TIGHTENER_PLUGINS_RELEASE_ROOT%InDesign%INDESIGN_TIGHTENER_VERSION%.%INDESIGN_TIGHTENER_SDK_VERSION%\Windows\
SET INDESIGN_APP_PLUGIN_FOLDER=%INDESIGN_APP_ROOT%Plug-Ins\
SET INDESIGN_APP_ROROHIKO_PLUGIN_FOLDER=%INDESIGN_APP_PLUGIN_FOLDER%Rorohiko\
