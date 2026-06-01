---
# df-bd35
title: .claude.json
status: draft
type: feature
priority: normal
created_at: 2026-06-01T18:47:47Z
updated_at: 2026-06-01T18:50:34Z
parent: df-lw9i
---

Add option to skip onboarding. If true, merge the following json with ~/.claude.json: 
```json
{"hasCompletedOnboarding":true}
```

For auth, if ~/.claude/.credentials.json exist on the host, this could be mounted to the container, but the user would need to add this mount config to their devcontainer.json
