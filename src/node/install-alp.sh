#!/bin/sh
# Copyright (c) Stuart Bell 
# Licensed under the MIT License. See https://github.com/stu-bell/devcontainer-features/blob/main/LICENSE for license information.
set -e

echo "Installing Node.js on Alpine Linux via apk..."
apk update 
apk --no-cache add nodejs npm

