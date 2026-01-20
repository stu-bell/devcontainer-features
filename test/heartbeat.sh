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
    echo "OUTPUT_LOGFILE=${tmp_file}"

    echo "Monitor command output in realtime:"
    echo "tail -f $tmp_file"
    echo ""
    echo "Command: $cmd_to_run"

    local start_time=$(date +%s)

    # Execute the command in the background
    # We use eval to correctly handle commands with quotes and arguments
    eval "$cmd_to_run" > "$tmp_file" 2>&1 &
    local cmd_pid=$!
    
    local interval=120
    echo -e "\n--- Monitoring Started ---"
    echo -e "Updates every $interval seconds..."
    printf "%-10s %-15s %s\n" "Elapsed"   "Lines in Log"
    echo "------------------------------------"

    # Monitor the background process
    while ps -p $cmd_pid > /dev/null; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        local hours=$((elapsed / 3600))
        local minutes=$(((elapsed % 3600) / 60))
        local seconds=$((elapsed % 60))
        local formatted_time=$(printf "%02d:%02d:%02d" $hours $minutes $seconds)
        local line_count=$(wc -l < "$tmp_file" 2>/dev/null || echo "0")
        printf "%-10s %-15s %s\n" "$formatted_time" "$line_count"
        sleep $interval
    done

    # Wait for the command to finish and get its exit code
    wait $cmd_pid
    local exit_code=$?

    echo "------------------------------------"
    echo "--- Monitoring Finished --"

    # Report result
    echo "Command exit code: $exit_code." >&2
    echo "Full output log: $tmp_file" >&2
    echo "Last lines of output from $tmp_file:" >&2
    tail -n 50 "$tmp_file" >&2

    return $exit_code
}

# If the script is executed directly, pass all arguments to the heartbeat function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    heartbeat "$@"
fi
