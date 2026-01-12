#!/bin/sh
# Copyright (c) 2026 Stuart Bell 
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.
set -e
. ./util.sh

# TODO Check if sufficient version already installed

# OS detection
if os_alpine ; then
	echo "Installing Python3 and pipx on Alpine Linux via apk..."
	apk update 
	apk --no-cache add python3 py3-pip
else
	# install from official feature
	# TODO pass options
	install_oci_feature "ghcr.io/devcontainers/features/python:1.8.0"
fi

# TODO verify version 
version=$(remote_user_run python3 -v) || echo python installation could not be verified
echo "python installed $version"

