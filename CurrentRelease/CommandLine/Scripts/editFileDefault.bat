@ECHO OFF

SET SUBLIME3=C:\Program Files\Sublime Text 3\subl.exe
SET SUBLIME4=C:\Program Files\Sublime Text\subl.exe
SET NOTEPADpp=C:\Program Files\Notepad++\notepad++.exe
SET NOTEPAD=C:\Windows\Notepad.exe

IF EXIST "%SUBLIME4%" (
    "%SUBLIME4%" "%1"
) ELSE IF EXIST "%SUBLIME3%" (
    "%SUBLIME3%" "%1"
) ELSE IF EXIST "%NOTEPADpp%" (
    "%NOTEPADpp%" "%1"
) ELSE IF EXIST "%NOTEPAD%" (
    "%NOTEPAD%" "%1"
) ELSE (
    ECHO Cannot find a suitable text editor. Please consult the documentation to see how to set that up
)