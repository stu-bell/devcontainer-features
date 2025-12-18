#!/bin/sh
# Copyright (c) Stuart Bell 
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.
set -e
# has_command, is_root_user, semver_major, echored
. ./util.sh

# make sure there isn't already an installation of the tool
if has_command nvim; then
	echo "Neovim is already installed:"
	nvim -v
	exit 0
fi

# Check for root 
is_root_user || {
	echored "ERROR: This script must be run as root."
	exit 1
}

# OS detection. Populates ID, ID_LIKE, VERSION
. /etc/os-release
# Alpine
if [ "${ID}" = "alpine" ]; then
	/bin/sh "$(dirname "$0")/install-alp.sh" "$@"
# Debian, Ubuntu
elif [ "${ID}" = "debian" ] || \
     [ "${ID_LIKE}" = "debian" ];  then
	/bin/bash "$(dirname $0)/install-appimage.sh" "$@"
else
# this script does not install for the current distro
	echored "Unsupported Linux distribution (${ID}/${ID_LIKE}) for Neovim installation via this feature."
	echo "Attempting install via AppImage..."
	/bin/bash "$(dirname $0)/install-appimage.sh" "$@"
fi

# Verify installation
if has_command nvim; then
	echo "Neovim installed successfully:"
	nvim -v
else
	echo "ERROR: Failed to install or run Neovim. See https://neovim.io/doc/install/#linux"
	echo "Attempting to run nvim -v for diagnostics:"
	nvim -v 2>&1
	exit 1
fi

# Clone git repo for user Neovim config
if [ -n "$CONFIG_GIT_URL" ]; then
	# check git installed
	has_command git || {

		echored "ERROR: CONFIG_GIT_URL specified but git is not installed."
		echored "Install git by including devcontainer feature: ghcr.io/devcontainers/features/common-utils"
		exit 1
	}

	# clone the config
	echo "Cloning from $CONFIG_GIT_URL..."
	mkdir -p $CONFIG_LOCATION
	GIT_TERMINAL_PROMPT=0 git clone --depth 1 "$CONFIG_GIT_URL" "${CONFIG_LOCATION}/nvim"
fi

