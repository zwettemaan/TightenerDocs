export TIGHTENER_PYTHON=`dirname $0`
cd "${TIGHTENER_PYTHON}"
export TIGHTENER_PYTHON=`pwd`/

if [ ! -f "dirconfig.sh" ]; then 
    echo "Copy dirconfig_sample.sh to dirconfig.sh and adjust it - change the directory paths to suit"
    exit
fi

killApps

./uninstallJupyterMacKernel.sh idjsreplwrapper
./uninstallJupyterMacKernel.sh jsxreplwrapper
./uninstallJupyterMacKernel.sh tqlreplwrapper
