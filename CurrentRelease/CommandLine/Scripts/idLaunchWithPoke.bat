@ECHO OFF

CALL "%TIGHTENER_SCRIPTS%idSetEnv.bat"

REM https://stackoverflow.com/questions/19328981/vbscript-to-check-for-open-process-by-user

ECHO FUNCTION isProcessRunning(BYVAL strComputer,BYVAL strProcessName)> %TIGHTENER_SYSCONFIG_ROOT%pokeInDesignTimeslices.vbs
ECHO     DIM objWMIService, strWMIQuery>> %TIGHTENER_SYSCONFIG_ROOT%pokeInDesignTimeslices.vbs
ECHO     strWMIQuery = "Select * from Win32_Process where name like '" ^& strProcessName ^& "'">> %TIGHTENER_SYSCONFIG_ROOT%pokeInDesignTimeslices.vbs
ECHO     SET objWMIService = GETOBJECT("winmgmts:" _>> %TIGHTENER_SYSCONFIG_ROOT%pokeInDesignTimeslices.vbs
ECHO         ^& "{impersonationLevel=impersonate}!\\" _>> %TIGHTENER_SYSCONFIG_ROOT%pokeInDesignTimeslices.vbs 
ECHO             ^& strComputer ^& "\root\cimv2")>> %TIGHTENER_SYSCONFIG_ROOT%pokeInDesignTimeslices.vbs
ECHO     IF objWMIService.ExecQuery(strWMIQuery).Count > 0 THEN>> %TIGHTENER_SYSCONFIG_ROOT%pokeInDesignTimeslices.vbs
ECHO         isProcessRunning = TRUE>> %TIGHTENER_SYSCONFIG_ROOT%pokeInDesignTimeslices.vbs
ECHO     ELSE>> %TIGHTENER_SYSCONFIG_ROOT%pokeInDesignTimeslices.vbs
ECHO         isProcessRunning = FALSE>> %TIGHTENER_SYSCONFIG_ROOT%pokeInDesignTimeslices.vbs
ECHO     END IF>> %TIGHTENER_SYSCONFIG_ROOT%pokeInDesignTimeslices.vbs
ECHO END FUNCTION>> %TIGHTENER_SYSCONFIG_ROOT%pokeInDesignTimeslices.vbs
ECHO SET myInDesign = CreateObject("InDesign.Application.%INDESIGN_TIGHTENER_VERSION%")>> %TIGHTENER_SYSCONFIG_ROOT%pokeInDesignTimeslices.vbs
ECHO WHILE isProcessRunning(".","InDesign.exe")>> %TIGHTENER_SYSCONFIG_ROOT%pokeInDesignTimeslices.vbs
ECHO    myInDesign.tightenerTimeslice()>> %TIGHTENER_SYSCONFIG_ROOT%pokeInDesignTimeslices.vbs
ECHO WEND>> %TIGHTENER_SYSCONFIG_ROOT%pokeInDesignTimeslices.vbs

cscript "%TIGHTENER_SYSCONFIG_ROOT%pokeInDesignTimeslices.vbs" >NUL 2>&1 