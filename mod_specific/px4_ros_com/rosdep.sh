#!/bin/bash

## for installing px4_msgs from debian package instead of apt

mkdir -p /etc/ros/rosdep/sources.list.d
cat << EOF > rosdep.yaml
px4_msgs:
    ubuntu: ros-foxy-px4-msgs

EOF
echo "yaml file://${PWD}/rosdep.yaml" > /etc/ros/rosdep/sources.list.d/50-fogsw.list
