#!/bin/sh
set -e

# Terminal colours
RED='\033[0;31m'
NC='\033[0m'

# make sure there isn't already an installation of the tool
if command -v nvim  > /dev/null 2>&1; then
	echo -e "Neovim is already installed: \n$(nvim -v)"
    exit 0
fi

# Check for root 
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}ERROR: This script must be run as root.${NC}"
    exit 1
fi

# Check for dependencies
need_deps=""
if ! command -v curl >/dev/null 2>&1; then
	need_deps="curl"
fi
if [ "$need_deps" != "" ]; then
	echo -e "${RED}ERROR: Dependency not found: ${need_deps}${NC}" >&2
	echo -e "Please install ${need_deps} before installing this feature."
	echo -e "See ghcr.io/devcontainers/features/common-utils"
	exit 1
fi

# Detect architecture
# https://learn.microsoft.com/en-us/windows/msix/package/device-architecture
arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/x86_64/)
if [[ "$arch" != "x86_64" && "$arch" != "aarch64" ]]; then
  echo -e "${RED}ERROR: Unsupported architecture '$arch'. Only x86_64 and aarch64 (ARM64) are supported."
  exit 1
fi

# Install
echo -e "Installing neovim via appimage: https://neovim.io/doc/install/#appimage-universal-linux-package"
curl -LO "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${arch}.appimage"
chmod u+x nvim-linux-${arch}.appimage
mkdir -p /opt/nvim
mv nvim-linux-x86_64.appimage /opt/nvim/nvim
# add to path: /opt/nvim/

# Verify installation
if nvim -v > /dev/null 2>&1; then
	echo -e "Neovim installed successfully: \n$(nvim -v)"
else
	echo "ERROR: Failed to install or run Neovim. See https://neovim.io/doc/install/#linux"
	echo "Attempting to run nvim -v for diagnostics:"
	nvim -v 2>&1 || true # || true waits until explicit exit
	exit 1
fi

