#!/bin/bash
#
# Tests devcontainer.json configurations to verify they build successfully or fail
# with expected error messages.
# Currently tests a single scenario - designed to be extended to loop over multiple scenarios.
# test/test-builds.sh --scenarios-file test/scenarios.json --blank-docker-config

set -e
#
# TODO add verbose option, to display all output. Or make it verbose by default and add a quiet option to just show test results?
VERBOSE=true

# Default values
IGNORE_DOCKER_CONFIG=${IGNORE_DOCKER_CONFIG:-false}
FEATURE_NAME=${FEATURE_NAME:-"node"}
FEATURE_SRC_PATH=${FEATURE_SRC_PATH:-""}
TEST_WORKSPACE=${TEST_WORKSPACE:-"/tmp/devcontainer_test_builds"}
SCENARIOS_FILE=${SCENARIOS_FILE:-""}
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
  echo "  --feature-name, -f <name>        Feature name (default: node)"
  echo "  --feature-src-path <path>        Feature source path (default: ../src/FEATURE_NAME)"
  echo "  --test-workspace-path <path>     Test workspace path (default: /tmp/devcontainer_test_builds)"
  echo "  --scenarios-file <path>          Path to a JSON file containing multiple test scenarios"
  echo "  --expected-exit-code <code>      Expected exit code (default: 0)"
  echo "  --expected-message <message>     Expected error message (for failure tests)"
  echo "  --blank-docker-config            Use a blank Docker configuration: {"auths":{}}"
  echo "  -h, --help                       Show this help message"
  echo ""
  echo "Examples:"
  echo "  # Test a successful build"
  echo "  $(basename "$0") --feature-name node"
  echo ""
  echo "  # Test an expected failure"
  echo "  $(basename "$0") --feature-name node --expected-exit-code 1 --expected-message 'invalid version'"
}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
echored() {
    echo -e "${RED}$@${NC}"
}
echogrn() {
    echo -e "${GREEN}$@${NC}"
}
echoyel() {
    echo -e "${YELLOW}$@${NC}"
}



parse_arguments() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --blank-docker-config)
        IGNORE_DOCKER_CONFIG=true
        shift
        ;;
      --feature-name|-f)
        FEATURE_NAME="$2"
        if [ -z "$FEATURE_NAME" ]; then
          echored "Error: --feature-name requires a value." >&2
          exit 1
        fi
        shift 2
        ;;
      --feature-src-path)
        FEATURE_SRC_PATH="$2"
        if [ -z "$FEATURE_SRC_PATH" ]; then
          echored "Error: --feature-src-path requires a value." >&2
          exit 1
        fi
        shift 2
        ;;
      --test-workspace-path)
        TEST_WORKSPACE="$2"
        if [ -z "$TEST_WORKSPACE" ]; then
          echored "Error: --test-workspace-path requires a value." >&2
          exit 1
        fi
        shift 2
        ;;
      --scenarios-file)
        SCENARIOS_FILE="$2"
        if [ -z "$SCENARIOS_FILE" ]; then
          echored "Error: --scenarios-file requires a value." >&2
          exit 1
        fi
        shift 2
        ;;
      --expected-exit-code)
        EXPECTED_EXIT_CODE="$2"
        if [ -z "$EXPECTED_EXIT_CODE" ]; then
          echored "Error: --expected-exit-code requires a value." >&2
          exit 1
        fi
        shift 2
        ;;
      --expected-message)
        EXPECTED_MESSAGE="$2"
        shift 2
        ;;
      -h|--help)
        show_help
        exit 0
        ;;
      *)
        echored "Error: Unknown argument: $1" >&2
        echo "Use --help for usage information." >&2
        exit 1
        ;;
    esac
  done
}



check_dependencies() {
    local need_deps=""
    if ! command -v jq >/dev/null 2>&1; then
        need_deps="jq \nInstall: apt-get install jq  or  brew install jq"
    fi
    if ! command -v devcontainer >/dev/null 2>&1; then
        need_deps="devcontainer \nInstall: npm install -g @devcontainers/cli"
    fi
    if ! command -v docker >/dev/null 2>&1; then
        need_deps="Docker \nInstall: https://docker.com"
    fi
    if [ "$need_deps" != "" ]; then
        echored "Error: Dependency not found: ${need_deps}" >&2
        exit 1
    fi
    return 0
}

load_scenarios() {
    local scenarios_file="$1"

    if [ -z "$scenarios_file" ]; then
        echored "Error: No scenarios file provided." >&2
        return 1
    fi

    if [ ! -f "$scenarios_file" ]; then
        echored "Error: Scenarios file not found at $scenarios_file" >&2
        return 1
    fi

    echoyel "Loading scenarios from $scenarios_file..." >&2
    SCENARIOS=$(jq -c '.' "$scenarios_file")
    if [ $? -ne 0 ]; then
        echored "Error: Invalid JSON in scenarios file: $scenarios_file" >&2
        return 1
    fi
    echogrn "✓ Scenarios loaded successfully." >&2
    echo "$SCENARIOS" # Output the scenarios for main function to capture
    return 0
}

ignore_docker_config() {
   if [ "$IGNORE_DOCKER_CONFIG" = true ]; then
        export DOCKER_CONFIG=/tmp/docker-test-config
        mkdir -p "$DOCKER_CONFIG"
        echo '{"auths":{}}' > "$DOCKER_CONFIG/config.json"
        echoyel "Using temporary Docker config: ${DOCKER_CONFIG}/config.json"
   fi
}

setup_test_workspace() {
    local devcontainer_dir="$TEST_WORKSPACE/.devcontainer"
    
    echoyel "Setting up test workspace..."
    
    # Clean up if it already exists
    rm -rf "$TEST_WORKSPACE"
    mkdir -p "$devcontainer_dir"
    
    # Write devcontainer.json
    # TODO this devcontainer.json should be a node on each of the scenarios.json

# TODO feature should be relative to the scenarios.json file
# Try to resolve feature paths and if they're found relative to the scenarios.json dir, 
# copy the folder to the temp workspace folder. update the feature path in the devcontainer.json 
# to the new path relative to the temp .devcontainer folder 

    cat > "$devcontainer_dir/devcontainer.json" <<EOF
{
  "image": "mcr.microsoft.com/devcontainers/base:alpine",
  "features": {
    "./${FEATURE_NAME}": {}
  }
}
EOF
    
    # Validate JSON
# TODO review this jq condition
    if ! jq empty "$devcontainer_dir/devcontainer.json" 2>/dev/null; then
        echored "✗ Error: Invalid JSON in devcontainer.json" >&2
        return 1
    fi
    
    # Copy feature source
    # Set default feature path if not provided
    if [ -z "$FEATURE_SRC_PATH" ]; then
        FEATURE_SRC_PATH="src/${FEATURE_NAME}"
    fi
    
    if [ ! -d "$FEATURE_SRC_PATH" ]; then
        echored "✗ Error: Feature source not found at $FEATURE_SRC_PATH" >&2
        return 1
    fi
    
    cp -r "$FEATURE_SRC_PATH" "$devcontainer_dir/"
    
    echogrn "✓ Created test workspace at $TEST_WORKSPACE"
    echogrn "✓ Created devcontainer.json"
    echogrn "✓ Copied feature from $FEATURE_SRC_PATH"
    
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
    echoyel "Running devcontainer build..."
    echo "Workspace: $workspace_folder"
    echo "Image label: $id_label"
    echo ""
    
    # Capture build output and exit code
    BUILD_OUTPUT=$(devcontainer build --no-cache --image-name "$id_label" --workspace-folder "$workspace_folder" 2>&1)
    BUILD_EXIT_CODE=$?
    
    # Show output if verbose or if build failed
    if [ "$VERBOSE" = true ] || [ $BUILD_EXIT_CODE -ne 0 ]; then
        echo "Build output:"
        echo "----------------------------------------"
        echo "$BUILD_OUTPUT"
        echo "----------------------------------------"
        echo ""
    fi
    
    # Clean up container image
    echoyel "Cleaning up test image..."
    if docker rmi -f "$id_label" 2>/dev/null; then
        echogrn "✓ Image removed"
    else
        echoyel "Note: Image cleanup skipped (may not exist)"
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
            echogrn "✓ Build succeeded as expected (exit code: $exit_code)"
            test_result="expected_success"
            passed=true
        else
            echored "✗ Build should have succeeded but failed (exit code: $exit_code)" >&2
            echo ""
            echo "Build output:"
            echo "$output"
            test_result="unexpected_fail"
        fi
    else
        # Expecting failure
        if [ "$exit_code" -eq 0 ]; then
            echored "✗ Build should have failed but succeeded" >&2
            test_result="unexpected_success"
        else
            echogrn "✓ Build failed as expected (exit code: $exit_code)"
            
            # Check error message if provided
            if [ -n "$expected_message" ]; then
                if echo "$output" | grep -q "$expected_message"; then
                    echogrn "✓ Expected error message found: '$expected_message'"
                    test_result="expected_fail_correct_message"
                    passed=true
                else
                    echored "✗ Expected error message not found" >&2
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
        echogrn "✓ TEST PASSED"
    else
        ((FAILED_TESTS++))
        echored "✗ TEST FAILED" >&2
    fi
    
    # Store result
    TEST_RESULTS+=("$test_name|$test_result|$passed")
    
    echo ""
}

run_scenarios() {
    local scenarios_file="$1"

    # Load scenarios from the file
    local SCENARIOS_JSON
    SCENARIOS_JSON=$(load_scenarios "$scenarios_file")
    if [ $? -ne 0 ]; then
        exit 1
    fi

    # Get the number of scenarios
    local NUM_SCENARIOS
    NUM_SCENARIOS=$(echo "$SCENARIOS_JSON" | jq '. | length')
    if [ $? -ne 0 ]; then
        echored "✗ Error: Invalid JSON in scenarios file: $scenarios_file" >&2
        exit 1
    fi

    if [ "$NUM_SCENARIOS" -eq 0 ]; then
        echoyel "No scenarios found in $scenarios_file. Exiting."
        return 0
    fi

    for i in $(seq 0 $((NUM_SCENARIOS - 1))); do
        local SCENARIO
        SCENARIO=$(echo "$SCENARIOS_JSON" | jq -c ".[$i]")
        if [ $? -ne 0 ]; then
            echored "✗ Error: Invalid JSON in scenarios file: $scenarios_file" >&2
            exit 1
        fi

        # Extract values for the current scenario
        FEATURE_NAME=$(echo "$SCENARIO" | jq -r '.feature_name // ""')
        FEATURE_SRC_PATH=$(echo "$SCENARIO" | jq -r '.feature_src_path // ""')
        EXPECTED_EXIT_CODE=$(echo "$SCENARIO" | jq -r '.expected_exit_code // 0')
        EXPECTED_MESSAGE=$(echo "$SCENARIO" | jq -r '.expected_message // ""')
        local TEST_NAME="Scenario: $(echo "$SCENARIO" | jq -r '.name // "Unnamed Scenario"') (Feature: $FEATURE_NAME)"
        
        echo ""
        echo "*****************************************"
        echo "Running $TEST_NAME"
        echo "*****************************************"
        
        # Setup test workspace for each scenario
        if ! setup_test_workspace; then
            run_test \
                "$TEST_NAME" \
                "1" \
                "Workspace setup failed" \
                "$EXPECTED_EXIT_CODE" \
                "$EXPECTED_MESSAGE"
            continue
        fi
        
        # Build the devcontainer
        build_devcontainer "$TEST_WORKSPACE"
        local build_exit_code=$?
        
        # Run the test
        run_test \
            "$TEST_NAME" \
            "$build_exit_code" \
            "$BUILD_OUTPUT" \
            "$EXPECTED_EXIT_CODE" \
            "$EXPECTED_MESSAGE"
    done
}

print_summary() {
    echo ""
    echo "========================================="
    echo "TEST SUMMARY"
    echo "========================================="
    echo "Total Tests: $TOTAL_TESTS"
    echogrn "Passed: $PASSED_TESTS"
    echored "Failed: $FAILED_TESTS" >&2
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
        echogrn "All tests passed!"
        return 0
    else
        echored "Some tests failed." >&2
        return 1
    fi
}

cleanup() {
    if [ -d "$TEST_WORKSPACE" ]; then
        echoyel "Cleaning up test workspace..."
        rm -rf "$TEST_WORKSPACE"
    fi
}

main() {
    set +e
    # Parse command line arguments
    parse_arguments "$@"
    if [ $? -ne 0 ]; then
        echored "Error parsing arguments" >&2
        exit 1
    fi
    
    # Check dependencies
    check_dependencies
    if [ $? -ne 0 ]; then
        exit 1
    fi
    
    # Setup Docker config if requested
    ignore_docker_config
    
    # Setup trap for cleanup
    trap cleanup EXIT
    
    if [ -n "$SCENARIOS_FILE" ]; then
        run_scenarios "$SCENARIOS_FILE"
    else
    # TODO this shouldn't be here. scenarios file is required
        echoyel "No scenarios file provided. Running single test."
        # Run a single test using command-line arguments
        if ! setup_test_workspace; then
            run_test \
                "Feature: $FEATURE_NAME" \
                "1" \
                "Workspace setup failed" \
                "$EXPECTED_EXIT_CODE" \
                "$EXPECTED_MESSAGE"
            print_summary
            exit 1
        fi
        
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
    fi
    
    # Print summary and exit with appropriate code
    print_summary
    local summary_exit_code=$?
    set -e
    exit $summary_exit_code
}

# Run main function
main "$@"
