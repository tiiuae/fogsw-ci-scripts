#!/bin/bash

build_dir=$1
dest_dir=$2

source /opt/ros/foxy/setup.bash

# Copy debian files from mod_specific directory
cp ${build_dir}/packaging/debian/* ${dest_dir}/DEBIAN/

cd ${build_dir}
./gradlew build
mkdir -p ${dest_dir}/usr/bin/
mkdir -p ${dest_dir}/usr/share/fastddsgen/java/
cp build/libs/fastddsgen.jar ${dest_dir}/usr/share/fastddsgen/java/
cp scripts/fastddsgen ${dest_dir}/usr/bin/
