#!/bin/sh
# Copyright (c) Stuart Bell 
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.
set -e

# Detect architecture and normalize
arch=$(uname -m)
case "$arch" in
  x86_64)
    arch="x86_64"
    ;;
  aarch64|arm64)
    arch="arm64"
    ;;
  *)
    echo "ERROR: Unsupported architecture '$arch'. Only x86_64 and arm64 are supported."
    exit 1
    ;;
esac

echo "Installing neovim via appimage: https://neovim.io/doc/install/#appimage-universal-linux-package"
curl -LO "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${arch}.appimage"
chmod u+x "nvim-linux-${arch}.appimage"
# /dev/null to reduce noise
"./nvim-linux-${arch}.appimage" --appimage-extract > /dev/null

# Move extracted files to /opt/nvim
mkdir -p /opt/nvim
mv squashfs-root /opt/nvim/
ln -sf /opt/nvim/squashfs-root/usr/bin/nvim /usr/local/bin/nvim

# Clean up
rm "nvim-linux-${arch}.appimage"

