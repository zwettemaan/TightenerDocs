@ECHO off

SET TIGHTENER_PYTHON=%~dp0
CD %TIGHTENER_PYTHON%

jupyter kernelspec remove jsxreplwrapper -y
jupyter kernelspec remove idjsreplwrapper -y
jupyter kernelspec remove tqlreplwrapper -y
jupyter kernelspec remove tqlindesignreplwrapper -y

FOR /F "usebackq tokens=*" %%A IN (`python3 -c "import sysconfig; print(sysconfig.get_paths()['purelib'])"`) DO SET DIR_SITE_PACKAGES=%%A
IF EXIST "%DIR_SITE_PACKAGES%\tightenerkernel" RMDIR /S /Q "%DIR_SITE_PACKAGES%\tightenerkernel"