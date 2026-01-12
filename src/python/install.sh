#!/bin/sh
# Copyright (c) 2026 Stuart Bell 
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.
set -e
. ./util.sh

# TODO Check if sufficient version already installed
has_command python3
min_req_ver="3.12"
installed_version="$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
semver_gte "$installed_version" "$min_req_ver"

# OS detection
if os_alpine ; then
	echo "Installing Python3 and pip on Alpine Linux via apk..."
	apk update 
	apk --no-cache add python3 py3-pip
else
	# install from official feature
	# TODO pass options
	install_oci_feature "ghcr.io/devcontainers/features/python:1.8.0"
fi

# verify version 
version=$(remote_user_run 'python3 --version' || remote_user_run 'python --version')
echo "Python installed: $version"

