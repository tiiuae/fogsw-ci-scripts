#!/bin/bash

build_nbr=$1

get_commit() {
	cd mavlink-router
	echo $(git rev-parse HEAD)
}

build() {
	pushd mavlink-router
	./autogen.sh && ./configure CFLAGS='-O2' --sysconfdir=/etc --localstatedir=/var --libdir=/usr/lib64 --prefix=/usr --disable-systemd
	make || exit 1
	make DESTDIR=${build_dir} install
	popd
}

make_deb() {
	version=$1
	echo "Creating deb package..."

	mkdir ${build_dir}/DEBIAN
	cp debian/control ${build_dir}/DEBIAN/
	cp debian/postinst ${build_dir}/DEBIAN/
	cp debian/prerm ${build_dir}/DEBIAN/
	mkdir -p ${build_dir}/etc/mavlink-router/
	cp main.conf  ${build_dir}/etc/mavlink-router/

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

	echo mavlink_router_${version}_amd64.deb
	fakeroot dpkg-deb --build ${build_dir} ./mavlink-router_${version}_amd64.deb
	echo "Done"
}

build_dir=$(mktemp -d)
version=2.0.${build_nbr}
build
make_deb $version
