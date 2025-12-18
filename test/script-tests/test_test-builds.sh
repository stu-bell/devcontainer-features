#!/bin/bash
set -e

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Get the directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
TEST_BUILDS_SCRIPT="$SCRIPT_DIR/../test-builds.sh"

# WIP script to test test-builds.sh

echo "Running scenarios_pass.json..."
if "$TEST_BUILDS_SCRIPT" --scenarios-file "$SCRIPT_DIR/scenarios_pass.json"; then
    echo -e "${GREEN}✅ Success: test-builds.sh exited with 0 as expected.${NC}"
else
    echo -e "${RED}❌ Failure: test-builds.sh exited with a non-zero status.${NC}" >&2
    exit 1
fi

echo "Running scenarios_fail.json..."
# FIXME this succeeds if at least one scenario errors, we need to test that all scenarios fail
# TODO the output of a test includesthe following lines:
# Total Tests: N
# Passed: 0
# Failed: N
#
# We should be able to test that all tests failed by grepping for Passed: 0. Even better, grepping for Totaltest and comparing it to the number of failed tests
# That and confirming that exit code 1 should be sufficient
if ! "$TEST_BUILDS_SCRIPT" --scenarios-file "$SCRIPT_DIR/scenarios_fail.json"; then # Note the '!' here
    echo -e "${GREEN}✅ Success: test-builds.sh exited with a non-zero status as expected.${NC}"
else
    echo -e "${RED}❌ Failure: test-builds.sh exited with 0, but a non-zero status was expected.${NC}" >&2
    exit 1
fi

echo -e "${GREEN}✅ All tests passed.${NC}"
