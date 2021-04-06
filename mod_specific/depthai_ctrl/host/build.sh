build_dir=$1
dest_dir=$2

# Copy debian files from mod_specific directory
cp ${build_dir}/debian/* ${dest_dir}/DEBIAN/

mkdir -p ${dest_dir}/usr/local/bin
mkdir -p ${dest_dir}/etc/udev/rules.d
cp movidius_usb_hotplug.sh ${dest_dir}/usr/local/bin/
cp 80-movidius-host.rules ${dest_dir}/etc/udev/rules.d/
chmod +x ${dest_dir}/usr/local/bin/movidius_usb_hotplug.sh
chmod 644 ${dest_dir}/etc/udev/rules.d/80-movidius-host.rules
