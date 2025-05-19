@ECHO OFF

REM Consult %HOME%\Documents\Controlled\Rorohiko\TightenerComponents\SETUP_README.md
REM Manually copy this script into %HOME%\Documents\Controlled\Rorohiko\TightenerComponents
REM 
REM Make sure you're logged in to Github:
REM   gh auth login
REM Make sure the proper config and key files for glueco.de are in ~/.ssh
REM and that command-line git is installed

@ECHO OFF

REM Make sure you're logged in to Github:
REM   gh auth login
REM Make sure the proper con)g and key )les for glueco.de are in ~/.ssh
REM and that command-line git is installed

SET SCRIPT_DIR=%~dp0\
CD %SCRIPT_DIR%

IF NOT EXIST ActivePageItems (
    git clone -b main git@rorohiko.glueco.de:/home/git/ActivePageItems.git
)

IF NOT EXIST Color2Gray (
    git clone -b main git@rorohiko.glueco.de:/home/git/Color2Gray.git
)

IF NOT EXIST CRDT_ES (
    git clone -b main https://github.com/zwettemaan/CRDT_ES.git
)

IF NOT EXIST CRDT_UXP (
    git clone -b main https://github.com/zwettemaan/CRDT_UXP.git
)

IF NOT EXIST easyScript (
    git clone -b main git@rorohiko.glueco.de:/home/git/easyScript.git
)

IF NOT EXIST InDesignTightener (
    git clone -b main https://github.com/zwettemaan/InDesignTightener.git
)

IF NOT EXIST JSXGetURL (
    git clone -b master git@rorohiko.glueco.de:/home/git/JSXGetURL.git
)

IF NOT EXIST PluginInstaller (
    git clone -b main git@rorohiko.glueco.de:/home/git/PluginInstaller.git
)

IF NOT EXIST SizeLabels (
    git clone -b main git@rorohiko.glueco.de:/home/git/SizeLabels.git
)

IF NOT EXIST SmokeWordStacks (
    git clone -b main git@rorohiko.glueco.de:/home/git/SmokeWordStacks.git
)

IF NOT EXIST Store (
    git clone -b main https://github.com/zwettemaan/Store.git
)

IF NOT EXIST Swimmer (
    git clone -b main git@rorohiko.glueco.de:/home/git/Swimmer.git
)

IF NOT EXIST StringsAttached (
    git clone -b main git@rorohiko.glueco.de:/home/git/StringsAttached.git
)

IF NOT EXIST Sudoku (
    git clone -b main git@rorohiko.glueco.de:/home/git/Sudoku.git
)

IF NOT EXIST Swimmer (
    git clone -b main git@rorohiko.glueco.de:/home/git/Swimmer.git
)

IF NOT EXIST TableAxe (
    git clone -b main git@rorohiko.glueco.de:/home/git/TableAxe.git
)

IF NOT EXIST TextExporter5 (
    git clone -b master git@rorohiko.glueco.de:/home/git/TextExporter4.git TextExporter5
)

IF NOT EXIST Tightener (
    git clone -b main https://github.com/zwettemaan/Tightener.git
)

IF NOT EXIST TightenerDLL (
    git clone -b main https://github.com/zwettemaan/TightenerDLL.git
)

IF NOT EXIST TightenerDocs (
    git clone -b main https://github.com/zwettemaan/TightenerDocs.git
)

IF NOT EXIST TightenerExternalLibs (
    git clone -b main git@rorohiko.glueco.de:/home/git/TightenerExternalLibs.git
)

IF NOT EXIST TightenerGW (
    git clone -b main https://github.com/zwettemaan/TightenerGW.git
)

IF NOT EXIST TightenerMainSite (
    git clone -b main https://github.com/zwettemaan/TightenerMainSite.git
)

IF NOT EXIST TightenerRegistry (
    git clone -b main git@rorohiko.glueco.de:/home/git/TightenerRegistry.git
)

IF NOT EXIST TightenerSecrets_glueco.de (
    git clone -b main git@rorohiko.glueco.de:/home/git/TightenerSecrets.git TightenerSecrets_glueco.de
)

IF NOT EXIST ucf (
    git clone -b main git@rorohiko.glueco.de:/home/git/ucf.git
)

IF NOT EXIST XojoTightener (
    git clone -b main https://github.com/zwettemaan/XojoTightener.git
)
