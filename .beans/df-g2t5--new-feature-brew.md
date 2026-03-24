---
# df-g2t5
title: 'new feature: Homebrew'
status: draft
type: task
created_at: 2026-03-12T15:40:26Z
updated_at: 2026-03-12T15:40:26Z
---
Read these instructions carefully. If further clarification is required, append questions to the body of this bean and set the status to draft (so the user can review and update). When the user provides the information to continue, they will reset the bean status to todo.

For a recap of how to use beans, read the result of `beans prime`

Implement a new devcontainer feature in src/homebrew that should install homebrew (https://brew.sh/), and optionally, a brew package

This feature has already been started in src/homebrew, but it may need reimplementing

feature options:
- brewPackage: Name of Brew package to install
- brewPackageVersion: Minimum required version of brew package to install
- brewArgs: argument string to pass to brew install command

containerEnv:
- "PATH": "/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

install.sh:
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

Features considered for implementation but rejected (DO NOT IMPLEMENT THESE):
- Add an option to remove brew after package install to keep the image small? This is just for the purpose of installing a package with brew

# Implementation comments/notes from agent:

agent to update this section...

