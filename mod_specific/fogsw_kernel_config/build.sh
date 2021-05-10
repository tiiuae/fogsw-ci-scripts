#!/bin/bash

BUILD_DIR=$1

if [ -e linux ]; then
    LINUX_SRC="/linux"
elif [ -e linux-hwe-5.8-5.8.0 ]; then
    LINUX_SRC="/linux-hwe-5.8-5.8.0"
else
    echo "ERROR: linux kernel sources are missing."
    exit 1
fi

echo "$PWD Create kernel configuration."
# Other possible configurations:
#    x86_kvm_release, x86_kvm_guest_release,
#    x86_kvm_secure_release, x86_kvm_guest_secure_release
/${BUILD_DIR}/config/defconfig_builder.sh -k /${BUILD_DIR}${LINUX_SRC} -t x86_debug
pushd /${BUILD_DIR}${LINUX_SRC} > /dev/null
make x86_debug_defconfig
popd > /dev/null

exit 0
