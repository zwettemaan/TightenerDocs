if [ -d "${TIGHTENER_LOCAL_DATA_ROOT}NamedPipes" ]; then
    ls -1 "${TIGHTENER_LOCAL_DATA_ROOT}NamedPipes" | while read PIPE_NAME; do rm "${TIGHTENER_LOCAL_DATA_ROOT}NamedPipes/${PIPE_NAME}"; done
fi

echo ""
echo "Core Tightener Processes:"
echo ""
echo "----BEGIN"
ps ax | grep -e "CommandLine/Mac/Tightener" -e "XojoTightener.app/Contents/MacOS/XojoTightener" -e "CommandLine/Mac/TightenerGW/TightenerGW" | grep -e "grep -e " -v | sed "s/^.*\///g"
echo "----END"

echo ""
echo "Active Named Pipes:"
echo ""
echo "----BEGIN"
ls -1 "${TIGHTENER_LOCAL_DATA_ROOT}NamedPipes"
echo "----END"
