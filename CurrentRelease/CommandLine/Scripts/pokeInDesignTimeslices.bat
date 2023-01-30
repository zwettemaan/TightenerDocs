@ECHO OFF

CALL "%TIGHTENER_SCRIPTS%idSetEnv.bat"

ECHO Set myInDesign = CreateObject("InDesign.Application.%INDESIGN_TIGHTENER_VERSION%") > %TIGHTENER_SYSCONFIG_ROOT%pokeInDesignTimeslices.vbs
ECHO while true >> %TIGHTENER_SYSCONFIG_ROOT%pokeInDesignTimeslices.vbs
ECHO    WScript.Echo "1" >> %TIGHTENER_SYSCONFIG_ROOT%pokeInDesignTimeslices.vbs
ECHO    myInDesign.tightenerTimeslice() >> %TIGHTENER_SYSCONFIG_ROOT%pokeInDesignTimeslices.vbs
ECHO wend >> %TIGHTENER_SYSCONFIG_ROOT%pokeInDesignTimeslices.vbs

cscript "%TIGHTENER_SYSCONFIG_ROOT%pokeInDesignTimeslices.vbs"