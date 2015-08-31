FROM linuxserver/baseimage
MAINTAINER Stian Larsen <lonixx@gmail.com>

# Configure nzbdrone's apt repository
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FDA5DFFC && \
echo "deb http://apt.sonarr.tv/ master main" > /etc/apt/sources.list.d/sonarr.list && \
apt-get update -q && \
apt-get install -qy libmono-cil-dev python nzbdrone && \
apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


#Adding Custom files
ADD init/ /etc/my_init.d/
ADD services/ /etc/service/
RUN chmod -v +x /etc/service/*/run
RUN chmod -v +x /etc/my_init.d/*.sh
 

#Ports and Volumes
VOLUME /config /downloads /tv
EXPOSE 8989
