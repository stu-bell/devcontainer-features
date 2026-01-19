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

- feature src/open-code works well by installing the open-code client. We need to add a command to the src/open-code/install.sh to create `/config/opencode` and add permission for the remote user to edit and execute files in the folder `/config/opencode`. This is because the remote user will not have root privileges when running the installed open-code application. Without this permission, when the user runs the opencode command, the user receives an error saying it needs permissions to create and access `/config/opencode`.
- bump minor open-code/devcontainer-feature.json version.
- Leave the rest of the install.sh approach, util.sh and test/open-code/scenarios.json unchanged. 
- Re-run the tests to confirm the installation works using: `test/heartbeat.sh "test/test-builds.sh -s test/open-code/scenarios.json"`
