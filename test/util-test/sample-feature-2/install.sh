#!/bin/sh
# Copyright (c) 2026 Stuart Bell
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.
set -e
. ./util.sh

# Sample feature for testing util functions

# Make sure there isn't already an installation of the tool
install_dir='/home/vscode/.local/hello'
remote_user_has_command hello && {
    echo "hello is already installed"
    exit 0
}

# os detection
os_alpine && echo on alpine
os_debian_like && echo on debian like

# alpine dependencies
ensure_bash_on_alpine

# mock install
mkdir -p "$install_dir"
cat > "$install_dir/hello" << 'EOF'
#!/bin/bash
VERSION="1.0.0"
case "$1" in
    -v|--version)
        echo "helloworld $VERSION"
        exit 0
        ;;
    "")
        echo "Hello, World!"
        ;;
esac
EOF
chmod +x "$install_dir/hello"

add_to_user_profiles 'export PATH="$HOME/.local/hello:$PATH"'

# Verify installation
has_command /home/vscode/.local/hello/hello && echo Has command by full path

echo Remote user run full path
remote_user_run "$install_dir/hello"

echo Remote user run path
remote_user_run hello

installedversion=$(remote_user_run 'hello -v')
echo Installed version: $installedversion

echo Remote user has command
remote_user_has_command 'hello' && {
    echo "hello installed successfully"
}

