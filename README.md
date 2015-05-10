# lonix/nzbdrone


**sample create command:**
```
docker create --name=<name> -v /etc/localtime:/etc/localtime:ro -v <path to data>:/config -v <path to tv>:/tv -v <path to downloads>:/downloads -e PGID=<gid> -e PUID=<uid>  -p 80:80 lonix/nzbdrone:2.0
```

**You need to map**
* PORT: 8989 for Webui
* MOUNT: /downloads for downloads
* MOUNT: /etc/localhost for timesync (Not required)
* MOUNT: /config for Configuration storage
* MOUNT: /tv for tv-collection
* VARIABLE: PGID for for GroupID
* VARIABLE: PUID for for UserID

It is based on phusion-baseimage with ssh removed. (use docker exec).


**Credits**
lonix <lonixx@gmail.com>

**Versions**
2.0 gid/uid fix. and code cleanup.
1.0: Inital release

