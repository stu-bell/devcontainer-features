#!/bin/bash
# TODO UNDER DEVELOPMENT
#
# Loops over a set of scenarios.json that are designed to fail during devcontainer build. 
#
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Create test workspace directory
FEATURE_PATH="../../src/geminicli/"

# TODO figure out where we're going to put temp devcontainer directory. we also need to copy the feature folder there
TEST_WORKSPACE="./buildfails"
DEVCONTAINER_DIR="$TEST_WORKSPACE/.devcontainer"

echo -e "${YELLOW}Setting up test workspace...${NC}"

# Clean up if it exists
rm -rf "$TEST_WORKSPACE"
mkdir -p "$DEVCONTAINER_DIR"

# Write sample devcontainer.json
# TODO: loop over a set of JSON definitions. Need to include the expected failure message
# TODO option to filter to specific failure scenarios? overkill? you're better off adding this feature to the devcontainer features test cli?
# Note the feature path is relative to the copy of the feature source folder, copied to $DEVCONTAINER_DIR, so should always start with ./
cat > "$DEVCONTAINER_DIR/devcontainer.json" <<'EOF'
{
  "image": "mcr.microsoft.com/devcontainers/base:debian",
  "features": {
    "./geminicli": {
	"node_min_major_version": 18
    }
  }
}
EOF

cp -r "$FEATURE_PATH" "$DEVCONTAINER_DIR"

echo -e "${GREEN}✓ Created test workspace at $TEST_WORKSPACE${NC}"
echo -e "${GREEN}✓ Created devcontainer.json${NC}"

# Run the test script
echo ""
echo -e "${YELLOW}Running test...${NC}"

WORKSPACE_FOLDER="$TEST_WORKSPACE"
EXPECTED_MESSAGE="replace me with the error message you're testing for"

echo "Running devcontainer build --workspace-folder $WORKSPACE_FOLDER..."
echo "Building workspace container may take a while..."
# Prevent set -e from stopping the script when build fails
set +e
# --no-cache so we test the build from scratch 
OUTPUT=$(devcontainer build --no-cache --workspace-folder "$WORKSPACE_FOLDER" 2>&1)
EXIT_CODE=$?
set -e

if [ $EXIT_CODE -ne 0 ]; then
    echo -e "${GREEN}✓ Build failed as expected (exit code: $EXIT_CODE)${NC}"
	if echo "$OUTPUT" | grep -q "$EXPECTED_MESSAGE"; then
	    echo -e "${GREEN}✓ Expected error message found${NC}"
	else
	    echo -e "${RED}✗ Expected error message not found${NC}"
	    echo "Expected: $EXPECTED_MESSAGE"
	    echo "Output:"
# option to suppress output for failed tests
	    echo "$OUTPUT"
	fi
else
    echo -e "${RED}✗ Build should have failed but succeeded${NC}"
    echo "Output:"
# option to suppress output for failed tests
    echo "$OUTPUT"
fi

# Cleanup
# TODO: do we need to clean up any docker artifacts (image caches etc?) 
# TODO devcontainer build should just build the container, not start it. 
# TODO Can we just use docker builder prune -a -f ?
echo ""
echo ""
echo -e "${YELLOW}Cleaning up...${NC}"
rm -rf "$TEST_WORKSPACE"
echo -e "${GREEN}✓ Test workspace removed${NC}"
