build_dir=$1
dest_dir=$2

# Copy debian files from mod_specific directory
cp ${build_dir}/packaging/debian/* ${dest_dir}/DEBIAN/

cd $build_dir
./autogen.sh && ./configure CFLAGS='-O2' --sysconfdir=/etc --localstatedir=/var --libdir=/usr/lib64 --prefix=/usr --disable-systemd
make || exit 1
make DESTDIR=${dest_dir} install

mkdir -p ${dest_dir}/etc/mavlink-router/
cp ${build_dir}/main.uart.conf  ${dest_dir}/etc/mavlink-router/
cp ${build_dir}/main.eth.conf  ${dest_dir}/etc/mavlink-router/
