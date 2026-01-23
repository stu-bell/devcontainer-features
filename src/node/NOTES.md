# Usage

Dependency feature for features requiring Node.

Installs Node unless a version equal or greater to feature option min_node_version is already found.

Errors if the installed version does not meet the min_node_version.

# OS Support

Tested on Alpine, Ubuntu, Debian.

If OS is Alpine Linux, uses apk and ignores all other feature options.

Otherwise uses the official devcontainer Node feature: ghcr.io/devcontainers/features/node. Remaining options are passed to this feature.

