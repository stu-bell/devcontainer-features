#!/bin/bash
set -e

# Run a command as the remote user for the devcontainer.
remote_user_run() {
    command_to_run="$1"
    USER_OPTION="${REMOTE_USER_NAME:-automatic}"
    _REMOTE_USER="${_REMOTE_USER:-${USER_OPTION}}"
    if [ "${_REMOTE_USER}" = "auto" ] || [ "${_REMOTE_USER}" = "automatic" ]; then
        _REMOTE_USER="$(id -un 1000 2>/dev/null || echo "vscode")" # vscode fallback
    fi
    echo "Running as: $_REMOTE_USER, command: $command_to_run" >&2
    # Escape single quotes in command_to_run for the inner sh -lc call
    escaped_command_to_run=$(echo "$command_to_run" | sed "s/'/'\\''/g")

    su - "${_REMOTE_USER}" -c "sh -lc '$escaped_command_to_run'"
}

PACKAGE="${PACKAGE:-}"

if [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    echo "Homebrew already installed, skipping."
else
    echo "Installing Homebrew..."
    remote_user_run 'NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    echo "Homebrew installed successfully."

    echo "Verifying installation paths..."
    for path in /home/linuxbrew/.linuxbrew/bin /home/linuxbrew/.linuxbrew/sbin; do
        if [ ! -d "$path" ]; then
            echo "WARNING: expected Homebrew path not found: $path"
            echo "You may need to add Homebrew to your PATH manually. Run:"
            echo '  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
            echo "Or check the Homebrew installation at https://docs.brew.sh/Homebrew-on-Linux"
        fi
    done
fi

if [ -n "$PACKAGE" ]; then
    echo "Installing brew package: $PACKAGE"
    remote_user_run 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && brew install '"$PACKAGE"
    echo "$PACKAGE installed successfully."
fi

