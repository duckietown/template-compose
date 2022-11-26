# parameters
ARG REPO_NAME="<REPO_NAME_HERE>"
ARG MAINTAINER="<YOUR_FULL_NAME> (<YOUR_EMAIL_ADDRESS>)"

# ==================================================>
# ==> Do not change this code
ARG ARCH=arm64v8
ARG COMPOSE_VERSION=latest
ARG BASE_IMAGE=compose
ARG BASE_TAG=${COMPOSE_VERSION}-${ARCH}

# extend dt-commons
ARG SUPER_IMAGE=dt-commons
ARG MAJOR=ente
ARG SUPER_IMAGE_TAG=${MAJOR}-${ARCH}
ARG DOCKER_REGISTRY=docker.io
FROM ${DOCKER_REGISTRY}/duckietown/${SUPER_IMAGE}:${SUPER_IMAGE_TAG} as dt-commons

# define base image
FROM afdaniele/${BASE_IMAGE}:${BASE_TAG}

# copy stuff from the super image
COPY --from=dt-commons /environment.sh /environment.sh
COPY --from=dt-commons /usr/local/bin/dt-advertise /usr/local/bin/dt-advertise
COPY --from=dt-commons /code/dt-commons /code/dt-commons

# copy dependencies files only
COPY ./dependencies-apt.txt /tmp/

# install apt dependencies
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    $(awk -F: '/^[^#]/ { print $1 }' /tmp/dependencies-apt.txt | uniq) \
  && rm -rf /var/lib/apt/lists/*

# copy dependencies files only
COPY ./dependencies-py3.txt /tmp/

# install python dependencies
ARG PIP_INDEX_URL="https://pypi.org/simple"
ENV PIP_INDEX_URL=${PIP_INDEX_URL}

RUN python3 -m pip install -r /tmp/dependencies-py3.txt

# copy dependencies files only
COPY ./dependencies-compose.txt /tmp/

# install compose dependencies
RUN python3 ${COMPOSE_DIR}/public_html/system/lib/python/compose/package_manager.py \
  --install $(awk -F: '/^[^#]/ { print $1 }' /tmp/dependencies-compose.txt | uniq)

# copy launch script
COPY ./launch.sh /launch.sh

# define launch script
ENV LAUNCHFILE "/launch.sh"

# redefine entrypoint
ENTRYPOINT "${LAUNCHFILE}"

# store module name
ARG REPO_NAME
LABEL org.duckietown.label.module.type="${REPO_NAME}"
ENV DT_MODULE_TYPE "${REPO_NAME}"

# store module metadata
ARG ARCH
ARG COMPOSE_VERSION
ARG BASE_IMAGE
ARG BASE_TAG
ARG MAINTAINER
LABEL org.duckietown.label.architecture="${ARCH}"
LABEL org.duckietown.label.code.location="/var/www/html/"
LABEL org.duckietown.label.base.major="${COMPOSE_VERSION}"
LABEL org.duckietown.label.base.image="${BASE_IMAGE}"
LABEL org.duckietown.label.base.tag="${BASE_TAG}"
LABEL org.duckietown.label.maintainer="${MAINTAINER}"
# <== Do not change this code
# <==================================================

# configure \compose\
RUN python3 ${COMPOSE_DIR}/configure.py \
  # --<KEY_1> <VALUE_1> \
  # --<KEY_2> <VALUE_2> \
  # ...
