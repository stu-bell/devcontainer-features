#!/bin/sh
# Copyright (c) Stuart Bell 
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.
set -e
# has_command, semver_major
. ./util.sh

# Make sure there isn't already an installation of the tool
has_command gemini && {
    echo "Gemini CLI $(gemini --version) is already installed"
    exit 0
}

# Check node is installed
NODE_MIN_MAJOR_VERSION=${NODE_MIN_MAJOR_VERSION:-18}
MSG_NODE_MISSING="Ensure Node.js (minimum v${NODE_MIN_MAJOR_VERSION}.x) and npm are installed before this feature installs, using an appropriate base image or feature.
FAILED TO INSTALL Gemini CLI"

has_command node || {
    echo "ERROR: could not find node. $MSG_NODE_MISSING"
    exit 1
}

# Check minimum node version
CURRENT_VERSION=$(node -v)
CURRENT_MAJOR=$(semver_major "$CURRENT_VERSION") 
if [ "$CURRENT_MAJOR" -ge "$NODE_MIN_MAJOR_VERSION" ]; then
    echo "Found Node.js $CURRENT_VERSION"
else
    echo "ERROR: Insufficient version of Node.js $CURRENT_VERSION is installed. $MSG_NODE_MISSING"
    exit 1
fi

# Check npm is installed
has_command npm || {
    echo "ERROR: could not find npm. $MSG_NODE_MISSING"
    exit 1
}
echo "Using npm $(npm -v)"

# Install Gemini CLI via npm
GEMINI_V=${VERSION:-"latest"}
echo "Installing Gemini CLI version ${GEMINI_V}..."
npm install -g @google/gemini-cli@${GEMINI_V}

# Verify installation
if has_command gemini; then
    echo "Gemini CLI $(gemini --version) installed successfully"
    exit 0
else
    echo "ERROR: Failed to install Gemini CLI"
    exit 1
fi
