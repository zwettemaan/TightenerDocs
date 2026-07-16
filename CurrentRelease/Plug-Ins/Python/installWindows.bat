@ECHO off

SET TIGHTENER_PYTHON=%~dp0
CD %TIGHTENER_PYTHON%

jupyter kernelspec install jsxreplwrapper
jupyter kernelspec install idjsreplwrapper
jupyter kernelspec install tqlreplwrapper
jupyter kernelspec install tqlindesignreplwrapper

REM Shared kernel implementation package - must be importable by python3
FOR /F "usebackq tokens=*" %%A IN (`python3 -c "import sysconfig; print(sysconfig.get_paths()['purelib'])"`) DO SET DIR_SITE_PACKAGES=%%A
IF EXIST "%DIR_SITE_PACKAGES%\tightenerkernel" RMDIR /S /Q "%DIR_SITE_PACKAGES%\tightenerkernel"
XCOPY /E /I /Y tightenerkernel "%DIR_SITE_PACKAGES%\tightenerkernel"