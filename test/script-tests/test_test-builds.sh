#!/bin/bash
set -e
# WIP script to test test-builds.sh

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Get the directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
TEST_BUILDS_SCRIPT="$SCRIPT_DIR/../test-builds.sh"

# All these scenarios should fail
echo "Running scenarios_fail.json..."
# Capture output and exit code, while also showing progress
output_file=$(mktemp)
# The script output is tee'd to stdout for live progress, and to a file for parsing
"$TEST_BUILDS_SCRIPT" --quiet --scenarios-file "$SCRIPT_DIR/scenarios_fail.json" 2>&1 | tee "$output_file"
exit_code=${PIPESTATUS[0]}
output=$(cat "$output_file")
rm "$output_file"

# We expect a non-zero exit code because tests in scenarios_fail.json should fail
if [ "$exit_code" -eq 0 ]; then
    echo -e "${RED}❌ Failure: test-builds.sh exited with 0, but a non-zero status was expected.${NC}" >&2
    exit 1
fi

# Strip ANSI color codes from the output before parsing
output_no_color=$(echo "$output" | sed -r "s/\x1B\[[0-9;]*[mK]//g")

# Check that Passed count is 0 and Total equals Failed, and that the summary block is contiguous
summary_block=$(echo "$output_no_color" | grep -A 2 "Total Tests:")

if [ -z "$summary_block" ]; then
    echo -e "${RED}❌ Failure: Could not find 'Total Tests:' line in output.${NC}" >&2
    exit 1
fi

total_tests=$(echo "$summary_block" | grep "Total Tests:" | awk '{print $3}')
passed_tests=$(echo "$summary_block" | grep "Passed:" | awk '{print $2}')
failed_tests=$(echo "$summary_block" | grep "Failed:" | awk '{print $2}')

# Check if we successfully parsed the numbers from the block
if [ -z "$total_tests" ] || [ -z "$passed_tests" ] || [ -z "$failed_tests" ]; then
    echo -e "${RED}❌ Failure: Could not parse a contiguous test summary block from output.${NC}" >&2
    echo "Expected 'Total Tests:', 'Passed:', and 'Failed:' on consecutive lines." >&2
    exit 1
fi

if [ "$passed_tests" -eq 0 ] && [ "$total_tests" -gt 0 ] && [ "$total_tests" -eq "$failed_tests" ]; then
    echo -e "${GREEN}✅ Success: test-builds.sh exited non-zero and all scenarios failed as expected.${NC}"
else
    echo -e "${RED}❌ Failure: Not all scenarios failed as expected.${NC}" >&2
    echo "Parsed summary: Passed: $passed_tests, Failed: $failed_tests, Total: $total_tests" >&2
    exit 1
fi

# All these scenarios should pass
echo "Running scenarios_pass.json..."
if "$TEST_BUILDS_SCRIPT" --quiet --scenarios-file "$SCRIPT_DIR/scenarios_pass.json"; then
    echo -e "${GREEN}✅ Success: test-builds.sh exited with 0 as expected.${NC}"
else
    echo -e "${RED}❌ Failure: test-builds.sh exited with a non-zero status.${NC}" >&2
    exit 1
fi

echo -e "${GREEN}✅ All tests passed.${NC}"
