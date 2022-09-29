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
	--build-arg APP_NAME=tvb \
	--build-arg APP_VERSION=0.6 \
	.

	# --build-arg EBRAINS_TOKEN=$EBRAINS_TOKEN \
	
# this just adds a hip user
docker build -t hip-test -f test.dockerfile .

# start a container for testing
docker rm -f hip-test || true
docker run -d --name hip-test \
	--entrypoint '' \
	-p 127.0.0.1:8888:8888 \
	-v /home/duke/nextcloud:/home/hip/nextcloud \
	-v /home/duke/subjects:/home/hip/subjects \
	-v /home/duke/tvb-pipeline:/home/hip/tvb-pipeline \
	-w /home/hip \
	hip-test \
	bash -c 'source /apps/tvb/conda/bin/activate && jupyter lab --ip=0.0.0.0'
sleep 10
docker logs hip-test
