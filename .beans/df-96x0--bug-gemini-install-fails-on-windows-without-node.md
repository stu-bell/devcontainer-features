---
# df-96x0
title: BUG gemini install fails on windows without node
status: todo
type: task
priority: normal
created_at: 2026-03-12T15:26:49Z
updated_at: 2026-06-01T18:51:57Z
parent: df-wqjh
---

gemini install fails on windows when using devcontainer json without node already installed. THe install OCI feature funtion appears from the logs to correctly install node, however, the remainder of the gemini install script can't seem to find the node installation, and so fails. THis doesn't seem to be reproducible in tests, even when using the published tests in _global, however attempts to install the feature on an ubuntu image without node preinstalled, on a windows host, fail. 
