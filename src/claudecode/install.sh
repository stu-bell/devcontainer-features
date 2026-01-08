#!/bin/sh
# Copyright (c) Stuart Bell 
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.
set -e
# os_debian_like os_alpine ensure_bash_on_alpine echoyel echogrn echored semver_major s_root_user has_command
. ./util.sh


# Make sure there isn't already an installation of the tool
has_command claude && {
    echo "Claude Code $(claude -v) is already installed"
    exit 0
}

# dependencies
ensure_bash_on_alpine
has_command curl || {
    echored "ERROR: This feature requires curl to be installed. Install with devcontainer feature ghcr.io/devcontainers/features/common-utils"
    exit 1
}

# install Claude Code
echo "Installing Claude Code via https://claude.ai/install.sh"
# Run the install as the remote user, as script installs locally
run_as_remote_user 'curl -fsSL https://claude.ai/install.sh | bash'

# Verify installation
if run_as_remote_user 'claude -v' > /dev/null 2>&1; then
    version=$(run_as_remote_user 'claude -v')
    echo "Claude Code ${version} installed successfully"
else
    echo "ERROR: Failed to install Claude Code"
    exit 1
fi

