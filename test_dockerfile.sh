#!/bin/bash

# if [[ -z "$EBRAINS_TOKEN" ]]; then
# 	echo "no EBRAINS_TOKEN env var found, will now request EBRAINS user/pass to get token:"
# 	EBRAINS_TOKEN=$(python3 get_token.py)
# fi

set -eux

# some versions & metadata
base='ubuntu:22.04'
ci_registry_image=deploy-hip
davfs2_version=latest
dockerfs_type=nc-webdav
dockerfs_version=latest
card=foo
ci_registry=bar
tag=''
fs_ver=7.4.1
fsl_ver=6.0.6
tvb_ver=0.6

# build image, hip style
function make_hip_image() {
	app_name=$1
	app_ver=$2
	app_build_ctx=$3
	docker build -t ${ci_registry_image}/${app_name}:${app_ver}${tag} \
		--build-arg CI_REGISTRY_IMAGE=${ci_registry_image} \
		--build-arg CARD=${card} \
		--build-arg CI_REGISTRY=${ci_registry} \
		--build-arg TAG=${tag} \
		--build-arg APP_NAME=${app_name} \
		--build-arg APP_VERSION=${app_ver} \
		--build-arg DOCKERFS_TYPE=${dockerfs_type} \
		--build-arg DOCKERFS_VERSION=${dockerfs_version} \
		--build-arg FREESURFER_VERSION=${fs_ver} \
		--build-arg FSL_VERSION=${fsl_ver} \
		$app_build_ctx
}

# get started
docker pull $base
docker tag $base ${ci_registry_image}/${dockerfs_type}:${dockerfs_version}${tag}

# shim directories for fs & fsl stages
mkdir -p ./stage-{fs,fsl}/scripts
mkdir -p ./stage-{fs,fsl}/apps/{freesurfer,fsl}/config

# build images
make_hip_image freesurfer $fs_ver ./stage-fs
make_hip_image fsl $fsl_ver ./stage-fsl
make_hip_image tvb $tvb_ver ./

# test image & container
docker build -t hip-test \
	--build-arg fromimage=${ci_registry_image}/tvb:${tvb_ver}${tag} \
	-f test.dockerfile .

# start a container for testing
docker rm -f hip-test || true

# x11 isn't available via rdp (on wsl) so make gui args conditional
set +u
guiargs="
	--device=/dev/dri:/dev/dri \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-e DISPLAY=$DISPLAY \
	--shm-size=1g \
	--gpus all \
"
#	-v $XAUTHORITY:/root/.Xauthority \
#	-v $XAUTHORITY:/home/hip/.Xauthority \
if [[ -z "$DISPLAY" ]]; then guiargs=""; fi
echo guiargs=$guiargs

docker run --rm -it --name hip-test \
	--entrypoint '' \
	-h tvb \
	$guiargs \
	-p 127.0.0.1:8888:8888 \
	-w /home/woodman \
	-v /mnt/d/hip-prod:/home/woodman/nextcloud \
	hip-test \
	jlab-entry.sh

# jlab-entry startweb
