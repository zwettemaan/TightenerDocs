@ECHO OFF

IF "%TIGHTENER_GIT_ROOT%" == "" GOTO ERROR_MISSING_RELEASE_ROOT
IF NOT EXIST "%TIGHTENER_GIT_ROOT%" GOTO ERROR_NON_EXISTENT_RELEASE_ROOT

IF NOT EXIST "%APPDATA%\net.tightener" MKDIR "%APPDATA%\net.tightener"
IF NOT EXIST "%APPDATA%\net.tightener\SysConfig" MKDIR "%APPDATA%\net.tightener\SysConfig"

IF EXIST "%APPDATA%\net.tightener\SysConfig\config.ini" DEL "%APPDATA%\net.tightener\SysConfig\config.ini"

MKLINK /H "%APPDATA%\net.tightener\SysConfig\config.ini" "%TIGHTENER_RELEASE_ROOT%SampleScripts\TestScripts\config.ini" > NUL 2>&1

ECHO Link to config.ini was created

GOTO :DONE

:ERROR_NON_EXISTENT_RELEASE_ROOT

ECHO Directory %%TIGHTENER_GIT_ROOT%% does not exist. Please follow instructions in README.md

GOTO DONE

:ERROR_MISSING_RELEASE_ROOT

ECHO %%TIGHTENER_GIT_ROOT%% has not been set up. Please follow instructions in README.md

GOTO DONE

:DONE
