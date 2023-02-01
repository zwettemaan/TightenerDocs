@ECHO OFF

REM
REM Usages:
REM
REM   uninstall.bat
REM   uninstall.bat all
REM
REM By adding a command line parameter 'all' you can also remove Tightener preferences and InDesign plugins
REM

SET TIGHTENER_UNINSTALL_DIR=%~dp0

"%TIGHTENER_UNINSTALL_DIR%CommandLine\Scripts\clearEnvironment.bat" %1

