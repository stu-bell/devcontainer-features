
# Node.js (node)

Installs Node.js, if the minimum requested major version is not already installed.

## Example Usage

```json
"features": {
    "ghcr.io/stu-bell/devcontainer-features/node:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| node_min_major_version | Minimum major version of Node.js required. | string | 22 |

# OS Support

This is intended as a dependency for my features requiring Node.js. You should probably check out the official devcontainer Node.js feature: https://github.com/devcontainers/features/tree/main/src/node

Tested on Alpine, Debian, Ubuntu. 

- Alpine: installs from apk. Option `node_min_major_version` is not supported for apk install
- Debian/ Ubuntu: from https://deb.nodesource.com 

# PATH variable for node

devcontainer-feature.json adds `/usr/bin` to PATH


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/stu-bell/devcontainer-features/blob/main/src/node/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
