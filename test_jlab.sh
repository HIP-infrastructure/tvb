#!/bin/bash

docker build -t jlab -f jlab.dockerfile .

docker rm -f jlab-test || true

docker run --rm -it --name jlab-test \
	--entrypoint '' \
	--shm-size=1g \
	--gpus all \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-e DISPLAY=$DISPLAY \
	-h $HOSTNAME \
	-v $XAUTHORITY:/root/.Xauthority \
	-v $XAUTHORITY:/home/hip/.Xauthority \
	jlab \
	bash
