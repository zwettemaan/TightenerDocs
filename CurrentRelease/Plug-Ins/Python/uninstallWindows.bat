@ECHO off

SET TIGHTENER_PYTHON=%~dp0
CD %TIGHTENER_PYTHON%

jupyter kernelspec remove jsxreplwrapper -y
jupyter kernelspec remove idjsreplwrapper -y
jupyter kernelspec remove tqlreplwrapper -y