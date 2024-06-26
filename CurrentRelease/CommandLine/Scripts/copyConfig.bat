@ECHO off

IF "%TIGHTENER_RELEASE_ROOT%" == "" GOTO ERROR_MISSING_RELEASE_ROOT
IF NOT EXIST "%TIGHTENER_RELEASE_ROOT%" GOTO ERROR_NON_EXISTENT_RELEASE_ROOT

IF NOT EXIST "%APPDATA%\net.tightener" MD "%APPDATA%\net.tightener"
IF NOT EXIST "%APPDATA%\net.tightener\SysConfig" MD "%APPDATA%\net.tightener\SysConfig"

IF EXIST "%APPDATA%\net.tightener\SysConfig\config.ini" DEL "%APPDATA%\net.tightener\SysConfig\config.ini"

IF "%PROCESSOR_ARCHITECTURE%" == "ARM64" (
    SET TIGHTENER_APPS_PLATFORM=Windows arm64
) ELSE (
    SET TIGHTENER_APPS_PLATFORM=Windows x86_64
)

SET TIGHTENER_RELEASE_ROOT_ESCAPED=%TIGHTENER_RELEASE_ROOT:\=\\%
SET TIGHTENER_BINARIES_ESCAPED=%TIGHTENER_BINARIES:\=\\%

ECHO # > "%APPDATA%\net.tightener\SysConfig\config.ini.tmp"
ECHO # Placeholders added by 'copyConfig' >> "%APPDATA%\net.tightener\SysConfig\config.ini.tmp"
ECHO # >> "%APPDATA%\net.tightener\SysConfig\config.ini.tmp"
ECHO. >> "%APPDATA%\net.tightener\SysConfig\config.ini.tmp"
ECHO [placeholders] >> "%APPDATA%\net.tightener\SysConfig\config.ini.tmp"
ECHO. >> "%APPDATA%\net.tightener\SysConfig\config.ini.tmp"
ECHO TIGHTENER_RELEASE_ROOT = "%TIGHTENER_RELEASE_ROOT_ESCAPED%" >> "%APPDATA%\net.tightener\SysConfig\config.ini.tmp"
ECHO TIGHTENER_BINARIES = "%TIGHTENER_BINARIES_ESCAPED%" >> "%APPDATA%\net.tightener\SysConfig\config.ini.tmp"
ECHO TIGHTENER_APPS_PLATFORM = "%TIGHTENER_APPS_PLATFORM%" >> "%APPDATA%\net.tightener\SysConfig\config.ini.tmp"
ECHO. >> "%APPDATA%\net.tightener\SysConfig\config.ini.tmp"

COPY /B "%APPDATA%\net.tightener\SysConfig\config.ini.tmp" + "%TIGHTENER_RELEASE_ROOT%Config\config.ini" "%APPDATA%\net.tightener\SysConfig\config.ini" > NUL
DEL "%APPDATA%\net.tightener\SysConfig\config.ini.tmp"

ECHO config.ini was created

GOTO :DONE

:ERROR_NON_EXISTENT_RELEASE_ROOT

ECHO Directory %%TIGHTENER_RELEASE_ROOT%% does not exist. Please follow instructions in README.md

GOTO DONE

:ERROR_MISSING_RELEASE_ROOT

ECHO %%TIGHTENER_RELEASE_ROOT%% has not been set up. Please follow instructions in README.md

GOTO DONE

:DONE
