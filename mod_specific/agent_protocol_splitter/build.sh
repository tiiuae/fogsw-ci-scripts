build_dir=$1
dest_dir=$2

# Copy debian files from mod_specific directory
cp ../mod_specific/agent_protocol_splitter/debian/control ${dest_dir}/DEBIAN/
cp ../mod_specific/agent_protocol_splitter/debian/postinst ${dest_dir}/DEBIAN/
cp ../mod_specific/agent_protocol_splitter/debian/prerm ${dest_dir}/DEBIAN/

cd $build_dir/src
cmake ..
make || exit 1
mkdir -p ${dest_dir}/usr/bin/
cp protocol_splitter $dest_dir/usr/bin/ && make clean
