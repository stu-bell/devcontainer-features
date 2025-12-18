#!/bin/sh
# Copyright (c) Stuart Bell 
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.

# check if a command exists
has_command() {
    command -v "$1" > /dev/null 2>&1
}

# check if user is root user
is_root_user() {
    [ "$(id -u)" -eq 0 ]
}

# parse major verion from a semantic version string
semver_major() {
    echo "${1#v}" | cut -d'.' -f1
}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
echored() {
    echo -e "${RED}$@${NC}"
}
echogrn() {
    echo -e "${GREEN}$@${NC}"
}
echoyel() {
    echo -e "${YELLOW}$@${NC}"
}
