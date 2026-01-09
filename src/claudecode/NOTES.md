# Supported OS

Tested on Debian and Ubuntu.


# Get Started

Add the feature to your devcontainer.json: 

```devcontainer.json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/stu-bell/devcontainer-features/claudecode": {}
  }
}
```

Start your devcontainer, ssh in, and run: `claude`

# Known Issues

## High Memory Usage During Installation

During installation, especially with limited memory (e.g., in a Docker-in-Docker environment), the Claude Code installer (`https://claude.ai/install.sh`) has been observed to consume a significant amount of RAM, leading to the installation process being "Killed" due to Out-Of-Memory (OOM) errors. **Workaround:** If you encounter memory-related installation failures, consider increasing the memory allocation for your Docker/Podman container or devcontainer.
