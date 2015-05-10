#!/bin/bash

if [ ! "$(id -u abc)" -eq "$PUID" ]; then usermod -u "$PUID" abc ; fi
if [ ! "$(id -g abc)" -eq "$PGID" ]; then groupmod  -o -g "$PGID" abc ; fi

echo "
-----------------------------------
GID/UID
-----------------------------------
User uid:    $(id -u abc)
User gid:    $(id -g abc)
-----------------------------------
"
