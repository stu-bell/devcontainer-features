#!/bin/sh
set -e

# make sure there isn't already an installation of the tool
if command -v gemini  > /dev/null 2>&1; then
    echo "Gemini CLI $(gemini --version) is already installed"
    exit 0
fi

# ensure node and npm are installed. Min v 20 required by gemini cli. Can be changed in feature options
NODE_MIN_MAJOR_VERSION="${NODE_MIN_MAJOR_VERSION:-20}" ./install-node.sh

# Check min node version installed
MSG_NODE_MISSING="Ensure Node.js (minimum v${NODE_MIN_MAJOR_VERSION}.x) and npm are installed before this feature installs, using an appropriate base image or feature. 
FAILED TO INSTALL Gemini CLI"
if command -v node > /dev/null 2>&1; then
  CURRENT_VERSION=$(node -v)
  CURRENT_MAJOR=$(echo "$CURRENT_VERSION" | cut -c2- | cut -d. -f1)
  if [ "$CURRENT_MAJOR" -ge "$NODE_MIN_MAJOR_VERSION" ]; then
    echo "Found Node.js $CURRENT_VERSION"
  else
    echo "ERROR: Insufficient version of Node.js $CURRENT_VERSION is installed. $MSG_NODE_MISSING"
    exit 1
  fi
else 
    # Node not found
    echo "ERROR: could not find node. $MSG_NODE_MISSING"
    exit 1
fi

# check npm is installed
if command -v npm > /dev/null 2>&1; then
  echo "Using npm $(npm -v)"
else 
    echo "ERROR: could not find npm. $MSG_NODE_MISSING"
    exit 1
fi

# Install Gemini CLI via npm
GEMINI_V=${VERSION:-"latest"}
echo "Installing Gemini CLI version ${GEMINI_V}..."
npm install -g @google/gemini-cli@${GEMINI_V}

# Verify installation
if command -v gemini  > /dev/null 2>&1; then
    echo "Gemini CLI $(gemini --version) installed successfully"
else
    echo "ERROR: Failed to install Gemini CLI"
    exit 1
fi

