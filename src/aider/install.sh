#!/bin/sh
set -e
. ./util.sh

# ensure python installed
min_py_ver=${MIN_PYTHON_VERSION:-"3.12.0"}
install_oci_feature "ghcr.io/stu-bell/devcontainer-features/python" \
    "VERSION=${min_py_ver}"

# The python feature installs pip to /usr/local/python/current/bin
# This path needs to be added to the current session's PATH for 'pip' to found.
export PATH="/usr/local/python/current/bin:$PATH"

remote_user_run "pip install aider-install"
remote_user_run 'aider-install'

# verify version
echo "Aider installed: $(remote_user_run 'aider --version')"

