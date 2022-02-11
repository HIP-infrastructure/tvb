#!/bin/bash

if [[ -z "$EBRAINS_TOKEN" ]]; then
	echo "no EBRAINS_TOKEN env var found, will now request EBRAINS user/pass to get token:"
	EBRAINS_TOKEN=$(python3 get_token.py)
fi

set -eux

docker pull ubuntu
docker tag ubuntu deploy-hip/nc-webdav:latest
docker build -t hip-deploy \
	--build-arg CI_REGISTRY_IMAGE=deploy-hip \
	--build-arg DAVFS2_VERSION=latest \
	--build-arg CARD=foo \
	--build-arg CI_REGISTRY=bar \
	--build-arg APP_NAME=tvb \
	--build-arg APP_VERSION=0.4 \
	--build-arg EBRAINS_TOKEN=$EBRAINS_TOKEN \
	.
