FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    curl libgtk-3-0 libnotify4 libnss3 libxss1 \
    xdg-utils libatspi2.0-0 libsecret-1-0 \
    libasound2 libsecret-common libgbm1

RUN curl -sSLO https://github.com/jupyterlab/jupyterlab-desktop/releases/download/v4.0.5-1/JupyterLab-Setup-Debian.deb \
 && dpkg -i JupyterLab-Setup-Debian.deb

RUN apt-get install -y python-is-python3 python3-pip \
 && pip install jupyterlab matplotlib mne nibabel cmdstanpy

RUN mkdir -p /root/.config/jupyterlab-desktop
ADD jlab-settings.json /root/.config/jupyterlab-desktop/settings.json

CMD jlab --no-sandbox folder/welcome.ipynb
