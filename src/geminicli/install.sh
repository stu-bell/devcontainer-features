#!/bin/sh
set -e

# Configuration
NODE_MIN_MAJOR_VERSION=${NODE_MIN_MAJOR_VERSION:-18}

# Function to check if a command exists
# Returns 0 if found, 1 if not found
has_command() {
    command -v "$1" > /dev/null 2>&1
}

# Make sure there isn't already an installation of the tool
has_command gemini && {
    echo "Gemini CLI $(gemini --version) is already installed"
    exit 0
}

MSG_NODE_MISSING="Ensure Node.js (minimum v${NODE_MIN_MAJOR_VERSION}.x) and npm are installed before this feature installs, using an appropriate base image or feature.
FAILED TO INSTALL Gemini CLI"

# Check node is installed
has_command node || {
    echo "ERROR: could not find node. $MSG_NODE_MISSING"
    exit 1
}

# Check minimum node version
CURRENT_VERSION=$(node -v)
CURRENT_MAJOR=$(echo "$CURRENT_VERSION" | cut -c2- | cut -d. -f1)

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
