---
# df-mi7w
title: headless during install
status: draft
type: task
priority: normal
created_at: 2026-06-01T18:52:45Z
updated_at: 2026-06-01T18:54:24Z
parent: df-96um
---

Option to start nvim in headless mode during install, then quit. This would for example, allow Lazy vim plugins to install during feature install, which means when the container has been built, nvim is ready to go. Could include an option to run a command, such as Plug install, which hopefully helps setup other plugin systems.
