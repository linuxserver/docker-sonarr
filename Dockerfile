FROM phusion/baseimage:0.9.16
MAINTAINER Stian Larsen <lonixx@gmail.com>
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh
ENV DEBIAN_FRONTEND noninteractive
ENV TERM screen
ENV HOME /root


# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# Configure nzbdrone's apt repository
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FDA5DFFC && \
echo "deb http://update.nzbdrone.com/repos/apt/debian master main" >> /etc/apt/sources.list && \
apt-get update -q && \
apt-get install -qy libmono-cil-dev nzbdrone && \
apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#Ports and Volumes
VOLUME /config
VOLUME /downloads
VOLUME /tv
EXPOSE 8989

#Adding Custom files
ADD init/ /etc/my_init.d/
ADD services/ /etc/service/
RUN chmod -v +x /etc/service/*/run
RUN chmod -v +x /etc/my_init.d/*.sh
 
#Adduser
RUN useradd -u 911 -U -s /bin/false abc
RUN usermod -G users abc

