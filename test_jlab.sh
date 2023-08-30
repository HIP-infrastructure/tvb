#!/bin/bash

docker build -t jlab -f jlab.dockerfile .

docker rm -f jlab-test || true

mkdir nextcloud
docker run --rm -it --name jlab-test \
	--shm-size=1g \
	--gpus all \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-e DISPLAY=$DISPLAY \
	-h $HOSTNAME \
	-p 127.0.0.1:8888:8888 \
	-v $XAUTHORITY:/home/hip/.Xauthority \
	-v $PWD/nextcloud:/home/hip/nextcloud \
	jlab jlab-entry.sh startapp
