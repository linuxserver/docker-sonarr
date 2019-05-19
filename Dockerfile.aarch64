FROM lsiobase/mono:arm64v8-bionic

# set version label
ARG BUILD_DATE
ARG VERSION
ARG SONARR_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs"

# set environment variables
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_CONFIG_HOME="/config/xdg"
ENV SONARR_BRANCH="master"

RUN \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install -y \
        jq && \
 echo "**** install sonarr ****" && \
 mkdir -p /opt/NzbDrone && \
  if [ -z ${SONARR_VERSION+x} ]; then \
	SONARR_VERSION=$(curl -sX GET https://services.sonarr.tv/v1/download/${SONARR_BRANCH} \
	| jq -r '.version'); \
 fi && \
 curl -o \
	/tmp/sonarr.tar.gz -L \
	"https://download.sonarr.tv/v2/${SONARR_BRANCH}/mono/NzbDrone.${SONARR_BRANCH}.${SONARR_VERSION}.mono.tar.gz" && \
 tar xf \
	/tmp/sonarr.tar.gz -C \
	/opt/NzbDrone --strip-components=1 && \
 echo "**** cleanup ****" && \
 apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8989
VOLUME /config /downloads /tv
