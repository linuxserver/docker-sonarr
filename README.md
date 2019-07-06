[![linuxserver.io](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/linuxserver_medium.png)](https://linuxserver.io)

The [LinuxServer.io](https://linuxserver.io) team brings you another container release featuring :-

 * regular and timely application updates
 * easy user mappings (PGID, PUID)
 * custom base image with s6 overlay
 * weekly base OS updates with common layers across the entire LinuxServer.io ecosystem to minimise space usage, down time and bandwidth
 * regular security updates

Find us at:
* [Discord](https://discord.gg/YWrKVTn) - realtime support / chat with the community and the team.
* [IRC](https://irc.linuxserver.io) - on freenode at `#linuxserver.io`. Our primary support channel is Discord.
* [Blog](https://blog.linuxserver.io) - all the things you can do with our containers including How-To guides, opinions and much more!

# [linuxserver/sonarr](https://github.com/linuxserver/docker-sonarr)
[![](https://img.shields.io/discord/354974912613449730.svg?logo=discord&label=LSIO%20Discord&style=flat-square)](https://discord.gg/YWrKVTn)
[![](https://images.microbadger.com/badges/version/linuxserver/sonarr.svg)](https://microbadger.com/images/linuxserver/sonarr "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/linuxserver/sonarr.svg)](https://microbadger.com/images/linuxserver/sonarr "Get your own version badge on microbadger.com")
![Docker Pulls](https://img.shields.io/docker/pulls/linuxserver/sonarr.svg)
![Docker Stars](https://img.shields.io/docker/stars/linuxserver/sonarr.svg)
[![Build Status](https://ci.linuxserver.io/buildStatus/icon?job=Docker-Pipeline-Builders/docker-sonarr/master)](https://ci.linuxserver.io/job/Docker-Pipeline-Builders/job/docker-sonarr/job/master/)
[![](https://lsio-ci.ams3.digitaloceanspaces.com/linuxserver/sonarr/latest/badge.svg)](https://lsio-ci.ams3.digitaloceanspaces.com/linuxserver/sonarr/latest/index.html)

[Sonarr](https://sonarr.tv/) (formerly NZBdrone) is a PVR for usenet and bittorrent users. It can monitor multiple RSS feeds for new episodes of your favorite shows and will grab, sort and rename them. It can also be configured to automatically upgrade the quality of files already downloaded when a better quality format becomes available.


[![sonarr](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/sonarr-banner.png)](https://sonarr.tv/)

## Supported Architectures

Our images support multiple architectures such as `x86-64`, `arm64` and `armhf`. We utilise the docker manifest for multi-platform awareness. More information is available from docker [here](https://github.com/docker/distribution/blob/master/docs/spec/manifest-v2-2.md#manifest-list) and our announcement [here](https://blog.linuxserver.io/2019/02/21/the-lsio-pipeline-project/). 

Simply pulling `linuxserver/sonarr` should retrieve the correct image for your arch, but you can also pull specific arch images via tags.

The architectures supported by this image are:

| Architecture | Tag |
| :----: | --- |
| x86-64 | amd64-latest |
| arm64 | arm64v8-latest |
| armhf | arm32v7-latest |

## Version Tags

This image provides various versions that are available via tags. `latest` tag usually provides the latest stable version. Others are considered under development and caution must be exercised when using them.

| Tag | Description |
| :----: | --- |
| latest | Stable releases from Sonarr (currently v2) |
| develop | Development releases from Sonarr (currently v2) |
| preview | Preview releases from Sonarr (currently v3) |
| 5.14 | Stable Sonarr releases, but run on Mono 5.14 |

## Usage

Here are some example snippets to help you get started creating a container.

### docker

```
docker create \
  --name=sonarr \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/London \
  -e UMASK_SET=022 `#optional` \
  -p 8989:8989 \
  -v <path to data>:/config \
  -v <path/to/tvseries>:/tv \
  -v <path/to/downloadclient-downloads>:/downloads \
  --restart unless-stopped \
  linuxserver/sonarr
```


### docker-compose

Compatible with docker-compose v2 schemas.

```
---
version: "2"
services:
  sonarr:
    image: linuxserver/sonarr
    container_name: sonarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London
      - UMASK_SET=022 #optional
    volumes:
      - <path to data>:/config
      - <path/to/tvseries>:/tv
      - <path/to/downloadclient-downloads>:/downloads
    ports:
      - 8989:8989
    restart: unless-stopped
```

## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 8989` | The port for the Sonarr webinterface |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e TZ=Europe/London` | Specify a timezone to use EG Europe/London, this is required for Sonarr |
| `-e UMASK_SET=022` | control permissions of files and directories created by Sonarr |
| `-v /config` | Database and sonarr configs |
| `-v /tv` | Location of TV library on disk |
| `-v /downloads` | Location of download managers output directory |

## User / Group Identifiers

When using volumes (`-v` flags) permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1000` and `PGID=1000`, to find yours use `id user` as below:

```
  $ id username
    uid=1000(dockeruser) gid=1000(dockergroup) groups=1000(dockergroup)
```


&nbsp;
## Application Setup

Access the webui at `<your-ip>:8989`, for more information check out [Sonarr](https://sonarr.tv/).



## Support Info

* Shell access whilst the container is running: `docker exec -it sonarr /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f sonarr`
* container version number 
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' sonarr`
* image version number
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' linuxserver/sonarr`

## Updating Info

Most of our images are static, versioned, and require an image update and container recreation to update the app inside. With some exceptions (ie. nextcloud, plex), we do not recommend or support updating apps inside the container. Please consult the [Application Setup](#application-setup) section above to see if it is recommended for the image.  
  
Below are the instructions for updating containers:  
  
### Via Docker Run/Create
* Update the image: `docker pull linuxserver/sonarr`
* Stop the running container: `docker stop sonarr`
* Delete the container: `docker rm sonarr`
* Recreate a new container with the same docker create parameters as instructed above (if mapped correctly to a host folder, your `/config` folder and settings will be preserved)
* Start the new container: `docker start sonarr`
* You can also remove the old dangling images: `docker image prune`

### Via Docker Compose
* Update all images: `docker-compose pull`
  * or update a single image: `docker-compose pull sonarr`
* Let compose update all containers as necessary: `docker-compose up -d`
  * or update a single container: `docker-compose up -d sonarr`
* You can also remove the old dangling images: `docker image prune`

### Via Watchtower auto-updater (especially useful if you don't remember the original parameters)
* Pull the latest image at its tag and replace it with the same env variables in one run:
  ```
  docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower \
  --run-once sonarr
  ```

**Note:** We do not endorse the use of Watchtower as a solution to automated updates of existing Docker containers. In fact we generally discourage automated updates. However, this is a useful tool for one-time manual updates of containers where you have forgotten the original parameters. In the long term, we highly recommend using Docker Compose.

* You can also remove the old dangling images: `docker image prune`

## Building locally

If you want to make local modifications to these images for development purposes or just to customize the logic: 
```
git clone https://github.com/linuxserver/docker-sonarr.git
cd docker-sonarr
docker build \
  --no-cache \
  --pull \
  -t linuxserver/sonarr:latest .
```

The ARM variants can be built on x86_64 hardware using `multiarch/qemu-user-static`
```
docker run --rm --privileged multiarch/qemu-user-static:register --reset
```

Once registered you can define the dockerfile to use with `-f Dockerfile.aarch64`.

## Versions

* **13.06.19:** - Add env variable for setting umask.
* **10.05.19:** - Rebase to Bionic.
* **23.03.19:** - Switching to new Base images, shift to arm32v7 tag.
* **01.02.19:** - Multi arch images and pipeline build logic
* **15.12.17:** - Fix continuation lines.
* **12.07.17:** - Add inspect commands to README, move to jenkins build and push.
* **17.04.17:** - Switch to using inhouse mono baseimage, adds python also.
* **14.04.17:** - Change to mount /etc/localtime in README, thanks cbgj.
* **13.04.17:** - Switch to official mono repository.
* **30.09.16:** - Fix umask
* **23.09.16:** - Add cd to /opt fixes redirects with althub (issue #25) , make XDG config environment variable
* **15.09.16:** - Add libcurl3 package.
* **09.09.16:** - Add layer badges to README.
* **27.08.16:** - Add badges to README.
* **20.07.16:** - Rebase to xenial.
* **31.08.15:** - Cleanup, changed sources to fetch binarys from. also a new baseimage.
