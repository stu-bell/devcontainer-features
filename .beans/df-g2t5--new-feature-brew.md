---
# df-g2t5
title: 'new feature: Homebrew'
status: completed
type: epic
priority: normal
created_at: 2026-03-12T15:40:26Z
updated_at: 2026-06-01T18:51:07Z
---

Read these instructions carefully. If further clarification is required, append questions to the body of this bean and set the status to draft (so the user can review and update). When the user provides the information to continue, they will reset the bean status to todo.

For a recap of how to use beans, read the result of `beans prime`

# Changes required

The following brief has been implemented, however the following changes have been made. Read the brief for context about the original implementation

Changes: 

- test/homebrew/scenarios.json: jq is not a good tool choice for testing, as it is likely already available on the debian system

# Brief

Implement a new devcontainer feature in src/homebrew that should install homebrew (https://brew.sh/), and optionally, a brew package

This feature has already been started in src/homebrew, but it may need reimplementing

feature options:
- brewPackage: Name of Brew package to install
- brewPackageVersion: Minimum required version of brew package to install
- brewArgs: argument string to pass to brew install command

containerEnv:
- "PATH": "/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

install.sh:
1. Check dependencies are installed: bash, curl. Install them if not
1. check if brew is installed. if not, install with brew.sh script below
1. verify brew is installed correctly
1. if a brewPackage is not specified, exit here
1. if a brewpackage is specified, ensure we can use brew install, add to path if necessary
1. check if that package is installed, and check that the required brewPackageVersion is installed, if a sufficient version of the required package is not found, install with brew install
1. verify that the brew package is installed correctly

non-functional requirements:
1. Read other features in the src folder and follow similar implementation patterns where relevant
1. should work on alpine, ubuntu and debian images (may have to be a posix compliant script). bash may need to be installed on alpine
1. Use util functions where appropriate (see ./test/util-test/sample-feature/util.sh)
1. write test scenarios for the feature - run `test/test-builds.sh --help` for scenario file structure
1. When running tests, use test/heartbeat.sh to wrap the test command, to avoid polluting context with test logs. Use grep or tail to read the test logs.

Install script from homebrew: https://brew.sh/
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

Documentation: add to the NOTES.md file the command to uninstall homebrew at https://github.com/homebrew/install#uninstall-homebrew

# Implementation comments/notes from agent:

## Implementation

Reimplemented `src/homebrew` with:

- **`devcontainer-feature.json`**: Replaced single `package` option with `brewPackage`, `brewPackageVersion`, `brewArgs`. Kept `containerEnv` PATH entries.
- **`install.sh`**: Full rewrite using `util.sh` patterns:
  - Skips gracefully on Alpine (Homebrew requires glibc; Alpine uses musl libc)
  - Installs `curl`/`bash` dependencies if missing
  - Installs Homebrew via official `brew.sh` script as remote user
  - Verifies brew binary at `/home/linuxbrew/.linuxbrew/bin/brew`
  - Exits early if no `brewPackage` specified
  - Checks if package + `brewPackageVersion` requirement is already satisfied before installing (uses `semver_gte`)
  - Verifies package post-install
- **`util.sh`**: Copied from `test/util-test/sample-feature/util.sh` (v0.1.4)
- **`NOTES.md`**: Documents supported OS, usage examples, and Homebrew uninstall command from https://github.com/homebrew/install#uninstall-homebrew
- **`test/homebrew/scenarios.json`**: 5 scenarios — alpine (warns + exits 0), ubuntu, debian, ubuntu-with-package (hello), ubuntu-with-package-version (hello >= 2.10). Replaced `jq` with `hello` (GNU Hello) as `jq` is pre-installed on Debian/Ubuntu and would not validate brew actually installed it.
