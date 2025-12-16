#!/bin/bash
set -e
set -x

# Test script for scenario filtering in test-builds.sh

# Create a temporary directory for our test scenarios
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

# Create a dummy scenarios.json
cat > "$TEST_DIR/scenarios.json" << EOF
[
  {
    "name": "scenario-A",
    "expected_exit_code": 0,
    "devcontainer": {
      "image": "mcr.microsoft.com/devcontainers/base:alpine"
    }
  },
  {
    "name": "scenario-B",
    "expected_exit_code": 0,
    "devcontainer": {
      "image": "mcr.microsoft.com/devcontainers/base:alpine"
    }
  },
  {
    "name": "scenario-C",
    "expected_exit_code": 0,
    "devcontainer": {
      "image": "mcr.microsoft.com/devcontainers/base:alpine"
    }
  }
]
EOF

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
echored() {
    echo -e "${RED}$@${NC}"
}
echogrn() {
    echo -e "${GREEN}$@${NC}"
}

# --- Test Cases ---

# Test Case 1: Run all scenarios
echo "--- Test Case 1: Run all scenarios ---"
output=$(./test/test-builds.sh --scenarios-file "$TEST_DIR/scenarios.json" --quiet)
if echo "$output" | grep -q "Running Scenario: scenario-A" && \
   echo "$output" | grep -q "Running Scenario: scenario-B" && \
   echo "$output" | grep -q "Running Scenario: scenario-C"; then
    echogrn "✓ PASSED: All scenarios ran when none were specified."
else
    echored "✗ FAILED: Not all scenarios ran."
    echo "$output"
    exit 1
fi

# Test Case 2: Run a single scenario
echo "--- Test Case 2: Run a single scenario ---"
output=$(./test/test-builds.sh --scenarios-file "$TEST_DIR/scenarios.json" --scenarios scenario-B --quiet)
if echo "$output" | grep -q "Running Scenario: scenario-B" && \
   ! echo "$output" | grep -q "Running Scenario: scenario-A" && \
   ! echo "$output" | grep -q "Running Scenario: scenario-C"; then
    echogrn "✓ PASSED: Only the specified single scenario ran."
else
    echored "✗ FAILED: Incorrect scenarios ran for single selection."
    echo "$output"
    exit 1
fi

# Test Case 3: Run multiple scenarios
echo "--- Test Case 3: Run multiple scenarios ---"
output=$(./test/test-builds.sh --scenarios-file "$TEST_DIR/scenarios.json" --scenarios scenario-A scenario-C --quiet)
if echo "$output" | grep -q "Running Scenario: scenario-A" && \
   echo "$output" | grep -q "Running Scenario: scenario-C" && \
   ! echo "$output" | grep -q "Running Scenario: scenario-B"; then
    echogrn "✓ PASSED: Correct multiple scenarios ran."
else
    echored "✗ FAILED: Incorrect scenarios ran for multiple selection."
    echo "$output"
    exit 1
fi

# Test Case 4: Invalid scenario name
echo "--- Test Case 4: Invalid scenario name ---"
error_output=$(./test/test-builds.sh --scenarios-file "$TEST_DIR/scenarios.json" --scenarios scenario-invalid 2>&1 >/dev/null)
exit_code=$?
if [ $exit_code -ne 0 ] && echo "$error_output" | grep -q "Error: Scenario name 'scenario-invalid' not found"; then
    echogrn "✓ PASSED: Script exited with an error for invalid scenario."
else
    echored "✗ FAILED: Script did not fail as expected for invalid scenario."
    echo "$error_output"
    exit 1
fi

# Test Case 5: Mix of valid and invalid scenarios
echo "--- Test Case 5: Mix of valid and invalid scenarios ---"
error_output=$(./test/test-builds.sh --scenarios-file "$TEST_DIR/scenarios.json" --scenarios scenario-A scenario-invalid 2>&1 >/dev/null)
exit_code=$?
if [ $exit_code -ne 0 ] && echo "$error_output" | grep -q "Error: Scenario name 'scenario-invalid' not found"; then
    echogrn "✓ PASSED: Script exited with an error for mixed validity scenarios."
else
    echored "✗ FAILED: Script did not fail as expected for mixed validity scenarios."
    echo "$error_output"
    exit 1
fi

echogrn "--- All scenario filtering tests passed! ---"
