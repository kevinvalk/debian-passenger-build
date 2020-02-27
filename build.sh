# Build the images
docker build . -t passenger-arm64v8 \
	--build-arg IMAGE=arm64v8/debian \
	--build-arg PASSENGER_VERSION=6.0.4 \
	--build-arg ARCHITECTURE=arm64

docker build . -t passenger-amd64 \
	--build-arg IMAGE=debian \
	--build-arg PASSENGER_VERSION=6.0.4 \
	--build-arg ARCHITECTURE=amd64

# Get the artifacts
containerid=$(docker create passenger-arm64v8)
docker cp $containerid:/artifacts deb-arm64v8
docker rm -f $containerid

containerid=$(docker create passenger-amd64)
docker cp $containerid:/artifacts deb-amd64
docker rm -f $containerid
