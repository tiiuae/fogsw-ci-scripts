#!/bin/bash

# Usage: generate_deb.sh <module-dir> <deb-output-dir> <sub-path>

set -e

if [ "$1" = "" ]; then
	echo "ERROR: module root directory not given"
	echo " usage: $0 <module-dir> <deb-output-dir> <sub-path>"
	exit 1
fi

build_base_dir=$(realpath $1)
build_dir=$build_base_dir
script_dir=$(dirname $(realpath $0))
output_dir=$(realpath ${2:-${build_base_dir}})

pushd ${build_base_dir}
name=$(basename $(git config --get remote.origin.url) | sed 's/.git//')
popd

mod_specific_path=${script_dir}/mod_specific/${name}

sub_path=${3}
if [ "$sub_path" != "" ]; then
	build_dir=$build_dir/$sub_path
	mod_specific_path=$mod_specific_path/$sub_path
fi

# Copy CI/CD scripts to module path
mkdir -p ${build_dir}/packaging/common
cp -f -R ${script_dir}/* ${build_dir}/packaging/common/

# Copy mod_specific files if not available already
if [ -d $mod_specific_path ]; then
	cp -f -R $mod_specific_path/* ${build_dir}/packaging/
fi

cd ${build_base_dir}
# Prepare Dockerfile
cp -f ${build_dir}/packaging/common/Dockerfile.template ./Dockerfile
if [ -e ${build_dir}/packaging/Dockerfile.dep ]; then
	cp ${build_dir}/packaging/Dockerfile.dep .
	sed -i '/^### INCLUDE_DEPENDENCIES/ r ./Dockerfile.dep' ./Dockerfile
fi

# Generate debian package
iname=fogsw-${name,,}
docker build --build-arg COMMIT_ID=$(git rev-parse HEAD) \
	--build-arg GIT_VER=$(git log --date=format:%Y%m%d --pretty=~git%cd.%h -n 1) \
	--build-arg BUILD_NUMBER=${GITHUB_RUN_NUMBER} \
	--build-arg PACKAGE_SUBDIR=${sub_path} \
	--build-arg DISTRIBUTION=${DISTRIBUTION} -t ${iname} .
container_id=$(docker create ${iname} "")
docker cp ${container_id}:/packages .
docker rm ${container_id}
mkdir -p $output_dir
cp packages/*.deb $output_dir
rm -Rf packages
