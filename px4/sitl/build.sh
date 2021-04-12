#!/bin/bash

# Usage: build.sh <px4-source-dir> <output-dir>

set -e

if [ "$1" = "" ]; then
	echo "ERROR: PX4 source directory not given"
	echo " usage: $0 <px4-source-dir> <output-dir>"
	exit 1
fi

build_dir=$(realpath $1)
script_dir=$(dirname $(realpath $0))
output_dir=$(realpath ${2:-${build_dir}})

cd ${build_dir}

git_version_string=$(git log --date=format:%Y%m%d --pretty=git%cd.%h -n 1)

# Copy Dockerfile and tools
cp -f $script_dir/Dockerfile .

# Generate debian package
iname=tii-px4-sitl-artifacts
docker build -t ${iname} .
container_id=$(docker create ${iname} "")
mkdir -p tmp_
pushd tmp_
docker cp ${container_id}:/px4_sitl .
docker rm ${container_id}
mkdir -p $output_dir
tar czvf $output_dir/px4_sitl_build-${git_version_string}.tar.gz px4_sitl
popd
rm -Rf tmp_
