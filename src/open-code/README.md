
# Open Code (via opencode.ai/install) (open-code)

Installs Open Code for AI code assistance https://opencode.ai

## Example Usage

```json
"features": {
    "ghcr.io/stu-bell/devcontainer-features/open-code:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| open_code_version | Specific version number to install, eg: 1.1.13 | string | latest |

# Supported OS

Tested on Alpine, Debian and Ubuntu.


# Get Started

Add the feature to your devcontainer.json: 

```devcontainer.json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/stu-bell/devcontainer-features/open-code": {}
  }
}
```

Start your devcontainer, ssh in, and run: `opencode`



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/stu-bell/devcontainer-features/blob/main/src/open-code/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
