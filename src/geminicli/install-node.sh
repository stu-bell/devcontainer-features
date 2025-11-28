#!/bin/sh
set -e

# Check if node is already available
if command -v node > /dev/null 2>&1 && command -v npm > /dev/null 2>&1; then
  echo "Already installed: Node.js: $(node -v) | npm: $(npm -v)"
  exit 0
fi

# Detect OS, populates ID, ID_LIKE
. /etc/os-release
if [ "${ID}" = "alpine" ]; then
    apk --no-cache add nodejs npm

elif [ "${ID}" = "debian" ] || \
   [ "${ID_LIKE}" = "debian" ] || \
   [ "${ID}" = "rhel" ] || \
   [ "${ID}" = "fedora" ] || \
   [ "${ID}" = "mariner" ]; then

    # OS supported by official node install featured
    ./install-node-microsoft.sh
fi

# validate node install
if command -v node > /dev/null 2>&1 && command -v npm > /dev/null 2>&1; then
  echo "Successfully installed Node.js: $(node -v) | npm: $(npm -v)"
else
    echo "Could not install node. Ensure node and npm are installed before this feature installs, using an appropriate base image or feature."
    exit 1
fi

