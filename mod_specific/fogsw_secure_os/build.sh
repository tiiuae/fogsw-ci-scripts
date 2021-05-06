#!/bin/bash

build_dir=$1
dest_dir=$2

# Copy debian files from mod_specific directory
cp ${build_dir}/debian/* ${dest_dir}/DEBIAN/
cp -r ${build_dir}/etc ${dest_dir}

exit 0

