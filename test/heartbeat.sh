#!/bin/bash

# A wrapper function to execute a long-running command with a "heartbeat".
# It runs the command in the background, redirecting its output to a temporary file.
# While the command is running, it periodically prints the line count of the
# output file and the elapsed time, providing a heartbeat and preventing
# timeouts in CI/CD environments.

# Usage:
#   heartbeat your-long-running-command --with --args

heartbeat() {
    if [ $# -eq 0 ]; then
        echo "Usage: heartbeat <command --with --args>" >&2
        return 1
    fi

    local cmd_to_run="$@"
    local tmp_file
    tmp_file=$(mktemp)

    # For scriptability, echo the temp file path in a parsable format
    echo "HEARTBEAT_LOG_PATH=${tmp_file}"

    echo "Executing command with heartbeat. Full output will be logged to: $tmp_file"
    echo "Command: $cmd_to_run"
    
    local start_time=$(date +%s)

    # Execute the command in the background
    # We use eval to correctly handle commands with quotes and arguments
    eval "$cmd_to_run" > "$tmp_file" 2>&1 &
    local cmd_pid=$!

    echo -e "\n--- Heartbeat Monitoring Started ---"
    printf "%-10s %-15s %s\n" "Elapsed (s)" "Lines in Log" "Status"
    echo "------------------------------------"

    # Monitor the background process
    while ps -p $cmd_pid > /dev/null; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        local line_count=$(wc -l < "$tmp_file" 2>/dev/null || echo "0")
        printf "%-10s %-15s %s\n" "$elapsed" "$line_count" "Running..."
        sleep 30
    done

    # Wait for the command to finish and get its exit code
    wait $cmd_pid
    local exit_code=$?

    echo "------------------------------------"
    echo "--- Heartbeat Monitoring Finished --"

    # Report result
    if [ $exit_code -ne 0 ]; then
        echo "Command failed with exit code $exit_code." >&2
        echo "Full output log: $tmp_file" >&2
        echo "Last 100 lines of output from $tmp_file:" >&2
        tail -n 100 "$tmp_file" >&2
    else
        echo "Command completed successfully."
        # Optionally, you can echo the tmp_file path here for successful runs too
        # echo "Full output log: $tmp_file"
    fi

    return $exit_code
}

# If the script is executed directly, pass all arguments to the heartbeat function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    heartbeat "$@"
fi
