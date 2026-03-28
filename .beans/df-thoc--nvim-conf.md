---
# df-thoc
title: nvim-conf
status: draft
type: bug
created_at: 2026-03-28T16:58:33Z
updated_at: 2026-03-28T16:58:33Z
---

neovim feature option still using XDG_CONFIG_HOME /config when cloning nvim config. bump feature version. ensure default config_location is the remote user's home directory ~/.config so that config is cloned to ~/.config/nvim. Update NOTES.md and test mount config - don't think we can use ~/.config/nvim in the mount config. 

Test the following config for lazy nvim to recommend ways of keeping config cloning small:

## env vars
In lazy nvim config, set: `enabled = (vim.env.<ENVVAR> == "true")`  and set the value of the ENVVAR in devcontainer.json

## initialise lazy nvim in post create command

`nvim --headless "+Lazy! sync" +qa`

