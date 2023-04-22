@ECHO off

REM
REM Evaluate a TQL expression. 
REM
REM e.g.
REM
REM evalTQL sqrt(2)
REM
REM Don't double-quote the expression, and don't use spaces in the expression; this is different than how it works on Mac
REM

SET QUIT_DELAY_MS=0

FOR /f "usebackq tokens=*" %%A in (`powershell -Command "[guid]::NewGuid().ToString()"`) DO SET EVAL_TQL_SESSION_ID_RAW=%%A
SET EVAL_TQL_SESSION_ID=%EVAL_TQL_SESSION_ID_RAW:-=%
SET COORDINATOR_NAME=net.tightener.coordinator.scriptrunner.EVALTQL.%EVAL_TQL_SESSION_ID%

echo %1 | Tightener -n %COORDINATOR_NAME% -t n -w %QUIT_DELAY_MS% -f -

:DONE