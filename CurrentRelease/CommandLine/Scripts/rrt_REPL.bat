@ECHO off

SETLOCAL EnableDelayedExpansion

REM
REM Interactively run TQL commands
REM
REM rrt_REPL <target> 
REM
REM e.g.
REM
REM rrt_REPL indesign 
REM rrt_REPL tgh://freddy/indesign/main
REM rrt_REPL tgh://sandy.rorohiko.com/net.tightener.coordinator.indesign.17.0/main
REM rrt_REPL tgh://sandy.rorohiko.com/net.tightener.coordinator.indesign.17.0.configuration_noport/main
REM

IF "%1" == "" (
    ECHO Usage:
    ECHO   rrt_REPL target 
    ECHO.
    GOTO DONE
)

SET RRT_REMOTE_URL=%1

ECHO Starting rrt_REPL.tql. Enter 'quit()' to terminate the REPL loop.

Tightener -N console -t n -f "%TIGHTENER_SCRIPTS%rrt_REPL.tql"

ECHO Done.

:DONE


