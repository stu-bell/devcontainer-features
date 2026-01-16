# Progress
Agent to update this section to notify user of key design decisions or problems encountered

# Intro
- This document contains instructions for a task
- Review the whole doc and ask me for more info if needed
- Check for edge cases or design flaws or features that I may have missed and ask me for clarification if necessary
- Keep a note to, at significant points during the task, replace the #Progress section with a progress update. Keep progress updates concise. They should only contain enough for me to decide if I need to assist or course-correct
- Keep a note to, after completion of all tasks, prepend a summary of changes and any outstanding work to this todo doc for me to review

- Run test commands by directing test output to a temp file, to save tokens. Grep or tail (test results at the end of the file) for failure messages if the tests have a non-zero exit code, rather than reading the whole file.
- Run tests: `tmp=$(mktemp) && test/test-builds.sh -s test/path/to/scenarios.json -o scenario names >"$tmp"`
- Test docs: `test/test-builds.sh --help`

# Task details...

test scripts produce a lot of output which is token intensive for the agent. the following attempt writes test output to a temp file which can then be searched using grep or tail.

`tmp=$(mktemp) && test/test-builds.sh -s test/path/to/scenarios.json -o scenario names >"$tmp"`

However, the agent kills the task after a timeout with no output, which may be common for long-running tests. So we need some kind of command that runs the test, writes the output to the temp file, and periodically prints progress (eg line numbers of the test file) to STDOUT while the test is running
