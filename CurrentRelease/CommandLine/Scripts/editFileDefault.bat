@ECHO OFF

SET SUBLIME=C:\Program Files\Sublime Text 3\subl.exe
SET NOTEPADpp=C:\Program Files\Notepad++\notepad++.exe
SET NOTEPAD=C:\Windows\Notepad.exe

IF EXIST "%SUBLIME%" (
    "%SUBLIME%" "%1"
) ELSE IF EXIST "%NOTEPADpp%" (
    "%NOTEPADpp%" "%1"
) ELSE IF EXIST "%NOTEPAD%" (
    "%NOTEPAD%" "%1"
) ELSE (
    ECHO Cannot find a suitable text editor. Please consult the documentation to see how to set that up
)