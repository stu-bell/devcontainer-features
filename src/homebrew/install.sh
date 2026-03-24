#!/bin/sh
# Copyright (c) 2026 Stuart Bell
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.
set -e
. ./util.sh

BREW_PACKAGE="${BREWPACKAGE:-}"
BREW_PACKAGE_VERSION="${BREWPACKAGEVERSION:-}"
BREW_ARGS="${BREWARGS:-}"
BREW_BIN="/home/linuxbrew/.linuxbrew/bin/brew"

# Homebrew requires glibc and does not support Alpine (musl libc)
if os_alpine; then
    echoyel "WARNING: Homebrew does not support Alpine Linux (musl libc). Skipping installation."
    exit 0
fi

# 1. Check dependencies are installed: bash, curl. Install them if not.
has_command curl || {
    echo "curl not found, installing..."
    apt_get_install curl ca-certificates
}
has_command bash || {
    echo "bash not found, installing..."
    apt_get_install bash
}

# 2. Check if brew is installed. If not, install with brew.sh script.
if [ -x "$BREW_BIN" ]; then
    echo "Homebrew is already installed."
else
    echo "Installing Homebrew..."
    remote_user_run 'NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
fi

# 3. Verify brew is installed correctly.
if ! [ -x "$BREW_BIN" ]; then
    echored "ERROR: Homebrew not found at $BREW_BIN. Installation may have failed."
    exit 1
fi
echogrn "Homebrew installed: $($BREW_BIN --version | head -1)"

# 4. If a brewPackage is not specified, exit here.
[ -z "$BREW_PACKAGE" ] && exit 0

# 5. If a brewPackage is specified, ensure we can use brew install, add to PATH if necessary.
export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"

# 6. Check if that package is installed and if the required brewPackageVersion is met.
NEEDS_INSTALL=true
if remote_user_run 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && brew list --formula '"$BREW_PACKAGE"' > /dev/null 2>&1'; then
    echo "Package '$BREW_PACKAGE' is already installed."
    if [ -n "$BREW_PACKAGE_VERSION" ]; then
        installed_ver=$(remote_user_run 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && brew list --versions '"$BREW_PACKAGE" | awk '{print $2}' | cut -d'_' -f1)
        if semver_gte "$installed_ver" "$BREW_PACKAGE_VERSION"; then
            echo "Installed version $installed_ver meets minimum required version $BREW_PACKAGE_VERSION."
            NEEDS_INSTALL=false
        else
            echo "Installed version $installed_ver does not meet minimum required $BREW_PACKAGE_VERSION, reinstalling."
        fi
    else
        NEEDS_INSTALL=false
    fi
fi

if [ "$NEEDS_INSTALL" = "true" ]; then
    echo "Installing brew package: $BREW_PACKAGE"
    remote_user_run 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && brew install '"$BREW_ARGS $BREW_PACKAGE"
fi

# 7. Verify that the brew package is installed correctly.
if remote_user_run 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && brew list '"$BREW_PACKAGE"' > /dev/null 2>&1'; then
    echogrn "Package '$BREW_PACKAGE' installed successfully."
else
    echored "ERROR: Package '$BREW_PACKAGE' installation could not be verified."
    exit 1
fi
