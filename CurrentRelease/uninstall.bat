@ECHO OFF

SETLOCAL EnableDelayedExpansion

REM
REM Usages:
REM
REM   uninstall.bat
REM   uninstall.bat all
REM
REM By adding a command line parameter 'all' you can also remove Tightener preferences and InDesign plugins
REM

IF "%1" == "all" (
    NET SESSION >NUL 2>&1
    IF NOT !ERRORLEVEL! == 0 (
            ECHO.
            ECHO Need administrative privileges for this script
            ECHO.
            GOTO DONE
    )
)

SET TIGHTENER_UNINSTALL_DIR=%~dp0

"%TIGHTENER_UNINSTALL_DIR%CommandLine\Scripts\clearEnvironment.bat" %1

:DONE