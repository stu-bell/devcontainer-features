# Test devcontainer builds

test-builds.sh refers to a scenarios.json file (an array of scenario objects). Each scenario includes devcontainer.json and the expected build exit code. 

Run `test-builds.sh --help` and `test-builds.sh --generate` to see a sample scenarios.json.

Once you've creaed your scenarios.json, run it with `test-builds.sh -s <PATH_TO_YOUR_FILE>.json` 

# Build only

test-builds.sh builds the devcontainer, it doesn't run it. To validate that any installed features run, consider adding a validation step to the end of your install.sh script that runs a simple command (eg checking the version or help text)

Note that a workaround is needed for features that install to the current user, as the feature installs as root, not the remote user. An example of this is in the cursorcli feature.

# Using during development and debugging

The --only flag allows a list of scenario names to run (other scenarios in the file are ignored).

# Testing the test script

Scripts for verifying test-build.sh behaviour are in test/script-tests

