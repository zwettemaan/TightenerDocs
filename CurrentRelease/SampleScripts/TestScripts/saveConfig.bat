@ECHO off

IF "%TIGHTENER_RELEASE_ROOT%" == "" GOTO ERROR_MISSING_RELEASE_ROOT
IF NOT EXIST "%TIGHTENER_RELEASE_ROOT%" GOTO DONE

IF NOT EXIST "%APPDATA%\net.tightener" GOTO DONE
IF NOT EXIST "%APPDATA%\net.tightener\SysConfig" GOTO DONE
IF NOT EXIST "%APPDATA%\net.tightener\SysConfig\config.ini" GOTO DONE
IF EXIST "%TIGHTENER_RELEASE_ROOT%SampleScripts\TestScripts\savedConfig.ini" GOTO DONE

FIND /c "isDebugConfig" "%APPDATA%\net.tightener\SysConfig\config.ini" >NUL
IF %ERRORLEVEL% EQU 1 GOTO IS_NOT_DEBUG_CONFIG
GOTO DONE

:IS_NOT_DEBUG_CONFIG

COPY "%APPDATA%\net.tightener\SysConfig\config.ini" "%TIGHTENER_RELEASE_ROOT%SampleScripts\TestScripts\savedConfig.ini" > NUL 2>&1

ECHO config.ini was saved

GOTO DONE

:ERROR_MISSING_RELEASE_ROOT

ECHO %%TIGHTENER_RELEASE_ROOT%% has not been set up. Please follow instructions in README.md

:DONE
