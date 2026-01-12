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
        _REMOTE_USER="$(id -un 1000 2>/dev/null || echo "vscode")" # vscode fallback
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

# Download and install an OCI feature
#     install_oci_feature "ghcr.io/devcontainers/features/python:1.8.0" \
#         "VERSION=3.11" \
#         "INSTALL_JUPYTERLAB=true" \
#         "OPTIMIZE=true"
install_oci_feature() {
    FEATURE_URI=$1
    shift  # Remove first argument, rest are options
    
    # dependencies
    has_command curl || {
        echored "ERROR: This feature requires curl to be installed. Install with devcontainer feature ghcr.io/devcontainers/features/common-utils"
        exit 1
    }
    has_command sed || {
        echored "ERROR: This feature requires sed to be installed. Install with devcontainer feature ghcr.io/devcontainers/features/common-utils"
        exit 1
    }
    has_command grep || {
        echored "ERROR: This feature requires grep to be installed. Install with devcontainer feature ghcr.io/devcontainers/features/common-utils"
        exit 1
    }
    has_command tar || {
        echored "ERROR: This feature requires tar to be installed."
        exit 1
    }

    # Parse the URI (format: registry/repo/path:tag or registry/repo/path@digest)
    REGISTRY=$(echo "$FEATURE_URI" | cut -d'/' -f1)
    REPO_AND_TAG=$(echo "$FEATURE_URI" | cut -d'/' -f2-)
    
    # Check if tag or digest is present
    case "$REPO_AND_TAG" in
        *:*|*@*)
            REPO=$(echo "$REPO_AND_TAG" | sed 's/[:@].*//')
            TAG=$(echo "$REPO_AND_TAG" | sed 's/.*[:@]//')
            ;;
        *)
            REPO="$REPO_AND_TAG"
            TAG="latest"
            ;;
    esac
    
    echo "Installing OCI feature: $FEATURE_URI"
    echo "Registry: $REGISTRY, Repo: $REPO, Tag: $TAG"
    
    # Display options if provided
    if [ $# -gt 0 ]; then
        echo "Options:"
        for opt in "$@"; do
            echo "  $opt"
        done
    fi
    
    # Create temp directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Get anonymous token (works for most public registries)
    echo "Getting authentication token..."
    TOKEN=$(curl -s "https://${REGISTRY}/token?scope=repository:${REPO}:pull" | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')
    
    # If token endpoint fails, try without token first
    if [ -z "$TOKEN" ]; then
        echo "No token endpoint, attempting without authentication..."
    fi
    
    # Get the manifest
    echo "Fetching manifest..."
    if [ -n "$TOKEN" ]; then
        MANIFEST=$(curl -sL "https://${REGISTRY}/v2/${REPO}/manifests/${TAG}" \
            -H "Authorization: Bearer ${TOKEN}" \
            -H "Accept: application/vnd.oci.image.manifest.v1+json" \
            -H "Accept: application/vnd.docker.distribution.manifest.v2+json")
    else
        MANIFEST=$(curl -sL "https://${REGISTRY}/v2/${REPO}/manifests/${TAG}" \
            -H "Accept: application/vnd.oci.image.manifest.v1+json" \
            -H "Accept: application/vnd.docker.distribution.manifest.v2+json")
    fi
    
    if [ -z "$MANIFEST" ] || echo "$MANIFEST" | grep -q "errors"; then
        echo "Error: Failed to fetch manifest"
        echo "$MANIFEST"
        cd -
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    # Extract layer digests (using sed for better Alpine compatibility)
    LAYERS=$(echo "$MANIFEST" | sed -n 's/.*"digest":"\(sha256:[a-f0-9]*\)".*/\1/p')
    
    if [ -z "$LAYERS" ]; then
        echo "Error: No layers found in manifest"
        cd -
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    # Download and extract each layer
    echo "$LAYERS" | while read -r DIGEST; do
        [ -z "$DIGEST" ] && continue
        echo "Downloading layer: $DIGEST"
        
        if [ -n "$TOKEN" ]; then
            curl -sL "https://${REGISTRY}/v2/${REPO}/blobs/${DIGEST}" \
                -H "Authorization: Bearer ${TOKEN}" \
                -o layer.tar.gz
        else
            curl -sL "https://${REGISTRY}/v2/${REPO}/blobs/${DIGEST}" \
                -o layer.tar.gz
        fi
        
        # Try to extract (Alpine's tar handles both gzipped and plain)
        if tar -tzf layer.tar.gz >/dev/null 2>&1; then
            tar -xzf layer.tar.gz 2>/dev/null || tar -xf layer.tar.gz 2>/dev/null || true
        else
            tar -xf layer.tar.gz 2>/dev/null || echo "Warning: Could not extract layer"
        fi
        rm -f layer.tar.gz
    done
    
    # Run the install script if it exists
    if [ -f "./install.sh" ]; then
        echo "Running install.sh with bash..."
        chmod +x ./install.sh
        
        # Check if bash is available
        if ! command -v bash >/dev/null 2>&1; then
            echo "Error: bash is required but not found"
            cd -
            rm -rf "$TEMP_DIR"
            return 1
        fi
        
        # Export all provided options as environment variables and run with bash
        for opt in "$@"; do
            export "$opt"
        done
        
        bash ./install.sh
    else
        echo "Warning: install.sh not found in feature"
    fi
    
    # Cleanup
    cd -
    rm -rf "$TEMP_DIR"
    
    echo "Feature installation complete for $FEATURE_URI"
}
