@ECHO off

REM Testing turn-around speeds
REM Grab a list of strings (all files in the Tightener git repo) 
REM and shoot them off to rrt_REPL to be evaluated as strings
REM
REM Usage:
REM
REM   PingPongTest <targetcoordinator>
REM

setlocal EnableDelayedExpansion

IF "%1" == "" (
    ECHO.
    ECHO.Usage:
    ECHO.  %0 COORDINATOR
    GOTO DONE
)

FOR /F "tokens=*" %%A IN ('DIR /B/S %TIGHTENER_GIT_ROOT%') DO (
    ECHO.^>^>^> %%A
    CALL pingPongReverseString %1 "%%A"
    ECHO.
)

:DONE