#!/bin/sh
# Copyright (c) Stuart Bell
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.
set -e
# has_command, semver_major, semver_gte
. ./util.sh

# Make sure there isn't already an installation of the tool
if remote_user_has_command gemini; then
    echo "Gemini CLI $(gemini --version) is already installed"
    exit 0
fi

# Check if sufficient node version already installed
# It *should* be, based on the dependsOn feature, but not all devcontainer implementing tools support dependsOn, at the time of writing
min_req_ver="$(semver_pad ${MIN_NODE_VERSION:-20})"
installed_version=$(node -v) || echo "No Node installation found."
if semver_gte "$installed_version" "$min_req_ver"; then
    echo "Found Node version $installed_version"
else 
    # Install node feature
    install_oci_feature "ghcr.io/stu-bell/devcontainer-features/node" \
        "MIN_NODE_VERSION=$min_req_ver" 
fi

# Check npm is installed
if ! has_command npm; then
    echo "ERROR: could not find npm. $MSG_NODE_MISSING"
    exit 1
fi
echo "Using npm $(npm -v)"

# Install Gemini CLI via npm
GEMINI_VERSION=${GEMINI_VERSION:-"latest"}
echo "Installing Gemini CLI version ${GEMINI_VERSION}..."
npm install -g @google/gemini-cli@${GEMINI_VERSION}

# Verify installation
if has_command gemini; then
    echo "Gemini CLI $(gemini --version) installed successfully"
    exit 0
else
    echo "ERROR: Failed to install Gemini CLI"
    exit 1
fi
