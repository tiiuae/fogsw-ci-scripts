#!/bin/bash

BUILD_DIR=$1
KERNEL_CONFIG=$2

if [ -e linux ]; then
    LINUX_SRC="/linux"
elif [ -e linux-hwe-5.8-5.8.0 ]; then
    LINUX_SRC="/linux-hwe-5.8-5.8.0"
else
    echo "ERROR: linux kernel sources are missing."
    exit 1
fi

if [ "${KERNEL_CONFIG}" == "" ]; then
    echo "ERROR: linux kernel configuration parameter is missing."
    exit 1
fi

if [ "${KERNEL_CONFIG}" != "x86_kvm_secure_release" ] && \
   [ "${KERNEL_CONFIG}" != "x86_kvm_guest_secure_release" ] && \
   [ "${KERNEL_CONFIG}" != "x86_debug" ] ; then
    echo "ERROR: linux kernel configuration (${KERNEL_CONFIG}) parameter is not valid."
    exit 1
fi

echo "Create kernel configuration: ${KERNEL_CONFIG}."
# Other possible configurations:
#    x86_kvm_release, x86_kvm_guest_release,
#    x86_kvm_secure_release, x86_kvm_guest_secure_release
/${BUILD_DIR}/config/defconfig_builder.sh -k /${BUILD_DIR}${LINUX_SRC} -t ${KERNEL_CONFIG}
pushd /${BUILD_DIR}${LINUX_SRC} > /dev/null
make ${KERNEL_CONFIG}_defconfig
popd > /dev/null

exit 0
