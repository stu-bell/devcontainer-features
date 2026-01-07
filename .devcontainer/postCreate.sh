#! /bin/sh

# change directory to the workspace folder on container start
echo 'cd /workspaces/*' | tee -a ~/.profile ~/.bashrc ~/.zshrc > /dev/null

