#!/bin/bash

source /apps/tvb-hip/setup-env.sh
export HOME=/home/$(whoami)
echo "HOME is $HOME"
cp /apps/tvb/hip-tvb-app*/*.ipynb $HOME/
cp -r /apps/tvb/hip-tvb-app*/tvb-pipeline $HOME/
jlab=/apps/tvb-hip/jupyterlab_app
$jlab/node_modules/electron/dist/electron --no-sandbox $jlab