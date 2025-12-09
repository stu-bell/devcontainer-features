#!/bin/bash
#
# Tests devcontainer.json configurations to verify they build successfully or fail
# with expected error messages.
# 
#
# test/test-builds.sh -s test/scenarios.json --blank-docker-config



# TODO after all tests are complete, display a summary of: test name, test result, build result, if the expected output was found, the expeted output being searched for if it was not found.
# TODO option to provide a list of one or more scenario names to run. Other scenarios in the json should be skipped for this run.
# TODO when loading scenarios.json, ensure that there are no objects in the array with matching name keys, error if so
# TODO add optional scenario description to scenarios.json, to print alongside tests that fail, if the description is provided
# TODO add option to generate template scenarios.json, which just outputs a starter scenarios.json  that the user can save to a file and fill in. 
# TODO if scenarios.json param is blank, or resolves to a non existant, or invalid file, output a message explaining where the file should be and give an example of how it should look. If we've included the option to generate a blank scenarios.json, provide the command to do that
# TODO change expected message on  scenarios to expected output, which should be tested for in the output regardless of build success or failure, since we may want to test for an expected output message in a successful build. only test if the expeced_output  key is present and not a blank string. 
# TODO pass grep options for testing expected output
# TODO include a test-script property on each scenario which includes a path to a test script for that scenario. Multiple scenarios might share the same test. Script should exit 0 to pass, 1 to fail
# TODO accept an array of expected output strings to test for, all should be present
# TODO accept non-local features (current behaviour is to treat feature as a local path and copy the folder)
#

show_help() {
  echo "Usage: $(basename "$0") [OPTIONS]"
  echo ""
  echo "Tests a devcontainer.json configuration by building it and verifying the result."
  echo ""
  echo "Options:"
  echo "  -s, --scenarios-file <path>      Path to a JSON file containing multiple test scenarios"
  echo "  -g, --generate-sample            Output sample scenarios.json"
  echo "  --test-workspace-path <path>     Test workspace path (default: /tmp/devcontainer_test_builds)"
  echo "  --quiet                          Suppress build outputs unless a test fails"
  echo "  --blank-docker-config            Use a blank Docker configuration: {"auths":{}}"
  echo "  -h, --help                       Show this help message"
  echo ""
  echo "Examples:"
  echo "  # Test scenarios in test/scenarios.json"
  echo "  $(basename "$0") --scenarios-file test/scenarios.json"
  echo ""
  echo "  # Generate a sample scenarios.json"
  echo "  $(basename "$0") --generate-sample"
  echo ""
}

# Help string produced with --generate-sample
sample_json=$(cat << 'EOF'
[
  {
    "name": "Demo build success",
    "expected_exit_code": 0,
    "expected_output": "",
    "devcontainer": {
      "image": "mcr.microsoft.com/devcontainers/base:alpine",
      "features": {
        "../src/hello": {}
      }
    }
  },
  {
    "name": "Demo build error",
    "expected_exit_code": 1,
    "expected_output": "demonstrate a build error",
    "devcontainer": {
      "image": "mcr.microsoft.com/devcontainers/base:alpine",
      "features": {
        "../src/hello": {
          "forceBuildError": true
        }
      }
    }
  }
]
EOF
)

set -e

# Default values
IGNORE_DOCKER_CONFIG=${IGNORE_DOCKER_CONFIG:-false}
TEST_WORKSPACE=${TEST_WORKSPACE:-"/tmp/devcontainer_test_builds"}
SCENARIOS_FILE=${SCENARIOS_FILE:-""}
VERBOSE=${VERBOSE:-true}
GENERATE_SAMPLE=${GENERATE_SAMPLE:-false}

# Test tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
declare -a TEST_RESULTS=()

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
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
      --test-workspace-path)
        TEST_WORKSPACE="$2"
        if [ -z "$TEST_WORKSPACE" ]; then
          echored "Error: --test-workspace-path requires a value." >&2
          exit 1
        fi
        shift 2
        ;;
      -s|--scenarios-file)
        SCENARIOS_FILE="$2"
        if [ -z "$SCENARIOS_FILE" ]; then
          echored "Error: --scenarios-file requires a value." >&2
          exit 1
        fi
        shift 2
        ;;
      --quiet)
        VERBOSE=false
        shift
        ;;
      -g|--generate-sample)
        GENERATE_SAMPLE=true
        shift
        ;;
      --blank-docker-config)
        IGNORE_DOCKER_CONFIG=true
        shift
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
    local scenarios_content
    scenarios_content=$(jq -c '.' "$scenarios_file")
    if [ $? -ne 0 ]; then
        echored "Error: Invalid JSON in scenarios file: $scenarios_file" >&2
        return 1
    fi
    echo "$scenarios_content" # Echo the content to stdout
    echogrn "✓ Scenarios loaded successfully." >&2
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
    local devcontainer_json_content="$1"
    local scenarios_file="$2"
    local devcontainer_dir="$TEST_WORKSPACE/.devcontainer"
    
    echoyel "Setting up test workspace..."
    
    # Clean up if it already exists
    rm -rf "$TEST_WORKSPACE"
    mkdir -p "$devcontainer_dir"
    
    # Get the directory of the scenarios file to resolve relative paths
    local scenarios_dir
    scenarios_dir=$(dirname "$scenarios_file")

    # Read feature paths and copy them over
    local feature_paths
    feature_paths=$(echo "$devcontainer_json_content" | jq -r '.features | keys[]' 2>/dev/null)
    if [ -n "$feature_paths" ]; then
        local modified_json_content="$devcontainer_json_content"
        
        # Loop over each feature path
        for feature_path in $feature_paths; do
            # Resolve the real path of the feature source
            local real_feature_path
            real_feature_path=$(realpath "$scenarios_dir/$feature_path")
            
            if [ ! -d "$real_feature_path" ]; then
                echored "✗ Error: Feature source not found for '$feature_path' (resolved to '$real_feature_path')" >&2
                return 1
            fi
            
            # Copy feature source to the temp .devcontainer folder
            cp -r "$real_feature_path" "$devcontainer_dir/"
            
            # Get the feature's directory name and update the json
            # in the devcontainer json provided by scenarios.json, the feature path is relative to the scenarios.json file
            # in the devcontainer.json of the temporary workspace, we need the feature path to be relative to the 
            # copy of the feature in the temp workspace
            local feature_name
            feature_name=$(basename "$real_feature_path")
            local new_feature_path="./$feature_name"
            
            modified_json_content=$(echo "$modified_json_content" | jq --arg old "$feature_path" --arg new "$new_feature_path" '(.features[$new] = .features[$old]) | del(.features[$old])')
            echogrn "✓ Copied feature from '$feature_path' and updated path to '$new_feature_path'"
        done
        devcontainer_json_content="$modified_json_content"
    fi

    # Write the (potentially modified) devcontainer.json
    echo "$devcontainer_json_content" > "$devcontainer_dir/devcontainer.json"
    
    # Validate JSON
    if ! jq empty "$devcontainer_dir/devcontainer.json" 2>/dev/null; then
        echored "✗ Error: Invalid JSON in devcontainer.json" >&2
        return 1
    fi
    
    echogrn "✓ Created test workspace at $TEST_WORKSPACE"
    echogrn "✓ Created devcontainer.json"
    
    if [ "$VERBOSE" = true ]; then
        echo ""
        echoyel "devcontainer.json contents:"
        cat "$devcontainer_dir/devcontainer.json"
        echo ""
    fi
    
    return 0
}

build_devcontainer() {
    local workspace_folder="$1"
    local id_label="dc-test-build-$(date +%s)-$$"
    
    echo ""
    echo "Workspace: $workspace_folder"
    echo "Image label: $id_label"
    echo ""
    echoyel "Running devcontainer build..."
    
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
    local expected_output="$5" # Renamed from expected_message
    
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
            passed=true # Assume passed for now, will check output next
        fi
    fi

    # Check for expected output if provided
    if [ -n "$expected_output" ]; then
        if echo "$output" | grep -q "$expected_output"; then
            echogrn "✓ Expected output found: '$expected_output'"
            if [ "$passed" = true ]; then
                test_result="expected_success_and_output" # or expected_fail_and_output
            else
                test_result="expected_output_found_but_exit_code_mismatch"
                passed=false
            fi
        else
            echored "✗ Expected output NOT found: '$expected_output'" >&2
            echo "Expected substring: '$expected_output'"
            echo ""
            echo "Actual output:"
            echo "$output"
            test_result="expected_output_not_found"
            passed=false
        fi
    else
        if [ "$passed" = true ]; then
            test_result="no_specific_output_expected_and_passed"
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
    local load_scenarios_exit_code=$?
    if [ $load_scenarios_exit_code -ne 0 ]; then
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

        EXPECTED_EXIT_CODE=$(echo "$SCENARIO" | jq -r '.expected_exit_code // 0')
        EXPECTED_MESSAGE=$(echo "$SCENARIO" | jq -r '.expected_output // ""')
        DEVCONTAINER_JSON_CONTENT=$(echo "$SCENARIO" | jq -c '.devcontainer // {}')
        local TEST_NAME="Scenario: $(echo "$SCENARIO" | jq -r '.name // "Unnamed Scenario"')"
        
        echo ""
        echo "*****************************************"
        echo "Running $TEST_NAME"
        echo "*****************************************"
        
        # Setup test workspace for each scenario
        local setup_output
        setup_output=$(setup_test_workspace "$DEVCONTAINER_JSON_CONTENT" "$scenarios_file" 2>&1)
        if [ $? -ne 0 ]; then
            run_test \
                "$TEST_NAME" \
                "1" \
                "$setup_output" \
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
        echoyel "Done"
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

    # sample scnearios.json
    if $GENERATE_SAMPLE ; then
        echo "$sample_json"
        exit 0
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
    
    if [ -z "$SCENARIOS_FILE" ]; then
        echored "Error: --scenarios-file is a required argument." >&2
        exit 1
    fi

    run_scenarios "$SCENARIOS_FILE"
    
    # Print summary and exit with appropriate code
    print_summary
    local summary_exit_code=$?
    set -e
    exit $summary_exit_code
}

# Run main function
main "$@"

