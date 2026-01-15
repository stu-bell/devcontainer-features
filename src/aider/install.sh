#!/bin/sh
# Copyright (c) 2026 Stuart Bell 
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.
set -e
. ./util.sh

# ensure python installed
min_py_ver=${MIN_PYTHON_VERSION:-"3.12.0"}
install_oci_feature "ghcr.io/stu-bell/devcontainer-features/python" \
    "VERSION=${min_py_ver}"

# run install
remote_user_run 'python3 -m pip install aider-install'
remote_user_run 'aider-install'

# verify version
echo "Aider installed: $(remote_user_run 'aider --version')"

