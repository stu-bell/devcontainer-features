#!/bin/sh
set -e

# Function to check if a command exists
# Returns 0 if found, 1 if not found
has_command() {
    command -v "$1" > /dev/null 2>&1
}

# make sure there isn't already an installation of the tool
if has_command gemini ; then
    echo "Gemini CLI $(gemini --version) is already installed"
    exit 0
fi

MSG_NODE_MISSING="Ensure Node.js (minimum v${NODE_MIN_MAJOR_VERSION}.x) and npm are installed before this feature installs, using an appropriate base image or feature. 
FAILED TO INSTALL Gemini CLI"

# Check min node version installed
has_command node || {
    echo "ERROR: could not find node. $MSG_NODE_MISSING"
    exit 1
}
CURRENT_VERSION=$(node -v)
CURRENT_MAJOR=$(echo "$CURRENT_VERSION" | cut -c2- | cut -d. -f1)
if [ "$CURRENT_MAJOR" -ge "$NODE_MIN_MAJOR_VERSION" ]; then
  echo "Found Node.js $CURRENT_VERSION"
else
  echo "ERROR: Insufficient version of Node.js $CURRENT_VERSION is installed. $MSG_NODE_MISSING"
  exit 1
fi

# check npm is installed
if has_command npm; then
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
has_command gemini && {
    echo "Gemini CLI $(gemini --version) installed successfully"
    exit 0
}

echo "ERROR: Failed to install Gemini CLI"
exit 1

