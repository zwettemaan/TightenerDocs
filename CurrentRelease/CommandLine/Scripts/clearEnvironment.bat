@ECHO OFF

REM Yes, that is a single quote in all those SETX > NUL commands! SETX > NUL is weird

SETLOCAL EnableDelayedExpansion

IF "%TIGHTENER_RELEASE_ROOT%" == "" (
    ECHO.
    ECHO TIGHTENER_RELEASE_ROOT env var is missing.
    ECHO.
    GOTO NOTINSTALLED
)

IF "%TIGHTENER_SCRIPTS%" == "" (
    ECHO.
    ECHO TIGHTENER_SCRIPTS env var is missing.
    ECHO.
    GOTO NOTINSTALLED
)

REG QUERY "HKEY_CURRENT_USER\TightenerSavedEnvironment" >NUL 2>&1
IF %ERRORLEVEL% == 1 (
    ECHO.
    ECHO HKEY_CURRENT_USER\TightenerSavedEnvironment is missing.
    ECHO.
    GOTO NOTINSTALLED
)

FOR /f "tokens=2*" %%A IN ('REG QUERY "HKEY_CURRENT_USER\Environment" /v Path') DO SET USER_PATH_IN_REG=%%B

SET LAST_CHAR_OF_USER_PATH=!USER_PATH_IN_REG:~-1!
IF "!LAST_CHAR_OF_USER_PATH!" == ";" (
    SET USER_PATH_SAVED_BY_TIGHTENER_UNINSTALLER=!USER_PATH_IN_REG!
) ELSE (
    SET USER_PATH_SAVED_BY_TIGHTENER_UNINSTALLER=!USER_PATH_IN_REG!;
)
SETX > NUL USER_PATH_SAVED_BY_TIGHTENER_UNINSTALLER "!USER_PATH_SAVED_BY_TIGHTENER_UNINSTALLER!

SET NEW_PATH=
SET PARSED_PATH=!USER_PATH_SAVED_BY_TIGHTENER_UNINSTALLER!
:PROCESS_PATH
FOR /f "tokens=1* delims=;" %%A IN ("!PARSED_PATH!") DO (
  SET SEGMENT=%%A
  SET PARSED_PATH=%%B
  if "!SEGMENT!" == "%TIGHTENER_BINARIES%" (
    SET SEGMENT=
  )
  if "!SEGMENT!" == "%TIGHTENER_SCRIPTS%" (
    SET SEGMENT=
  )
  if "!SEGMENT!" == "%TIGHTENER_BUILD_SCRIPTS%" (
    SET SEGMENT=
  )
  if "!SEGMENT!" == "%TIGHTENER_TEST_SCRIPTS%" (
    SET SEGMENT=
  )
  if NOT "!SEGMENT!" == "" (
    SET NEW_PATH=!NEW_PATH!!SEGMENT!;
  )
  IF "!PARSED_PATH!" NEQ "" (
      goto :PROCESS_PATH
  )
)

SETX > NUL PATH "!NEW_PATH!

REG DELETE HKEY_CURRENT_USER\Environment /f /v TIGHTENER_GIT_ROOT >NUL 2>&1
REG DELETE HKEY_CURRENT_USER\Environment /f /v TIGHTENER_RELEASE_ROOT >NUL 2>&1
REG DELETE HKEY_CURRENT_USER\Environment /f /v TIGHTENER_BINARIES >NUL 2>&1
REG DELETE HKEY_CURRENT_USER\Environment /f /v TIGHTENER_SCRIPTS >NUL 2>&1
REG DELETE HKEY_CURRENT_USER\Environment /f /v TIGHTENER_BUILD_SCRIPTS >NUL 2>&1
REG DELETE HKEY_CURRENT_USER\Environment /f /v TIGHTENER_TEST_SCRIPTS >NUL 2>&1
REG DELETE HKEY_CURRENT_USER\Environment /f /v TIGHTENER_CONFIG_NODE_NAME >NUL 2>&1
REG DELETE HKEY_CURRENT_USER\Environment /f /v TIGHTENER_LOCAL_DATA_ROOT >NUL 2>&1
REG DELETE HKEY_CURRENT_USER\Environment /f /v TIGHTENER_SYSCONFIG_ROOT >NUL 2>&1
REG DELETE HKEY_CURRENT_USER\TightenerSavedEnvironment /f >NUL 2>&1

ECHO.
ECHO Tightener has been removed from your Windows environment.
ECHO.
ECHO The current user path as it was before uninstall has been saved under 
ECHO USER_PATH_SAVED_BY_TIGHTENER_UNINSTALLER, just in case.
ECHO There is also a saved USER_PATH_SAVED_BY_TIGHTENER which was the user path
ECHO when Tightener was installed. You can delete these manually if desired.
ECHO Any plug-ins you might have installed (e.g. by way of idPluginInstall) 
ECHO have not been removed - please remove these manually.
ECHO.

GOTO DONE

:NOTINSTALLED

ECHO.
ECHO Cannot find some of the needed Tightener environment variables - maybe it is
ECHO not installed.
ECHO.
ECHO Please verify and adjust your environment manually.
ECHO.

:DONE

SET /P REPLY=Press [Enter] to close this window.

EXIT 

