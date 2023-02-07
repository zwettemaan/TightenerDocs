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

REM We only need this script for ID, not IDS, so this wants to be inside the ELSE below, but the
REM parenthesis in the VBScript cause problems even when escaped with ^ when the ECHO
REM statements are inside the () of the conditional

REM https://stackoverflow.com/questions/19328981/vbscript-to-check-for-open-process-by-user

SET C=%TIGHTENER_SYSCONFIG_ROOT%pokeInDesignTimeslices.vbs

ECHO FUNCTION isProcessRunning(BYVAL strComputer,BYVAL strProcessName)> %C%
ECHO     DIM objWMIService, strWMIQuery>> %C%
ECHO     strWMIQuery = "Select * from Win32_Process where name like '" ^& strProcessName ^& "'">> %C%
ECHO     SET objWMIService = GETOBJECT("winmgmts:" _>> %C%
ECHO         ^& "{impersonationLevel=impersonate}!\\" _>> %C% 
ECHO             ^& strComputer ^& "\root\cimv2")>> %C%
ECHO     IF objWMIService.ExecQuery(strWMIQuery).Count > 0 THEN>> %C%
ECHO         isProcessRunning = TRUE>> %C%
ECHO     ELSE>> %C%
ECHO         isProcessRunning = FALSE>> %C%
ECHO     END IF>> %C%
ECHO END FUNCTION>> %C%
ECHO SET myInDesign = CreateObject("InDesign.Application.%INDESIGN_TIGHTENER_VERSION%")>> %C%
ECHO WHILE isProcessRunning(".","InDesign.exe")>> %C%
ECHO    myInDesign.tightenerTimeslice()>> %C%
ECHO WEND>> %C%

IF "%INDESIGN_TIGHTENER_IS_SERVER%" == "1" (
    "%INDESIGN_APP_ROOT%%INDESIGN_APP_FILE%" -console
) ELSE (    
    cscript "%C%" >NUL 2>&1 
)

:DONE