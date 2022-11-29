@ECHO OFF

REM
REM The user can set up their own preferred editor %TIGHTENER_SYSCONFIG_ROOT%editFile.bat
REM If that file cannot be found, we fall back to calling Release\CommandLine\Scripts\editFileDefault.bat
REM

SET EDIT_OVERRIDE=%TIGHTENER_SYSCONFIG_ROOT%editFile.bat

IF NOT EXIST "%EDIT_OVERRIDE%" (
    editFileDefault %1
    GOTO DONE
)

"%EDIT_OVERRIDE%" %1

:DONE
