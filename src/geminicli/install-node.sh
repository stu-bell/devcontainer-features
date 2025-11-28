#!/bin/sh

# Scripts sourcing this script will need source nvm, before calling node or npm
# # Source nvm if it exists
# if [ -s "$HOME/.nvm/nvm.sh" ]; then
#     . "$HOME/.nvm/nvm.sh"
# fi

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
    echo "Installing node on Alpine Linux via apk..."
    apk --no-cache add nodejs npm

# Debian, Ubuntu
elif [ "${ID}" = "debian" ] || \
     [ "${ID_LIKE}" = "debian" ];  then

    # Download and install node version manager (nvm)
    echo "Installing node via nvm"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    \. "$HOME/.nvm/nvm.sh"
    nvm install "${NODE_VERSION:-"24"}" 
fi

# validate node install
if command -v node > /dev/null 2>&1 && command -v npm > /dev/null 2>&1; then
  echo "Successfully installed Node.js: $(node -v) | npm: $(npm -v)"
else
    echo "Could not install node. Ensure node and npm are installed before this feature installs, using an appropriate base image or feature."
    exit 1
fi

