#!/bin/sh
set -e

# make sure there isn't already an installation of the tool
if command -v gemini  > /dev/null 2>&1; then
    echo "Gemini CLI is already installed"
    exit 0
fi

# ensure node and npm are installed
./install-node.sh

# TODO add this to install-node.sh as comment if it works
# Source nvm if it exists
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    . "$HOME/.nvm/nvm.sh"
fi

# Check npm is installed
if command -v node > /dev/null 2>&1 && command -v npm > /dev/null 2>&1; then
  echo "Found Node.js: $(node -v) | npm: $(npm -v)"
fi

# Install Gemini CLI via npm
echo "Installing Gemini CLI..."
if [ "$VERSION" = "latest" ]; then
    npm install -g @google/gemini-cli
else
    npm install -g @google/gemini-cli@${VERSION}
fi

# Verify installation
if command -v gemini  > /dev/null 2>&1; then
    echo "Gemini CLI $(gemini --version) installed successfully"
else
    echo "Failed to install Gemini CLI"
    exit 1
fi

