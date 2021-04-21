#!/bin/bash

build_dir=$1

echo "Build and package Linux Kernel."
pushd /${build_dir}/linux-hwe-5.8-5.8.0/ > /dev/null
fakeroot make-kpkg --initrd --revision=1.0.custom --jobs $(nproc) kernel_image
mv ../*.deb /
popd > /dev/null

exit 0

