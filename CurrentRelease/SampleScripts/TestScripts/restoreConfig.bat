@ECHO off

IF NOT EXIST "%TIGHTENER_RELEASE_ROOT%SampleScripts\TestScripts\savedConfig.ini" GOTO DONE

IF "%TIGHTENER_RELEASE_ROOT%" == "" GOTO ERROR_MISSING_RELEASE_ROOT
IF NOT EXIST "%TIGHTENER_RELEASE_ROOT%" GOTO ERROR_NON_EXISTENT_RELEASE_ROOT

IF NOT EXIST "%APPDATA%\net.tightener" MD "%APPDATA%\net.tightener"
IF NOT EXIST "%APPDATA%\net.tightener\SysConfig" MD "%APPDATA%\net.tightener\SysConfig"

IF EXIST "%APPDATA%\net.tightener\SysConfig\config.ini" DEL "%APPDATA%\net.tightener\SysConfig\config.ini"

COPY "%TIGHTENER_RELEASE_ROOT%SampleScripts\TestScripts\savedConfig.ini" "%APPDATA%\net.tightener\SysConfig\config.ini" > NUL 2>&1
DEL "%TIGHTENER_RELEASE_ROOT%SampleScripts\TestScripts\savedConfig.ini"

ECHO config.ini was restored

GOTO :DONE

:ERROR_NON_EXISTENT_RELEASE_ROOT

ECHO Directory %%TIGHTENER_RELEASE_ROOT%% does not exist. Please follow instructions in README.md

GOTO DONE

:ERROR_MISSING_RELEASE_ROOT

ECHO %%TIGHTENER_RELEASE_ROOT%% has not been set up. Please follow instructions in README.md

GOTO DONE

:DONE
