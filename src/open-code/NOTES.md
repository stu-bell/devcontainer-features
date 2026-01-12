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

