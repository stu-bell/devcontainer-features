#!/bin/bash
#
# Tests devcontainer.json configurations to verify they build successfully or fail
# with expected error messages.
# Currently tests a single scenario - designed to be extended to loop over multiple scenarios.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Default values
IGNORE_DOCKER_CONFIG=${IGNORE_DOCKER_CONFIG:-""}
FEATURE_NAME=${FEATURE_NAME:-"node"}
FEATURE_SRC_PATH=${FEATURE_SRC_PATH:-""}
TEST_WORKSPACE=${TEST_WORKSPACE:-"/tmp/devcontainer_test_builds"}
VERBOSE=${VERBOSE:-false}
EXPECTED_EXIT_CODE=${EXPECTED_EXIT_CODE:-0}
EXPECTED_MESSAGE=${EXPECTED_MESSAGE:-""}

# Test tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
declare -a TEST_RESULTS=()

show_help() {
  echo "Usage: $(basename "$0") [OPTIONS]"
  echo ""
  echo "Tests a devcontainer.json configuration by building it and verifying the result."
  echo ""
  echo "Options:"
  echo "  --ignore-docker-config           Ignore Docker configuration (use temp config)"
  echo "  --feature-name, -f <name>        Feature name (default: node)"
  echo "  --feature-src-path <path>        Feature source path (default: ../src/FEATURE_NAME)"
  echo "  --test-workspace-path <path>     Test workspace path (default: /tmp/devcontainer_test_builds)"
  echo "  --expected-exit-code <code>      Expected exit code (default: 0)"
  echo "  --expected-message <message>     Expected error message (for failure tests)"
  echo "  --verbose, -v                    Show detailed build output"
  echo "  -h, --help                       Show this help message"
  echo ""
  echo "Examples:"
  echo "  # Test a successful build"
  echo "  $(basename "$0") --feature-name node"
  echo ""
  echo "  # Test an expected failure"
  echo "  $(basename "$0") --feature-name node --expected-exit-code 1 --expected-message 'invalid version'"
}

parse_arguments() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --ignore-docker-config)
        IGNORE_DOCKER_CONFIG=true
        shift
        ;;
      --feature-name|-f)
        FEATURE_NAME="$2"
        if [ -z "$FEATURE_NAME" ]; then
          echo "Error: --feature-name requires a value." >&2
          exit 1
        fi
        shift 2
        ;;
      --feature-src-path)
        FEATURE_SRC_PATH="$2"
        if [ -z "$FEATURE_SRC_PATH" ]; then
          echo "Error: --feature-src-path requires a value." >&2
          exit 1
        fi
        shift 2
        ;;
      --test-workspace-path)
        TEST_WORKSPACE="$2"
        if [ -z "$TEST_WORKSPACE" ]; then
          echo "Error: --test-workspace-path requires a value." >&2
          exit 1
        fi
        shift 2
        ;;
      --expected-exit-code)
        EXPECTED_EXIT_CODE="$2"
        if [ -z "$EXPECTED_EXIT_CODE" ]; then
          echo "Error: --expected-exit-code requires a value." >&2
          exit 1
        fi
        shift 2
        ;;
      --expected-message)
        EXPECTED_MESSAGE="$2"
        shift 2
        ;;
      --verbose|-v)
        VERBOSE=true
        shift
        ;;
      -h|--help)
        show_help
        exit 0
        ;;
      *)
        echo "Error: Unknown argument: $1" >&2
        echo "Use --help for usage information." >&2
        exit 1
        ;;
    esac
  done
}

check_dependencies() {
    local need_deps=false
    if ! command -v jq >/dev/null 2>&1; then
        echo -e "${RED}✗ Dependency not found: jq${NC}"
        echo "  Install: apt-get install jq  or  brew install jq"
        need_deps=true
    fi
    if ! command -v devcontainer >/dev/null 2>&1; then
        echo -e "${RED}✗ Dependency not found: devcontainer${NC}"
        echo "  Install: npm install -g @devcontainers/cli"
        need_deps=true
    fi
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}✗ Dependency not found: docker${NC}"
        echo "  Install: https://docker.com"
        need_deps=true
    fi
    if [ "$need_deps" = true ]; then
        return 1
    fi
    echo -e "${GREEN}✓ All dependencies found${NC}"
    return 0
}

ignore_docker_config() {
   if [[ "$IGNORE_DOCKER_CONFIG" == "true" ]] || [[ "$IGNORE_DOCKER_CONFIG" == "1" ]]; then
        export DOCKER_CONFIG=/tmp/docker-test-config
        mkdir -p "$DOCKER_CONFIG"
        echo '{"auths":{}}' > "$DOCKER_CONFIG/config.json"
        echo -e "${YELLOW}Using temporary Docker config: ${DOCKER_CONFIG}/config.json${NC}"
   fi
}

setup_test_workspace() {
    local devcontainer_dir="$TEST_WORKSPACE/.devcontainer"
    
    echo -e "${YELLOW}Setting up test workspace...${NC}"
    
    # Clean up if it already exists
    rm -rf "$TEST_WORKSPACE"
    mkdir -p "$devcontainer_dir"
    
    # Write devcontainer.json
    cat > "$devcontainer_dir/devcontainer.json" <<EOF
{
  "image": "mcr.microsoft.com/devcontainers/base:alpine",
  "features": {
    "./${FEATURE_NAME}": {}
  }
}
EOF
    
    # Validate JSON
    if ! jq empty "$devcontainer_dir/devcontainer.json" 2>/dev/null; then
        echo -e "${RED}✗ Error: Invalid JSON in devcontainer.json${NC}"
        return 1
    fi
    
    # Copy feature source
    # Run from dir of current test script so relative paths work
    cd "$(dirname "$0")"
    
    # Set default feature path if not provided
    if [ -z "$FEATURE_SRC_PATH" ]; then
        FEATURE_SRC_PATH="../src/${FEATURE_NAME}"
    fi
    
    if [ ! -d "$FEATURE_SRC_PATH" ]; then
        echo -e "${RED}✗ Error: Feature source not found at $FEATURE_SRC_PATH${NC}"
        return 1
    fi
    
    cp -r "$FEATURE_SRC_PATH" "$devcontainer_dir/"
    
    echo -e "${GREEN}✓ Created test workspace at $TEST_WORKSPACE${NC}"
    echo -e "${GREEN}✓ Created devcontainer.json${NC}"
    echo -e "${GREEN}✓ Copied feature from $FEATURE_SRC_PATH${NC}"
    
    if [ "$VERBOSE" = true ]; then
        echo ""
        echo "devcontainer.json contents:"
        cat "$devcontainer_dir/devcontainer.json"
        echo ""
    fi
    
    return 0
}

build_devcontainer() {
    local workspace_folder="$1"
    local id_label="dc-test-build-$(date +%s)-$$"
    
    echo ""
    echo -e "${YELLOW}Running devcontainer build...${NC}"
    echo "Workspace: $workspace_folder"
    echo "Image label: $id_label"
    echo ""
    
    # Disable exit on error temporarily
    set +e
    
    # Capture build output and exit code
    BUILD_OUTPUT=$(devcontainer build --no-cache --image-name "$id_label" --workspace-folder "$workspace_folder" 2>&1)
    BUILD_EXIT_CODE=$?
    
    # Re-enable exit on error
    set -e
    
    # Show output if verbose or if build failed
    if [ "$VERBOSE" = true ] || [ $BUILD_EXIT_CODE -ne 0 ]; then
        echo "Build output:"
        echo "----------------------------------------"
        echo "$BUILD_OUTPUT"
        echo "----------------------------------------"
        echo ""
    fi
    
    # Clean up container image
    echo -e "${YELLOW}Cleaning up test image...${NC}"
    if docker rmi -f "$id_label" 2>/dev/null; then
        echo -e "${GREEN}✓ Image removed${NC}"
    else
        echo -e "${YELLOW}Note: Image cleanup skipped (may not exist)${NC}"
    fi
    
    return $BUILD_EXIT_CODE
}

run_test() {
    local test_name="$1"
    local exit_code="$2"
    local output="$3"
    local expected_exit_code="$4"
    local expected_message="$5"
    
    echo ""
    echo "========================================="
    echo "Test: $test_name"
    echo "========================================="
    
    local test_result=""
    local passed=false
    
    # Check exit code expectation
    if [ "$expected_exit_code" -eq 0 ]; then
        # Expecting success
        if [ "$exit_code" -eq 0 ]; then
            echo -e "${GREEN}✓ Build succeeded as expected (exit code: $exit_code)${NC}"
            test_result="expected_success"
            passed=true
        else
            echo -e "${RED}✗ Build should have succeeded but failed (exit code: $exit_code)${NC}"
            echo ""
            echo "Build output:"
            echo "$output"
            test_result="unexpected_fail"
        fi
    else
        # Expecting failure
        if [ "$exit_code" -eq 0 ]; then
            echo -e "${RED}✗ Build should have failed but succeeded${NC}"
            test_result="unexpected_success"
        else
            echo -e "${GREEN}✓ Build failed as expected (exit code: $exit_code)${NC}"
            
            # Check error message if provided
            if [ -n "$expected_message" ]; then
                if echo "$output" | grep -q "$expected_message"; then
                    echo -e "${GREEN}✓ Expected error message found: '$expected_message'${NC}"
                    test_result="expected_fail_correct_message"
                    passed=true
                else
                    echo -e "${RED}✗ Expected error message not found${NC}"
                    echo "Expected substring: '$expected_message'"
                    echo ""
                    echo "Actual output:"
                    echo "$output"
                    test_result="expected_fail_wrong_message"
                fi
            else
                # No specific message to check, just that it failed
                test_result="expected_fail"
                passed=true
            fi
        fi
    fi
    
    # Update counters
    ((TOTAL_TESTS++))
    if [ "$passed" = true ]; then
        ((PASSED_TESTS++))
        echo -e "${GREEN}✓ TEST PASSED${NC}"
    else
        ((FAILED_TESTS++))
        echo -e "${RED}✗ TEST FAILED${NC}"
    fi
    
    # Store result
    TEST_RESULTS+=("$test_name|$test_result|$passed")
    
    echo ""
}

print_summary() {
    echo ""
    echo "========================================="
    echo "TEST SUMMARY"
    echo "========================================="
    echo "Total Tests: $TOTAL_TESTS"
    echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
    echo -e "${RED}Failed: $FAILED_TESTS${NC}"
    echo ""
    
    if [ ${#TEST_RESULTS[@]} -gt 0 ]; then
        echo "Detailed Results:"
        echo "-----------------------------------------"
        printf "%-40s %s\n" "Test Name" "Result"
        echo "-----------------------------------------"
        
        for result in "${TEST_RESULTS[@]}"; do
            IFS='|' read -r name status passed <<< "$result"
            if [ "$passed" = "true" ]; then
                printf "${GREEN}✓${NC} %-38s ${GREEN}%s${NC}\n" "$name" "$status"
            else
                printf "${RED}✗${NC} %-38s ${RED}%s${NC}\n" "$name" "$status"
            fi
        done
    fi
    
    echo "========================================="
    echo ""
    
    # Return exit code based on results
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}Some tests failed.${NC}"
        return 1
    fi
}

cleanup() {
    if [ -d "$TEST_WORKSPACE" ]; then
        echo -e "${YELLOW}Cleaning up test workspace...${NC}"
        rm -rf "$TEST_WORKSPACE"
    fi
}

main() {
    # Parse command line arguments
    parse_arguments "$@"
    
    # Check dependencies
    check_dependencies || exit 1
    
    # Setup Docker config if requested
    ignore_docker_config
    
    # Setup trap for cleanup
    trap cleanup EXIT
    
    # Setup test workspace
    setup_test_workspace || exit 1
    
    # Build the devcontainer
    build_devcontainer "$TEST_WORKSPACE"
    local build_exit_code=$?
    
    # Run the test
    run_test \
        "Feature: $FEATURE_NAME" \
        "$build_exit_code" \
        "$BUILD_OUTPUT" \
        "$EXPECTED_EXIT_CODE" \
        "$EXPECTED_MESSAGE"
    
    # Print summary and exit with appropriate code
    print_summary
    exit $?
}

# Run main function
main "$@"
