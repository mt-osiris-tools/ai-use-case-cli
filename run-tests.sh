#!/bin/bash
# run-tests.sh - Test runner for AI Use Case CLI
#
# Usage:
#   ./run-tests.sh              # Run all tests
#   ./run-tests.sh version      # Run specific test file
#   ./run-tests.sh --verbose    # Run with verbose output
#   ./run-tests.sh --help       # Show help

set -euo pipefail

# Colors
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
RED=$'\033[0;31m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
NC=$'\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_DIR="${SCRIPT_DIR}/tests"
BATS_BIN="${TESTS_DIR}/bats/bats-core/bin/bats"

# Check if bats is available
check_bats() {
    if [ ! -x "$BATS_BIN" ]; then
        echo -e "${RED}Error: bats-core not found${NC}"
        echo ""
        echo "Initialize git submodules to install bats-core:"
        echo "  ${CYAN}git submodule update --init --recursive${NC}"
        exit 1
    fi
}

# Show help
show_help() {
    cat << EOF
${BLUE}AI Use Case CLI - Test Runner${NC}

${YELLOW}USAGE${NC}
  ./run-tests.sh [options] [test-file...]

${YELLOW}OPTIONS${NC}
  --help, -h        Show this help message
  --verbose, -v     Run tests with verbose output
  --tap             Output in TAP format
  --filter PATTERN  Only run tests matching PATTERN
  --list            List available test files
  --count           Show test count without running

${YELLOW}EXAMPLES${NC}
  ./run-tests.sh                    # Run all tests
  ./run-tests.sh version            # Run version.bats only
  ./run-tests.sh version config     # Run version.bats and config-manager.bats
  ./run-tests.sh --verbose          # Run all tests with verbose output
  ./run-tests.sh --filter "help"    # Run only tests containing "help"

${YELLOW}TEST FILES${NC}
EOF
    for test_file in "${TESTS_DIR}"/*.bats; do
        if [ -f "$test_file" ]; then
            local name
            name="$(basename "$test_file" .bats)"
            echo "  ${GREEN}${name}${NC}"
        fi
    done
    echo ""
    echo "${YELLOW}SETUP${NC}"
    echo "  If tests fail to run, ensure submodules are initialized:"
    echo "    ${CYAN}git submodule update --init --recursive${NC}"
}

# List available test files with counts
list_tests() {
    check_bats
    echo -e "${BLUE}Available test files:${NC}"
    echo ""
    for test_file in "${TESTS_DIR}"/*.bats; do
        if [ -f "$test_file" ]; then
            local name count
            name="$(basename "$test_file" .bats)"
            count=$("$BATS_BIN" --count "$test_file" 2>/dev/null || echo "?")
            printf "  ${GREEN}%-25s${NC} (%s tests)\n" "$name" "$count"
        fi
    done
}

# Count tests without running
count_tests() {
    check_bats
    local total=0

    for test_file in "${TESTS_DIR}"/*.bats; do
        if [ -f "$test_file" ]; then
            local count
            count=$("$BATS_BIN" --count "$test_file" 2>/dev/null || echo "0")
            total=$((total + count))
        fi
    done

    echo -e "${BLUE}Total tests: ${GREEN}${total}${NC}"
}

# Main
main() {
    local verbose=false
    local tap=false
    local filter=""
    local test_files=()

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                show_help
                exit 0
                ;;
            --verbose|-v)
                verbose=true
                shift
                ;;
            --tap)
                tap=true
                shift
                ;;
            --filter)
                filter="$2"
                shift 2
                ;;
            --list)
                list_tests
                exit 0
                ;;
            --count)
                count_tests
                exit 0
                ;;
            -*)
                echo -e "${RED}Error: Unknown option: $1${NC}"
                echo "Run './run-tests.sh --help' for usage"
                exit 1
                ;;
            *)
                # Treat as test file name (without .bats extension)
                test_files+=("$1")
                shift
                ;;
        esac
    done

    check_bats

    # Build bats arguments
    local bats_args=()

    if [ "$verbose" = true ]; then
        bats_args+=("--verbose-run")
    fi

    if [ "$tap" = true ]; then
        bats_args+=("--tap")
    fi

    if [ -n "$filter" ]; then
        bats_args+=("--filter" "$filter")
    fi

    # Determine which test files to run
    local files_to_run=()
    if [ ${#test_files[@]} -eq 0 ]; then
        # Run all tests
        for test_file in "${TESTS_DIR}"/*.bats; do
            if [ -f "$test_file" ]; then
                files_to_run+=("$test_file")
            fi
        done
    else
        # Run specified tests
        for name in "${test_files[@]}"; do
            local test_file="${TESTS_DIR}/${name}.bats"
            if [ -f "$test_file" ]; then
                files_to_run+=("$test_file")
            else
                echo -e "${RED}Error: Test file not found: ${name}.bats${NC}"
                exit 1
            fi
        done
    fi

    if [ ${#files_to_run[@]} -eq 0 ]; then
        echo -e "${YELLOW}No test files found in ${TESTS_DIR}${NC}"
        echo ""
        echo "Create test files with .bats extension in the tests/ directory."
        exit 0
    fi

    echo -e "${BLUE}=== AI Use Case CLI Test Suite ===${NC}"
    echo ""
    echo -e "Test files: ${CYAN}${#files_to_run[@]}${NC}"
    echo ""

    # Run tests
    "$BATS_BIN" "${bats_args[@]}" "${files_to_run[@]}"

    local exit_code=$?

    echo ""
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}All tests passed!${NC}"
    else
        echo -e "${RED}Some tests failed${NC}"
    fi

    exit $exit_code
}

main "$@"
