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

echo "Build and package Linux Kernel."
pushd /${BUILD_DIR}${LINUX_SRC} > /dev/null
fakeroot make-kpkg --initrd --revision=1 --jobs $(nproc) kernel_image
mv ../*.deb /
popd > /dev/null

exit 0

