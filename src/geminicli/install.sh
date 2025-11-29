#!/bin/sh
set -e

# make sure there isn't already an installation of the tool
if command -v gemini  > /dev/null 2>&1; then
    echo "Gemini CLI $(gemini --version) is already installed"
    exit 0
fi

# version var overwritten by node install
GEMINI_VERSION="${VERSION:-latest}"

# ensure node and npm are installed. Min v 20 required by gemini
NODE_MAJOR_VERSION="${NODE_MAJOR_VERSION:- 20}"
export NODE_MAJOR_VERSION
./install-node.sh

# Check npm is installed
if command -v node > /dev/null 2>&1 && command -v npm > /dev/null 2>&1; then
  echo "Found Node.js: $(node -v) | npm: $(npm -v)"
else 
    echo "Could not find an node or npm. Ensure Node.js and npm are installed before this feature installs, using an appropriate base image or feature."
fi

# Install Gemini CLI via npm
echo "Installing Gemini CLI version ${GEMINI_VERSION}..."
if [ "$GEMINI_VERSION" = "latest" ]; then
    npm install -g @google/gemini-cli
else
    npm install -g @google/gemini-cli@${GEMINI_VERSION}
fi

# Verify installation
if command -v gemini  > /dev/null 2>&1; then
    echo "Gemini CLI $(gemini --version) installed successfully"
else
    echo "Failed to install Gemini CLI"
    exit 1
fi

