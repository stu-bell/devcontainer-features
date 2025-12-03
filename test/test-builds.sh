#!/bin/bash
# TODO UNDER DEVELOPMENT
#
# Loops over a set of scenarios.json that provides devcontainer.json config that 
# should either build succesfully or fail
# Tests whether build output was expected, and if it failed, if an expected failure 
# message is present.
# Does not start or execute inside the devcontainer.


set -e

# TODO document options
while [ $# -gt 0 ]; do
  case "$1" in
    --ignore-docker-config)
      IGNORE_DOCKER_CONFIG=true
      shift
      ;;
    # --feature-name <value>
    --feature-name)
      FEATURE_NAME="$2"
      if [ -z "$FEATURE_NAME" ]; then
        echo "Error: --feature-name requires a value." >&2
        exit 1
      fi
      shift 2
      ;;
    # -f alias for --feature-name
    -f)
      FEATURE_NAME="$2"
      if [ -z "$FEATURE_NAME" ]; then
        echo "Error: -f requires a value." >&2
        exit 1
      fi
      shift 2
      ;;
    # --feature-src-path <value>
    --feature-src-path)
      FEATURE_SRC_PATH="$2"
      if [ -z "$FEATURE_SRC_PATH" ]; then
        echo "Error: --feature-src-path requires a value." >&2
        exit 1
      fi
      shift 2
      ;;
    # --test-workspace-path <value>
    --test-workspace-path)
      TEST_WORKSPACE="$2"
      if [ -z "$TEST_WORKSPACE" ]; then
        echo "Error: --test-workspace-path requires a value." >&2
        exit 1
      fi
      shift 2
      ;;

    # # --option-name <value>
    # --option-name)
    #   VARIABLE_NAME="$2"
    #   if [ -z "$VARIABLE_NAME" ]; then
    #     echo "Error: --option-name requires a value." >&2
    #     exit 1
    #   fi
    #   shift 2
    #   ;;

    # Unknown
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

# default values
IGNORE_DOCKER_CONFIG=${IGNORE_DOCKER_CONFIG:-""}
FEATURE_NAME=${FEATURE_NAME:-"node"}
FEATURE_SRC_PATH=${FEATURE_SRC_PATH:-"../src/${FEATURE_NAME}"}
TEST_WORKSPACE=${TEST_WORKSPACE:-"/tmp/devcontainer_test_builds"}
DEVCONTAINER_DIR="$TEST_WORKSPACE/.devcontainer"

# check for dependencies
if ! command -v jq >/dev/null 2>&1; then
    echo "Dependency not found: jq"
    echo "Please install jq or use devcontainer feature common utils: ghcr.io/devcontainers/features/common-utils:latest"
fi
if ! command -v devcontainer >/dev/null 2>&1; then
    echo "Dependency not found: devcontainer"
    echo "Please install devcontainer cli: https://github.com/devcontainers/cli"
fi
if ! command -v docker >/dev/null 2>&1; then
    echo "Dependency not found: docker"
    echo "Please install docker: https://docker.com"
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ignore docker config?
if $IGNORE_DOCKER_CONFIG; then
	export DOCKER_CONFIG=/tmp/docker-test-config
	mkdir -p $DOCKER_CONFIG
	echo '{"auths":{}}' > $DOCKER_CONFIG/config.json
	echo Using Docker config: ${DOCKER_CONFIG}/config.json
	cat $DOCKER_CONFIG/config.json
fi

# Clean up if it exists
echo -e "${YELLOW}Setting up test workspace...${NC}"
rm -rf "$TEST_WORKSPACE"
mkdir -p "$DEVCONTAINER_DIR"

# Write sample devcontainer.json
# TODO: loop over a set of JSON definitions. Need to include the expected failure message
# TODO option to filter to specific failure scenarios? overkill? you're better off adding this feature to the devcontainer features test cli?
# Note the feature path is relative to the copy of the feature source folder, copied to $DEVCONTAINER_DIR, so should always start with ./
cat > "$DEVCONTAINER_DIR/devcontainer.json" <<EOF
{
  "image": "mcr.microsoft.com/devcontainers/base:alpine",
  "features": {
    "./${FEATURE_NAME}": {}
  }
}
EOF

# run from dir of current test script so relative paths work
cd $(dirname $0)
cp -r "$FEATURE_SRC_PATH" "$DEVCONTAINER_DIR"

echo -e "${GREEN}✓ Created test workspace at $TEST_WORKSPACE${NC}"
echo -e "${GREEN}✓ Created devcontainer.json${NC}"

# run the build
echo ""
echo -e "${YELLOW}Running build(s)...${NC}"
echo "Running devcontainer build --workspace-folder $WORKSPACE_FOLDER..."
echo "Building workspace container may take a while..."


# TODO get from json
WORKSPACE_FOLDER="$TEST_WORKSPACE"
EXPECTED_MESSAGE="replace me with the error message you're testing for"

# Pre-determined image name to aid cleanup
# format name=value
id_label="dc-test-build-$(date +%s)"
echo $id_label

# Run build
# Prevent set -e from stopping the script when build fails
set +e
# --no-cache so we test the build from scratch 
build_output=$(devcontainer build --no-cache --image-name "$id_label" --workspace-folder "$WORKSPACE_FOLDER" 2>&1)
echo "$build_output"
EXIT_CODE=$?
set -e

# Clean up container
echo -e "${YELLOW}Cleaning up...${NC}"
docker images
docker rmi -f "$id_label"
rm -rf "$TEST_WORKSPACE"


echo -e "${YELLOW}Build results${NC}"

# TODO from json
EXPECTED_EXIT_CODE=0


# Test result
TEST_RESULT="unknown"

# possible test output scenarios
if [ $EXPECTED_EXIT_CODE -eq 0 ]; then
    # Scenarios where success is expected
    if [ $EXIT_CODE -eq 0 ]; then
        # Expected success, actually succeeded
        echo -e "${GREEN}✓ Build succeeded as expected (exit code: $EXIT_CODE)${NC}"
        TEST_RESULT="expected_success"
    else
        # Expected success, but failed
        echo -e "${RED}✗ Build should have succeeded but failed (exit code: $EXIT_CODE)${NC}"
        echo "Output:"
        echo "$OUTPUT"
        TEST_RESULT="unexpected_fail"
    fi
else
    # Scenarios where failure is expected
    if [ $EXIT_CODE -eq 0 ]; then
        # Expected failure, but succeeded
        echo -e "${RED}✗ Build should have failed but succeeded${NC}"
        echo "Output:"
        echo "$OUTPUT"
        TEST_RESULT="unexpected_success"
    # elif [ -z "$OUTPUT" ]; then
    #     # Expected failure, got failure, but no output/error message
    #     echo -e "${RED}✗ Build failed but no output was captured${NC}"
    #     echo "Expected: $EXPECTED_MESSAGE"
    #     TEST_RESULT="expected_fail_silent"
    else
        # Build failed as expected, now check the error message
        echo -e "${GREEN}✓ Build failed as expected (exit code: $EXIT_CODE)${NC}"
        if echo "$OUTPUT" | grep -q "$EXPECTED_MESSAGE"; then
            # Expected failure with correct error message
            echo -e "${GREEN}✓ Expected error message found${NC}"
            TEST_RESULT="expected_fail"
        else
            # Expected failure but wrong error message
            echo -e "${RED}✗ Expected error message not found${NC}"
            echo "Expected: $EXPECTED_MESSAGE"
            echo "Actual output:"
            echo "$OUTPUT"
            TEST_RESULT="expected_fail_wrong_message"
        fi
    fi
fi

# Output final test result
echo ""
case "$TEST_RESULT" in
    expected_success|expected_failure)
        echo -e "${GREEN}✓ TEST PASSED: $TEST_RESULT${NC}"
        exit 0
        ;;
    unexpected_fail|unexpected_success|expected_fail_wrong_message|expected_fail_silent)
        echo -e "${RED}✗ TEST FAILED: $TEST_RESULT${NC}"
        exit 1
        ;;
    *)
        echo -e "${RED}TEST ERROR: unknown result${NC}"
        exit 2
        ;;
esac
