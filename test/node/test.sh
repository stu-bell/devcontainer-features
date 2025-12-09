#!/bin/bash

# This test can be run with the following command:
# devcontainer features test -f node --skip-scenarios -i mcr.microsoft.com/devcontainers/base:ubuntu 

# This test file will be executed against an auto-generated devcontainer.json that
# includes the specified feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md
#
# The value of all options will fall back to the default value in 
# the Feature's 'devcontainer-feature.json'.
#
# These scripts are run as 'root' by default. Although that can be changed
# with the '--remote-user' flag.
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
# checks command executes successfully
check "execute command" bash -c "echo node version: $(node -v)"

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults

