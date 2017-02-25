[linuxserverurl]: https://linuxserver.io
[forumurl]: https://forum.linuxserver.io
[ircurl]: https://www.linuxserver.io/irc/
[podcasturl]: https://www.linuxserver.io/podcast/

[![linuxserver.io](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/linuxserver_medium.png)][linuxserverurl]

The [LinuxServer.io][linuxserverurl] team brings you another container release featuring easy user mapping and community support. Find us for support at:
* [forum.linuxserver.io][forumurl]
* [IRC][ircurl] on freenode at `#linuxserver.io`
* [Podcast][podcasturl] covers everything to do with getting the most from your Linux Server plus a focus on all things Docker and containerisation!

# linuxserver/sonarr

[![](https://images.microbadger.com/badges/image/linuxserver/sonarr.svg)](http://microbadger.com/images/linuxserver/sonarr "Get your own image badge on microbadger.com")[![Docker Pulls](https://img.shields.io/docker/pulls/linuxserver/sonarr.svg)][hub][![Docker Stars](https://img.shields.io/docker/stars/linuxserver/sonarr.svg)][hub][![Build Status](http://jenkins.linuxserver.io:8080/buildStatus/icon?job=Dockers/LinuxServer.io-hub-built/linuxserver-sonarr)](http://jenkins.linuxserver.io:8080/job/Dockers/job/LinuxServer.io-hub-built/job/linuxserver-sonarr/)
[hub]: https://hub.docker.com/r/linuxserver/sonarr/

[Sonarr](https://sonarr.tv/) (formerly NZBdrone) is a PVR for usenet and bittorrent users. It can monitor multiple RSS feeds for new episodes of your favorite shows and will grab, sort and rename them. It can also be configured to automatically upgrade the quality of files already downloaded when a better quality format becomes available.

[![sonarr](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/sonarr-banner.png)][sonarrurl]
[sonarrurl]: https://sonarr.tv/

## Usage

```
docker create \
	--name sonarr \
	-p 8989:8989 \
	-e PUID=<UID> -e PGID=<GID> \
	-v /dev/rtc:/dev/rtc:ro \
	-v </path/to/appdata>:/config \
	-v <path/to/tvseries>:/tv \
	-v <path/to/downloadclient-downloads>:/downloads \
	linuxserver/sonarr
```

## Parameters

`The parameters are split into two halves, separated by a colon, the left hand side representing the host and the right the container side. 
For example with a port -p external:internal - what this shows is the port mapping from internal to external of the container.
So -p 8080:80 would expose port 80 from inside the container to be accessible from the host's IP on port 8080
http://192.168.x.x:8080 would show you what's running INSIDE the container on port 80.`


* `-p 8989` - the port sonarr webinterface
* `-v /dev/rtc:/dev/rtc:ro` - map hwclock as ReadOnly (mono throws exceptions otherwise)
* `-v /config` - database and sonarr configs
* `-v /tv` - location of TV library on disk
* `-v /downloads` - location of downloads folder
* `-e PGID` for for GroupID - see below for explanation
* `-e PUID` for for UserID - see below for explanation

It is based on ubuntu xenial with S6 overlay, for shell access whilst the container is running do `docker exec -it sonarr /bin/bash`.

### User / Group Identifiers

Sometimes when using data volumes (`-v` flags) permissions issues can arise between the host OS and the container. We avoid this issue by allowing you to specify the user `PUID` and group `PGID`. Ensure the data volume directory on the host is owned by the same user you specify and it will "just work" <sup>TM</sup>.

In this instance `PUID=1001` and `PGID=1001`. To find yours use `id user` as below:

```
  $ id <dockeruser>
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```

### Hardlink support

Since docker doesn't support hardlinks over volumes, this feature won't work, and Sonarr will fallback to copying the files from `/downloads` to `/tv`. This can take quite some time with large files, and it will require additional disk space.

For this feature to work, you will need to have the `download` folder and the `tv` folder on the same disk. Next, you need to map the parent directory that contains both the `download` folder and the `tv` folder to your docker container with the `-v <path/to/parent>:/data`. Finally, you need to update your "Remote Path Mappings" to match your new path. You also should update the Root Folder of your existing series in the "Series Editor" screen.

## Setting up the application
Access the webui at `<your-ip>:8989`, for more information check out [Sonarr](https://sonarr.tv/).

## Info

* Monitor the logs of the container in realtime `docker logs -f sonarr`.

## Changelog

+ **25.02.17:** Added documentation on hardlinks.
+ **30.09.16:** Fix umask
+ **23.09.16:** Add cd to /opt fixes redirects with althub (issue #25)
, make XDG config environment variable
+ **15.09.16:** Add libcurl3 package.
+ **09.09.16:** Add layer badges to README.
+ **27.08.16:** Add badges to README.
+ **20.07.16:** Rebase to xenial.
+ **31.08.15:** Cleanup, changed sources to fetch binarys from. also a new baseimage. 
