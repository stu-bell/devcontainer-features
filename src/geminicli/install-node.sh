#!/bin/sh

set -e

# Check if node is already available
if command -v node > /dev/null 2>&1 && command -v npm > /dev/null 2>&1; then
  echo "Already installed: Node.js: $(node -v) | npm: $(npm -v)"
  exit 0
fi

# Detect OS, populates ID, ID_LIKE
. /etc/os-release
# Alpine
if [ "${ID}" = "alpine" ]; then
    echo "Installing Node.js on Alpine Linux via apk..."
    apk --no-cache add nodejs npm

# Debian, Ubuntu
elif [ "${ID}" = "debian" ] || \
     [ "${ID_LIKE}" = "debian" ];  then

    echo "Installing Node.js from NodeSource..."
    export DEBIAN_FRONTEND=noninteractive
    curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR_VERSION:-24}.x" | bash -
    apt-get update -y
    apt-get install -y nodejs

else
# this script does not install for the current distro
  echo "Unsupported Linux distribution ${ID} / ${ID_LIKE} for Node.js installation via this feature"
fi

# validate node install
if command -v node > /dev/null 2>&1 && command -v npm > /dev/null 2>&1; then
  echo "Successfully installed Node.js: $(node -v) | npm: $(npm -v)"
else
    echo "Could not install Node.js."
    exit 1
fi

