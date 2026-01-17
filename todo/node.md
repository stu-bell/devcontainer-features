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

- the goal of feature src/node is to make it easy for other features to install the minimum required version of node, on any distro (including alpine). If nodesource has the required version, that gets used as it's quicker than using the official oci feature to build from source. Otherwise, the offical node feature can be used to install any version of node using nvm. 
- examine how python feature uses util.sh install oci feature function.
- replace the node version of util.sh with the src/python/util.sh (should be v0.1.4)
- in node/install.sh the OS detection if statement - in the else clause, instead of printing a message, use the install OCI feature to install node using ghcr.io/devcontainers/features/node and pass through devcontainer feature options in the same way the python feature in this repo passes through options to the ghcr.io/devcontainer-features/python feature 
- update the min major version logic in src/node/install.sh to use the semver_gte function in the new util.sh version
- test with `test/heartbeat.sh test/test-builds.sh -s test/node/scenarios.json`
- bump the node devcontainer-feature.json version
- update src/node/NOTES.md with instructions about how the dependency feature is used. 
