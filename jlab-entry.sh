#!/bin/bash

# the hip app will run the desktop electron app via `startapp`, but for dev
# purposes, we want to be able to connect to the identical jupyter env via
# normal web browser, using `startweb`.

# it's useful for code to know whether we're live on hip or in dev
if mount | grep GhostFS; then TVB_ON_HIP=yes; else TVB_ON_HIP=no; fi

# maybe the Dockerfile's ENV FREESURFER_HOME didn't work
if [[ -z "$FREESURFER_HOME" ]]
then
	# let's find FreeSurfer ourselves
	export FREESURFER_HOME="$(dirname $(dirname $(ls /usr/local/freesurfer/*/bin/recon-all)))"
fi

cd $HOME

# create settings folders
mkdir -p {.jupyter,.config/jupyterlab-desktop}/lab/user-settings/@jupyterlab/apputils-extension

# silence jupyter lab
for base in .jupyter .config/jupyterlab-desktop
do
cat > ${base}/lab/user-settings/@jupyterlab/apputils-extension/notification.jupyterlab-settings <<EOF
{
    "checkForUpdates": false,
    "doNotDisturbMode": false,
    "fetchNews": "false"
}
EOF
done

# silence jupyter desktop & provide its env vars
cat > .config/jupyterlab-desktop/settings.json <<EOF
{
  "checkForUpdatesAutomatically": false,
  "installUpdatesAutomatically": false,
  "pythonPath": "/usr/bin/python",
  "serverArgs": "",
  "serverEnvVars": {
    "SHELL": "/bin/bash",
    "FREESURFER_HOME": "$FREESURFER_HOME",
    "FSL_DIR": "/usr/local/fsl",
    "OS": "Linux",
    "FSLWISH": "/usr/local/fsl/bin/fslwish",
    "MINC_BIN_DIR": "$FREESURFER_HOME/mni/bin",
    "FSFAST_HOME": "$FREESURFER_HOME/fsfast",
    "FREESURFER": "$FREESURFER_HOME",
    "MNI_DATAPATH": "$FREESURFER_HOME/mni/data",
    "FS_OVERRIDE": "0",
    "FUNCTIONALS_DIR": "$FREESURFER_HOME/sessions",
    "MINC_LIB_DIR": "$FREESURFER_HOME/mni/lib",
    "FMRI_ANALYSIS_DIR": "$FREESURFER_HOME/fsfast",
    "MNI_DIR": "$FREESURFER_HOME/mni",
    "PERL5LIB": "$FREESURFER_HOME/mni/share/perl5",
    "FSLDIR": "/usr/local/fsl",
    "MNI_PERL5LIB": "$FREESURFER_HOME/mni/share/perl5",
    "LOCAL_DIR": "$FREESURFER_HOME/local",
    "FIX_VERTEX_AREA": "",
    "FSLTCLSH": "/usr/local/fsl/bin/fsltclsh",
    "SUBJECTS_DIR": "$HOME/subjects",
    "FSLMULTIFILEQUIT": "TRUE",
    "FSL_LOAD_NIFTI_EXTENSIONS": "0",
    "FSLGECUDAQ": "cuda.q",
    "PATH": "/usr/bin:$FREESURFER_HOME/bin:$FREESURFER_HOME/fsfast/bin:$FREESURFER_HOME/tktools:/usr/local/fsl/bin:/usr/local/fsl/share/fsl/bin:$FREESURFER_HOME/mni/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    "FSL_SKIP_GLOBAL": "0",
    "FSF_OUTPUT_FORMAT": "nii.gz",
    "FSL_BIN": "/usr/local/fsl/bin",
    "FSLOUTPUTTYPE": "NIFTI_GZ"
  },
  "startupMode": "restore-sessions"
}
EOF

# read env vars from desktop settings
source <(python <<EOF
import json
with open('.config/jupyterlab-desktop/settings.json') as fd:
    for key, val in json.load(fd)['serverEnvVars'].items():
	            print(f'export {key}="{val}"')
EOF
)

# copy the welcome notebook into place
cp /opt/welcome.ipynb ./welcome.ipynb
cp /opt/simulation.ipynb ./simulation.ipynb

# allow entrypoint to choose one of the commands
function startweb() {
	jupyter lab --ip=0.0.0.0 --no-browser
}

function startapp() {
	jlab --no-sandbox $HOME/welcome.ipynb
}

function toolinfo() {
	set +x
	which python
	python -V
	which mrconvert
	which flirt
	which recon-all
	echo FREESURFER_HOME=$FREESURFER_HOME
	echo SUBJECTS_DIR=$SUBJECTS_DIR
}

toolinfo | tee .tvb-app-toolinfo.txt
startapp
