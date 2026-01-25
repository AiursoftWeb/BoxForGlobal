#!/bin/bash

REAL_DOCKER="/usr/bin/docker"
HOST_IP="172.17.0.1"

# Target domains to inject
TARGET_DOMAINS=(
    "nuget.aiursoft.com"
    "hub.aiursoft.com"
    "npm.aiursoft.com"
    "mirror.aiursoft.com"
)

if [[ "$1" == "build" ]]; then
    shift
    
    # Build arguments array
    ADD_HOST_ARGS=()
    for domain in "${TARGET_DOMAINS[@]}"; do
        ADD_HOST_ARGS+=(--add-host "$domain:$HOST_IP")
    done

    # Execute real docker with host injection
    exec "$REAL_DOCKER" build "${ADD_HOST_ARGS[@]}" "$@"
else
    # Pass through other commands
    exec "$REAL_DOCKER" "$@"
fi
