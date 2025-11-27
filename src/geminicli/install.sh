#!/bin/bash
set -e

# make sure there isn't already an installation of the tool
if command -v gemini &> /dev/null; then
    echo "Gemini CLI is already installed"
    exit 0
fi

# Install Gemini CLI via npm
echo "Installing Gemini CLI..."
if [ "$VERSION" = "latest" ]; then
    npm install -g @google/gemini-cli
else
    npm install -g @google/gemini-cli@${VERSION}
fi

# Verify installation
if command -v gemini &> /dev/null && gemini --version &> /dev/null; then
    echo "Gemini CLI installed successfully"
    gemini --version
else
    echo "Failed to install Gemini CLI"
    exit 1
fi

