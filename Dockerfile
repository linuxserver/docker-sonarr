# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.19

# set version label
ARG BUILD_DATE
ARG VERSION
ARG SONARR_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thespad"

# set environment variables
ENV XDG_CONFIG_HOME="/config/xdg"
ENV SONARR_CHANNEL="v4-stable"
ENV SONARR_BRANCH="main"

RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    icu-libs \
    sqlite-libs \
    xmlstarlet && \
  echo "**** install sonarr ****" && \
  mkdir -p /app/sonarr/bin && \
  if [ -z ${SONARR_VERSION+x} ]; then \
    SONARR_VERSION=$(curl -sX GET http://services.sonarr.tv/v1/releases \
    | jq -r "first(.[] | select(.releaseChannel==\"${SONARR_CHANNEL}\") | .version)"); \
  fi && \
  curl -o \
    /tmp/sonarr.tar.gz -L \
    "https://services.sonarr.tv/v1/update/${SONARR_BRANCH}/download?version=${SONARR_VERSION}&os=linuxmusl&runtime=netcore&arch=x64" && \
  tar xzf \
    /tmp/sonarr.tar.gz -C \
    /app/sonarr/bin --strip-components=1 && \
  echo -e "UpdateMethod=docker\nBranch=${SONARR_BRANCH}\nPackageVersion=${VERSION:-LocalBuild}\nPackageAuthor=[linuxserver.io](https://linuxserver.io)" > /app/sonarr/package_info && \
  echo "**** cleanup ****" && \
  rm -rf \
    /app/sonarr/bin/Sonarr.Update \
    /tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8989

VOLUME /config
