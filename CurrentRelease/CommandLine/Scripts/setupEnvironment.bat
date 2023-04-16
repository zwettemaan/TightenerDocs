@ECHO off

REM Yes, that is a single quote in all those SETX > NUL commands! SETX > NUL is weird

SETLOCAL EnableDelayedExpansion

IF NOT EXIST "%APPDATA%\net.tightener" MD "%APPDATA%\net.tightener"
IF NOT EXIST "%APPDATA%\net.tightener\SysConfig" MD "%APPDATA%\net.tightener\SysConfig"

REG QUERY "HKEY_CURRENT_USER\TightenerSavedEnvironment" >NUL 2>&1
IF %ERRORLEVEL% == 1 (
    REG COPY "HKEY_CURRENT_USER\Environment" "HKEY_CURRENT_USER\TightenerSavedEnvironment" >NUL 2>&1
)

FOR /f "tokens=2*" %%A IN ('REG QUERY "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path') DO SET SYSTEM_PATH=%%B

FOR /f "tokens=2*" %%A IN ('REG QUERY "HKEY_CURRENT_USER\TightenerSavedEnvironment" /v Path') DO SET USER_PATH_SAVED_IN_REG_BY_TIGHTENER=%%B

IF "!USER_PATH_SAVED_BY_TIGHTENER!" == "" (
    SET LAST_CHAR_OF_SAVED_USER_PATH=!USER_PATH_SAVED_IN_REG_BY_TIGHTENER:~-1!
    IF "!LAST_CHAR_OF_SAVED_USER_PATH!" == ";" (
        SET USER_PATH_SAVED_BY_TIGHTENER=!USER_PATH_SAVED_IN_REG_BY_TIGHTENER!
    ) ELSE (
        SET USER_PATH_SAVED_BY_TIGHTENER=!USER_PATH_SAVED_IN_REG_BY_TIGHTENER!;
    )
    SETX > NUL USER_PATH_SAVED_BY_TIGHTENER "!USER_PATH_SAVED_BY_TIGHTENER!
)

REG DELETE HKEY_CURRENT_USER\Environment /f /v TIGHTENER_GIT_ROOT >NUL 2>&1
REG DELETE HKEY_CURRENT_USER\Environment /f /v TIGHTENER_DOCS_ROOT >NUL 2>&1
REG DELETE HKEY_CURRENT_USER\Environment /f /v TIGHTENER_RELEASE_ROOT >NUL 2>&1
REG DELETE HKEY_CURRENT_USER\Environment /f /v TIGHTENER_BINARIES >NUL 2>&1
REG DELETE HKEY_CURRENT_USER\Environment /f /v TIGHTENER_SCRIPTS >NUL 2>&1
REG DELETE HKEY_CURRENT_USER\Environment /f /v TIGHTENER_LOCAL_DATA_ROOT >NUL 2>&1
REG DELETE HKEY_CURRENT_USER\Environment /f /v TIGHTENER_SYSCONFIG_ROOT >NUL 2>&1
REG DELETE HKEY_CURRENT_USER\Environment /f /v TIGHTENER_DEFAULT_RR_TIMEOUT_MS >NUL 2>&1
REG DELETE HKEY_CURRENT_USER\Environment /f /v TIGHTENER_DEFAULT_RR_QUIT_DELAY_MS >NUL 2>&1
REG DELETE HKEY_CURRENT_USER\Environment /f /v TIGHTENER_DEFAULT_REPL_TIMEOUT_MS >NUL 2>&1
REG DELETE HKEY_CURRENT_USER\Environment /f /v TIGHTENER_DEFAULT_REPL_QUIT_DELAY_MS >NUL 2>&1

SET TIGHTENER_SCRIPTS=%~dp0
SETX > NUL TIGHTENER_SCRIPTS "%TIGHTENER_SCRIPTS%

PUSHD "%TIGHTENER_SCRIPTS%..\.."

SET TIGHTENER_RELEASE_ROOT=%cd%\
SETX > NUL TIGHTENER_RELEASE_ROOT "%TIGHTENER_RELEASE_ROOT%

SET TIGHTENER_BINARIES=%TIGHTENER_RELEASE_ROOT%CommandLine\Windows\
SETX > NUL TIGHTENER_BINARIES "%TIGHTENER_BINARIES%

SET TIGHTENER_ARM_BINARIES=%TIGHTENER_RELEASE_ROOT%CommandLine\Windows\ARM64\

IF "%PROCESSOR_ARCHITECTURE%" == "ARM64" (
    SETX > NUL TIGHTENER_ARM_BINARIES "%TIGHTENER_ARM_BINARIES%
    SET TIGHTENER_BINARIES_PATH=%TIGHTENER_ARM_BINARIES%;%TIGHTENER_BINARIES%
) ELSE (
    SET TIGHTENER_BINARIES_PATH=%TIGHTENER_BINARIES%
)

SET TIGHTENER_LOCAL_DATA_ROOT=%APPDATA%\net.tightener\
SETX > NUL TIGHTENER_LOCAL_DATA_ROOT "%TIGHTENER_LOCAL_DATA_ROOT%

SET TIGHTENER_SYSCONFIG_ROOT=%TIGHTENER_LOCAL_DATA_ROOT%SysConfig\
SETX > NUL TIGHTENER_SYSCONFIG_ROOT "%TIGHTENER_SYSCONFIG_ROOT%

SET TIGHTENER_DEFAULT_RR_TIMEOUT_MS=10000
SETX > NUL TIGHTENER_DEFAULT_RR_TIMEOUT_MS "%TIGHTENER_DEFAULT_RR_TIMEOUT_MS%

SET TIGHTENER_DEFAULT_RR_QUIT_DELAY_MS=500
SETX > NUL TIGHTENER_DEFAULT_RR_QUIT_DELAY_MS "%TIGHTENER_DEFAULT_RR_QUIT_DELAY_MS%

SET TIGHTENER_DEFAULT_REPL_TIMEOUT_MS=20000
SETX > NUL TIGHTENER_DEFAULT_REPL_TIMEOUT_MS "%TIGHTENER_DEFAULT_REPL_TIMEOUT_MS%

SET TIGHTENER_DEFAULT_REPL_QUIT_DELAY_MS=500
SETX > NUL TIGHTENER_DEFAULT_REPL_QUIT_DELAY_MS "%TIGHTENER_DEFAULT_REPL_QUIT_DELAY_MS%

IF NOT EXIST "%TIGHTENER_SYSCONFIG_ROOT%editFile.bat" (
    COPY "%TIGHTENER_SCRIPTS%editFileDefault.bat" "%TIGHTENER_SYSCONFIG_ROOT%editFile.bat" > NUL 2>&1
)

SET PATH_SUFFIX=!TIGHTENER_BINARIES_PATH!;%TIGHTENER_SCRIPTS%;

IF EXIST "%TIGHTENER_RELEASE_ROOT%..\..\TightenerDocs" (

    CD "%TIGHTENER_RELEASE_ROOT%..\..\TightenerDocs"

    SET TIGHTENER_DOCS_ROOT=!cd!\
    SETX > NUL TIGHTENER_DOCS_ROOT "!TIGHTENER_DOCS_ROOT!

    CD "%TIGHTENER_DOCS_ROOT%..\Tightener"

    IF EXIST .gitignore IF EXIST CMakeLists.txt IF EXIST README.md (

        SET TIGHTENER_GIT_ROOT=!cd!\
        SETX > NUL TIGHTENER_GIT_ROOT "!TIGHTENER_GIT_ROOT!

        SET TIGHTENER_BUILD_SCRIPTS=!TIGHTENER_GIT_ROOT!BuildScripts
        SETX > NUL TIGHTENER_BUILD_SCRIPTS "!TIGHTENER_BUILD_SCRIPTS!

        SET TIGHTENER_TEST_SCRIPTS=!TIGHTENER_RELEASE_ROOT!SampleScripts\TestScripts
        SETX > NUL TIGHTENER_TEST_SCRIPTS "!TIGHTENER_TEST_SCRIPTS!
        
        SET PATH_SUFFIX=!TIGHTENER_BINARIES_PATH!;%TIGHTENER_SCRIPTS%;!TIGHTENER_BUILD_SCRIPTS!;!TIGHTENER_TEST_SCRIPTS!;
    )

)

SETX > NUL PATH "!USER_PATH_SAVED_BY_TIGHTENER!!PATH_SUFFIX!

SET LAST_CHAR_OF_SYSTEM_PATH=!SYSTEM_PATH:~-1!

IF NOT "!LAST_CHAR_OF_SYSTEM_PATH!" == ";" (
    SET SYSTEM_PATH=!SYSTEM_PATH!;
)

IF "%TIGHTENER_CONFIG_NODE_NAME%" == "" (
    SETX > NUL TIGHTENER_CONFIG_NODE_NAME "localhost
)

SETX > NUL PATH "!USER_PATH_SAVED_BY_TIGHTENER!!PATH_SUFFIX!

IF NOT EXIST "%APPDATA%\net.tightener\SysConfig\config.ini" (
    CALL %TIGHTENER_SCRIPTS%copyConfig.bat
)

ECHO.
ECHO Tightener entries has been added to your Windows environment and PATH
ECHO Your current environment as it was before install has been saved in the 
ECHO registry under HKEY_CURRENT_USER\TightenerSavedEnvironment
ECHO No plug-ins have been installed. You can install these later as needed
ECHO (e.g. by way of idPluginInstall)
ECHO.

SET /P REPLY=Press [Enter] to close this window. The environment will be available when you launch a new CMD window.

EXIT 

