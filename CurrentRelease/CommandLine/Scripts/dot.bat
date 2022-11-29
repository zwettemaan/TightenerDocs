@ECHO OFF

SETLOCAL EnableDelayedExpansion

REM Remotely run TQL commands
REM
REM Direct command:
REM
REM   dot <target> "some TQL code"
REM
REM Read from stdin:
REM
REM   dot <target> 
REM
REM e.g.
REM
REM   dot indesign "app.quit();"
REM

IF "%1" == "" (
    ECHO Run TQL command. Usage:
    ECHO   dot target "command"
    echo Read input from stdin:
    echo    dot target
    ECHO.
    GOTO DONE
)

SET RRT_REMOTE_URL=%1

IF "%2" == "" (
    Tightener -N scriptrunner -f "%TIGHTENER_SCRIPTS%rrt_REPL.tql"
) ELSE (
    ECHO %2 > %TEMP%\dot_script_file.tql
    Tightener -N scriptrunner -f "%TIGHTENER_SCRIPTS%rrt_REPL.tql" < %TEMP%\dot_script_file.tql
)

:DONE
