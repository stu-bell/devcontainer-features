#!/usr/bin/env bash
# Usage: ./validate-json.sh [path]
# Defaults to checking all .json files in the repo if no path is provided

set -euo pipefail

TARGET="${1:-.}"
echo "Validating JSON files under: $(realpath "$TARGET")..."

# Find all JSON files recursively
files=()
while IFS= read -r -d $'\0' f; do
    files+=("$f")
# skip the .git repo
done < <(find "$TARGET" \
    -type d -name .git -prune -false \
    -o -type f -name "*.json" -print0)

if [ ${#files[@]} -eq 0 ]; then
    echo "No JSON files found under $TARGET"
    exit 0
fi

# Arrays to hold invalid files and their jq errors
declare -A errors
invalid=()

# Check each file
for file in "${files[@]}"; do
    # sed to remove comment lines starting with // before testing with jq
    if ! output=$(sed -E 's|//.*$||' "$file" | jq . 2>&1); then
        echo "❌ $file"
        invalid+=("$file")
        errors["$file"]="$output"
    else
        echo "✅ $file"
    fi
done

# Re-print all invalid files with jq errors at the end
if [ ${#invalid[@]} -gt 0 ]; then
    echo
    echo "Invalid JSON files:"
    for f in "${invalid[@]}"; do
        echo "❌ $f"
        echo "  ${errors[$f]}" | sed 's/^/    /' # sed indents every line of the output
	echo ""
    done
fi

