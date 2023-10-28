@ECHO off

DEL /Q "%APPDATA%\net.tightener\NamedPipes\*.*"

REM Sleep for 1 seconds
ping -n 1 127.0.0.1 > NUL

ECHO.
ECHO Core Tightener Tasks:
ECHO.
ECHO ----BEGIN
PowerShell -Command "Get-Process | Where-Object {$_.name -match '(.*Tightener.*|.*XojoTightener.*)' }"
ECHO ----END

ECHO.
ECHO Active Named Pipes:
ECHO.
ECHO ----BEGIN
DIR /B "%APPDATA%\net.tightener\NamedPipes\*.*"
ECHO ----END

pause