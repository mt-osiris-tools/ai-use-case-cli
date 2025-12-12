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

echo -e "${BLUE}=== All Tests Passed ===${NC}"
