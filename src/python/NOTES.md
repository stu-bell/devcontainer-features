Dependency feature for features requiring Python.

Installs Python unless a version equal or greater to feature option min\_python\_version is already found. 

If OS is Alpine Linux, uses apk and ignores all other feature options.

If OS is Debian/Ubuntu and option apt\_get is true, uses apt-get and ignores all other feature options. 

Otherwise uses the official devcontainer python feature: ghcr.io/devcontainers/features/python. Remaining options are passed to this feature.

Errors if the installed version does not meet the min\_python\_version

# OS Support

Tested on Alpine, Debian, Ubuntu. 


