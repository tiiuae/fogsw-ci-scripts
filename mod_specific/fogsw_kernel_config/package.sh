#!/bin/bash

BUILD_DIR=$1
# $2 is the MODULE_GEN_CONFIG variable coming from environment.
KERNEL_CONFIG=$2

if [ -e linux ]; then
    LINUX_SRC="/linux"
elif [ -e linux-hwe-5.8-5.8.0 ]; then
    LINUX_SRC="/linux-hwe-5.8-5.8.0"
elif [ -e linux-hwe-5.11-5.11.0 ]; then
    LINUX_SRC="/linux-hwe-5.11-5.11.0"
else
    echo "ERROR: linux kernel sources are missing."
    exit 1
fi

if [ "${KERNEL_CONFIG}" == "" ]; then
    echo "ERROR: linux kernel configuration parameter is missing."
    exit 1
fi

echo -n "INFO: Setting linux kernel local version to "
if [ "${KERNEL_CONFIG}" == "x86_kvm_secure_release" ]; then
    echo "sec-rel"
    local_ver="-sec-rel"
elif [ "${KERNEL_CONFIG}" == "x86_kvm_guest_secure_release" ]; then
    echo "guest-sec-rel"
    local_ver="-guest-sec-rel"
elif [ "${KERNEL_CONFIG}" == "x86_debug" ]; then
    echo "debug"
    local_ver="-debug"
elif [ "${KERNEL_CONFIG}" == "fog" ]; then
    echo "fog"
    local_ver="-fog"
else
    echo "ERROR: linux kernel configuration parameter is not valid."
    exit 1
fi
if [ ! -e /${BUILD_DIR}${LINUX_SRC}/.config ]; then
    echo "ERROR: Kernel .config file does not exist in /${BUILD_DIR}${LINUX_SRC}/."
    exit 1
fi
sed -i "s/CONFIG_LOCALVERSION=.*/CONFIG_LOCALVERSION=\"${local_ver}\"/g" /${BUILD_DIR}${LINUX_SRC}/.config

echo "Build and package Linux Kernel."
pushd /${BUILD_DIR}${LINUX_SRC} > /dev/null
fakeroot make-kpkg --initrd --revision=2 --jobs $(nproc) kernel_image
mv ../*.deb /
popd > /dev/null

exit 0

