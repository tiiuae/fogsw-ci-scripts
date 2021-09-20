#!/bin/bash

BUILD_DIR=$1
# This variable is ignored.
TMP_DEB_DIR=$2
# $3 is the MODULE_GEN_CONFIG variable coming from environment.
KERNEL_CONFIG=$3

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

if [ "${KERNEL_CONFIG}" != "x86_kvm_secure_release" ] && \
   [ "${KERNEL_CONFIG}" != "x86_kvm_guest_secure_release" ] && \
   [ "${KERNEL_CONFIG}" != "x86_debug" ] && \
   [ "${KERNEL_CONFIG}" != "fog" ]; then
    echo "ERROR: linux kernel configuration (${KERNEL_CONFIG}) parameter is not valid."
    exit 1
fi

echo "Create kernel configuration: ${KERNEL_CONFIG}."
# Other possible configurations:
#    x86_kvm_release, x86_kvm_guest_release,
#    x86_kvm_secure_release, x86_kvm_guest_secure_release
#    ubuntu
if [ "${KERNEL_CONFIG}" == "fog" ]; then
    cp /${BUILD_DIR}/config/config-5.11.0-34-generic /${BUILD_DIR}${LINUX_SRC}/arch/x86/configs/${KERNEL_CONFIG}_defconfig
    pushd /${BUILD_DIR}${LINUX_SRC} > /dev/null
    make ${KERNEL_CONFIG}_defconfig
    scripts/config --set-str SYSTEM_TRUSTED_KEYS ""
    scripts/config --set-str SYSTEM_REVOCATION_KEYS ""
    scripts/config --enable ATH_REG_DYNAMIC_USER_REG_HINTS
    scripts/config --enable ATH_REG_DYNAMIC_USER_CERT_TESTING
    scripts/config --enable CFG80211_CERTIFICATION_ONUS
    popd > /dev/null
else
    /${BUILD_DIR}/config/defconfig_builder.sh -k /${BUILD_DIR}${LINUX_SRC} -t ${KERNEL_CONFIG}
    pushd /${BUILD_DIR}${LINUX_SRC} > /dev/null
    make ${KERNEL_CONFIG}_defconfig
    popd > /dev/null
fi

exit 0
