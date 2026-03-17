#!/bin/sh
# Copyright (c) Stuart Bell 
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.
set -e
. ./util.sh


# Check if sufficient version already installed
min_req_ver="$(semver_pad ${MIN_NODE_VERSION:-22})"
installed_version=$(node -v) || echo "No Node installation found."
if [ "$min_req_ver" != "latest" ] && [ -n "$installed_version" ]; then
	if semver_gte "$installed_version" "$min_req_ver"; then
        echo "Found Node version $installed_version"
        exit 0
    fi
fi

# OS detection
if os_alpine; then
    echo "Installing Node.js on Alpine Linux via apk..."
    apk update 
    apk --no-cache add nodejs npm
else
    install_oci_feature "ghcr.io/devcontainers/features/node:1" \
        "VERSION=$min_req_ver" \
        "NODEGYPDEPENDENCIES=${NODEGYPDEPENDENCIES:-true}" \
        "NVMINSTALLPATH=${NVMINSTALLPATH:-/usr/local/share/nvm}" \
        "PNPMVERSION=${PNPMVERSION:-latest}" \
        "NVMVERSION=${NVMVERSION:-latest}" \
        "INSTALLYARNUSINGAPT=${INSTALLYARNUSINGAPT:-true}"
fi

# verify version
if ! installed_ver=$(node -v); then
    echored "Could not install Node"
    exit 1
fi
echoyel "Node installed: $installed_ver"
if [ "$min_req_ver" != "latest" ] && [ "$min_req_ver" != "lts" ] && ! semver_gte "$installed_ver" "$min_req_ver"; then
    echored "Could not find version $min_req_ver"
    exit 1
fi

