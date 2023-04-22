@ECHO off

DEL /Q "%APPDATA%\net.tightener\NamedPipes\*.*"

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