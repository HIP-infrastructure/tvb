FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# base packages incl. python
RUN apt-get update && apt-get install -y \
    curl libgtk-3-0 libnotify4 libnss3 libxss1 xdg-utils libatspi2.0-0 \
    libsecret-1-0 libasound2 libsecret-common libgbm1 python-is-python3 \
    python3-pip jq make build-essential git neovim

# setup python env
RUN pip install jupyterlab matplotlib mne nibabel ipywidgets scipy \
    tvb-library tvb-data numba \
 && pip install --upgrade "jax[cuda11_pip]" -f \
 	https://storage.googleapis.com/jax-releases/jax_cuda_releases.html \
 && pip install vbjax

# install jupyterlab desktop app
RUN curl -sSLO https://github.com/jupyterlab/jupyterlab-desktop/releases/download/v4.0.5-1/JupyterLab-Setup-Debian.deb \
 && dpkg -i JupyterLab-Setup-Debian.deb

# get copy of tvb recon pipeline
RUN cd /opt && git clone https://github.com/ins-amu/tvb-pipeline

# setup configs for jupyter (convert to script?)
RUN adduser hip
RUN mkdir -p /home/hip/.config/jupyterlab-desktop/lab/user-settings/@jupyterlab/apputils-extension
RUN mkdir -p /home/hip/.jupyter/lab/user-settings/@jupyterlab/apputils-extension
ADD jlab-settings.json /home/hip/.config/jupyterlab-desktop/settings.json
ADD jlab-notifications.json /home/hip/.config/jupyterlab-desktop/lab/user-settings/@jupyterlab/apputils-extension/notification.jupyterlab-settings
ADD jlab-notifications.json /home/hip/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/notification.jupyterlab-settings
ADD welcome.ipynb /home/hip/welcome.ipynb
RUN chown -R hip:hip /home/hip/.config
RUN chown -R hip:hip /home/hip/.jupyter

ADD jlab-entry.sh /usr/local/bin/jlab-entry.sh
USER hip
CMD jlab-entry.sh
