# Progress
A reusable heartbeat script is now located at `test/heartbeat.sh`. Its calling convention has been simplified to not require quotes around the command, and it now provides a machine-readable output for the log file path. This script wraps long-running commands, providing periodic updates to prevent CI/CD timeouts, and handles output logging and error reporting. The test documentation in this file has been updated to reflect these changes.

# Intro
- This document contains instructions for a task
- Review the whole doc and ask me for more info if needed
- Check for edge cases or design flaws or features that I may have missed and ask me for clarification if necessary
- Keep a note to, at significant points during the task, replace the #Progress section with a progress update. Keep progress updates concise. They should only contain enough for me to decide if I need to assist or course-correct
- Keep a note to, after completion of all tasks, prepend a summary of changes and any outstanding work to this todo doc for me to review

- **New recommended test command structure:**
  A wrapper script is now available at `test/heartbeat.sh` to run long-running commands while providing a "heartbeat" to prevent CI/CD timeouts.

  **Usage:**

  ```bash
  ./test/heartbeat.sh test/test-builds.sh -s test/path/to/scenarios.json [other_args]
  ```
  
  To get the log file path for scripting, you can parse the first line of the output:
  `LOG_FILE=$(./test/heartbeat.sh ... | head -n 1 | cut -d'=' -f2)`

  Replace `test/path/to/scenarios.json` with the actual scenarios file, and `[other_args]` with any other necessary arguments (e.g., `-o "Scenario Name"`).
  
  **How it works:**
  - The `heartbeat.sh` script takes the command to execute as direct arguments.
  - The first line of output is a machine-readable path to the log file: `HEARTBEAT_LOG_PATH=/path/to/tempfile`.
  - It runs the command in the background, redirecting all output (`stdout` and `stderr`) to this temporary file.
  - Every 30 seconds, it prints a "Heartbeat" message to the console, showing the process is still running and the current size of the output log.
  - When the command finishes, it checks the exit code:
    - On success, it reports completion.
    - On failure, it prints the last 100 lines of the output file to the console for quick debugging.
  - The temporary file is not automatically cleaned up, and its path is printed to the console for debugging purposes.

- Test docs: `test/test-builds.sh --help`

# Task details...


test scripts produce a lot of output which is token intensive for the agent. the following attempt writes test output to a temp file which can then be searched using grep or tail.

`tmp=$(mktemp) && test/test-builds.sh -s test/path/to/scenarios.json -o scenario names >"$tmp"`

However, the agent kills the task after a timeout with no output, which may be common for long-running tests. So we need some kind of command that runs the test, writes the output to the temp file, and periodically prints progress (eg line numbers of the test file) to STDOUT while the test is running
