#!/bin/bash

# usage: ./package.sh path_to_firmware dest_dir

set -e

if [ "$1" = "" ]; then
	echo "ERROR: PX4 firmware source directory not given"
	echo " usage: $0 <px4-fw-source-dir> <output-dir>"
	exit 1
elif [ "$2" = "" ]; then
	echo "ERROR: Package output directory not given"
	echo " usage: $0 <px4-fw-source-dir> <output-dir>"
	exit 1
fi

fw_dir=$(realpath $1)
script_dir=$(dirname $(realpath $0))
dest_dir=$(realpath $2)


build_px4() {
	pushd ${fw_dir}

	# Copy Dockerfile and tools
	cp -f $script_dir/Dockerfile .

	# Generate debian package
	iname=tii-px4-pixhawk-artifacts
	docker build -t ${iname} .
	container_id=$(docker create ${iname} "")
	mkdir -p tmp_
	pushd tmp_
	docker cp ${container_id}:/artifacts .
	docker rm ${container_id}
	mkdir -p ${packaging_dir}/opt/px4fwupdater/
	cp artifacts/* ${packaging_dir}/opt/px4fwupdater/
	popd
	rm -Rf tmp_
	popd
}

make_deb() {
	echo "Creating deb package..."
	mkdir ${packaging_dir}/DEBIAN/

	cp ${script_dir}/debian/control ${packaging_dir}/DEBIAN/
	cp ${script_dir}/debian/postinst ${packaging_dir}/DEBIAN/
	cp ${script_dir}/debian/prerm ${packaging_dir}/DEBIAN/

	pushd ${fw_dir}
	version=$(git describe --always --tags --dirty | sed 's/^v//')
	popd
	sed -i "s/Version:.*/&${version}/" ${packaging_dir}/DEBIAN/control

	cat ${packaging_dir}/DEBIAN/control
	echo px4fwupdater_${version}_amd64.deb
	fakeroot dpkg-deb --build ${packaging_dir} ${dest_dir}/px4fwupdater_${version}_amd64.deb

	px4_in_file=$(basename $(find ${packaging_dir}/opt/px4fwupdater/*.px4))
	px4_out_file=$(echo ${px4_in_file} | sed "s/\(.*\)\.px4/\1-${version}.px4/")
	echo "px4_in_file: $px4_in_file"
	echo "px4_out_file: $px4_out_file"
	cp ${packaging_dir}/opt/px4fwupdater/${px4_in_file} ${dest_dir}/${px4_out_file}
}

mkdir -p ${dest_dir}
packaging_dir=$(mktemp -d)
build_px4
make_deb
rm -rf ${packaging_dir}
echo "Done"
