---
# df-owxe
title: pr60
status: draft
type: bug
priority: normal
created_at: 2026-06-02T15:49:44Z
updated_at: 2026-06-10T15:55:45Z
parent: df-lw9i
---

We received this pull request: https://github.com/stu-bell/devcontainer-features/pull/60

```
darthrevan030
commented
2 weeks ago
• 
Fix: fall back to current user when UID 1000 does not exist
Problem:
When using this feature with standard Microsoft devcontainer base images (e.g. mcr.microsoft.com/devcontainers/typescript-node, python, go, cpp), the build fails with:
su: user vscode does not exist or the user entry does not contain all the required fields.

This happens because devcontainer features run during the Docker build phase, but the vscode user (UID 1000) is only created at container startup. So id -un 1000 fails and falls back to the hardcoded string "vscode", which doesn't exist in /etc/passwd at build time.

Fix
In util.sh, change the fallback in remote_user_run from:
sh_REMOTE_USER="$(id -un 1000 2>/dev/null || echo "vscode")" # vscode fallback 
to:
sh_REMOTE_USER="$(id -un 1000 2>/dev/null || id -un)" # fallback to current user 

id -un returns whoever is actually executing the script (root during build), which is guaranteed to exist. Claude Code's install script handles installing to the correct home directory regardless.
```

- I'm struggling to reproduce the error. Let's try a minimal devcontainer json that uses node, in order to get a non vscode username, plus the claude-code feature "ghcr.io/stu-bell/devcontainer-features/claude-code"
- Write a response for the PR which I will upload as a reply. Be polite and thank them for their work. Ask them for a minimal reproduction, what host system they're using. 
- confirm to me whether their assertion that id -un falls back to the current user is accurate. 
- Discuss why they might be encounering that error

UPDATE 2026-06-10 OP provided their minimal repro dc.json. I couldn't reproduce the error. They use vscode and docker (and win11/wsl). Not attempted to reproduce on that platform. 

Suggested action: If I can't reproduce the issue, but it passes the tests, ask AI what the potential side-effects and risks are of accepting the PR anyway. I don't want to shut down somebody else's PR
