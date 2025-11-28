# Supported OS

Gemini CLI runs off Node.js, so it *should* run on any container with Node.js v 20 or higher.

This feature checks for Node and attempts to install it if the OS is Alpine, Debian or Ubuntu. For other OS versions, ensure Node.js and npm are installed before this feature is installed (see [overrideFeatureInstallOrder](https://containers.dev/implementors/json_reference/#general-properties)).

