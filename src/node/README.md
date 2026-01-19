
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

Dependency feature for features requiring Node.

Installs Node unless a version equal or greater to feature option min_node_version is already found.

Errors if the installed version does not meet the min_node_version.

# OS Support

Tested on Alpine, Ubuntu, Debian.

If OS is Alpine Linux, uses apk and ignores all other feature options.

Otherwise uses the official devcontainer Node feature: ghcr.io/devcontainers/features/node. Remaining options are passed to this feature.



---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
