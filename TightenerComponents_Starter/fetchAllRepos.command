#
# Consult ~/Documents/Controlled/Rorohiko/TightenerComponents/SETUP_README.md
# Manually copy this script into ~/Documents/Controlled/Rorohiko/TightenerComponents
#
# Make sure you're logged in to Github:
#   gh auth login
# Make sure the proper config and key files for glueco.de are in ~/.ssh

export SCRIPT_DIR=`dirname $0`
cd $SCRIPT_DIR
export SCRIPT_DIR=`pwd`/

if [ ! -d ActivePageItems ]; then
    git clone -b main git@rorohiko.glueco.de:/home/git/ActivePageItems.git
fi

if [ ! -d Color2Gray ]; then
    git clone -b main git@rorohiko.glueco.de:/home/git/Color2Gray.git
fi

if [ ! -d CRDT_ES ]; then
    git clone -b main https://github.com/zwettemaan/CRDT_ES.git
fi

if [ ! -d CRDT_UXP ]; then
    git clone -b main https://github.com/zwettemaan/CRDT_UXP.git
fi

if [ ! -d easyScript ]; then
    git clone -b main git@rorohiko.glueco.de:/home/git/easyScript.git
fi

if [ ! -d InDesignTightener ]; then
    git clone -b main https://github.com/zwettemaan/InDesignTightener.git
fi

if [ ! -d JSXGetURL ]; then
    git clone -b master git@rorohiko.glueco.de:/home/git/JSXGetURL.git
fi

if [ ! -d PluginInstaller ]; then
    git clone -b main git@rorohiko.glueco.de:/home/git/PluginInstaller.git
fi

if [ ! -d SizeLabels ]; then
    git clone -b main git@rorohiko.glueco.de:/home/git/SizeLabels.git
fi

if [ ! -d SmokeWordStacks ]; then
    git clone -b main git@rorohiko.glueco.de:/home/git/SmokeWordStacks.git
fi

if [ ! -d Store ]; then
    git clone -b main https://github.com/zwettemaan/Store.git
fi

if [ ! -d Swimmer ]; then
    git clone -b main git@rorohiko.glueco.de:/home/git/Swimmer.git
fi

if [ ! -d StringsAttached ]; then
    git clone -b main git@rorohiko.glueco.de:/home/git/StringsAttached.git
fi

if [ ! -d Sudoku ]; then
    git clone -b main git@rorohiko.glueco.de:/home/git/Sudoku.git
fi

if [ ! -d Swimmer ]; then
    git clone -b main git@rorohiko.glueco.de:/home/git/Swimmer.git
fi

if [ ! -d TextExporter5 ]; then
    git clone -b master git@rorohiko.glueco.de:/home/git/TextExporter4.git TextExporter5
fi

if [ ! -d Tightener ]; then
    git clone -b main https://github.com/zwettemaan/Tightener.git
fi

if [ ! -d TightenerDLL ]; then
    git clone -b main https://github.com/zwettemaan/TightenerDLL.git
fi

if [ ! -d TightenerDocs ]; then
    git clone -b main https://github.com/zwettemaan/TightenerDocs.git
fi

if [ ! -d TightenerExternalLibs ]; then
    git clone -b main git@rorohiko.glueco.de:/home/git/TightenerExternalLibs.git
fi

if [ ! -d TightenerGW ]; then
    git clone -b main https://github.com/zwettemaan/TightenerGW.git
fi

if [ ! -d TightenerMainSite ]; then
    git clone -b main https://github.com/zwettemaan/TightenerMainSite.git
fi

if [ ! -d TightenerRegistry ]; then
    git clone -b main git@rorohiko.glueco.de:/home/git/TightenerRegistry.git
fi

if [ ! -d TightenerSecrets_glueco.de ]; then
    git clone -b main git@rorohiko.glueco.de:/home/git/TightenerSecrets.git TightenerSecrets_glueco.de
fi

if [ ! -d ucf ]; then
    git clone -b main git@rorohiko.glueco.de:/home/git/ucf.git
fi

if [ ! -d XojoTightener ]; then
    git clone -b main https://github.com/zwettemaan/XojoTightener.git
fi

