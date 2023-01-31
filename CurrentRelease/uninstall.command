export TIGHTENER_RELEASE_ROOT=`dirname $0`
cd $TIGHTENER_RELEASE_ROOT
export TIGHTENER_RELEASE_ROOT=`pwd`/

export TIGHTENER_SCRIPTS="${TIGHTENER_RELEASE_ROOT}/CommandLine/Scripts"

cd "${TIGHTENER_SCRIPTS}"

if [ `uname` = "Darwin" ]; then

    CLEARED_FILE_LIST="~/.zshenv and ~/.profile"
    ./clearEnvironmentInProfile ~/.zshenv 
    ./clearEnvironmentInProfile ~/.profile

    if [ "$1" == "all" ]; then
        echo ""
        echo "Removing Tightener preferences"
        rm -rf ~/"Library/Application Support/net.tightener"

        echo ""
        echo "Searching for InDesign Plug-Ins to remove..."
        find /Applications/Adobe\ InDesign* -iregex ".*/Tightener\(Server\)\{0,1\}\.InDesignPlugin" | while read a; do echo "Removing ${a}"; sudo rm -r "$a"; done
        echo "Search completed"
    fi

else

    CLEARED_FILE_LIST="~/.bashrc and ~/.profile"
    ./clearEnvironmentInProfile ~/.bashrc 
    ./clearEnvironmentInProfile ~/.profile

    if [ "$1" == "all" ]; then
        echo ""
        echo "Removing Tightener preferences"
        echo ""
        rm -rf "~/Library/Application Support/net.tightener"
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
fi