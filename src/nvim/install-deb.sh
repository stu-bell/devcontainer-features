#!/bin/sh
# Copyright (c) Stuart Bell 
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.
set -e

# echo "Installing Neovim via apt-get..."
# sudo apt-get update 
# sudo apt-get install -y neovim

echo "Installing Neovim from source"

echo "Installing Neovim dependencies..."
apt-get update -y
apt-get -y install ninja-build gettext cmake curl build-essential git

apt-get -y clean
rm -rf /var/lib/apt/lists/*

cd /tmp

# TODO branch name to config. But is v0.11.6 unstable
git clone --depth 1 --single-branch --branch release-0.11 https://github.com/neovim/neovim neovim
cd neovim

echo "Building Neovim..."
# CMAKE_BUILD_TYPE=Release for stable?
make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=/usr/local/nvim
sudo make install
ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/nvim

# rm -rf /tmp/neovim

