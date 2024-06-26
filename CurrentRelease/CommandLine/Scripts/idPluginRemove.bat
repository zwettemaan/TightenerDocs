@ECHO off

NET SESSION >NUL 2>&1
IF NOT %ERRORLEVEL% == 0 (
    ECHO Need administrative privileges for this script
    GOTO DONE
)

CALL "%TIGHTENER_SCRIPTS%idSetEnv.bat"

IF NOT EXIST "%INDESIGN_APP_ROROHIKO_PLUGIN_FOLDER%" GOTO DONE

IF %INDESIGN_TIGHTENER_IS_SERVER% == 1 (
    IF EXIST "%INDESIGN_APP_ROROHIKO_PLUGIN_FOLDER%TightenerServer.pln" DEL "%INDESIGN_APP_ROROHIKO_PLUGIN_FOLDER%TightenerServer.pln"
    IF EXIST "%INDESIGN_APP_ROROHIKO_PLUGIN_FOLDER%(TightenerServer Resources)" POWERSHELL -command "Remove-Item -Path '%INDESIGN_APP_ROROHIKO_PLUGIN_FOLDER%(TightenerServer Resources)' -Recurse"
) ELSE (
    IF EXIST "%INDESIGN_APP_ROROHIKO_PLUGIN_FOLDER%Tightener.pln" DEL "%INDESIGN_APP_ROROHIKO_PLUGIN_FOLDER%Tightener.pln"
    IF EXIST "%INDESIGN_APP_ROROHIKO_PLUGIN_FOLDER%(Tightener Resources)" POWERSHELL -command "Remove-Item -Path '%INDESIGN_APP_ROROHIKO_PLUGIN_FOLDER%(Tightener Resources)' -Recurse"
)

REM Will error if dir not empty, which is what we want
RD "%INDESIGN_APP_ROROHIKO_PLUGIN_FOLDER%" >NUL 2>&1

ECHO Plug-In removed from %INDESIGN_APP_ROROHIKO_PLUGIN_FOLDER%

:DONE