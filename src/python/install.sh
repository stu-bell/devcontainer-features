#!/bin/sh
# Copyright (c) 2026 Stuart Bell 
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.
set -e
. ./util.sh

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

# Check if sufficient version already installed
min_req_ver="$(semver_pad ${MIN_PYTHON_VERSION:-3.12})"
installed_version=$(get_python_version) || echo "No Python installation found."
if [ "$min_req_ver" != "latest" ] && [ -n "$installed_version" ]; then
	if semver_gte "$installed_version" "$min_req_ver"; then
		echo "Python $installed_version already installed"
		exit 0
    else 
        echo "Found Python $installed_version but require $min_req_ver"
	fi
fi

# OS detection
if os_alpine ; then
	apk_install python3 py3-pip
elif os_debian_like && [ "${APT_GET:-"true"}" = "true" ] ; then
    apt_get_install python3 python3-pip
else
	# install from official feature. omit version tag if requesting 'latest'
    feature_version=":$OFFICIAL_PYTHON_FEATURE_VERSION"
    if [ "$OFFICIAL_PYTHON_FEATURE_VERSION" = "latest" ]; then
        feature_version=""
    fi

    min_req_ver_option=""
    if [ "$min_req_ver" != "latest" ]; then
        min_req_ver_option="VERSION=${min_req_ver}"
    fi

    install_oci_feature \
        "ghcr.io/devcontainers/features/python${feature_version}" \
        "${min_req_ver_option:+${min_req_ver_option}}" \
        "INSTALLTOOLS=$INSTALLTOOLS" \
        "TOOLSTOINSTALL=$TOOLSTOINSTALL" \
        "OPTIMIZE=$OPTIMIZE" \
        "ENABLESHARED=$ENABLESHARED" \
        "INSTALLPATH=$INSTALLPATH" \
        "INSTALLJUPYTERLAB=$INSTALLJUPYTERLAB" \
        "CONFIGUREJUPYTERLABALLOWORIGIN=$CONFIGUREJUPYTERLABALLOWORIGIN" \
        "HTTPPROXY=$HTTPPROXY"

        # Add Python to PATH for verification
        add_to_user_profiles "export PATH=$INSTALLPATH/current/bin:/usr/local/bin:\$PATH"
        export PATH="$INSTALLPATH/current/bin:/usr/local/bin:/usr/local/python/current/bin:$PATH"
        echo PATH: "$PATH"


fi

# verify version
if ! installed_ver=$(get_python_version); then
    echored "Could not find python installation"
    exit 1
fi
echoyel "Python installed: $installed_ver"
if [ "$min_req_ver" != "latest" ] && ! semver_gte "$installed_ver" "$min_req_ver"; then
    echored "Could not find version $min_req_ver"
    exit 1
fi

