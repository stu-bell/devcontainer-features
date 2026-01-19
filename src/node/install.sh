#!/bin/sh
# Copyright (c) Stuart Bell 
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.
set -e
. ./util.sh

# Default env vars
export NODE_TARGET_VERSION="${NODE_TARGET_VERSION:-22}"

if os_alpine; then
    install_oci_feature "ghcr.io/cirolosapio/devcontainers-features/alpine-node:0.0.15" "version=$NODE_TARGET_VERSION"
else
    install_oci_feature "ghcr.io/devcontainers/features/node:1" "VERSION=$NODE_TARGET_VERSION"
fi
