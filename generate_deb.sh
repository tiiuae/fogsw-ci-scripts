#!/bin/bash

if [ "$1" = "" ]; then
	echo "ERROR: module root directory not given"
	echo " usage: $0 <module root dir>"
	exit 1
fi

build_dir=$(realpath $1)
script_dir=$(dirname $(realpath $0))
name=$(basename $build_dir)

# Copy mod_specific files if not available already
if [ -d ${script_dir}/mod_specific/$name ]; then
	cp -R ${script_dir}/mod_specific/$name/* ${build_dir}/packaging/
fi

# Prepare Dockerfile
cp ${build_dir}/packaging/common/Dockerfile.template ./Dockerfile
if [ -e ${build_dir}/packaging/Dockerfile.dep ]; then
	sed -i '/^### INCLUDE_DEPENDENCIES/ r packaging/Dockerfile.dep' Dockerfile
fi

# Generate debian package
iname=fogsw-${name,,}
docker build --build-arg BUILD_NUMBER=${GITHUB_RUN_NUMBER} --build-arg DISTRIBUTION=${DISTRIBUTION} -t ${iname} .
container_id=$(docker create ${iname} "")
docker cp ${container_id}:/packages .
docker rm ${container_id}
cp packages/*.deb .
rm -Rf packages

