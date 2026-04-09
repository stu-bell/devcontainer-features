#!/bin/sh
set -e

# devcontainer feature options
# colon-separated list of paths to source from each shell rc file
LOCAL_CONFIG_FILES=${LOCALCONFIGFILES:-}
# colon-separated list of shell rc files to append source lines to
SHELL_RC_FILES=${SHELLRCFILES:-"/etc/profile:/etc/bash.bashrc"}

if [ -z "${LOCAL_CONFIG_FILES}" ]; then
    echo "No local config files specified, skipping."
    exit 0
fi

# split SHELL_RC_FILES by colon and iterate
echo "$LOCAL_CONFIG_FILES" | tr ':' '\n' | while read -r file; do

    # rc line to source the script
    CONFIG_LINE=". ${file}"

    # split SHELL_RC_FILES by colon and iterate
    echo "$SHELL_RC_FILES" | tr ':' '\n' | while read -r rc; do
        # create the rc file if it doesn't exist
        if [ ! -f "$rc" ]; then
            mkdir -p "$(dirname "$rc")"
            touch "$rc"
        fi

	if [ "${IDEMPOTENT:-true}" = "true" ]; then
		# skip if already present to keep idempotent
		grep -qF "$CONFIG_LINE" "$rc" && continue
	fi

        # printf to ensure a blank line before the source line for readability
        printf '\n%s\n' "$CONFIG_LINE" >> "$rc"
    done
done

