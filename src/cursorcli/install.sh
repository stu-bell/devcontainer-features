#!/bin/sh
# Copyright (c) Stuart Bell 
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.
set -e
# os_debian_like os_alpine ensure_bash_on_alpine echoyel echogrn echored semver_major s_root_user has_command
. ./util.sh

# Make sure there isn't already an installation of the tool
has_command cursor-agent && {
    echo "Cursor CLI $(cursor-agent --version) is already installed"
    exit 0
}

has_command curl || {
    echored "ERROR: This feature requires curl to be installed. Install with devcontainer feature ghcr.io/devcontainers/features/common-utils"
    exit 1
}

# Note: cursor doesn't run on Alpine at the time of writing
ensure_bash_on_alpine

# install cursor
echo "Installing Cursor CLI via https://cursor.com/install"
# curl https://cursor.com/install -fsS | bash

# Use _REMOTE_USER if available, otherwise use the devcontainer.json option USER_NAME
USER_OPTION="${USER_NAME:-automatic}"
_REMOTE_USER="${_REMOTE_USER:-${USER_OPTION}}"
if [ "${_REMOTE_USER}" = "auto" ] || [ "${_REMOTE_USER}" = "automatic" ]; then
    _REMOTE_USER="$(id -un 1000 2>/dev/null || echo "vscode")" # fallback to vscode, but devcontainer.json can override
fi
echo "Running command as: $_REMOTE_USER"
# Run the install as the user
su - "${_REMOTE_USER}" -c 'curl https://cursor.com/install -fsS | bash'

echo verify
su - "${_REMOTE_USER}" -c '~/.local/bin/cursor-agent'

# Verify installation
# if has_command cursor-agent; then
#     echo "Cursor CLI $(cursor-agent --version) installed successfully"
#     exit 0
# else
#     echo "ERROR: Failed to install Cursor CLI"
#     exit 1
# fi
