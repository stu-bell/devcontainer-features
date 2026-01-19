#!/bin/sh
# Copyright (c) Stuart Bell 
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.
set -e
. ./util.sh

# Default env vars
export NODE_TARGET_VERSION="${NODE_TARGET_VERSION:-22}"

if os_alpine; then
    echo "Installing Node.js on Alpine Linux via apk..."
    apk update 
    apk --no-cache add nodejs npm
else
    install_oci_feature "ghcr.io/devcontainers/features/node:1" "VERSION=$NODE_TARGET_VERSION"
fi
