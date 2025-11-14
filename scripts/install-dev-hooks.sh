#!/bin/bash
# Install Development Git Hooks for ai-use-case-cli Repository
# This script installs git hooks specifically for developers working on the CLI tool itself
#
# Usage: ./scripts/install-dev-hooks.sh

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOKS_DIR="$REPO_ROOT/.git/hooks"

echo -e "${BLUE}=== Installing Development Git Hooks ===${NC}"
echo ""

# Check if we're in a git repository
if [ ! -d "$REPO_ROOT/.git" ]; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p "$HOOKS_DIR"

# Install version validation pre-commit hook
HOOK_FILE="$HOOKS_DIR/pre-commit"

echo -e "${YELLOW}Installing version validation hook...${NC}"

# Check if pre-commit hook already exists
if [ -f "$HOOK_FILE" ]; then
    echo -e "${YELLOW}⚠ Pre-commit hook already exists${NC}"

    # Check if it already has version validation
    if grep -q "validate-versions.sh" "$HOOK_FILE"; then
        echo -e "${GREEN}✓ Version validation already installed${NC}"
    else
        echo -e "${YELLOW}Adding version validation to existing hook...${NC}"

        # Backup existing hook
        cp "$HOOK_FILE" "$HOOK_FILE.backup"
        echo -e "${BLUE}Backed up existing hook to pre-commit.backup${NC}"

        # Add version validation before the final exit (platform-compatible)
        if [[ "$(uname)" == "Darwin" ]]; then
            # macOS (BSD sed)
            sed -i '' '/^exit 0$/i \
# Version validation for ai-use-case-cli repository\
if git diff --cached --name-only | grep -qE "(version\\.sh|README\\.md|CHANGELOG\\.md)"; then\
    echo "Validating version consistency..."\
    if ! ./scripts/utils/validate-versions.sh; then\
        echo ""\
        echo "❌ Version validation failed!"\
        echo "Fix version inconsistencies before committing."\
        echo "Or run: ai-use-case bump-version [major|minor|patch]"\
        exit 1\
    fi\
    echo "✓ Version validation passed"\
fi\
' "$HOOK_FILE"
        else
            # Linux (GNU sed)
            sed -i '/^exit 0$/i \
# Version validation for ai-use-case-cli repository\
if git diff --cached --name-only | grep -qE "(version\\.sh|README\\.md|CHANGELOG\\.md)"; then\
    echo "Validating version consistency..."\
    if ! ./scripts/utils/validate-versions.sh; then\
        echo ""\
        echo "❌ Version validation failed!"\
        echo "Fix version inconsistencies before committing."\
        echo "Or run: ai-use-case bump-version [major|minor|patch]"\
        exit 1\
    fi\
    echo "✓ Version validation passed"\
fi\
' "$HOOK_FILE"
        fi

        echo -e "${GREEN}✓ Version validation added to existing hook${NC}"
    fi
else
    # Create new pre-commit hook
    cat > "$HOOK_FILE" << 'EOF'
#!/bin/bash
# Git Pre-Commit Hook for ai-use-case-cli Repository
# Validates version consistency across all documentation files

# Version validation for ai-use-case-cli repository
if git diff --cached --name-only | grep -qE "(version\.sh|README\.md|CHANGELOG\.md)"; then
    echo "Validating version consistency..."
    if ! ./scripts/utils/validate-versions.sh; then
        echo ""
        echo "❌ Version validation failed!"
        echo "Fix version inconsistencies before committing."
        echo "Or run: ai-use-case bump-version [major|minor|patch]"
        exit 1
    fi
    echo "✓ Version validation passed"
fi

# Allow commit to proceed
exit 0
EOF

    chmod +x "$HOOK_FILE"
    echo -e "${GREEN}✓ Version validation hook installed${NC}"
fi

echo ""
echo -e "${GREEN}=== Installation Complete ===${NC}"
echo ""
echo -e "The following hooks are now active:"
echo -e "  ${BLUE}•${NC} Version validation (checks version.sh, README.md, CHANGELOG.md)"
echo ""
echo -e "${YELLOW}What this means:${NC}"
echo -e "  • Commits with version changes will be validated automatically"
echo -e "  • Prevents version inconsistencies from entering git history"
echo -e "  • Encourages use of: ai-use-case bump-version"
echo ""
echo -e "${YELLOW}To bypass validation (not recommended):${NC}"
echo -e "  git commit --no-verify"
echo ""
