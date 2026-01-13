#!/bin/sh
# Copyright (c) 2026 Stuart Bell 
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.
set -e
. ./util.sh

# Check if sufficient version already installed
# TODO min req version from config
min_req_ver="3.13"

# get semver of installed python
get_python_version() {
    set -e
    local python_cmd
    if remote_user_has_command python3; then
        python_cmd="python3"
    elif remote_user_has_command python; then
        python_cmd="python"
    else
        return 1
    fi
    ver=$(remote_user_run "$python_cmd -c 'import sys; print(\".\".join(map(str, sys.version_info[:3])))'")
    if [ -n "$ver" ]; then
        echo "$ver"
    else
        return 1
    fi
}

# check if required version or greater already installed
if installed_version=$(get_python_version); then
	if semver_gte "$installed_version" "$min_req_ver"; then
		echo "Python $installed_version already installed"
		exit 0
    else 
        echo "Found Python $installed_version but require $min_req_ver"
	fi
fi

# OS detection
if os_alpine ; then
	echo "Installing Python3 and pip on Alpine Linux via apk..."
	apk update 
	apk --no-cache add python3 py3-pip
else
	# install from official feature
	# TODO pass feature options
    # TODO get feature version from options
	install_oci_feature "ghcr.io/devcontainers/features/python:1.8.0"
fi

# verify version 
echo "Python installed: $(get_python_version)"
# Error if we couldn't install the required version
semver_gte "$(get_python_version)" "$min_req_ver" || echo "Could not install $min_req_ver" && exit 1

