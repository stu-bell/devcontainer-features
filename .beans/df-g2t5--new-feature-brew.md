---
# df-g2t5
title: 'new feature: Brew'
status: draft
type: task
created_at: 2026-03-12T15:40:26Z
updated_at: 2026-03-12T15:40:26Z
---

Install script from homebrew: https://brew.sh/
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

Note it provides instructions at the end on how to add brew to the PATH. We should provide an option in devcontainer.json to do this automatically (so that brew power users can override it manually). 

Should first check if the required version of brew is already installed. only install brew if a sufficient version of brew cannot be found. 

Add an option to install a brew package immediately after brew installs. Must be able to pass brew args. Note we can only install one package this way. can we find a workaround for this?

Add an option to remove brew after package install to keep the image small? This is just for the purpose of installing a package with brew


