#!/bin/sh
# Copyright (c) Stuart Bell 
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.
set -e

# Terminal colours
RED='\033[0;31m'
NC='\033[0m'

# make sure there isn't already an installation of the tool
if nvim -v  > /dev/null 2>&1; then
	echo "Neovim is already installed:"
	nvim -v
	exit 0
fi

# Check for root 
if [ "$(id -u)" -ne 0 ]; then
	echo "${RED}ERROR: This script must be run as root.${NC}"
	exit 1
fi

# OS detection. Populates ID, ID_LIKE, VERSION
. /etc/os-release
# Alpine
if [ "${ID}" = "alpine" ]; then
	/bin/sh "$(dirname "$0")/install-alp.sh" "$@"
# Debian, Ubuntu
elif [ "${ID}" = "debian" ] || \
     [ "${ID_LIKE}" = "debian" ];  then
	# /bin/bash "$(dirname $0)/install-deb.sh" "$@"
	/bin/bash "$(dirname $0)/install-appimage.sh" "$@"
else
# this script does not install for the current distro
	echo "${RED}Unsupported Linux distribution (${ID}/${ID_LIKE}) for Neovim installation.${NC}"
fi

# Verify installation
if nvim -v > /dev/null 2>&1; then
	echo "Neovim installed successfully:"
	nvim -v
else
	echo "ERROR: Failed to install or run Neovim. See https://neovim.io/doc/install/#linux"
	echo "Attempting to run nvim -v for diagnostics:"
	nvim -v 2>&1 || true # || true waits until explicit exit
	exit 1
fi

# Clone git repo for user Neovim config
if [ -n "$CONFIG_GIT_URL" ]; then
	# check git installed
	if ! command -v git >/dev/null 2>&1; then
		echo "${RED}ERROR: CONFIG_GIT_URL specified but git is not installed."
		echo "Install git by including devcontainer feature: ghcr.io/devcontainers/features/common-utils${NC}"
		exit 1
	fi

	# clone the config
	echo "Cloning from $CONFIG_GIT_URL..."
	mkdir -p $CONFIG_LOCATION
	GIT_TERMINAL_PROMPT=0 git clone --depth 1 "$CONFIG_GIT_URL" "${CONFIG_LOCATION}/nvim"
fi

