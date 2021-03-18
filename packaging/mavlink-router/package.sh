#!/bin/bash

build_nbr=$1
distr=${2:-focal}
arch=${3:-amd64}

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
	distribution=$2
	architecture=$3
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
	cat << EOF > ${build_dir}/usr/share/doc/${pkg_name}/changelog.Debian
${pkg_name} (${version}) ${distribution}; urgency=high

  * commit: $(get_commit)

 -- $(grep -oP '(?<=Maintainer: ).*' ${build_dir}/DEBIAN/control)  $(date +'%a, %d %b %Y %H:%M:%S %z')

EOF
	gzip ${build_dir}/usr/share/doc/${pkg_name}/changelog.Debian

	debfilename=${pkg_name}_${version}_${architecture}.deb
	echo "${debfilename}"
	fakeroot dpkg-deb --build ${build_dir} ./${debfilename}
	echo "Done"
	rm -rf ${build_dir}
}

build_dir=$(mktemp -d)
version=2.0.${build_nbr}
build
make_deb $version $distr $arch
