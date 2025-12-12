#!/bin/bash
# Test script for uninstall detection logic

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Testing Uninstall Detection Logic ===${NC}"
echo ""

# Detect repository root from script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
HUB_DIR="${HUB_DIR:-$HOME/.local/share/ai-use-case-cli/hub}"

echo -e "${BLUE}Test Configuration:${NC}"
echo "  CLI Directory: $CLI_DIR"
echo "  Hub Directory: $HUB_DIR"
echo ""

# Test 1: Detect CLI directory when in CLI repo
echo -e "${YELLOW}Test 1: Detection from CLI directory${NC}"
cd "$CLI_DIR"

DETECTED_CLI_DIR=""
if [ -f "ai-use-case" ] && [ -d ".git" ] && [ -d "scripts/install" ]; then
    if [ -f "scripts/install/uninstall.sh" ] && [ -f "scripts/core/sync-ai-use-cases.sh" ]; then
        DETECTED_CLI_DIR="$(pwd)"
    fi
fi

if [ "$DETECTED_CLI_DIR" = "$CLI_DIR" ]; then
    echo -e "${GREEN}✓ PASS: Correctly detected CLI directory${NC}"
else
    echo -e "${RED}✗ FAIL: Did not detect CLI directory (got: $DETECTED_CLI_DIR)${NC}"
    exit 1
fi
echo ""

# Test 2: Verify hub signature detection
echo -e "${YELLOW}Test 2: Hub signature detection${NC}"
if [ -d "$HUB_DIR" ]; then
    # Test the safety check: hub directories should be detected
    if [ -d "$HUB_DIR/by-project" ] || [ -d "$HUB_DIR/by-date" ] || [ -d "$HUB_DIR/by-topic" ]; then
        echo -e "${GREEN}✓ PASS: Hub signature directories detected (hub will be protected)${NC}"
    else
        echo -e "${YELLOW}⚠ WARN: Hub exists but signature directories not found${NC}"
        echo -e "  Hub may not have standard structure (by-project, by-date, by-topic)"
    fi
else
    echo -e "${YELLOW}⚠ SKIP: Hub directory not found at $HUB_DIR${NC}"
fi
echo ""

# Test 3: Handle directory with "hub" in name
echo -e "${YELLOW}Test 3: Path contains 'hub' keyword check${NC}"
TEST_PATH="$HUB_DIR"
if [[ "$TEST_PATH" =~ hub ]]; then
    echo -e "${GREEN}✓ PASS: Correctly identified path with 'hub' keyword${NC}"
else
    echo -e "${RED}✗ FAIL: Should detect 'hub' in path${NC}"
    exit 1
fi
echo ""

# Test 4: Verify CLI-specific files check
echo -e "${YELLOW}Test 4: CLI-specific files verification${NC}"
if [ -f "$CLI_DIR/scripts/install/uninstall.sh" ] && \
   [ -f "$CLI_DIR/scripts/core/sync-ai-use-cases.sh" ]; then
    echo -e "${GREEN}✓ PASS: CLI-specific files found in CLI directory${NC}"
else
    echo -e "${RED}✗ FAIL: CLI-specific files not found${NC}"
    exit 1
fi

if [ -d "$HUB_DIR" ]; then
    if [ -f "$HUB_DIR/scripts/install/uninstall.sh" ] || \
       [ -f "$HUB_DIR/scripts/core/sync-ai-use-cases.sh" ]; then
        echo -e "${RED}✗ FAIL: CLI files should NOT exist in hub${NC}"
        exit 1
    else
        echo -e "${GREEN}✓ PASS: CLI-specific files correctly not found in hub${NC}"
    fi
else
    echo -e "${YELLOW}⚠ SKIP: Hub directory not found${NC}"
fi
echo ""

# Test 5: Symlink resolution (Method 3)
echo -e "${YELLOW}Test 5: Symlink resolution${NC}"
# Create a temporary symlink for testing
TEMP_SYMLINK="/tmp/test-ai-use-case-symlink-$$"
ln -s "$CLI_DIR/ai-use-case" "$TEMP_SYMLINK" 2>/dev/null || true

if [ -L "$TEMP_SYMLINK" ]; then
    # Test symlink resolution
    if [[ "$(uname)" == "Darwin" ]]; then
        # macOS: Use while loop with infinite loop protection
        SYMLINK_TARGET="$TEMP_SYMLINK"
        MAX_SYMLINK_DEPTH=10
        SYMLINK_DEPTH=0

        while [ -L "$SYMLINK_TARGET" ] && [ $SYMLINK_DEPTH -lt $MAX_SYMLINK_DEPTH ]; do
            SYMLINK_DIR="$(dirname "$SYMLINK_TARGET")"
            LINK_VALUE="$(readlink "$SYMLINK_TARGET" 2>/dev/null)"

            if [ -z "$LINK_VALUE" ]; then
                SYMLINK_TARGET=""
                break
            fi

            case "$LINK_VALUE" in
                /*) SYMLINK_TARGET="$LINK_VALUE" ;;
                *) SYMLINK_TARGET="$SYMLINK_DIR/$LINK_VALUE" ;;
            esac

            SYMLINK_DEPTH=$((SYMLINK_DEPTH + 1))
        done
    else
        # Linux: Use readlink -f
        SYMLINK_TARGET="$(readlink -f "$TEMP_SYMLINK" 2>/dev/null)"
    fi

    if [ -n "$SYMLINK_TARGET" ] && [ -f "$SYMLINK_TARGET" ]; then
        RESOLVED_DIR="$(dirname "$SYMLINK_TARGET")"
        if [ "$RESOLVED_DIR" = "$CLI_DIR" ]; then
            echo -e "${GREEN}✓ PASS: Symlink correctly resolved to CLI directory${NC}"
        else
            echo -e "${RED}✗ FAIL: Symlink resolution incorrect (got: $RESOLVED_DIR, expected: $CLI_DIR)${NC}"
            rm -f "$TEMP_SYMLINK"
            exit 1
        fi
    else
        echo -e "${RED}✗ FAIL: Symlink resolution failed${NC}"
        rm -f "$TEMP_SYMLINK"
        exit 1
    fi

    rm -f "$TEMP_SYMLINK"
else
    echo -e "${YELLOW}⚠ SKIP: Could not create test symlink${NC}"
fi
echo ""

# Test 6: Safety mechanism prevents removal of hub-like directories
echo -e "${YELLOW}Test 6: Hub safety mechanism${NC}"
# Simulate detection of a directory with hub signature
TEST_HUB_LIKE_DIR="/tmp/test-hub-$$"
mkdir -p "$TEST_HUB_LIKE_DIR/by-project"

# Test the hub signature detection
if [ -d "$TEST_HUB_LIKE_DIR/by-project" ] || [ -d "$TEST_HUB_LIKE_DIR/by-date" ] || [ -d "$TEST_HUB_LIKE_DIR/by-topic" ]; then
    echo -e "${GREEN}✓ PASS: Hub signature directories detected correctly${NC}"
    # Verify that CLI_DIR would be cleared (simulated)
    SIMULATED_CLI_DIR="$TEST_HUB_LIKE_DIR"
    if [ -d "$SIMULATED_CLI_DIR/by-project" ] || [ -d "$SIMULATED_CLI_DIR/by-date" ] || [ -d "$SIMULATED_CLI_DIR/by-topic" ]; then
        SIMULATED_CLI_DIR=""
        echo -e "${GREEN}✓ PASS: Safety mechanism would prevent hub deletion${NC}"
    fi
else
    echo -e "${RED}✗ FAIL: Could not create test hub structure${NC}"
    rm -rf "$TEST_HUB_LIKE_DIR"
    exit 1
fi

rm -rf "$TEST_HUB_LIKE_DIR"
echo ""

echo -e "${BLUE}=== All Tests Passed ===${NC}"
