#!/bin/sh
# Copyright (c) Stuart Bell 
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.

# v0.1.1
# os_debian_like os_alpine ensure_bash_on_alpine echoyel echogrn echored semver_major s_root_user has_command run_as_remote_user

# check if a command exists
has_command() {
    command -v "$1" > /dev/null 2>&1
}
# MISSING_DEPS=""
# for cmd in git node npm; do
#     if ! assert_dependency "$cmd"; then
#         MISSING_DEPS="$MISSING_DEPS $cmd"
#     fi
# done
# if [ -n "$MISSING_DEPS" ]; then
#     echo "ERROR: Missing:$MISSING_DEPS"
#     exit 1
# fi

# check if user is root user
is_root_user() {
    [ "$(id -u)" -eq 0 ]
}

# parse major verion from a semantic version string
semver_major() {
    echo "${1#v}" | cut -d'.' -f1
}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
echored() {
    echo -e "${RED}$@${NC}"
}
echogrn() {
    echo -e "${GREEN}$@${NC}"
}
echoyel() {
    echo -e "${YELLOW}$@${NC}"
}

# If we're using Alpine, install bash before executing
ensure_bash_on_alpine() {
    . /etc/os-release
    if [ "${ID}" = "alpine" ]; then
        apk add --no-cache bash
    fi
}

# OS detection. Populates ID, ID_LIKE, VERSION
os_alpine() {
    . /etc/os-release
    [ "${ID}" = "alpine" ]
}
os_debian_like() {
    . /etc/os-release
    [ "${ID}" = "debian" ] || [ "${ID_LIKE}" = "debian" ]
}

# Run a command as the remote user for the devcontainer. 
run_as_remote_user() {
# Use _REMOTE_USER if available, otherwise use the devcontainer.json option USER_NAME
    command_to_run="$1"
    USER_OPTION="${REMOTE_USER_NAME:-automatic}"
    _REMOTE_USER="${_REMOTE_USER:-${USER_OPTION}}"
    if [ "${_REMOTE_USER}" = "auto" ] || [ "${_REMOTE_USER}" = "automatic" ]; then
        _REMOTE_USER="$(id -un 1000 2>/dev/null || echo "vscode")" # vscode fallback
    fi
    echo "Running as: $_REMOTE_USER, command: $command_to_run"
    su - "${_REMOTE_USER}" -c "$command_to_run"
}

