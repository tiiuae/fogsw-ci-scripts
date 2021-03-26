#!/bin/bash

build_dir=$1
dest_dir=$2

source /opt/ros/foxy/setup.bash

# Copy debian files from mod_specific directory
cp ${build_dir}/packaging/debian/* ${dest_dir}/DEBIAN/

cd ${build_dir}
./gradlew build
mkdir -p ${dest_dir}/usr/bin/
mkdir -p ${dest_dir}/usr/share/fastrtpsgen/java/
cp build/libs/fastrtpsgen.jar ${dest_dir}/usr/share/fastrtpsgen/java/
cp scripts/fastrtpsgen ${dest_dir}/usr/bin/
