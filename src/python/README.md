
# Python (python)

Installs Python, unless a version greater or equal to the minimum required version is found. Extends official Python feature (ghcr.io/devcontainers/features/python) to support Alpine.

## Example Usage

```json
"features": {
    "ghcr.io/stu-bell/devcontainer-features/python:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| min_python_version | Feature exits early if this version or greater is already installed. | string | latest |
| apt_get | If true, uses apt_get on Debian like distros, instead of building from source. Other options in this feature are ignored. | boolean | true |
| official_python_feature_version | Version of the official python DEVCONTAINER FEATURE to use for non-alpine distros. | string | latest |
| installTools | Flag indicating whether or not to install the tools specified via the 'toolsToInstall' option. Default is 'true'. Option ignored on Alpine. | boolean | true |
| toolsToInstall | Comma-separated list of tools to install when 'installTools' is true. Defaults to a set of common Python tools like pylint. Option ignored on Alpine. | string | flake8,autopep8,black,yapf,mypy,pydocstyle,pycodestyle,bandit,pipenv,virtualenv,pytest,pylint |
| optimize | Optimize Python for performance when compiled (slow). Option ignored on Alpine. | boolean | false |
| enableShared | Enable building a shared Python library. Option ignored on Alpine. | boolean | false |
| installPath | The path where python will be installed. Option ignored on Alpine. | string | /usr/local/python |
| installJupyterlab | Install JupyterLab, a web-based interactive development environment for notebooks. Option ignored on Alpine. | boolean | false |
| configureJupyterlabAllowOrigin | Configure JupyterLab to accept HTTP requests from the specified origin. Option ignored on Alpine. | string | - |
| httpProxy | Connect to GPG keyservers using a proxy for fetching source code signatures by configuring this option. Option ignored on Alpine. | string | - |

Dependency feature for features requiring Python.

Installs Python unless a version equal or greater to feature option min\_python\_version is already found. 

If OS is Alpine Linux, uses apk and ignores all other feature options.

If OS is Debian/Ubuntu and option apt\_get is true, uses apt-get and ignores all other feature options. 

Otherwise uses the official devcontainer python feature: ghcr.io/devcontainers/features/python. Remaining options are passed to this feature.

Errors if the installed version does not meet the min\_python\_version

# OS Support

Tested on Alpine, Debian, Ubuntu. 




---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
