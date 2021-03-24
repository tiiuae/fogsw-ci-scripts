build_dir=$1
dest_dir=$2

# Copy debian files from mod_specific directory
cp ${build_dir}/packaging/debian/* ${dest_dir}/DEBIAN/

cd $build_dir/src
cmake ..
make || exit 1
mkdir -p ${dest_dir}/usr/bin/
cp protocol_splitter $dest_dir/usr/bin/ && make clean
