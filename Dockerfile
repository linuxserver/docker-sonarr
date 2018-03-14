FROM lsiobase/mono:xenial
MAINTAINER sparklyballs

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_CONFIG_HOME="/config/xdg"

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8989
VOLUME /config
