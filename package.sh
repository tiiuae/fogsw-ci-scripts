#!/bin/bash

usage() {
	echo "
Usage: $(basename "$0") [-h] [-m dir] [-b nbr] [-d dist] [-a arch] [-c commit_id]
 -- Generate debian package from fog_sw module.
Params:
    -h  Show help text.
    -m  Module directory to generate deb package from (MANDATORY).
    -b  Build number. This will be tha last digit of version string (x.x.N).
    -d  Distribution string in debian changelog.
    -a  Target architecture the module is built for. e.g. amd64, arm64.
    -r  ROS2 node packaging.
    -c  Commit id of the git repository HEAD
"
	exit 0
}

check_arg() {
	if [ "$(echo $1 | cut -c1)" = "-" ]; then
		return 1
	else
		return 0
	fi
}

error_arg() {
	echo "$0: option requires an argument -- $1"
	usage
}

mod_dir=""
build_nbr=0
distr=""
arch=""
version=""
ros=0
git_commit_hash=""

while getopts "hm:b:d:a:rc:" opt
do
	case $opt in
		h)
			usage
			;;
		m)
			check_arg $OPTARG && mod_dir=$OPTARG || error_arg $opt
			;;
		b)
			check_arg $OPTARG && build_nbr=$OPTARG || error_arg $opt
			;;
		d)
			check_arg $OPTARG && distr=$OPTARG || error_arg $opt
			;;
		a)
			check_arg $OPTARG && arch=$OPTARG || error_arg $opt
			;;
		r)
			ros=1
			;;
		c)
			check_arg $OPTARG && git_commit_hash=$OPTARG || error_arg $opt
			;;
		\?)
			usage
			;;
	esac
done

if [ "$mod_dir" = "" ]; then
	echo "$0: Module directory is mandatory option!"
	usage
else
	## Remove trailing '/' mark in module dir, if exists
	mod_dir=$(echo $mod_dir | sed 's/\/$//')
fi

if [ $ros = 1 ]; then
	:
else
	[ "$distr" = "" ] && distr="focal"
	[ "$arch" = "" ] && arch="amd64"
	version="1.0.0"
fi


## Debug prints
echo 
echo "mod_dir: $mod_dir"
echo "build_nbr: $build_nbr"
echo "distr: $distr"
echo "arch: $arch"
echo "ros: $ros"
echo "git_commit_hash: $git_commit_hash"


cd $mod_dir

## Generate package
echo "Creating deb package..."
if [ $ros = 1 ]; then
### ROS2 Packaging

	### Create version string
	sed -i "s/[0-9]*<\/version>/${build_nbr}<\/version>/" package.xml
	version=$(grep "<version>" package.xml | sed 's/[^>]*>\([^<"]*\).*/\1/')

	echo "version: ${version}"

	if [ -e ./packaging/rosdep.sh ]; then
		./packaging/rosdep.sh
	fi

	if [ ! -e /etc/ros/rosdep/sources.list.d/20-default.list ]; then
			echo "--- Initialize rosdep"
			sudo rosdep init
	fi
	echo "--- Updating rosdep"
	rosdep update

	title="$version ($(date +%Y-%m-%d))"
	cat << EOF_CHANGELOG > CHANGELOG.rst
$title
$(printf '%*s' "${#title}" | tr ' ' "-")
* commit: $(git rev-parse HEAD)
EOF_CHANGELOG

	bloom-generate rosdebian --os-name ubuntu --os-version focal --ros-distro foxy --place-template-files \
	&& sed -i "s/@(DebianInc)@(Distribution)//" debian/changelog.em \
	&& [ ! "$distr" = "" ] && sed -i "s/@(Distribution)/${distr}/" debian/changelog.em || : \
	&& bloom-generate rosdebian --os-name ubuntu --os-version focal --ros-distro foxy --process-template-files \
	&& sed -i 's/^\tdh_shlibdeps.*/& --dpkg-shlibdeps-params=--ignore-missing-info/g' debian/rules \
	&& fakeroot debian/rules clean \
	&& fakeroot debian/rules binary

else

	build_dir=$(mktemp -d)
	mkdir ${build_dir}/DEBIAN

	## Build the module
	##   module build.sh contains actions:
	##    - building binaries from sources
	##    - copy artifacts to the build_dir
	echo "Build the module..."
	if [ -e ./packaging/build.sh ]; then
		./packaging/build.sh $PWD ${build_dir}
	else
		echo "ERROR: No build script available"
		exit 1
	fi

	### Create version string
	version="1.0.${build_nbr}"
	#version=$(echo $version | sed "s/\([0-9]*\.[0-9]*\.\).*/\1/")${build_nbr}
	echo "version: ${version}"

	sed -i "s/VERSION/${version}/" ${build_dir}/DEBIAN/control
	cat ${build_dir}/DEBIAN/control

	### create changelog
	pkg_name=$(grep -oP '(?<=Package: ).*' ${build_dir}/DEBIAN/control)
	mkdir -p ${build_dir}/usr/share/doc/${pkg_name}
	cat << EOF > ${build_dir}/usr/share/doc/${pkg_name}/changelog.Debian
${pkg_name} (${version}) ${distribution}; urgency=high

  * commit: ${git_commit_hash}

 -- $(grep -oP '(?<=Maintainer: ).*' ${build_dir}/DEBIAN/control)  $(date +'%a, %d %b %Y %H:%M:%S %z')

EOF
	gzip ${build_dir}/usr/share/doc/${pkg_name}/changelog.Debian

	### create debian package
	debfilename=${pkg_name}_${version}_${arch}.deb
	echo "${debfilename}"
	fakeroot dpkg-deb --build ${build_dir} ../${debfilename}

fi

rm -rf ${build_dir}
echo "Done"
