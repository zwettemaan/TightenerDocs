@ECHO off

SETLOCAL EnableDelayedExpansion

REM
REM Run one ExtendScript commands
REM
REM doe <target> "some extendScript code"
REM
REM Read from stdin:
REM
REM   doe <target> 
REM
REM e.g.
REM
REM doe indesign "alert('hello');"
REM

IF "%1" == "" (
    ECHO Run ExtendScript command. Usage:
    ECHO   doe target "command"
    echo Read input from stdin:
    echo    doe target
    ECHO.
    GOTO DONE
)

SET RRE_REMOTE_URL=%1

IF "%2" == "" (
    Tightener -N console -t n -f "%TIGHTENER_SCRIPTS%rre_REPL.tql"
) ELSE (
    ECHO %2 > %TEMP%\doe_script_file.jsx
    Tightener -N console -i -t n -f "%TIGHTENER_SCRIPTS%rre_REPL.tql" < %TEMP%\doe_script_file.jsx
)

:DONE


