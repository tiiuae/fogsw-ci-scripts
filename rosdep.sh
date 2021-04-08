#!/bin/bash

## for installing additional non-ROS2 dependencies to debian package generated by bloom


if [ ! -e /etc/ros/rosdep/sources.list.d/20-default.list ]; then
        echo "--- Initialize rosdep"
        sudo rosdep init
fi

yamlpath=""
if [ -e $1/rosdep.yaml ]; then
    yamlpath=$1/rosdep.yaml
elif [ -e $1/packaging/rosdep.yaml ]; then
    yamlpath=$1/packaging/rosdep.yaml
fi

if [ "$yamlpath" != "" ]; then
    echo "--- Add module specific dependencies"
    cat $yamlpath
    mkdir -p /etc/ros/rosdep/sources.list.d
    echo "yaml file://${yamlpath}" > /etc/ros/rosdep/sources.list.d/51-fogsw-module.list
fi

echo "--- Updating rosdep"
rosdep update