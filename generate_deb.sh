#!/bin/bash

name=$1
url=$2

if [ -d $name ]; then
	rm -Rf $name
fi

git clone $url $name
cd $name
git submodule update --init --recursive
cd ..

grep -B100000 "### INCLUDE_DEPENDENCIES" Dockerfile.template | head -n -1 > Dockerfile
if [ -e $name/packaging/Dockerfile.dep ]; then
	cat $name/packaging/Dockerfile.dep >> Dockerfile
elif [ -e ./mod_specific/$name/Dockerfile.dep ]; then
	cat ./mod_specific/$name/Dockerfile.dep >> Dockerfile
fi
grep -A100000 "### INCLUDE_DEPENDENCIES" Dockerfile.template | tail -n +2 >> Dockerfile


docker build --build-arg BUILD_NUMBER=${GITHUB_RUN_NUMBER} --build-arg DISTRIBUTION=${DISTRIBUTION} --build-arg DIRECTORY=${name} -t fogsw-${name} .
container_id=$(docker create fogsw-${name} "")
docker cp ${container_id}:/packages .
docker rm ${container_id}
cp packages/*.deb .
rm -Rf packages
rm -Rf $name
