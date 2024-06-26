#
# Usages:
#
#   uninstall.command
#   uninstall.command all
#
# By adding a command line parameter 'all' you can also remove Tightener preferences and InDesign plugins
#

export TIGHTENER_RELEASE_ROOT=`dirname $0`
cd $TIGHTENER_RELEASE_ROOT
export TIGHTENER_RELEASE_ROOT=`pwd`/

export TIGHTENER_SCRIPTS="${TIGHTENER_RELEASE_ROOT}/CommandLine/Scripts/"

cd "${TIGHTENER_SCRIPTS}"

if [ `uname` = "Darwin" ]; then

    CLEARED_FILE_LIST="~/.zshenv and ~/.profile"
    ./clearEnvironmentInProfile ~/.zshenv 
    ./clearEnvironmentInProfile ~/.profile

    if [ "$1" == "all" ]; then

        echo ""
        ./idPluginRemoveAll

        echo ""
        echo "Removing Tightener preferences."
        if [ -d ~/"Library/Application Support/net.tightener/Licensing" ]; then
            echo "Retaining ~/Library/Application Support/net.tightener/Licensing - need to delete manually"
            cd ~/"Library/Application Support/net.tightener"
            find . -maxdepth 1 -type d -not -name '.' -not -name '..' -not -name 'Licensing' -print0 | xargs -0 rm -rf --
        else
            rm -rf ~/"Library/Application Support/net.tightener"
        fi
        
    fi

else

    CLEARED_FILE_LIST="~/.bashrc and ~/.profile"
    ./clearEnvironmentInProfile ~/.bashrc 
    ./clearEnvironmentInProfile ~/.profile

    if [ "$1" == "all" ]; then

        echo ""
        echo "Removing Tightener preferences."

        if [ -d ~/.net.tightener/net.tightener/Licensing ]; then
            echo "Retaining ~/.net.tightener/net.tightener/Licensing - need to delete manually"
            cd ~/.net.tightener/net.tightener
            find . -maxdepth 1 -type d -not -name '.' -not -name '..' -not -name 'Licensing' -print0 | xargs -0 rm -rf --
        else
            rm -rf ~/.net.tightener/net.tightener
        fi
    fi

fi

echo ""
echo "Tightener has been removed from your ${CLEARED_FILE_LIST} profile files"

if [ "$1" != "all" ]; then
    echo ""
    echo "The Tightener preferences are stored in ${TIGHTENER_LOCAL_DATA_ROOT}."
    echo "This folder has not been deleted - you can delete it manually if desired."
    echo ""
    echo "Any plug-ins you might have installed (e.g. by way of idPluginInstall)"
    echo "have not been removed - please remove these manually"
    echo ""
    echo "Alternatively, you can run"
    echo ""
    echo "  cd_tightener"
    echo "  ./uninstall.command all"
    echo ""
    echo "from a Terminal window to force the uninstaller to also try to remove prefs and plug-ins"
fi