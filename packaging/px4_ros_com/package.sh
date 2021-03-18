build_nbr=$1
distr=${2:-focal}

echo "--- Generating /etc/ros/rosdep/sources.list.d/50-fogsw.list (as su)"
mkdir -p /etc/ros/rosdep/sources.list.d

echo "px4_msgs: \n    ubuntu: ros-foxy-px4-msgs \n" > rosdep.yaml
echo "yaml file://${PWD}/rosdep.yaml" > /etc/ros/rosdep/sources.list.d/50-fogsw.list

if [ ! -e /etc/ros/rosdep/sources.list.d/20-default.list ]; then
        echo "--- Initialize rosdep"
        sudo rosdep init
fi
echo "--- Updating rosdep"
rosdep update

cd px4_ros_com
sed -i "s/[0-9]*<\/version>/${build_nbr}<\/version>/" package.xml
version=$(grep "<version>" package.xml | sed 's/[^>]*>\([^<"]*\).*/\1/')
title="$version ($(date +%Y-%m-%d))"
dashes=$(printf '%*s' "${#title}" | tr ' ' "=")
echo "$title" > CHANGELOG.rst
echo "$dashes" >> CHANGELOG.rst
echo "* commit: $(git rev-parse HEAD)" >> CHANGELOG.rst

bloom-generate rosdebian --os-name ubuntu --os-version focal --ros-distro foxy --place-template-files \
&& sed -i "s/@(DebianInc)@(Distribution)//" debian/changelog.em \
&& [ ! "$distr" = "" ] && sed -i "s/@(Distribution)/${distr}/" debian/changelog.em || : \
&& bloom-generate rosdebian --os-name ubuntu --os-version focal --ros-distro foxy --process-template-files \
&& sed -i 's/^\tdh_shlibdeps.*/& --dpkg-shlibdeps-params=--ignore-missing-info/g' debian/rules \
&& fakeroot debian/rules binary
cd ..
