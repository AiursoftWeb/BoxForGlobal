#!/bin/bash
REAL_DOCKER="/usr/bin/docker"
HOST_IP="172.17.0.1"
TARGET_DOMAIN="nuget.aiursoft.com"

if [[ "$1" == "build" ]]; then
    shift
    exec "$REAL_DOCKER" build --add-host "$TARGET_DOMAIN:$HOST_IP" "$@"
else
    exec "$REAL_DOCKER" "$@"
fi
