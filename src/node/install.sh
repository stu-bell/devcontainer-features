#!/bin/sh
# Copyright (c) Stuart Bell 
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.
set -e

# Default env vars
export NODE_MIN_MAJOR_VERSION="${NODE_MIN_MAJOR_VERSION:-22}"

# Check for root 
if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Check if sufficient version of node already installed
if command -v node > /dev/null 2>&1 ; then
  CURRENT_VERSION=$(node -v)
  CURRENT_MAJOR=$(echo "$CURRENT_VERSION" | cut -c2- | cut -d. -f1)
  if [ "$CURRENT_MAJOR" -ge "$NODE_MIN_MAJOR_VERSION" ]; then
    echo "Found already installed: Node.js $CURRENT_VERSION"
    exit 0
  else
    echo "Node.js version $CURRENT_VERSION is installed but version ${NODE_MIN_MAJOR_VERSION}.x or higher is required"
  fi
fi

# OS detection. Populates ID, ID_LIKE, VERSION
. /etc/os-release
# Alpine
if [ "${ID}" = "alpine" ]; then
     exec /bin/sh "$(dirname "$0")/install-alp.sh" "$@"
# Debian, Ubuntu
elif [ "${ID}" = "debian" ] || \
     [ "${ID_LIKE}" = "debian" ];  then
     exec /bin/bash "$(dirname $0)/install-deb.sh" "$@"

else
# this script does not install for the current distro
  echo "ERROR: Unsupported Linux distribution (${ID}/${ID_LIKE}) for Node.js installation via this feature. Please use an appropriate script or devcontainer feature to install Node.js for your system."
fi

# validate node install
if command -v node > /dev/null 2>&1 ; then
  CURRENT_VERSION=$(node -v)
  CURRENT_MAJOR=$(echo "$CURRENT_VERSION" | cut -c2- | cut -d. -f1)
  if [ "$CURRENT_MAJOR" -ge "$NODE_MIN_MAJOR_VERSION" ]; then
    echo "Installation complete: Node.js $CURRENT_VERSION"
    exit 0
  else
    echo "WARNING: Attempted to install Node.js v${NODE_MIN_MAJOR_VERSION} but installed version ${CURRENT_VERSION}."
  fi
else
    echo "ERROR: Could not install Node.js."
    exit 1
fi

