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

echo %1 | Tightener -N scriptrunner -t n -w %QUIT_DELAY_MS% -f -

:DONE