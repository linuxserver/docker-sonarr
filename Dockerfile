FROM ghcr.io/linuxserver/baseimage-mono:focal

# set version label
ARG BUILD_DATE
ARG VERSION
ARG SONARR_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# set environment variables
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_CONFIG_HOME="/config/xdg"
ENV SONARR_BRANCH="main"

RUN \
 echo "**** add mediaarea repository ****" && \
  curl -L \
    "https://mediaarea.net/repo/deb/repo-mediaarea_1.0-12_all.deb" \
    -o /tmp/key.deb && \
  dpkg -i /tmp/key.deb && \
  echo "deb https://mediaarea.net/repo/deb/ubuntu focal main" | tee /etc/apt/sources.list.d/mediaarea.list && \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y \
    jq \
    mediainfo \
    libmono-system-net-http4.0-cil \
    libmono-corlib4.5-cil \
    libmono-microsoft-csharp4.0-cil \
    libmono-posix4.0-cil \
    libmono-system-componentmodel-dataannotations4.0-cil \
    libmono-system-configuration-install4.0-cil \
    libmono-system-configuration4.0-cil \
    libmono-system-core4.0-cil \
    libmono-system-data-datasetextensions4.0-cil \
    libmono-system-data4.0-cil \
    libmono-system-identitymodel4.0-cil \
    libmono-system-io-compression4.0-cil \
    libmono-system-numerics4.0-cil \
    libmono-system-runtime-serialization4.0-cil \
    libmono-system-security4.0-cil \
    libmono-system-servicemodel4.0a-cil \
    libmono-system-serviceprocess4.0-cil \
    libmono-system-transactions4.0-cil \
    libmono-system-web4.0-cil \
    libmono-system-xml-linq4.0-cil \
    libmono-system-xml4.0-cil \
    libmono-system4.0-cil && \    
  echo "**** install sonarr ****" && \
  mkdir -p /app/sonarr/bin && \
  if [ -z ${SONARR_VERSION+x} ]; then \
    SONARR_VERSION=$(curl -sX GET http://services.sonarr.tv/v1/releases \
    | jq -r ".[] | select(.branch==\"$SONARR_BRANCH\") | .version"); \
  fi && \
  curl -o \
    /tmp/sonarr.tar.gz -L \
    "https://download.sonarr.tv/v3/${SONARR_BRANCH}/${SONARR_VERSION}/Sonarr.${SONARR_BRANCH}.${SONARR_VERSION}.linux.tar.gz" && \
  tar xf \
    /tmp/sonarr.tar.gz -C \
    /app/sonarr/bin --strip-components=1 && \
  echo "UpdateMethod=docker\nBranch=${SONARR_BRANCH}\nPackageVersion=${VERSION}\nPackageAuthor=[linuxserver.io](https://linuxserver.io)" > /app/sonarr/package_info && \
  rm -rf /app/sonarr/bin/Sonarr.Update && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8989
VOLUME /config
