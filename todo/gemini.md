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

- This task depends on the completion of `todo/node.md`. Complete task `todo/node.md` before proceding with this task.
- feature src/gemini-cli. 
- Replace util.sh with the updated version from src/python/util.sh (v0.1.4)
- Also replace util-test/sample-feature/util.sh with the updated version for testing
- in src/gemini-cli/install.sh, use the install_oci_feature function from the updated util.sh to install feature ghcr.io/stu-bell/devcontainer-features/node, (the source of which is also in this repo in src/node , in case you need to refer to it)
- update the min major node version logic to use a minimum semantic version and use the semver_gte function to check that a sufficient version of node is installed.
- bump the geminicli feature version in devcontainer-feature.json
- test with `test/heartbeat.sh test/test-builds.sh -s test/gemini-cli/scenarios.json`

