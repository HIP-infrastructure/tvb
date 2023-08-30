#!/bin/bash

function startweb() {
# read env vars from desktop settings.json
cd $HOME
source <(python <<EOF
import json
with open('.config/jupyterlab-desktop/settings.json') as fd:
    for key, val in json.load(fd)['serverEnvVars'].items():
        print(f'export {key}="{val}"')
EOF
)
jupyter lab --ip=0.0.0.0 --no-browser
}

function startapp() {
jlab --no-sandbox $HOME/welcome.ipynb
}

$1
