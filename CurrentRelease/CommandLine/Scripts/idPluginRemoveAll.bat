@ECHO off

NET SESSION >NUL 2>&1
IF NOT %ERRORLEVEL% == 0 (
    ECHO Need administrative privileges for this script
    GOTO DONE
)

CALL "%TIGHTENER_SCRIPTS%idSetEnv.bat"

ECHO Searching for InDesign Plug-Ins to delete

PUSHD "%PROGRAMFILES%"

(FOR /f "delims=" %%i IN ('DIR /s /b /a:-d "Tightener.pln"') do (DEL /Q "%%i") >NUL 2>&1
FOR /f "delims=" %%i IN ('DIR /s /b /a:d "(Tightener Resources)"') do (RMDIR /S /Q "%%i") >NUL 2>&1
FOR /f "delims=" %%i IN ('DIR /s /b /a:-d "TightenerServer.pln"') do (DEL /Q "%%i") >NUL 2>&1
FOR /f "delims=" %%i IN ('DIR /s /b /a:d "(TightenerServer Resources)"') do (RMDIR /S /Q "%%i") >NUL 2>&1) >NUL 2>&1

FOR /f "delims=" %%i IN ('DIR /s /b /a:d "Plug-Ins"') do (

    PUSHD "%%i"

    IF EXIST Rorohiko (
        REM RMDIR will fail if not empty, and that's desired behavior
        RMDIR Rorohiko >NUL 2>NUL
    )

    POPD
)

POPD

ECHO Search complete

:DONE