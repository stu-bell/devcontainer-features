# Progress
Agent to replace this section when appropriate

# Intro
- This document contains instructions for a task
- Review the whole doc and ask me for more info if needed
- Check for edge cases or design flaws or features that I may have missed and ask me for clarification if necessary
- At significant points during the task, replace the #Progress section with a progress update. Keep progress updates concise. They should only contain enough for me to decide if I need to assist with the task. 
- After completion of all tasks, prepend a summary of changes to this todo doc for me to review

# Task

- examine how python feature uses util.sh install oci feature function.
- replace the node version of util.sh with the src/python/util.sh (should be v0.1.4)
- in node/install.sh the OS detection if statement - in the else clause, instead of printing a message, use the install OCI feature to install node using ghcr.io/devcontainers/features/node and pass through devcontainer feature options in the same way the python feature in this repo passes through options to the ghcr.io/devcontainer-features/python feature 
- update the min major version logic in src/node/install.sh to use the semver_gte function in the new util.sh version
