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

# a lot of stuff depends on this path, so symlink it in place
RUN mkdir -p /apps/tvb-hip && ln -s /apps/tvb-hip /apps/${APP_NAME}

WORKDIR /apps/${APP_NAME}

# token required to pull from data proxy, but doesn't persist in image
ARG EBRAINS_TOKEN

RUN apt-get update && \
    apt-get install -y curl

RUN curl -k -L https://github.com/ins-amu/hip-tvb-app/archive/refs/tags/v$APP_VERSION.tar.gz | tar xz \
 && ./hip-tvb-app-$APP_VERSION/install-packages.sh

RUN python3 hip-tvb-app-$APP_VERSION/sync_image.py \
 && tar -C / -xzf /apps/${APP_NAME}/app.tar.* && rm /apps/${APP_NAME}/app.tar.*

# we could clean up but image is already enormous
    # apt-get remove -y --purge curl && \
    # apt-get autoremove -y --purge && \
    # apt-get clean && \
    # rm -rf /var/lib/apt/lists/*

ENV APP_SHELL="no"
ENV APP_CMD="/apps/tvb-hip/start.sh"
ENV PROCESS_NAME="electron"
ENV DIR_ARRAY=".jupyter"

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/

# uncomment for deployment, I can't test this locally myself
# ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
