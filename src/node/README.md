
# Node.js (node)

Checks if the system already includes a Node installation with version greater or equal to option min_node_version, and installs Node if not. For non-Alpine systems, uses ghcr.io/devcontainers/features/node

## Example Usage

```json
"features": {
    "ghcr.io/stu-bell/devcontainer-features/node:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| min_node_version | Minimum version of Node required. | string | 22.0.0 |
| nodeGypDependencies | Install dependencies to compile native node modules (node-gyp)? Ignore on Alpine. | boolean | true |
| nvmInstallPath | The path where NVM will be installed. Ignore on Alpine. | string | /usr/local/share/nvm |
| pnpmVersion | Select or enter the PNPM version to install. Ignored on Alpine. | string | latest |
| nvmVersion | Version of NVM to install. Ignored on Alpine. | string | latest |
| installYarnUsingApt | On Debian and Ubuntu systems, you have the option to install Yarn globally via APT. If you choose not to use this option, Yarn will be set up using Corepack instead. This choice is specific to Debian and Ubuntu; for other Linux distributions, Yarn is always installed using Corepack, with a fallback to installation via NPM if an error occurs. Ignored on Alpine. | boolean | true |

# Usage

`ghcr.io/stu-bell/devcontainer-features/node`

## Options

`node_target_version` - version of Node.js to install.

# OS Support

This feature acts as a wrapper around two other devcontainer features:

- Alpine: `ghcr.io/cirolosapio/devcontainers-features/alpine-node`
- Other distros: `ghcr.io/devcontainers/features/node`

Refer to the documentation for these features for more information.

# Dependencies

This feature depends on the following features:

- `ghcr.io/cirolosapio/devcontainers-features/alpine-node`
- `ghcr.io/devcontainers/features/node`


---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
