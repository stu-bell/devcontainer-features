#!/bin/bash
set -e

# Test script for the heartbeat.sh wrapper

# --- Test Setup ---
# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echogrn() {
    echo -e "${GREEN}$@${NC}"
}

echored() {
    echo -e "${RED}$@${NC}"
}

# Find the root of the repository
REPO_ROOT=$(git rev-parse --show-toplevel)
HEARTBEAT_SCRIPT="$REPO_ROOT/test/heartbeat.sh"

# --- Test Cases ---

# Test 1: Successful command
test_success() {
    echo "--- Running Test 1: Successful command ---"
    
    local output
    output=$($HEARTBEAT_SCRIPT echo "Hello World")
    local exit_code=$?

    if [ "$exit_code" -ne 0 ]; then
        echored "FAIL: Expected exit code 0, but got $exit_code"
        return 1
    fi

    if ! echo "$output" | grep -q "Command completed successfully"; then
        echored "FAIL: Did not find success message in output."
        echo "Output was:"
        echo "$output"
        return 1
    fi

    # Check that the log file was created and contains the command output
    local log_file
    log_file=$(echo "$output" | head -n 1 | cut -d'=' -f2)

    if [ ! -f "$log_file" ]; then
        echored "FAIL: Log file not found at $log_file"
        return 1
    fi

    if ! grep -q "Hello World" "$log_file"; then
        echored "FAIL: Log file does not contain expected command output."
        echo "Log file content:"
        cat "$log_file"
        return 1
    fi

    echogrn "PASS: Successful command test"
    rm "$log_file" # Clean up
    return 0
}

# Test 2: Failed command
test_failure() {
    echo "--- Running Test 2: Failed command ---"

    # We use `set +e` to handle the non-zero exit code of the command
    set +e
    local output
    output=$($HEARTBEAT_SCRIPT not-a-real-command 2>&1)
    local exit_code=$?
    set -e

    if [ "$exit_code" -ne 127 ]; then
        echored "FAIL: Expected exit code 127, but got $exit_code"
        return 1
    fi

    if ! echo "$output" | grep -q "Command failed with exit code 127"; then
        echored "FAIL: Did not find failure message in output."
        echo "Output was:"
        echo "$output"
        return 1
    fi

    echogrn "PASS: Failed command test"

    # Clean up the log file
    local log_file
    log_file=$(echo "$output" | head -n 1 | cut -d'=' -f2)
    if [ -f "$log_file" ]; then
        rm "$log_file"
    fi
    return 0
}

# Test 3: Log file parsing
test_log_parsing() {
    echo "--- Running Test 3: Log file parsing ---"

    local output
    output=$($HEARTBEAT_SCRIPT echo "testing")
    local log_file_path
    log_file_path=$(echo "$output" | head -n 1 | cut -d'=' -f2)

    if [ -z "$log_file_path" ]; then
        echored "FAIL: Could not parse log file path from output."
        echo "Output was:"
        echo "$output"
        return 1
    fi

    if [ ! -f "$log_file_path" ]; then
        echored "FAIL: Parsed log file path does not point to a file: $log_file_path"
        return 1
    fi

    echogrn "PASS: Log file parsing test"
    rm "$log_file_path" # Clean up
    return 0
}


# --- Main execution ---
main() {
    local overall_result=0

    test_success || overall_result=1
    echo
    test_failure || overall_result=1
    echo
    test_log_parsing || overall_result=1
    echo

    if [ "$overall_result" -eq 0 ]; then
        echogrn "All heartbeat tests passed!"
    else
        echored "Some heartbeat tests failed."
    fi

    return $overall_result
}

main
