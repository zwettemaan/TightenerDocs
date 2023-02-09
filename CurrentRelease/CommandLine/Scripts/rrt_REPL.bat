@ECHO off

SETLOCAL EnableDelayedExpansion

REM
REM Interactively run TQL commands
REM
REM rrt_REPL <target> [ "<TQLCommand>" [quitDelayMS] ]
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
    ECHO   rrt_REPL target [ "tqlCommand" [ quitDelayMS] ] 
    ECHO.
    GOTO DONE
)

IF "%~2" == "" (
    ECHO Starting rrt_REPL.tql. Enter 'quit' to terminate the REPL loop.
    SET SWITCH_STDIN=-I
    SET RRT_1LINE=
    SET TIMEOUT_MS=%TIGHTENER_DEFAULT_REPL_TIMEOUT_MS%
    SET QUIT_DELAY_MS=%TIGHTENER_DEFAULT_REPL_QUIT_DELAY_MS%
) ELSE (
    SET SWITCH_STDIN=
    REM On Windows, rrt_REPL.tql strips the extra ""
    SET RRT_1LINE="%~2"
    SET TIMEOUT_MS=%TIGHTENER_DEFAULT_RR_TIMEOUT_MS%
    IF "%3" == "" (
        SET QUIT_DELAY_MS=%TIGHTENER_DEFAULT_RR_QUIT_DELAY_MS%
    ) ELSE (
        SET QUIT_DELAY_MS=%3
    )
)

SET RRT_REMOTE_URL=%1
SET TIMEOUT_MS=%TIGHTENER_DEFAULT_REPL_TIMEOUT_MS%
SET QUIT_DELAY_MS=%TIGHTENER_DEFAULT_RR_QUIT_DELAY_MS%

FOR /f "usebackq tokens=*" %%A in (`powershell -Command "[guid]::NewGuid().ToString()"`) DO SET RRT_REPL_SESSION_ID=%%A
SET RRT_REPL_SESSION_ID=%RRT_REPL_SESSION_ID:-=%
SET COORDINATOR_NAME=net.tightener.coordinator.console.%RRT_REPL_SESSION_ID%

REM -n <long>  : long coordinator name
REM -I         : read standard stdin 
REM -t n       : no tests to be run
REM -f <path>  : process script

Tightener -n %COORDINATOR_NAME% -o %TIMEOUT_MS% -w %QUIT_DELAY_MS% %SWITCH_STDIN% -t n -f "%TIGHTENER_SCRIPTS%rrt_REPL.tql"

IF "%~2" == "" (
    ECHO Done.
)

:DONE


