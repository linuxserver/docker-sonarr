[linuxserverurl]: https://linuxserver.io
[forumurl]: https://forum.linuxserver.io
[ircurl]: https://www.linuxserver.io/irc/
[podcasturl]: https://www.linuxserver.io/podcast/
[appurl]: https://sonarr.tv/
[hub]: https://hub.docker.com/r/linuxserver/sonarr/

[![linuxserver.io](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/linuxserver_medium.png)][linuxserverurl]

The [LinuxServer.io][linuxserverurl] team brings you another container release featuring easy user mapping and community support. Find us for support at:
* [forum.linuxserver.io][forumurl]
* [IRC][ircurl] on freenode at `#linuxserver.io`
* [Podcast][podcasturl] covers everything to do with getting the most from your Linux Server plus a focus on all things Docker and containerisation!

# linuxserver/sonarr
[![](https://images.microbadger.com/badges/version/linuxserver/sonarr.svg)](https://microbadger.com/images/linuxserver/sonarr "Get your own version badge on microbadger.com")[![](https://images.microbadger.com/badges/image/linuxserver/sonarr.svg)](https://microbadger.com/images/linuxserver/sonarr "Get your own image badge on microbadger.com")[![Docker Pulls](https://img.shields.io/docker/pulls/linuxserver/sonarr.svg)][hub][![Docker Stars](https://img.shields.io/docker/stars/linuxserver/sonarr.svg)][hub][![Build Status](https://ci.linuxserver.io/buildStatus/icon?job=Docker-Builders/x86-64/x86-64-sonarr)](https://ci.linuxserver.io/job/Docker-Builders/job/x86-64/job/x86-64-sonarr/)

[Sonarr](https://sonarr.tv/) (formerly NZBdrone) is a PVR for usenet and bittorrent users. It can monitor multiple RSS feeds for new episodes of your favorite shows and will grab, sort and rename them. It can also be configured to automatically upgrade the quality of files already downloaded when a better quality format becomes available.

[![sonarr](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/sonarr-banner.png)][appurl]

## Usage

```
docker create \
	--name sonarr \
	-p 8989:8989 \
	-e PUID=<UID> -e PGID=<GID> \
	-e TZ=<timezone> \ 
	-v /etc/localtime:/etc/localtime:ro \
	-v </path/to/appdata>:/config \
	-v <path/to/tvseries>:/tv \
	-v <path/to/downloadclient-downloads>:/downloads \
	linuxserver/sonarr
```

You can choose between ,using tags, various branch versions of sonarr, no tag is required to remain on the main branch.

Add one of the tags,  if required,  to the linuxserver/sonarr line of the run/create command in the following format, linuxserver/sonarr:develop

#### Tags

+ **develop**

## Parameters

`The parameters are split into two halves, separated by a colon, the left hand side representing the host and the right the container side. 
For example with a port -p external:internal - what this shows is the port mapping from internal to external of the container.
So -p 8080:80 would expose port 80 from inside the container to be accessible from the host's IP on port 8080
http://192.168.x.x:8080 would show you what's running INSIDE the container on port 80.`


* `-p 8989` - the port sonarr webinterface
* `-v /config` - database and sonarr configs
* `-v /tv` - location of TV library on disk
* `-v /etc/localtime` for timesync - see [Localtime](#localtime) for important information
* `-e TZ` for timezone information, Europe/London - see [Localtime](#localtime) for important information
* `-e PGID` for for GroupID - see below for explanation
* `-e PUID` for for UserID - see below for explanation

It is based on ubuntu xenial with S6 overlay, for shell access whilst the container is running do `docker exec -it sonarr /bin/bash`.

## Localtime

It is important that you either set `-v /etc/localtime:/etc/localtime:ro` or the TZ variable, mono will throw exceptions without one of them set.

### User / Group Identifiers

Sometimes when using data volumes (`-v` flags) permissions issues can arise between the host OS and the container. We avoid this issue by allowing you to specify the user `PUID` and group `PGID`. Ensure the data volume directory on the host is owned by the same user you specify and it will "just work" <sup>TM</sup>.

In this instance `PUID=1001` and `PGID=1001`. To find yours use `id user` as below:

```
  $ id <dockeruser>
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```

## Setting up the application
Access the webui at `<your-ip>:8989`, for more information check out [Sonarr](https://sonarr.tv/).

## Info

Monitor the logs of the container in realtime `docker logs -f sonarr`.

* container version number 

`docker inspect -f '{{ index .Config.Labels "build_version" }}' sonarr`

* image version number

`docker inspect -f '{{ index .Config.Labels "build_version" }}' linuxserver/sonarr`

## Versions

+ **12.07.17:** Add inspect commands to README, move to jenkins build and push.
+ **17.04.17:** Switch to using inhouse mono baseimage, adds python also.
+ **14.04.17:** Change to mount /etc/localtime in README, thanks cbgj.
+ **13.04.17:** Switch to official mono repository.
+ **30.09.16:** Fix umask
+ **23.09.16:** Add cd to /opt fixes redirects with althub (issue #25)
, make XDG config environment variable
+ **15.09.16:** Add libcurl3 package.
+ **09.09.16:** Add layer badges to README.
+ **27.08.16:** Add badges to README.
+ **20.07.16:** Rebase to xenial.
+ **31.08.15:** Cleanup, changed sources to fetch binarys from. also a new baseimage. 
