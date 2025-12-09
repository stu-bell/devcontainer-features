#!/bin/sh
# Copyright (c) Stuart Bell 
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.
set -e

NODE_MIN_MAJOR_VERSION="${NODE_MIN_MAJOR_VERSION:-22}"
echo "Installing Node.js from NodeSource and apt-get..."
export DEBIAN_FRONTEND=noninteractive
URL="https://deb.nodesource.com/setup_${NODE_MIN_MAJOR_VERSION}.x"
echo "Fetching from: $URL"
curl -fsSL $URL | bash -
# NOTE: apt-get requires adding /usr/bin to path
apt-get update -y
apt-get install -y nodejs

