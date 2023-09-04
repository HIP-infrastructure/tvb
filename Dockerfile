ARG CI_REGISTRY_IMAGE
ARG TAG
ARG DOCKERFS_TYPE
ARG DOCKERFS_VERSION
ARG FREESURFER_VERSION
ARG FSL_VERSION

# use prebuild freesurfer & fsl
FROM ${CI_REGISTRY_IMAGE}/freesurfer:${FREESURFER_VERSION}${TAG} as freesurfer
FROM ${CI_REGISTRY_IMAGE}/fsl:${FSL_VERSION}${TAG} as fsl

# and building this
FROM ${CI_REGISTRY_IMAGE}/${DOCKERFS_TYPE}:${DOCKERFS_VERSION}${TAG}
LABEL maintainer="marmaduke.woodman@univ-amu.fr"

ARG DEBIAN_FRONTEND=noninteractive
ARG CARD
ARG CI_REGISTRY
ARG APP_NAME
ARG APP_VERSION

LABEL app_version=$APP_VERSION
LABEL app_tag=$TAG

# install deb pacakges, w/ newer nodejs for building jlab ext
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl gnupg \
 && mkdir -p /etc/apt/keyrings \
 && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
 && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
libnss3-dev libx11-xcb1 libxcb-dri3-0 libxcomposite1 libxcursor1 libxdamage1 \
libxfixes3 libxi6 libxtst6 libatk1.0-0 libatk-bridge2.0-0 libgdk-pixbuf2.0-0 \
libgtk-3-0 libgtk-3-0 libpangocairo-1.0-0 libpango-1.0-0 libcairo2 libdrm2 \
libgbm1 libasound2 libatspi2.0-0 libgtk-3-0 libnotify4 libnss3 libxss1 \
libglu1-mesa-dev xorg-dev xserver-xorg-video-intel libncurses5 libgomp1 libice6 \
libjpeg62 libx11-dev gettext xterm x11-apps csh file bc xorg libsm6 libxft2 \
libxmu6 libxt6 mrtrix3 xdg-utils git build-essential tcsh perl \
libsecret-1-0 libasound2 libsecret-common libgbm1 python-is-python3 python3-pip \
jq make build-essential git neovim wget datalad bc unzip nodejs

COPY --from=freesurfer /usr/local/freesurfer /usr/local/freesurfer
COPY --from=fsl /usr/local/fsl /usr/local/fsl

# setup python env (TODO consider using fsl's python)
RUN pip install jupyterlab matplotlib mne nibabel ipywidgets scipy \
    tvb-library tvb-data numba pybids siibra requests pyunicore nilearn \
    pyvista pytest \
 && pip install --upgrade "jax[cuda11_pip]" -f \
 	https://storage.googleapis.com/jax-releases/jax_cuda_releases.html \
 && pip install vbjax
# install jupyterlab desktop app
RUN curl -sSLO https://github.com/jupyterlab/jupyterlab-desktop/releases/download/v4.0.5-1/JupyterLab-Setup-Debian.deb \
 && dpkg -i JupyterLab-Setup-Debian.deb
# get copy of tvb recon pipeline
RUN cd /opt && git clone https://github.com/ins-amu/tvb-pipeline
# enable tvb-version
RUN pip3 install torch torchvision torchaudio \
	--index-url https://download.pytorch.org/whl/cpu \
 && pip3 install sbi \
 && cd /opt && git clone https://github.com/the-virtual-brain/tvb-inversion \
 && cd tvb-inversion && pip3 install -e .

# missing cl driver ftm
# RUN pip3 install pyopencl

ARG FREESURFER_VERSION
ENV FREESURFER_HOME=/usr/local/freesurfer/${FREESURFER_VERSION}
ADD ./apps/${APP_NAME}/license.txt $FREESURFER_HOME/license.txt

ADD ./apps/${APP_NAME}/jlab-entry.sh /usr/local/bin/jlab-entry.sh
ADD ./apps/${APP_NAME}/welcome.ipynb /opt/welcome.ipynb

ENV APP_SPECIAL="no"
ENV APP_CMD="/usr/local/bin/jlab-entry.sh"
ENV PROCESS_NAME="/opt/JupyterLab/jupyterlab-desktop"
ENV DIR_ARRAY=".config/jupyterlab-desktop"
ENV CONFIG_ARRAY=".bash_profile"

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/

# uncomment for deployment, I can't test this locally myself
ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
