@ECHO off

SET TIGHTENER_PYTHON=%~dp0
CD %TIGHTENER_PYTHON%

jupyter kernelspec install jsxreplwrapper
jupyter kernelspec install idjsreplwrapper
jupyter kernelspec install tqlreplwrapper