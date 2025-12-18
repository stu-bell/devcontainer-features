# Supported OS

Tested on Debian and Ubuntu.

Cursor CLI does not work on Alpine. See [this forum discussion](https://forum.cursor.com/t/cursor-agent-does-not-work-with-non-glibc-based-distributions-such-as-alpine-linux/141571)


# Get Started

Add the feature to your devcontainer.json: 

```devcontainer.json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/stu-bell/devcontainer-features/cursorcli": {}
  }
}
```

Start your devcontainer, ssh in, and run: `cursor-agent`

