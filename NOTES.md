# TODO

1. TODOs in test/test-builds.sh
1. release pipeline triggering too often?
1. Can we move documentation generation to a pipeline before release?
1. Use ./test/test-builds.sh to test duplicate installs and combinations of features (like the devconainer test --global option?)
1. test-build.sh to start container and execute a test.sh script referenced by the scenario

# Tests

see [test/README](./test/README.md)

# To add a feature

1. Add a folder in test for your feature
1. Start the devcontainer for the repo
1. Make sure the test works (fails!) with
1. Build out your feature until your tests pass
1. Use your feature locally in your .devcontainer projects
1. Or [disbribute it](./README-template.md#distributing-features)


# Docs generation

From the src directory (devcontainer cli command is available in the devcontainer for this project)
`devcontainer features generate-docs -n stu-bell/devcontainer-features`

