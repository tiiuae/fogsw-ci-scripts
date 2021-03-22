#!/bin/bash

build_dir=$1
dest_dir=$2

cd ${build_dir}
go mod download || exit
go build || exit
mkdir -p ${dest_dir}/usr/bin
cp -f communication_link ${dest_dir}/usr/bin/ && go clean || exit

cd videonode || exit
go mod download || exit
go build || exit
cp -f config.yml ${dest_dir}/usr/bin/ || exit
cp -f videonode ${dest_dir}/usr/bin/ && go clean || exit

cd ..
cp packaging/debian/* ${dest_dir}/DEBIAN/
