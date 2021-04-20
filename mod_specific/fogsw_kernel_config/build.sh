#!/bin/bash

build_dir=$1

echo "$PWD Create kernel configuration."
/${build_dir}/config/defconfig_builder.sh -k /${build_dir}/linux-hwe-5.8-5.8.0/ -t x86_kvm_release
pushd /${build_dir}/linux-hwe-5.8-5.8.0/ > /dev/null
make x86_kvm_release_defconfig
popd > /dev/null

exit 0
