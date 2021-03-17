url=https://github.com/tiiuae/mesh_com.git
name=mesh_com

if [ -d $name ]; then
	rm -Rf $name
fi

git clone $url $name
cd $name
git submodule update --init --recursive
cd ..
docker build --build-arg BUILD_NUMBER=${GITHUB_RUN_NUMBER} -t fogsw-${name} .
container_id=$(docker create fogsw-${name} "")
docker cp ${container_id}:/packages .
docker rm ${container_id}
cp packages/*.deb ..
rm -Rf packages
rm -Rf $name
