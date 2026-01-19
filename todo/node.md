# Summary of changes
- Replaced the OS-specific installation scripts (`install-alp.sh` and `install-deb.sh`) with a single `install.sh` that uses existing community and official features to install Node.js.
- For Alpine, the feature now uses `ghcr.io/cirolosapio/devcontainers-features/alpine-node`.
- For other distributions, it uses `ghcr.io/devcontainers/features/node`.
- Updated `devcontainer-feature.json` to remove the `containerEnv` and bumped the version.
- Updated `NOTES.md` to reflect the new implementation.
- Updated tests to use the new implementation.

# Progress
Agent to update this section at relevant progress points...

# Intro
- This document contains instructions for a task
- Review the whole doc and ask me for more info if needed
- Check for edge cases or design flaws or features that I may have missed and ask me for clarification if necessary
- Keep a note to, at significant points during the task, replace the #Progress section with a progress update. Keep progress updates concise. They should only contain enough for me to decide if I need to assist or course-correct
- Keep a note to, after completion of all tasks, prepend a summary of changes to this todo doc for me to review

- Run test commands by directing test output to a temp file, to save tokens. Grep (or read the tail lines of the file) for failure messages if the tests have a non-zero exit code, rather than reading the whole file.
- Run tests: `test/heartbeat.sh "test/test-builds.sh -s test/path/to/scenarios.json -o scenario names"`
- Test docs: `test/test-builds.sh --help`

# Task details...

- for OS alpine cases, remove the dependency cirolosapio/.../alpine-node and instead use: 
```
echo "Installing Node.js on Alpine Linux via apk..."
apk update 
apk --no-cache add nodejs npm
```

- change the version option to min_node_version, which will be a semantic version. This will be passed to the install OCI feature $VERSION option. Before installation, min_node_version will be used to check if a sufficient version is already installed. After installation, the actual installed version of node should be tested against $MIN_NODE_VERSION and the feature install should exit 1 if the installed version is not greater than or equal to. 
- update the min major version logic in src/node/install.sh to use the semver_gte function in the new util.sh version
- test with `test/heartbeat.sh test/test-builds.sh -s test/node/scenarios.json`

- the ghcr.io/devcontainers/features/node feature includes the following options. Copy these options into this src/node feature and pass them through in install_oci_feature. Document that they are ignored on alpine:
```
        "nodeGypDependencies": {
            "type": "boolean",
            "default": true,
            "description": "Install dependencies to compile native node modules (node-gyp)?"
        },
        "nvmInstallPath": {
            "type": "string",
            "default": "/usr/local/share/nvm",
            "description": "The path where NVM will be installed."
        },
        "pnpmVersion": {
            "type": "string",
            "proposals": [
                "latest",
                "8.8.0",
                "8.0.0",
                "7.30.0",
                "6.14.8",
                "5.18.10",
                "none"
            ],
            "default": "latest",
            "description": "Select or enter the PNPM version to install"
        },
        "nvmVersion": {
            "type": "string",
            "proposals": [
                "latest",
                "0.39"
            ],
            "default": "latest",
            "description": "Version of NVM to install."
        },
        "installYarnUsingApt": {
            "type": "boolean",
            "default": true,
            "description": "On Debian and Ubuntu systems, you have the option to install Yarn globally via APT. If you choose not to use this option, Yarn will be set up using Corepack instead. This choice is specific to Debian and Ubuntu; for other Linux distributions, Yarn is always installed using Corepack, with a fallback to installation via NPM if an error occurs."
        }
```
