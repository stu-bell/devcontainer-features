#!/bin/sh
# Copyright (c) 2026 Stuart Bell
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.
set -e
. ./util.sh

# Make sure there isn't already an installation of the tool
remote_user_has_command opencode && {
    version=$(remote_user_run 'opencode -v')
    echo "Open Code $version is already installed"
    exit 0
}

# dependencies
has_command curl || {
    echored "ERROR: This feature requires curl to be installed. Install with devcontainer feature ghcr.io/devcontainers/features/common-utils"
    exit 1
}

# alpine dependencies
ensure_bash_on_alpine

# install Open Code
echo "Installing Open Code via https://opencode.ai/install"
echo ""
# Run the install as the remote user, as script installs locally
if [ "${OPEN_CODE_VERSION-latest}" = "latest" ] ; then
    remote_user_run 'curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path'
else
    remote_user_run "curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path --version $OPEN_CODE_VERSION"
fi
add_to_user_profiles 'export PATH="$HOME/.opencode/bin:$PATH"'

# Verify installation
remote_user_has_command 'opencode' && {
    version=$(remote_user_run 'opencode -v')
    echo "Open Code ${version} installed successfully"
}

