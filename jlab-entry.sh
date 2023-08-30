#!/bin/bash

# the hip app will run the desktop electron app via `startapp`, but for dev
# purposes, we want to be able to connect to the identical jupyter env via
# normal web browser, using `startweb`.

# it's useful for code to know whether we're live on hip or in dev
if mount | grep GhostFS; then TVB_ON_HIP=yes; else TVB_ON_HIP=no; fi

function startweb() {
cd $HOME
mkdir -p $HOME/.jupyter/lab/user-settings/@jupyterlab/apputils-extension
# TODO consider a merge instead of overwrite?
cat > $HOME/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/notification.jupyterlab-settings <<EOF
{
    "checkForUpdates": false,
    "doNotDisturbMode": false,
    "fetchNews": "false"
}
EOF
# this should inherit dockerfile env vars, but this is still insufficient
jupyter lab --ip=0.0.0.0 --no-browser
}

function startapp() {
mkdir -p $HOME/.config/jupyterlab-desktop/lab/user-settings/@jupyterlab/apputils-extension
# TODO need to collect important env vars into this
cat > $HOME/.config/jupyterlab-desktop/settings.json <<EOF
{
  "checkForUpdatesAutomatically": false,
  "installUpdatesAutomatically": false,
  "pythonPath": "/usr/bin/python",
  "serverArgs": "",
  "serverEnvVars": {
    "SHELL": "/bin/bash",
    "FREESURFER_HOME": "$FREESURFER_HOME"
  },
  "startupMode": "restore-sessions"
}
EOF
# TODO consider a merge instead of overwrite?
cat > $HOME/.config/jupyterlab-desktop/lab/user-settings/@jupyterlab/apputils-extension/notification.jupyterlab-settings <<EOF
{
    "checkForUpdates": false,
    "doNotDisturbMode": false,
    "fetchNews": "false"
}
EOF
jlab --no-sandbox $HOME/welcome.ipynb
}

# in both cases, copy the welcome notebook into place
# TODO use the tvb_hip package for this
cp /opt/welcome.ipynb $HOME/welcome.ipynb

$1
