#!/bin/bash

# usage: ./package.sh path_to_firmware dest_dir <build_number>

set -e

if [ "$1" = "" ]; then
	echo "ERROR: PX4 firmware source directory not given"
	echo " usage: $0 <px4-fw-source-dir> <output-dir> <build-number>"
	exit 1
elif [ "$2" = "" ]; then
	echo "ERROR: Package output directory not given"
	echo " usage: $0 <px4-fw-source-dir> <output-dir> <build-number>"
	exit 1
fi

fw_dir=$(realpath $1)
script_dir=$(dirname $(realpath $0))
dest_dir=$(realpath $2)
build_nbr=${3-:0}


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

	cp debian/control ${packaging_dir}/DEBIAN/
	cp debian/postinst ${packaging_dir}/DEBIAN/
	cp debian/prerm ${packaging_dir}/DEBIAN/

	sed -i "s/Version:.*/&.${build_nbr}/" ${packaging_dir}/DEBIAN/control
	version=$(grep Version ${packaging_dir}/DEBIAN/control | cut -d' ' -f2)

	cat ${packaging_dir}/DEBIAN/control
	echo px4fwupdater_${version}_amd64.deb
	fakeroot dpkg-deb --build ${packaging_dir} ${dest_dir}/px4fwupdater_${version}_amd64.deb
}

packaging_dir=$(mktemp -d)
build_px4
make_deb
rm -rf ${packaging_dir}
echo "Done"
