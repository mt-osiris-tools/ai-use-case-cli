#!/bin/bash
# Test script for uninstall detection logic

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Testing Uninstall Detection Logic ===${NC}"
echo ""

# Test 1: Detect CLI directory when in CLI repo
echo -e "${YELLOW}Test 1: Detection from CLI directory${NC}"
cd /home/james/Documents/Projects/ai/ai-use-case-cli

CLI_DIR=""
if [ -f "ai-use-case" ] && [ -d ".git" ] && [ -d "scripts/install" ]; then
    if [ -f "scripts/install/uninstall.sh" ] && [ -f "scripts/core/sync-ai-use-cases.sh" ]; then
        CLI_DIR="$(pwd)"
    fi
fi

if [ "$CLI_DIR" = "/home/james/Documents/Projects/ai/ai-use-case-cli" ]; then
    echo -e "${GREEN}✓ PASS: Correctly detected CLI directory${NC}"
else
    echo -e "${RED}✗ FAIL: Did not detect CLI directory (got: $CLI_DIR)${NC}"
fi
echo ""

# Test 2: Reject hub directory
echo -e "${YELLOW}Test 2: Safety check for hub directory${NC}"
cd /home/james/Documents/Projects/ai/ai-use-case-hub

CLI_DIR=""
if [ -f "ai-use-case" ] && [ -d ".git" ] && [ -d "scripts/install" ]; then
    if [ -f "scripts/install/uninstall.sh" ] && [ -f "scripts/core/sync-ai-use-cases.sh" ]; then
        CLI_DIR="$(pwd)"
    fi
fi

# Check safety mechanism
if [ -n "$CLI_DIR" ]; then
    if [ -d "$CLI_DIR/by-project" ] || [ -d "$CLI_DIR/by-date" ] || [ -d "$CLI_DIR/by-topic" ]; then
        CLI_DIR=""
        echo -e "${GREEN}✓ PASS: Safety check prevented hub detection${NC}"
    else
        echo -e "${RED}✗ FAIL: Safety check should have blocked this${NC}"
    fi
else
    echo -e "${GREEN}✓ PASS: Did not detect hub as CLI (correct)${NC}"
fi
echo ""

# Test 3: Handle directory with "hub" in name
echo -e "${YELLOW}Test 3: Path contains 'hub' keyword check${NC}"
TEST_PATH="/home/james/Documents/Projects/ai/ai-use-case-hub"
if [[ "$TEST_PATH" =~ hub ]]; then
    echo -e "${GREEN}✓ PASS: Correctly identified path with 'hub' keyword${NC}"
else
    echo -e "${RED}✗ FAIL: Should detect 'hub' in path${NC}"
fi
echo ""

# Test 4: Verify CLI-specific files check
echo -e "${YELLOW}Test 4: CLI-specific files verification${NC}"
if [ -f "/home/james/Documents/Projects/ai/ai-use-case-cli/scripts/install/uninstall.sh" ] && \
   [ -f "/home/james/Documents/Projects/ai/ai-use-case-cli/scripts/core/sync-ai-use-cases.sh" ]; then
    echo -e "${GREEN}✓ PASS: CLI-specific files found in CLI directory${NC}"
else
    echo -e "${RED}✗ FAIL: CLI-specific files not found${NC}"
fi

if [ -f "/home/james/Documents/Projects/ai/ai-use-case-hub/scripts/install/uninstall.sh" ] || \
   [ -f "/home/james/Documents/Projects/ai/ai-use-case-hub/scripts/core/sync-ai-use-cases.sh" ]; then
    echo -e "${RED}✗ FAIL: CLI files should NOT exist in hub${NC}"
else
    echo -e "${GREEN}✓ PASS: CLI-specific files correctly not found in hub${NC}"
fi
echo ""

echo -e "${BLUE}=== Test Complete ===${NC}"
