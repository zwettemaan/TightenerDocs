@ECHO off

SETLOCAL EnableDelayedExpansion

REM
REM Interactively run ExtendScript commands
REM
REM rre_REPL <target> 
REM
REM e.g.
REM
REM rre_REPL indesign 
REM rre_REPL tgh://freddy/indesign/main
REM rre_REPL tgh://sandy.rorohiko.com/net.tightener.coordinator.indesign.17.0/main
REM rre_REPL tgh://sandy.rorohiko.com/net.tightener.coordinator.indesign.17.0.configuration_noport/main
REM

IF "%1" == "" (
    ECHO Usage:
    ECHO   rre_REPL target 
    ECHO.
    GOTO DONE
)

SET RRE_REMOTE_URL=%1

ECHO Starting rre_REPL.tql. Enter 'quit()' to terminate the REPL loop.

Tightener -N console -t n -f "%TIGHTENER_SCRIPTS%rre_REPL.tql"

ECHO Done.

:DONE


