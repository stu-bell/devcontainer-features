#!/bin/sh
set -e

echo "hello from shell config"

# Set working directory to workspace folder
WD=${CONTAINER_WORKSPACE_FOLDER:-"/workspaces/*"}
cd $WD

