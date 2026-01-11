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
if os_alpine; then 
    echo "NOTE: At the time of writing, Cursor does NOT WORK on Alpine Linux. This may be fixed by the time you're installing this feature."
    ensure_bash_on_alpine
fi

# install cursor
echo "Installing Cursor CLI via https://cursor.com/install"
# Run the install as the remote user, as script installs locally
run_as_remote_user 'curl https://cursor.com/install -fsS | bash'

# Verify installation
if run_as_remote_user '~/.local/bin/cursor-agent -v' > /dev/null 2>&1; then
    version=$(run_as_remote_user '~/.local/bin/cursor-agent -v')
    echo "Cursor CLI ${version} installed successfully"
else
    echo "ERROR: Failed to install Cursor CLI"
    exit 1
fi
