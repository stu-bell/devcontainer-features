#!/bin/sh
# Copyright (c) Stuart Bell 
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.
set -e

echo "Installing Neovim via apt-get..."
sudo apt-get update 
sudo apt-get install -y neovim

