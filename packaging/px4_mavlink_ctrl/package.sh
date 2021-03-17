build_nbr=$1

echo "--- Generating /etc/ros/rosdep/sources.list.d/50-fogsw.list (as su)"
mkdir -p /etc/ros/rosdep/sources.list.d

echo "mavsdk: \n    ubuntu: mavsdk \n" > rosdep.yaml
echo "yaml file://${PWD}/rosdep.yaml" > /etc/ros/rosdep/sources.list.d/50-fogsw.list

if [ ! -e /etc/ros/rosdep/sources.list.d/20-default.list ]; then
        echo "--- Initialize rosdep"
        sudo rosdep init
fi
echo "--- Updating rosdep"
rosdep update

cd px4_mavlink_ctrl

sed -i "s/[0-9]*<\/version>/${build_nbr}<\/version>/" package.xml
version=$(grep "<version>" package.xml | sed 's/[^>]*>\([^<"]*\).*/\1/')
title="$version ($(date +%Y-%m-%d))"
dashes=$(printf '%*s' "${#title}" | tr ' ' "=")
echo "$title" > CHANGELOG.rst
echo "$dashes" >> CHANGELOG.rst
echo "* commit: $(git rev-parse HEAD)" >> CHANGELOG.rst

bloom-generate rosdebian --os-name ubuntu --os-version focal --ros-distro foxy \
&& sed -i 's/^\tdh_shlibdeps.*/& --dpkg-shlibdeps-params=--ignore-missing-info/g' debian/rules \
&& fakeroot debian/rules binary
cd ..
