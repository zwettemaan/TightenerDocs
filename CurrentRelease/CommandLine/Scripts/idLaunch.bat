@ECHO off

CALL "%TIGHTENER_SCRIPTS%idSetEnv.bat"

IF "%INDESIGN_TIGHTENER_IS_SERVER%" == "1" (
    SET PLUGIN=%INDESIGN_APP_ROROHIKO_PLUGIN_FOLDER%TightenerServer.pln
) ELSE (
    SET PLUGIN=%INDESIGN_APP_ROROHIKO_PLUGIN_FOLDER%Tightener.pln
)

IF NOT EXIST "%PLUGIN%" (
    ECHO.Aborting.
    ECHO.No Tightener Plug-in installed in
    ECHO.   %INDESIGN_APP_ROROHIKO_PLUGIN_FOLDER%
    ECHO.You can try using idPluginInstall to install it.
    GOTO DONE
)

IF "%INDESIGN_TIGHTENER_IS_SERVER%" == "1" (
    "%INDESIGN_APP_ROOT%%INDESIGN_APP_FILE%" -console
) ELSE (    
    idPoke
)

:DONE