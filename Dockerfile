ARG CI_REGISTRY_IMAGE
ARG DAVFS2_VERSION
FROM ${CI_REGISTRY_IMAGE}/nc-webdav:${DAVFS2_VERSION}
LABEL maintainer="marmaduke.woodman@univ-amu.fr"

ARG DEBIAN_FRONTEND=noninteractive
ARG CARD
ARG CI_REGISTRY
ARG APP_NAME
ARG APP_VERSION

LABEL app_version=$APP_VERSION

WORKDIR /apps/${APP_NAME}

# a lot of stuff depends on this path, so symlink it in place
RUN mkdir -p /apps/tvb-hip && ln -s /apps/${APP_NAME} /apps/tvb-hip

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y libnss3-dev libx11-xcb1 libxcb-dri3-0 libxcomposite1 \
	libxcursor1 libxdamage1 libxfixes3 libxi6 libxtst6 libatk1.0-0 libatk-bridge2.0-0 \
	libgdk-pixbuf2.0-0 libgtk-3-0 libgtk-3-0 libpangocairo-1.0-0 libpango-1.0-0 libcairo2 \
	libdrm2 libgbm1 libasound2 libatspi2.0-0 curl git build-essential tcsh perl nodejs \
	python2 wget datalad bc libglu1-mesa-dev unzip

RUN wget -q https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/7.2.0/freesurfer-linux-ubuntu18_amd64-7.2.0.tar.gz \
 && tar xzf freesurfer-linux-ubuntu18_amd64-7.2.0.tar.gz \
 && rm freesurfer-linux-ubuntu18_amd64-7.2.0.tar.gz

RUN wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py \
 && echo "" | python2 fslinstaller.py

RUN curl -LO https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
 && bash Miniconda3-latest-Linux-x86_64.sh -b -p $PWD/conda \
 && rm Miniconda3-latest-Linux-x86_64.sh \
 && export PATH=$PWD/conda/bin:$PATH \
 && conda install -y jupyter numba scipy matplotlib \
 && conda install -y -c mrtrix3 mrtrix3 \
 && pip install tvb-data tvb-library tqdm pybids siibra requests pyunicore mne nilearn pyvista ipywidgets cmdstanpy \
 && install_cmdstan \
 && mv /root/.cmdstan $PWD/cmdstan

# we could clean up but image is already enormous
    # apt-get remove -y --purge curl && \
    # apt-get autoremove -y --purge && \
    # apt-get clean && \
    # rm -rf /var/lib/apt/lists/*

# needed because we have a different context
ADD ./apps/${APP_NAME}/better-start.sh /apps/tvb-hip/start2.sh
# ADD better-start.sh /apps/tvb-hip/start2.sh

# ensure bash is used, and our our kernelspec with $HOME env vars set
#RUN mkdir /etc/jupyter \
# && echo "c.ServerApp.terminado_settings = { 'shell_command': ['/usr/bin/bash'] }" > /etc/jupyter/jupyter_lab_config.py \
# && echo "c.KernelSpecManager.whitelist = { 'tvb' }" >> /etc/jupyter/jupyter_lab_config.py \
# && echo "c.KernelSpecManager.ensure_native_kernel = False" >> /etc/jupyter/jupyter_lab_config.py

ENV APP_SPECIAL="terminal"
ENV APP_CMD=""
ENV PROCESS_NAME=""
ENV DIR_ARRAY=""
ENV CONFIG_ARRAY=".bash_profile"

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/

# uncomment for deployment, I can't test this locally myself
ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
