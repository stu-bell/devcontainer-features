
# Google Gemini CLI (geminicli)

Installs Google Gemini CLI for AI code assistance https://geminicli.com

## Example Usage

```json
"features": {
    "ghcr.io/stu-bell/devcontainer-features/geminicli:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of Gemini CLI to install https://www.npmjs.com/package/@google/gemini-cli#release-cadence-and-tags | string | latest |
| node_min_major_version | Minimum major version of Node.js required. | string | 20 |


# ISSUES

TODO Node v20 seems to be installed correctly, however, for node18 scenarios, the wrong version of node (ie the v18) is being called. How do we call the correct version?

# Supported OS

Gemini CLI runs off Node.js, so it *should* run on any container with Node.js v 20 or higher.

This feature checks for Node and attempts to install it if the OS is Alpine, Debian or Ubuntu. For other OS versions, ensure Node.js and npm are installed before this feature is installed (see [overrideFeatureInstallOrder](https://containers.dev/implementors/json_reference/#general-properties)).

# PATH variable for node

devcontainer-feature.json adds `/usr/bin` to PATH. See install-node.sh for more details.



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/stu-bell/devcontainer-features/blob/main/src/geminicli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
