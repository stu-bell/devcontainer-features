#!/bin/sh
# Copyright (c) 2026 Stuart Bell 
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.

# v0.1.4
# check if a command exists
has_command() {
    command -v "$1" > /dev/null 2>&1
}

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
remote_user_run() {
# Use _REMOTE_USER if available, otherwise use the devcontainer.json option USER_NAME
    command_to_run="$1"
    USER_OPTION="${REMOTE_USER_NAME:-automatic}"
    _REMOTE_USER="${_REMOTE_USER:-${USER_OPTION}}"
    if [ "${_REMOTE_USER}" = "auto" ] || [ "${_REMOTE_USER}" = "automatic" ]; then
        _REMOTE_USER="$(id -un 1000 2>/dev/null || id -un)" # fallback to current user
    fi
    echo "Running as: $_REMOTE_USER, command: $command_to_run" >&2
    su - "${_REMOTE_USER}" -c "sh -lc '$command_to_run'"
}

# check if a command exists for remote user
remote_user_has_command() {
    remote_user_run "command -v \"$1\" > /dev/null 2>&1"
}

# append line to common user profile files. eg:
# add_to_user_profiles 'export PATH="$HOME/.local/bin:$PATH"'
add_to_user_profiles() {
    echo "$1" | tee -a \
  "$_REMOTE_USER_HOME/.profile" \
        "$_REMOTE_USER_HOME/.ashrc" \
        "$_REMOTE_USER_HOME/.bashrc" \
        "$_REMOTE_USER_HOME/.bash_profile" \
        "$_REMOTE_USER_HOME/.zshrc" \
        "$_REMOTE_USER_HOME/.zprofile" \
        > /dev/null
    # set user as owner of the files we've just created as root
    [ "$(id -u)" -eq 0 ] && chown -R "$_REMOTE_USER:$_REMOTE_USER" "$_REMOTE_USER_HOME"
}
