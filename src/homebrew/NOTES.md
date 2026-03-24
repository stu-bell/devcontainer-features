# Supported OS

Tested on Debian and Ubuntu. Alpine Linux is not supported (Homebrew requires glibc; Alpine uses musl libc).

# Get Started

Add the feature to your devcontainer.json:

```devcontainer.json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/stu-bell/devcontainer-features/homebrew": {}
  }
}
```

To also install a brew package:

```devcontainer.json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/stu-bell/devcontainer-features/homebrew": {
      "brewPackage": "jq",
      "brewPackageVersion": "1.6"
    }
  }
}
```

# Uninstall Homebrew

To uninstall Homebrew from within your container, run:

```sh
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
```

See https://github.com/homebrew/install#uninstall-homebrew for full uninstall instructions.
