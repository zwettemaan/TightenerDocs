@ECHO off

NET SESSION >NUL 2>&1
IF NOT %ERRORLEVEL% == 0 (
    ECHO Need administrative privileges for this script
    GOTO DONE
)

CALL "%TIGHTENER_SCRIPTS%idSetEnv.bat"
CALL idPluginRemove.bat

IF NOT EXIST "%INDESIGN_APP_ROROHIKO_PLUGIN_FOLDER%" MD "%INDESIGN_APP_ROROHIKO_PLUGIN_FOLDER%"

IF "%INDESIGN_TIGHTENER_IS_SERVER%" == "1" (
    COPY "%INDESIGN_RELEASE_PLUGIN_FOLDER%TightenerServer.pln" "%INDESIGN_APP_ROROHIKO_PLUGIN_FOLDER%TightenerServer.pln" > NUL
    POWERSHELL -command "Copy-Item '%INDESIGN_RELEASE_PLUGIN_FOLDER%(TightenerServer Resources)' '%INDESIGN_APP_ROROHIKO_PLUGIN_FOLDER%(TightenerServer Resources)' -Recurse"
) ELSE (
    COPY "%INDESIGN_RELEASE_PLUGIN_FOLDER%Tightener.pln" "%INDESIGN_APP_ROROHIKO_PLUGIN_FOLDER%Tightener.pln" > NUL
    POWERSHELL -command "Copy-Item '%INDESIGN_RELEASE_PLUGIN_FOLDER%(Tightener Resources)' '%INDESIGN_APP_ROROHIKO_PLUGIN_FOLDER%(Tightener Resources)' -Recurse"
)

ECHO.Plug-In installed in %INDESIGN_APP_ROROHIKO_PLUGIN_FOLDER%
ECHO.
ECHO.To uninstall, you can use the idPluginRemove command

:DONE