#!/bin/bash

# usage: ./package.sh path_to_bootloader dest_dir

set -e

if [ "$1" = "" ]; then
	echo "ERROR: PX4 bootloader source directory not given"
	echo " usage: $0 <px4-bl-source-dir> <output-dir>"
	exit 1
elif [ "$2" = "" ]; then
	echo "ERROR: Package output directory not given"
	echo " usage: $0 <px4-bl-source-dir> <output-dir>"
	exit 1
fi

fw_dir=$(realpath $1)
script_dir=$(dirname $(realpath $0))
dest_dir=$(realpath $2)


build_px4_bl() {
	pushd ${fw_dir}

	# Copy Dockerfile and tools
	cp -f $script_dir/Dockerfile .

	# Generate debian package
	iname=tii-px4-pixhawk-bl-artifacts
	docker build -t ${iname} .
	container_id=$(docker create ${iname} "")
	mkdir -p tmp_
	pushd tmp_
	docker cp ${container_id}:/artifacts .
	docker rm ${container_id}

	version=$(git describe --always --tags --dirty | sed 's/^v//')
	cd artifacts
	tar czvf ${dest_dir}/px4fmuv5_bl-${version}.tar.gz *

	popd
	rm -Rf tmp_
	popd
}

mkdir -p ${dest_dir}
build_px4_bl
echo "Done"
