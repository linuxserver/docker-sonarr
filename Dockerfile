FROM lsiobase/xenial
MAINTAINER sparklyballs

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_CONFIG_HOME="/config/xdg"

# install packages
RUN \
 apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 \
	--recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
 echo "deb http://download.mono-project.com/repo/debian wheezy main" \
	| tee /etc/apt/sources.list.d/mono-xamarin.list && \
 apt-get update && \
 apt-get install -y \
	libmono-cil-dev \
	mediainfo \
	sqlite3 && \

# cleanup
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8989
VOLUME /config
