FROM lsiobase/mono:xenial

# set version label
ARG BUILD_DATE
ARG VERSION
ARG SONARR_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs"

# set environment variables
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_CONFIG_HOME="/config/xdg"
ENV SONARR_BRANCH="develop"

RUN \
 if [ -z ${SONARR_VERSION+x} ]; then \
	SONARR_VERSION=$(curl -sX GET http://apt.sonarr.tv/dists/${SONARR_BRANCH}/main/binary-amd64/Packages \
	|grep -A 6 -m 1 "Package: nzbdrone" | awk -F ": " '/Version/{print $2;exit}'); \
 fi && \
 echo "**** add sonarr repository ****" && \
 apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FDA5DFFC && \
 echo "deb http://apt.sonarr.tv/ ${SONARR_BRANCH} main" > \
	/etc/apt/sources.list.d/sonarr.list && \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install -y \
	nzbdrone=${SONARR_VERSION} && \
 echo "**** cleanup ****" && \
 apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8989
VOLUME /config /downloads /tv
