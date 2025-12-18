#!/bin/sh
set -e

echo forcebuilderror option: $FORCEBUILDERROR
if [ "$FORCEBUILDERROR" = "true" ]; then
	RED='\033[0;91m'
	NC='\033[0m'
	echo -e "${RED}ERROR: Feature option forceBuildError was true, to demonstrate a build error.${NC}" >&2
	exit 1
fi
echo "demobuilderror completed without error"

