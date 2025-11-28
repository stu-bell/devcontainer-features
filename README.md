# Dev Container Features

Using https://github.com/devcontainers/feature-starter

# To add a feature

1. Add a folder in test for your feature
1. Start the devcontainer for the repo
1. Make sure the test works (fails!) with
1. Build out your feature until your tests pass
1. Use your feature locally in your .devcontainer projects
1. Or [disbribute it](./README-template.md#distributing-features)

# Tests

https://github.com/devcontainers/cli/blob/main/docs/features/test.md
https://containers.dev/guide/feature-authoring-best-practices

Command to quickly test feature with a particular image:
`devcontainer features test --skip-scenarios -f <FEATURE_NAME>  -i <IMAGE_URI>`
where <IMAGE_URI> could be, eg: mcr.microsoft.com/devcontainers/base:ubuntu 

## Duplicate tests

TODO

Tests what happens if a devcontainer.json installs the feature multiple times with different options. Feature installs should be idempotent.


# CI

TODO figure this out...
.github/workflows has yaml for 3 pipelines that may reference the starter template features (called color and hello)

# Docs generation

From the src directory (devcontainer cli command is available in the devcontainer for this project)
`devcontainer features generate-docs`
