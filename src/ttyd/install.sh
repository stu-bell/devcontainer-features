#!/bin/bash
set -e

VERSION="${VERSION:-"latest"}"

echo "Installing ttyd..."

# Detect architecture
ARCH=$(uname -m)
case $ARCH in
  x86_64)
    ARCH="x86_64"
    ;;
  aarch64|arm64)
    ARCH="aarch64"
    ;;
  armv7l)
    ARCH="armv7"
    ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

# Get the latest version if "latest" is specified
if [ "$VERSION" = "latest" ]; then
  echo "Fetching latest ttyd version..."
  VERSION=$(curl -s https://api.github.com/repos/tsl0922/ttyd/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
  echo "Latest version: $VERSION"
fi

# Download ttyd binary
DOWNLOAD_URL="https://github.com/tsl0922/ttyd/releases/download/${VERSION}/ttyd.${ARCH}"
echo "Downloading ttyd from: $DOWNLOAD_URL"

curl -L -o /tmp/ttyd "$DOWNLOAD_URL"

# Install ttyd
chmod +x /tmp/ttyd
mv /tmp/ttyd /usr/local/bin/ttyd

# Verify installation
if command -v ttyd >/dev/null 2>&1; then
  echo "ttyd installed successfully!"
  ttyd --version
else
  echo "Failed to install ttyd"
  exit 1
fi