---
# df-xsnz
title: version control for package features
status: draft
type: task
priority: normal
created_at: 2026-06-11T16:57:44Z
updated_at: 2026-06-11T17:03:23Z
---

For any package manager features, consider options for version and min_version

version compares as much as the semver as provided in the option. eg 24.3.8 will require 24.3.8. but 24 will be satisfied if 24.2.x is available. If existing version is higher than this, it'll still attempt to install the lower requested version

min_version is like version but is satisfied if a version of the tool of the specified version or greater is already installed. 

[ npm version ranges ](https://semver.npmjs.com/) use syntax ^ and ~, but that'll be more complicated for users and harder to implement/get right
