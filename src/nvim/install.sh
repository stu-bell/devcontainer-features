#!/bin/sh
# Copyright (c) Stuart Bell 
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.
set -e

# Terminal colours
RED='\033[0;31m'
NC='\033[0m'

# make sure there isn't already an installation of the tool
if nvim -v  > /dev/null 2>&1; then
	echo -e "Neovim is already installed: \n$(nvim -v)"
    exit 0
fi

# Check for root 
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}ERROR: This script must be run as root.${NC}"
    exit 1
fi

# OS detection. Populates ID, ID_LIKE, VERSION
. /etc/os-release
# Alpine
if [ "${ID}" = "alpine" ]; then
     exec /bin/sh "$(dirname "$0")/install-alp.sh" "$@"
# Debian, Ubuntu
elif [ "${ID}" = "debian" ] || \
     [ "${ID_LIKE}" = "debian" ];  then
     exec /bin/bash "$(dirname $0)/install-deb.sh" "$@"
else
# this script does not install for the current distro
	echo "Unsupported Linux distribution (${ID}/${ID_LIKE}) for Node.js installation via this feature. Please use an appropriate script or devcontainer feature to install Node.js for your system."
	echo "Attempting appimage installation..."
	exec /bin/bash "$(dirname $0)/install-appimage.sh" "$@"
fi

# Verify installation
if nvim -v > /dev/null 2>&1; then
	echo -e "Neovim installed successfully: \n$(nvim -v)"
else
	echo "ERROR: Failed to install or run Neovim. See https://neovim.io/doc/install/#linux"
	echo "Attempting to run nvim -v for diagnostics:"
	nvim -v 2>&1 || true # || true waits until explicit exit
	exit 1
fi

