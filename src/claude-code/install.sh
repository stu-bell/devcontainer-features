#!/bin/sh
# Copyright (c) 2026 Stuart Bell
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.
set -e
. ./util.sh

# Make sure there isn't already an installation of the tool
remote_user_has_command claude && {
    version=$(remote_user_run 'export PATH="$_REMOTE_USER_HOME/.local/bin:$PATH" && claude -v')
    echo "Claude Code $(claude -v) is already installed"
    exit 0
}

# dependencies
has_command curl || {
    echored "ERROR: This feature requires curl to be installed. Install with devcontainer feature ghcr.io/devcontainers/features/common-utils"
    exit 1
}

# alpine dependencies
ensure_bash_on_alpine
if os_alpine ; then 
    apk add --no-cache libgcc libstdc++ ripgrep
fi

# install Claude Code
echo "Installing Claude Code via https://claude.ai/install.sh"
echo ""
echo "Note: Claude install script does not output progress..."
# Run the install as the remote user, as script installs locally
remote_user_run 'curl -fsSL https://claude.ai/install.sh | bash'

# Verify installation
if ! os_alpine ; then
# FIXME: verification not working on alpine
    remote_user_has_command claude && {
        version=$(remote_user_run 'export PATH="$_REMOTE_USER_HOME/.local/bin:$PATH" && claude -v')
        echo "Claude Code ${version} installed successfully"
    }
fi

