@ECHO off

CALL "%TIGHTENER_SCRIPTS%idSetEnv.bat"

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

cscript "%C%" >NUL 2>&1 

:DONE