#!/bin/sh
# Note for installations via apt-get, prepend /usr/bin to the $PATH to prioritise the installation by apt-get
set -e

# Check if node is already available
REQUIRED_MAJOR=${NODE_MIN_MAJOR_VERSION:-24}
if command -v node > /dev/null 2>&1 ; then
  # check version is sufficient
  CURRENT_VERSION=$(node -v)
  CURRENT_MAJOR=$(echo "$CURRENT_VERSION" | cut -c2- | cut -d. -f1)
  if [ "$CURRENT_MAJOR" -ge "$REQUIRED_MAJOR" ]; then
    echo "Already installed: Node.js $CURRENT_VERSION"
    exit 0
  else
    echo "Node.js version $CURRENT_VERSION is installed but version ${REQUIRED_MAJOR}.x or higher is required"
  fi
fi

# Detect OS, populates ID, ID_LIKE, VERSION
. /etc/os-release
# Alpine
if [ "${ID}" = "alpine" ]; then
    echo "Installing Node.js on Alpine Linux via apk..."
    apk update 
    apk --no-cache add nodejs npm

# Debian, Ubuntu
elif [ "${ID}" = "debian" ] || \
     [ "${ID_LIKE}" = "debian" ];  then

    echo "Installing Node.js from NodeSource and apt-get..."
    export DEBIAN_FRONTEND=noninteractive
    URL="https://deb.nodesource.com/setup_${REQUIRED_MAJOR}.x"
    echo "Fetching from: $URL"
    curl -fsSL $URL | bash -
    apt-get update -y
    apt-get install -y nodejs

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

