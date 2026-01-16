# Progress
Agent to replace this section when appropriate...

# Intro
- This document contains instructions for a task
- Review the whole doc and ask me for more info if needed
- Check for edge cases or design flaws or features that I may have missed and ask me for clarification if necessary
- At significant points during the task, replace the #Progress section with a progress update. Keep progress updates concise. They should only contain enough for me to decide if I need to assist or course-correct
- After completion of all tasks, prepend a summary of changes to this todo doc for me to review

# Task details...

- feature src/gemini-cli. 
- Replace util.sh with the updated version from src/python/util.sh
- Also replace util-test/sample-feature/util.sh with the updated version
- in src/gemini-cli/install.sh, use the install_oci_feature function from the updated util.sh to install feature ghcr.io/stu-bell/devcontainer-features/node, (the source of which is also in this repo in src/node , in case you need to refer to it)
- update the min major node version logic to use a minimum semantic version and use the semver_gte function to check that a sufficient version of node is installed.
- bump the geminicli feature version in devcontainer-feature.json
- test/test-builds.sh -s test/gemini-cli/scenarios.json
