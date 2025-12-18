#!/bin/sh
# Copyright (c) Stuart Bell 
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.
set -e
# has_command, is_root_user, semver_major
. ./util.sh

# Default env vars
export NODE_MIN_MAJOR_VERSION="${NODE_MIN_MAJOR_VERSION:-22}"

# Check for root 
is_root_user || {
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
  }

# Check if sufficient version of node already installed
if has_command node ; then
 CURRENT_VERSION=$(node -v)
 CURRENT_MAJOR=$(semver_major "$CURRENT_VERSION") 
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
     /bin/sh "$(dirname "$0")/install-alp.sh" "$@"
# Debian, Ubuntu
elif [ "${ID}" = "debian" ] || \
     [ "${ID_LIKE}" = "debian" ];  then
     /bin/bash "$(dirname $0)/install-deb.sh" "$@"

else
# this script does not install for the current distro
  feature="Node.js"
  echo "ERROR: Unsupported Linux distribution (${ID}/${ID_LIKE}) for ${feature} installation via this feature. Please use an appropriate script or devcontainer feature to install ${feature} for your system."
fi

# validate node install
if has_command node ; then
  CURRENT_VERSION=$(node -v)
  CURRENT_MAJOR=$(semver_major "$CURRENT_VERSION") 
  if [ "$CURRENT_MAJOR" -ge "$NODE_MIN_MAJOR_VERSION" ]; then
    echo "Installation complete: Node.js $CURRENT_VERSION"
  else
    echo "WARNING: Attempted to install Node.js v${NODE_MIN_MAJOR_VERSION} but installed version ${CURRENT_VERSION}."
  fi
else
    echo "ERROR: Could not install Node.js."
    # attempt at error output
    node -v
    exit 1
fi

