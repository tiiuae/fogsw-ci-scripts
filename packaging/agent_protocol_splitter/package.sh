#!/bin/bash

build_nbr=$1

get_commit() {
	cd agent_protocol_splitter
	echo $(git rev-parse HEAD)
}

build() {
	pushd agent_protocol_splitter/src
	cmake ..
	make || exit 1
	cp protocol_splitter ../.. && make clean
	popd
}

make_deb() {
	version=$1
	echo "Creating deb package..."
	build_dir=$(mktemp -d)
	mkdir ${build_dir}/DEBIAN
	mkdir -p ${build_dir}/usr/bin/
	mkdir -p ${build_dir}/etc/systemd/system
	cp debian/control ${build_dir}/DEBIAN/
	cp debian/postinst ${build_dir}/DEBIAN/
	cp debian/prerm ${build_dir}/DEBIAN/
	cp protocol_splitter ${build_dir}/usr/bin/

	sed -i "s/VERSION/${version}/" ${build_dir}/DEBIAN/control
	cat ${build_dir}/DEBIAN/control

	# create changelog
	pkg_name=$(grep -oP '(?<=Package: ).*' ${build_dir}/DEBIAN/control)
	mkdir -p ${build_dir}/usr/share/doc/${pkg_name}
	echo "${pkg_name} (${version}-0focal) focal; urgency=high" > ${build_dir}/usr/share/doc/${pkg_name}/changelog.Debian
	echo >> ${build_dir}/usr/share/doc/${pkg_name}/changelog.Debian
	echo "  * commit: $(get_commit)" >> ${build_dir}/usr/share/doc/${pkg_name}/changelog.Debian
	echo >> ${build_dir}/usr/share/doc/${pkg_name}/changelog.Debian
	echo " -- $(grep -oP '(?<=Maintainer: ).*' ${build_dir}/DEBIAN/control)  $(date +'%a, %d %b %Y %H:%M:%S %z')" >> ${build_dir}/usr/share/doc/${pkg_name}/changelog.Debian
	echo >> ${build_dir}/usr/share/doc/${pkg_name}/changelog.Debian
	gzip ${build_dir}/usr/share/doc/${pkg_name}/changelog.Debian

	echo agent_protocol_splitter_${version}_amd64.deb
	fakeroot dpkg-deb --build ${build_dir} ./agent-protocol-splitter_${version}_amd64.deb
	rm -rf ${build_dir}
	echo "Done"
}

version=1.0.${build_nbr}
build
make_deb $version
