url=https://github.com/tiiuae/sim_mesh_distances.git
name=sim_mesh_distances

if [ -d $name ]; then
	rm -Rf $name
fi

git clone $url $name
cd $name
git submodule update --init --recursive
cd ..
docker build -t fogsw-${name} .
container_id=$(docker create fogsw-${name} "")
docker cp ${container_id}:/packages .
docker rm ${container_id}
cp packages/*.deb ..
rm -Rf packages
rm -Rf $name
