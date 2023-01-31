export KERNEL_NAME="$1"

. dirconfig.sh

rm -f "${DIR_KERNELS}/${KERNEL_NAME}"
rm -f "${DIR_SITE_PACKAGES}/${KERNEL_NAME}"
