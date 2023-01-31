export KERNEL_NAME="$1"

./uninstallJupyterMacKernel.sh "$1"

. dirconfig.sh

ln -s "${TIGHTENER_RELEASE_ROOT}Plug-Ins/Python/${KERNEL_NAME}" "${DIR_KERNELS}/${KERNEL_NAME}"
ln -s "${TIGHTENER_RELEASE_ROOT}Plug-Ins/Python/${KERNEL_NAME}" "${DIR_SITE_PACKAGES}/${KERNEL_NAME}"
