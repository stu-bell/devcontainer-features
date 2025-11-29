#!/bin/sh
# This script prepends /usr/bin to the $PATH to prioritise the node version installed by apt-get, to avoid conflicts with lower versions of node already installed.

set -e

# Check if node is already available
if command -v node > /dev/null 2>&1 ; then

  # check version is sufficient
  REQUIRED_MAJOR=${NODE_MAJOR_VERSION:-24}
  CURRENT_VERSION=$(node -v)
  CURRENT_VERSION=${CURRENT_VERSION#v}  # Remove 'v' prefix
  CURRENT_MAJOR=$(echo "$CURRENT_VERSION" | cut -d. -f1) # take the major number
  if [ "$CURRENT_MAJOR" -ge "$REQUIRED_MAJOR" ]; then
    echo "Already installed: Node.js: $(node -v)"
    exit 0
  else
    echo "Node.js version $CURRENT_VERSION is installed but version ${REQUIRED_MAJOR}x or higher is required"
  fi
fi

# Detect OS, populates ID, ID_LIKE, VERSION
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
    curl -fsSL "https://deb.nodesource.com/setup_$NODE_MAJOR_VERSION.x" | bash -
    apt-get update -y
    apt-get install -y nodejs

    # Update PATH to prioritize the newly installed node
    echo "Adding /usr/bin to PATH"
    export PATH="/usr/bin:$PATH"
else
# this script does not install for the current distro
  echo "Unsupported Linux distribution ${ID} / ${ID_LIKE} for Node.js installation via this feature"
fi

# validate node install
if command -v node > /dev/null 2>&1 && command -v npm > /dev/null 2>&1; then
  echo "Successfully installed Node.js $(node -v) | npm: $(npm -v)"
  echo "Node.js installed at: $(command -v node)"
else
    echo "ERROR Could not install Node.js."
    exit 1
fi

