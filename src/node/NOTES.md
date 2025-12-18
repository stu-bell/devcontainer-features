# OS Support

This is intended as a dependency for my features requiring Node.js. You should probably check out the official devcontainer Node.js feature: https://github.com/devcontainers/features/tree/main/src/node

Tested on Alpine, Debian, Ubuntu. 

- Alpine: installs from apk. Option `node_min_major_version` is not supported for apk install
- Debian/ Ubuntu: from https://deb.nodesource.com 

# PATH variable for node

devcontainer-feature.json adds `/usr/bin` to PATH
