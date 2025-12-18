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

