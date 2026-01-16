Summary of Changes:
- The `heartbeat.sh` script (located at `test/heartbeat.sh`) has been modified to provide enhanced progress reporting and a simplified calling convention.
- The script now accepts the command to run as direct arguments, removing the need to wrap the command in double quotes.
- Heartbeat messages now display the elapsed time and the current line count of the temporary log file in a table format.
- The temporary log file is no longer automatically deleted and will persist after the command finishes, facilitating debugging.
- The full path to the temporary log file is reported upon command completion, especially on failure, to ease debugging.
- A test script for `heartbeat.sh` has been created at `test/script-tests/test-heartbeat.sh` and all tests are passing.

# Progress
The `heartbeat.sh` script has been updated with enhanced progress reporting, including elapsed time and line count in a table format. The temporary log files are now preserved for debugging, and their paths are reported upon completion. This addresses the task's requirements for improved heartbeat functionality and log management. The calling convention has also been simplified to no longer require double quotes. A test script has been created and all tests are passing.

# Intro
- This document contains instructions for a task
- Review the whole doc and ask me for more info if needed
- Check for edge cases or design flaws or features that I may have missed and ask me for clarification if necessary
- Keep a note to, at significant points during the task, replace the #Progress section with a progress update. Keep progress updates concise. They should only contain enough for me to decide if I need to assist or course-correct
- Keep a note to, after completion of all tasks, prepend a summary of changes to this todo doc for me to review

- Run test commands by directing test output to a temp file, to save tokens. Grep (or read the tail lines of the file) for failure messages if the tests have a non-ze
ro exit code, rather than reading the whole file.
- Run tests: `test/heartbeat.sh test/test-builds.sh -s test/path/to/scenarios.json -o scenario names`
- Test docs: `test/test-builds.sh --help`

# Task details...

once we have a test script writing to a temp file. how can a user cat that file in a streamable way that updates as the file is written to? this is in case a user wants to browse the file while the output is being written

