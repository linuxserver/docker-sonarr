# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.18

# set version label
ARG BUILD_DATE
ARG VERSION
ARG SONARR_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thespad"

# set environment variables
ENV XDG_CONFIG_HOME="/config/xdg"
ENV SONARR_BRANCH="develop"

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
    | jq -r "first(.[] | select(.branch==\"$SONARR_BRANCH\") | .version)"); \
  fi && \
  curl -o \
    /tmp/sonarr.tar.gz -L \
    "https://download.sonarr.tv/v4/${SONARR_BRANCH}/${SONARR_VERSION}/Sonarr.${SONARR_BRANCH}.${SONARR_VERSION}.linux-musl-x64.tar.gz" && \
  tar xzf \
    /tmp/sonarr.tar.gz -C \
    /app/sonarr/bin --strip-components=1 && \
  echo -e "UpdateMethod=docker\nBranch=${SONARR_BRANCH}\nPackageVersion=${VERSION}\nPackageAuthor=[linuxserver.io](https://linuxserver.io)" > /app/sonarr/package_info && \
  echo "**** cleanup ****" && \
  rm -rf \
    /app/sonarr/bin/Sonarr.Update \
    /tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8989

VOLUME /config
