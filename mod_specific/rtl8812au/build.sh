#!/bin/bash

BUILD_DIR=$1
DEB_DIR=$2

if [ -e /build/linux-hwe-5.8-5.8.0 ]; then
    LINUX_SRC="/build/linux-hwe-5.8-5.8.0"
else
    echo "ERROR: linux kernel sources are missing."
    exit 1
fi

pushd ${LINUX_SRC} > /dev/null
cp ${BUILD_DIR}/packaging/config-5.8.0-55-generic .config
make modules_prepare
popd > /dev/null

# Build the driver here.
make KSRC=${LINUX_SRC} modules || exit 1

# Copy debian files from mod_specific directory
cp ${BUILD_DIR}/packaging/debian/* ${DEB_DIR}/DEBIAN/

mkdir -p ${DEB_DIR}/opt/rtl8812au_kmod
cp ${BUILD_DIR}/8812au.ko ${DEB_DIR}/opt/rtl8812au_kmod/

mkdir -p ${DEB_DIR}/etc/modules-load.d
cp ${BUILD_DIR}/packaging/rtl8812au.conf ${DEB_DIR}/etc/modules-load.d/rtl8812au.conf

exit 0
