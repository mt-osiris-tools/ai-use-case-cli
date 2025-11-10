#!/bin/bash
# AI Use Case CLI - Version Consistency Validator
# Validates that version references are consistent across all documentation files
#
# Usage:
#   ./validate-versions.sh              # Check all versions
#   ./validate-versions.sh --fix        # Interactive fix mode
#   ./validate-versions.sh --unreleased # Allow unreleased version references

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

# Parse arguments
ALLOW_UNRELEASED=false
FIX_MODE=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --unreleased)
            ALLOW_UNRELEASED=true
            shift
            ;;
        --fix)
            FIX_MODE=true
            shift
            ;;
        --help|-h)
            cat <<EOF
${BLUE}AI Use Case CLI - Version Consistency Validator${NC}

${YELLOW}Usage:${NC}
  $0 [options]

${YELLOW}Options:${NC}
  --unreleased    Allow unreleased version references (e.g., v3.6.0 when current is v3.5.0)
  --fix           Interactive mode to fix version inconsistencies
  --help, -h      Show this help message

${YELLOW}Description:${NC}
  Validates that version references are consistent across all documentation files:
  - scripts/utils/version.sh (source of truth)
  - README.md (header and footer)
  - CHANGELOG.md (latest release)
  - docs/COMMANDS.md (feature version markers)
  - docs/CLAUDE.md (feature version markers and version history)

${YELLOW}Examples:${NC}
  $0                  # Validate all versions match
  $0 --unreleased     # Allow unreleased feature references (during development)
  $0 --fix            # Interactively fix inconsistencies

${YELLOW}Exit Codes:${NC}
  0 - All versions consistent
  1 - Version inconsistencies found
  2 - Critical error (missing files, etc.)
EOF
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown option '$1'${NC}"
            echo "Use --help for usage information"
            exit 2
            ;;
    esac
done

echo -e "${BLUE}=== AI Use Case CLI - Version Validator ===${NC}"
echo ""

# Track validation status
ERRORS=0
WARNINGS=0

# 1. Get source of truth version
echo -e "${CYAN}[1/6] Checking source of truth (scripts/utils/version.sh)...${NC}"
VERSION_FILE="$REPO_ROOT/scripts/utils/version.sh"
if [ ! -f "$VERSION_FILE" ]; then
    echo -e "${RED}✗ CRITICAL: version.sh not found at $VERSION_FILE${NC}"
    exit 2
fi

CURRENT_VERSION=$(grep "^export CLI_VERSION=" "$VERSION_FILE" | sed 's/export CLI_VERSION="\(.*\)"/\1/')
if [ -z "$CURRENT_VERSION" ]; then
    echo -e "${RED}✗ CRITICAL: Could not extract version from version.sh${NC}"
    exit 2
fi

echo -e "${GREEN}✓ Current version: ${CURRENT_VERSION}${NC}"
echo ""

# 2. Check README.md
echo -e "${CYAN}[2/6] Checking README.md...${NC}"
README_FILE="$REPO_ROOT/README.md"
if [ ! -f "$README_FILE" ]; then
    echo -e "${RED}✗ CRITICAL: README.md not found${NC}"
    exit 2
fi

# Check header version
README_HEADER_VERSION=$(grep -o '<strong>v[0-9]\+\.[0-9]\+\.[0-9]\+</strong>' "$README_FILE" | head -1 | sed 's/<[^>]*>//g' | sed 's/v//')
if [ "$README_HEADER_VERSION" != "$CURRENT_VERSION" ]; then
    echo -e "${RED}✗ README.md header version mismatch:${NC}"
    echo -e "  Expected: v${CURRENT_VERSION}"
    echo -e "  Found:    v${README_HEADER_VERSION}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ README.md header: v${README_HEADER_VERSION}${NC}"
fi

# Check footer version
README_FOOTER_VERSION=$(grep "^\*\*Version\*\*:" "$README_FILE" | sed 's/\*\*Version\*\*: //')
if [ "$README_FOOTER_VERSION" != "$CURRENT_VERSION" ]; then
    echo -e "${RED}✗ README.md footer version mismatch:${NC}"
    echo -e "  Expected: ${CURRENT_VERSION}"
    echo -e "  Found:    ${README_FOOTER_VERSION}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ README.md footer: ${README_FOOTER_VERSION}${NC}"
fi

echo ""

# 3. Check CHANGELOG.md
echo -e "${CYAN}[3/6] Checking CHANGELOG.md...${NC}"
CHANGELOG_FILE="$REPO_ROOT/CHANGELOG.md"
if [ ! -f "$CHANGELOG_FILE" ]; then
    echo -e "${RED}✗ CRITICAL: CHANGELOG.md not found${NC}"
    exit 2
fi

# Get latest released version from CHANGELOG
CHANGELOG_VERSION=$(grep "^## \[" "$CHANGELOG_FILE" | grep -v "\[Unreleased\]" | head -1 | sed 's/## \[\([0-9]\+\.[0-9]\+\.[0-9]\+\)\].*/\1/')
if [ "$CHANGELOG_VERSION" != "$CURRENT_VERSION" ]; then
    echo -e "${YELLOW}⚠ CHANGELOG.md latest release differs:${NC}"
    echo -e "  Current version: ${CURRENT_VERSION}"
    echo -e "  Latest CHANGELOG release: ${CHANGELOG_VERSION}"

    if [ "$ALLOW_UNRELEASED" = true ]; then
        echo -e "${CYAN}  → Allowed (--unreleased mode): version ${CURRENT_VERSION} may be unreleased${NC}"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "${RED}  → This indicates version.sh was bumped but CHANGELOG wasn't updated${NC}"
        echo -e "${YELLOW}  → Run with --unreleased if this is intentional (during development)${NC}"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "${GREEN}✓ CHANGELOG.md latest release: ${CHANGELOG_VERSION}${NC}"
fi

echo ""

# 4. Check docs/COMMANDS.md for unreleased version references
echo -e "${CYAN}[4/6] Checking docs/COMMANDS.md...${NC}"
COMMANDS_FILE="$REPO_ROOT/docs/COMMANDS.md"
if [ ! -f "$COMMANDS_FILE" ]; then
    echo -e "${YELLOW}⚠ docs/COMMANDS.md not found (skipping)${NC}"
    WARNINGS=$((WARNINGS + 1))
else
    # Find version references like "v3.6.0+" or "(v3.6.0+)"
    COMMANDS_VERSIONS=$(grep -oE '\(v[0-9]+\.[0-9]+\.[0-9]+\+\)' "$COMMANDS_FILE" | sed 's/[()v+]//g' | sort -u)

    if [ -n "$COMMANDS_VERSIONS" ]; then
        echo -e "  Found version references:"
        FOUND_FUTURE_VERSION=false
        while IFS= read -r ver; do
            # Compare versions
            if [ "$(printf '%s\n' "$CURRENT_VERSION" "$ver" | sort -V | head -1)" != "$ver" ]; then
                echo -e "    ${RED}✗ v${ver}+ (future version, current is v${CURRENT_VERSION})${NC}"
                if [ "$ALLOW_UNRELEASED" = false ]; then
                    ERRORS=$((ERRORS + 1))
                    FOUND_FUTURE_VERSION=true
                fi
            else
                echo -e "    ${GREEN}✓ v${ver}+${NC}"
            fi
        done <<< "$COMMANDS_VERSIONS"

        if [ "$FOUND_FUTURE_VERSION" = true ] && [ "$ALLOW_UNRELEASED" = true ]; then
            echo -e "${CYAN}  → Allowed (--unreleased mode)${NC}"
        fi
    else
        echo -e "${GREEN}✓ No version references found${NC}"
    fi
fi

echo ""

# 5. Check docs/CLAUDE.md
echo -e "${CYAN}[5/6] Checking docs/CLAUDE.md...${NC}"
CLAUDE_FILE="$REPO_ROOT/docs/CLAUDE.md"
if [ ! -f "$CLAUDE_FILE" ]; then
    echo -e "${YELLOW}⚠ docs/CLAUDE.md not found (skipping)${NC}"
    WARNINGS=$((WARNINGS + 1))
else
    # Find version references in feature markers
    CLAUDE_VERSIONS=$(grep -oE '\(v[0-9]+\.[0-9]+\.[0-9]+\+\)' "$CLAUDE_FILE" | sed 's/[()v+]//g' | sort -u)

    if [ -n "$CLAUDE_VERSIONS" ]; then
        echo -e "  Found feature version references:"
        FOUND_FUTURE_VERSION=false
        while IFS= read -r ver; do
            if [ "$(printf '%s\n' "$CURRENT_VERSION" "$ver" | sort -V | head -1)" != "$ver" ]; then
                echo -e "    ${RED}✗ v${ver}+ (future version, current is v${CURRENT_VERSION})${NC}"
                if [ "$ALLOW_UNRELEASED" = false ]; then
                    ERRORS=$((ERRORS + 1))
                    FOUND_FUTURE_VERSION=true
                fi
            else
                echo -e "    ${GREEN}✓ v${ver}+${NC}"
            fi
        done <<< "$CLAUDE_VERSIONS"

        if [ "$FOUND_FUTURE_VERSION" = true ] && [ "$ALLOW_UNRELEASED" = true ]; then
            echo -e "${CYAN}  → Allowed (--unreleased mode)${NC}"
        fi
    fi

    # Check version history section
    echo -e "  Checking version history..."
    if grep -q "## Version History" "$CLAUDE_FILE"; then
        HISTORY_LATEST=$(grep -A1 "## Version History" "$CLAUDE_FILE" | grep "^- \*\*v" | head -1 | sed 's/- \*\*v\([0-9.]*\)\*\*.*/\1/')
        if [ -n "$HISTORY_LATEST" ]; then
            # Check if latest version in history matches or is ahead of current
            if [ "$(printf '%s\n' "$CURRENT_VERSION" "$HISTORY_LATEST" | sort -V | tail -1)" = "$HISTORY_LATEST" ]; then
                echo -e "    ${GREEN}✓ Version history includes v${HISTORY_LATEST}${NC}"
            else
                echo -e "    ${YELLOW}⚠ Version history latest (v${HISTORY_LATEST}) is older than current (v${CURRENT_VERSION})${NC}"
                WARNINGS=$((WARNINGS + 1))
            fi
        fi
    fi
fi

echo ""

# 6. Summary
echo -e "${CYAN}[6/6] Validation Summary${NC}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "  Current version: ${GREEN}${CURRENT_VERSION}${NC}"
echo -e "  Errors:          ${RED}${ERRORS}${NC}"
echo -e "  Warnings:        ${YELLOW}${WARNINGS}${NC}"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All version references are consistent!${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ Validation passed with warnings${NC}"
    exit 0
else
    echo -e "${RED}✗ Version inconsistencies detected!${NC}"
    echo ""
    echo -e "${YELLOW}To fix:${NC}"
    echo -e "  1. Review the errors above"
    echo -e "  2. Update version references to match v${CURRENT_VERSION}"
    echo -e "  3. Or use: ai-use-case bump-version <new-version>"
    echo -e "  4. See: docs/VERSION-UPDATE-CHECKLIST.md"
    echo ""
    exit 1
fi
