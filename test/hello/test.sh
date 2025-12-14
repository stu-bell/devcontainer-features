#!/bin/bash

# execute this test for a given base image with:
# devcontainer features test --skip-scenarios -f <FEATURENAME> -i mcr.microsoft.com/devcontainers/base:ubuntu
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md
#
# exit if a command exits with a non-zero status (ie, an error) to fail a test
set -e

# Optional: Import test library bundled with the devcontainer CLI
# See https://github.com/devcontainers/cli/blob/HEAD/docs/features/test.md#dev-container-features-test-lib
# Provides the 'check' and 'reportResults' commands.
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib. Syntax is...
# check <LABEL> <cmd> [args...]
check "execute command" bash -c "hello | grep 'hey, $(whoami)!'"

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
