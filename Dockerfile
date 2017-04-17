FROM lsiobase/mono
MAINTAINER sparklyballs

# set environment variables
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_CONFIG_HOME="/config/xdg"

# add sonarr repository
RUN \
 apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 \
	--recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
 echo "deb http://download.mono-project.com/repo/debian wheezy main" \
	| tee /etc/apt/sources.list.d/mono-xamarin.list && \

# install packages
 apt-get update && \
 apt-get install -y \
	nzbdrone && \

# cleanup
 apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8989
VOLUME /config /downloads /tv
