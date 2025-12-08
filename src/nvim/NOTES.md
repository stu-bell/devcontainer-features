# Clone Neovim config from Git repository

Devcontainer feature option `CONFIG_GIT_URL` takes a URL pointing to a public git repository to be cloned to the container.

The default location for the config can be changed using feature option `XDG_CONFIG_HOME`.

```

{
    "image": "mcr.microsoft.com/devcontainers/base:alpine",
    "features": {
        "ghcr.io/stu-bell/devcontainer-features/neovim": {
            "CONFIG_GIT_URL": "https://github.com/your_user/your_nvim_config"
        }
    }
}
```



# Local Neovim config

Local Neovim config files can be mounted to the container by adding a bind mount config to `devcontainer.json`.

The default mount source locations for Neovim are:

- for Linux/MacOS: `${localEnv:HOME}/.config/nvim/` 
- for Windows: `${localEnv:LOCALAPPDATA}/nvim/` 

If your local Neovim config is stored somewhere else, use that folder path.

This feature sets `XDG_CONFIG_HOME` in feature options. This defaults to `/config`, so the mount target should be `/config/nvim`.


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


