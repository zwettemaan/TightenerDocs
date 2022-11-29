@ECHO off

TASKKILL /f /fi "imagename eq tightener*" > NUL
TASKKILL /f /fi "imagename eq xojotightener*" > NUL
TASKKILL /f /fi "imagename eq tightenergw*" > NUL
 
DEL /Q "%APPDATA%\net.tightener\NamedPipes\*"
DEL /Q "%APPDATA%\net.tightener\SessionData\*"
