#!/bin/sh
# Copyright (c) Stuart Bell 
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.
# TODO branch name (release version) to config. 
# TODO fetch stable version (you can compare the version installed to the latest stable release version)
# https://github.com/neovim/neovim/releases/latest
# CMAKE_BUILD_TYPE=Release for stable? 
set -e

echo "Installing Neovim from source"

# https://neovim.io/doc/build/#build-prerequisites
echo "Installing Neovim dependencies..."
apt-get update -y
# build dependencies for debian
apt-get -y install ninja-build gettext cmake curl build-essential git

apt-get -y clean
rm -rf /var/lib/apt/lists/*

cd /tmp

branch=release-0.11
git clone --depth 1 --single-branch --branch ${branch} https://github.com/neovim/neovim neovim
cd neovim

echo "Building Neovim..."
make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=/usr/local/nvim
sudo make install
ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/nvim

rm -rf /tmp/neovim

