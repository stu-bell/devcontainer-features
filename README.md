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


devcontainer features test --skip-scenarios -f hello \
   -i mcr.microsoft.com/devcontainers/base:ubuntu 

# OS compatibility

https://containers.dev/guide/feature-authoring-best-practices#detect-platformos

write install.sh for the sh shell to target Alpine?

Someone has contributed an alpine node feature. 

remove the node dependsOn. 

Replace with installsAfter

and tell user to ensure node is installed with an appropriate feature. 

you can check if node is installed during install.sh and prompt user to add a feature that installs node


or you could pull the node install.sh script from the git repo, depending on the OS


# CI

TODO figure this out...
.github/workflows has yaml for 3 pipelines that may reference the starter template features (called color and hello)


