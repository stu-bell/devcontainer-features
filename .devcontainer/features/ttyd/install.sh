#!/bin/bash
set -e

VERSION="${VERSION:-"latest"}"

# Todo make sh compatible for alpine
# Todo install bash on alpine
# Todo make default command bash an option

# Todo check if ttyd already installed

echo "Installing ttyd..."

#Todo check for dependency curl

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

create_ttyd_sh() {
    # Create ttyd.sh if it doesn't exist
    TTYD_SCRIPT_PATH="${_REMOTE_WORKSPACE_FOLDER}/.devcontainer/ttyd.sh"
    if [ ! -f "$TTYD_SCRIPT_PATH" ]; then
      echo "Creating ttyd.sh..."
      # Create the directory if it doesn't exist
      mkdir -p "$(dirname "$TTYD_SCRIPT_PATH")"

      # Set default values from feature options, or hardcoded defaults
      _PORT="${PORT:-7681}"
      _COLS="${COLS:-80}"
      _FONTSIZE="${FONTSIZE:-20}"
      _READONLY="${READONLY:-false}"

      TTYD_FLAGS=""
      if [ "$_READONLY" = "true" ]; then
        TTYD_FLAGS="" # No -W flag for read-only
      else
        TTYD_FLAGS="-W" # Keep -W flag for writable terminal
      fi

      TTYD_ARGS="-p $_PORT $TTYD_FLAGS -t fontSize=$_FONTSIZE -t cols=$_COLS"

      cat <<EOF > "$TTYD_SCRIPT_PATH"
#!/usr/bin/env bash
nohup ttyd $TTYD_ARGS bash > /tmp/ttyd.log 2>&1 &
echo "ttyd logs at /tmp/ttyd
log"
EOF
    fi

    # Make ttyd.sh executable
    chmod a+x "$TTYD_SCRIPT_PATH"
    echo "ttyd.sh configured and executable."
}

create_ttyd_sh
