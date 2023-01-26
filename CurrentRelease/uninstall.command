export TIGHTENER_RELEASE_ROOT=`dirname $0`
cd $TIGHTENER_RELEASE_ROOT
export TIGHTENER_RELEASE_ROOT=`pwd`/

export TIGHTENER_SCRIPTS="${TIGHTENER_RELEASE_ROOT}/CommandLine/Scripts"

cd "${TIGHTENER_SCRIPTS}"

if [ `uname` = "Darwin" ]; then

    CLEARED_FILE_LIST="~/.zshenv and ~/.profile"
    ./clearEnvironmentInProfile ~/.zshenv 
    ./clearEnvironmentInProfile ~/.profile

else

    CLEARED_FILE_LIST="~/.bashrc and ~/.profile"
    ./clearEnvironmentInProfile ~/.bashrc 
    ./clearEnvironmentInProfile ~/.profile

fi

echo ""
echo "Tightener has been removed from your ${CLEARED_FILE_LIST} profile files"
echo ""
echo "The Tightener preferences are stored in ${TIGHTENER_LOCAL_DATA_ROOT}."
echo "This folder has not been deleted - you can delete it manually if desired."
echo ""
echo "Any plug-ins you might have installed (e.g. by way of idPluginInstall)"
echo "have not been removed - please remove these manually"
