
# Neovim (neovim)

Installs Neovim Editor. See neovim.io

## Example Usage

```json
"features": {
    "ghcr.io/stu-bell/devcontainer-features/neovim:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| CONFIG_GIT_URL | Optional URL to a public Git repository for Neovim config, cloned during feature install to ${CONFIG_LOCATION}/nvim. | string | - |
| CONFIG_LOCATION | - | string | /config |

# OS Support

Tested on Alpine/Ubuntu/Debian base images.

Alpine: installs via [apk](apk).

Anything else: attempts install via [AppImage](https://neovim.io/doc/install/#appimage-universal-linux-package).

# Clone Neovim config from Git repository

Devcontainer feature option `CONFIG_GIT_URL` takes a URL pointing to a public git repository to be cloned to the container.

```devcontainer.json
{
    "image": "mcr.microsoft.com/devcontainers/base:alpine",
    "features": {
        "ghcr.io/stu-bell/devcontainer-features/neovim": {
            "CONFIG_GIT_URL": "https://github.com/your_user/your_nvim_config"
        }
    }
}
```

If you need to clone config to a different location, you'll need to set feature option CONFIG_LOCATION *and* ensure containerEnv:XDG_CONFIG_HOME is set to the same value in your devcontainer.json.


# Local Neovim config

Local Neovim config files can be mounted to the container by adding a bind mount config to `devcontainer.json`.

The default mount source locations for Neovim are:

- for Linux/MacOS: `${localEnv:HOME}/.config/nvim/` 
- for Windows: `${localEnv:LOCALAPPDATA}/nvim/` 

If your local Neovim config is stored somewhere else, use that folder path.

This feature sets `XDG_CONFIG_HOME` in feature containerEnv to `/config`. So the mount target should be `/config/nvim`.


**Example devcontainer.json for Linux / MacOS host:**
```devcontainer.json
{
    "image": "mcr.microsoft.com/devcontainers/base:alpine",
    "features": {
        "ghcr.io/stu-bell/devcontainer-features/neovim": {}
    },
    "mounts": [
        // source should point to your host nvim config location
        "source=${localEnv:HOME}/.config/nvim/,target=/config/nvim,type=bind"
    ]
}
```


**Example devcontainer.json for Windows host:**
```devcontainer.json
{
    "image": "mcr.microsoft.com/devcontainers/base:alpine",
    "features": {
        "ghcr.io/stu-bell/devcontainer-features/neovim": {}
    },
    "mounts": [
        // source should point to your host nvim config location
        "source=${localEnv:LOCALAPPDATA}/nvim/,target=/config/nvim,type=bind"
    ]
}
```

# Get Started

Add the feature config to your devcontainer.json.
Start your devcontainer, ssh in, and run: `nvim`



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/stu-bell/devcontainer-features/blob/main/src/neovim/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
