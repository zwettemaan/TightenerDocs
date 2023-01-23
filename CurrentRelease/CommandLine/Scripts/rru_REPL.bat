@ECHO off

SETLOCAL EnableDelayedExpansion

REM
REM Interactively run UXPScript commands
REM
REM rru_REPL <target> 
REM
REM e.g.
REM
REM rru_REPL indesign 
REM rru_REPL tgh://freddy/indesign/main
REM rru_REPL tgh://sandy.rorohiko.com/net.tightener.coordinator.indesign.17.0/main
REM rru_REPL tgh://sandy.rorohiko.com/net.tightener.coordinator.indesign.17.0.configuration_noport/main
REM

IF "%1" == "" (
    ECHO Usage:
    ECHO   rru_REPL target 
    ECHO.
    GOTO DONE
)

SET RRU_REMOTE_URL=%1

ECHO Starting rru_REPL.tql. Enter 'quit()' to terminate the REPL loop.

Tightener -N console -I -t n -f "%TIGHTENER_SCRIPTS%rru_REPL.tql"

ECHO Done.

:DONE


