![https://linuxserver.io](https://www.linuxserver.io/wp-content/uploads/2015/06/linuxserver_medium.png)

The [LinuxServer.io](https://linuxserver.io) team brings you another container release featuring easy user mapping and community support. Find us for support at:
* [forum.linuxserver.io](https://forum.linuxserver.io)
* [IRC](https://www.linuxserver.io/index.php/irc/) on freenode at `#linuxserver.io`
* [Podcast](https://www.linuxserver.io/index.php/category/podcast/) covers everything to do with getting the most from your Linux Server plus a focus on all things Docker and containerisation!

# linuxserver/sonarr

![](https://sonarr.tv/img/logo.png)

[Sonarr](https://sonarr.tv/) (formerly NZBdrone) is a PVR for usenet and bittorrent users. It can monitor multiple RSS feeds for new episodes of your favorite shows and will grab, sort and rename them. It can also be configured to automatically upgrade the quality of files already downloaded when a better quality format becomes available.

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

**Parameters**

* `-p 8989` - the port sonarr webinterface
* `-v /dev/rtc:/dev/rtc:ro` - map hwclock to the docker hwclock as ReadOnly (mono throws exceptions otherwise)
* `-v /config` - database and sonarr configs
* `-v /tv` - location of TV library on disk
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

## Info

* Monitor the logs of the container in realtime `docker logs -f sonarr`.

## Changelog

+ **20.07.16:** Rebase to xenial.
+ **31.08.15:** Cleanup, changed sources to fetch binarys from. also a new baseimage. 
