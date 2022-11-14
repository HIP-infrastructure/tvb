#!/bin/bash

# if [[ -z "$EBRAINS_TOKEN" ]]; then
# 	echo "no EBRAINS_TOKEN env var found, will now request EBRAINS user/pass to get token:"
# 	EBRAINS_TOKEN=$(python3 get_token.py)
# fi

set -eux

ub=ubuntu:20.04
docker pull $ub
docker tag $ub deploy-hip/nc-webdav:latest
docker build -t hip-deploy \
	--build-arg CI_REGISTRY_IMAGE=deploy-hip \
	--build-arg DAVFS2_VERSION=latest \
	--build-arg CARD=foo \
	--build-arg CI_REGISTRY=bar \
	--build-arg TAG=baz \
	--build-arg APP_NAME=tvb \
	--build-arg APP_VERSION=0.6 \
	--build-arg DOCKERFS_TYPE=nc-webdav \
	--build-arg DOCKERFS_VERSION=latest \
	.

	# --build-arg EBRAINS_TOKEN=$EBRAINS_TOKEN \
	
# this just adds a hip user
docker build -t hip-test -f test.dockerfile .

# start a container for testing
docker rm -f hip-test || true

docker run --rm -it --name hip-test \
	--entrypoint '' \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-e DISPLAY=$DISPLAY \
	-h $HOSTNAME \
	-v $XAUTHORITY:/home/hip/.Xauthority \
	--network none \
	-v /home/duke/nextcloud:/home/hip/nextcloud \
	-v /home/duke/subjects:/home/hip/subjects \
	-v /home/duke/tvb-pipeline:/home/hip/tvb-pipeline \
	-w /home/hip \
	hip-test \
	bash -c 'source /apps/tvb/conda/bin/activate && jupyter lab'
