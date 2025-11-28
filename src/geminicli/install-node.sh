#!/bin/sh
set -e

# Check if node is already available
if command -v node > /dev/null 2>&1 && command -v npm > /dev/null 2>&1; then
  echo "Already installed: Node.js: $(node -v) | npm: $(npm -v)"
  exit 0
fi

# TODO install a requested version of node

# Detect OS, populates ID, ID_LIKE
. /etc/os-release
if [ "${ID}" = "alpine" ]; then
    echo "Installing node on Alpine Linux via apk..."
    apk --no-cache add nodejs npm

elif [ "${ID}" = "debian" ] || \
     [ "${ID_LIKE}" = "debian" ];  then

    # echo "Installing node from apt-get..."
    # apt-get update -y
    # apt-get install -y nodejs npm

    # Download and install node version manager (nvm)
    echo "Installing node via nvm"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    \. "$HOME/.nvm/nvm.sh"
    nvm install "${NODE_VERSION:-"lts"}" 
fi
echo "Node install completed."

# validate node install
if command -v node > /dev/null 2>&1 && command -v npm > /dev/null 2>&1; then
  echo "Successfully installed Node.js: $(node -v) | npm: $(npm -v)"
else
    echo "Could not install node. Ensure node and npm are installed before this feature installs, using an appropriate base image or feature."
    exit 1
fi

