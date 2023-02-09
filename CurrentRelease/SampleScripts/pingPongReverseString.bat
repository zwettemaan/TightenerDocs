@ECHO off

REM Part of pingPongTest.bat

setlocal EnableDelayedExpansion

SET testFilePath=%~2
SET escapedTestFilePath=%testFilePath:\=\\%
SET escaped2TestFilePath=%escapedTestFilePath:\=\\%
rrt_REPL %1 "var s=\"%escaped2TestFilePath%\";var sr=\"\";for(var idx=s.length-1;idx>=0;idx--){sr+=s.substr(idx,1)};sr"
