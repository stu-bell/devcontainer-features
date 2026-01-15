#!/bin/sh
# Copyright (c) 2026 Stuart Bell 
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.
set -e
. ./util.sh

# ensure python installed
min_py_ver=${MIN_PYTHON_VERSION:-"3.12.0"}
install_oci_feature "ghcr.io/stu-bell/devcontainer-features/python" \
    "VERSION=${min_py_ver}"

# FIXME: pip not found despite installing pip with the dependency feature and confirming with `which pip`

# run install
INSTALL_CMD=""
if remote_user_has_command pip3; then
    INSTALL_CMD="pip3 install aider-install"
elif remote_user_has_command python3; then
    INSTALL_CMD="python3 -m pip install aider-install"
elif remote_user_has_command python; then
    INSTALL_CMD="python -m pip install aider-install"
else
    echored "ERROR: Python or Pip not found."
    exit 1
fi
remote_user_run "$INSTALL_CMD"
remote_user_run 'aider-install'

# verify version
echo "Aider installed: $(remote_user_run 'aider --version')"

