
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

# Supported OS

Tested on Alpine, Debian or Ubuntu.

Gemini CLI runs off Node.js, so it *should* run on any container with Node.js v 20 or higher.

For other OS versions, ensure Node.js and npm are installed before this feature is installed (see [overrideFeatureInstallOrder](https://containers.dev/implementors/json_reference/#general-properties)).

# Get Started

Add the feature to your devcontainer.json: 

```devcontainer.json
{
  "image": "mcr.microsoft.com/devcontainers/typescript-node",
  "features": {
    "ghcr.io/stu-bell/devcontainer-features/geminicli": {
      "node_min_major_version": "20"
    }
  }
}
```

Start your devcontainer, ssh in, and run: `gemini`



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/stu-bell/devcontainer-features/blob/main/src/geminicli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
