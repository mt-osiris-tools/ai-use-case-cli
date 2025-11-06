#!/bin/bash
# AI Use Case CLI - Automated Version Bump Script
# Automates the entire version update process: version.sh, CHANGELOG.md, commit, tag, push
#
# Usage:
#   ./bump-version.sh [major|minor|patch|X.Y.Z] [options]
#
# Examples:
#   ./bump-version.sh patch              # 3.2.0 -> 3.2.1
#   ./bump-version.sh minor              # 3.2.0 -> 3.3.0
#   ./bump-version.sh major              # 3.2.0 -> 4.0.0
#   ./bump-version.sh 3.5.0              # Set specific version
#   ./bump-version.sh patch --dry-run    # Preview changes without applying
#   ./bump-version.sh minor --no-push    # Bump and commit but don't push
#
# Options:
#   --dry-run         Preview changes without applying them
#   --no-commit       Update files but don't commit
#   --no-tag          Don't create git tag
#   --no-push         Don't push to remote
#   --yes, -y         Skip confirmations (useful for CI/CD)
#   --help, -h        Show this help message

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
VERSION_FILE="$SCRIPT_DIR/version.sh"
CHANGELOG_FILE="$CLI_ROOT/CHANGELOG.md"

# Parse options
DRY_RUN=false
NO_COMMIT=false
NO_TAG=false
NO_PUSH=false
SKIP_CONFIRMATION=false
BUMP_TYPE=""

show_help() {
    cat <<EOF
${BOLD}AI Use Case CLI - Automated Version Bump${NC}

${CYAN}Usage:${NC}
  $0 [major|minor|patch|X.Y.Z] [options]

${CYAN}Bump Types:${NC}
  major           Bump major version (X.0.0) - breaking changes
  minor           Bump minor version (0.X.0) - new features
  patch           Bump patch version (0.0.X) - bug fixes
  X.Y.Z           Set specific version number

${CYAN}Options:${NC}
  --dry-run       Preview changes without applying them
  --no-commit     Update files but don't commit
  --no-tag        Don't create git tag
  --no-push       Don't push to remote
  --yes, -y       Skip confirmations (useful for CI/CD)
  --help, -h      Show this help message

${CYAN}Examples:${NC}
  $0 patch                    # 3.2.0 -> 3.2.1
  $0 minor                    # 3.2.0 -> 3.3.0
  $0 major                    # 3.2.0 -> 4.0.0
  $0 3.5.0                    # Set to 3.5.0
  $0 patch --dry-run          # Preview patch bump
  $0 minor --no-push          # Bump and commit but don't push

${CYAN}What it does:${NC}
  1. Parses current version from version.sh
  2. Calculates new version based on bump type
  3. Updates version.sh with new version
  4. Updates CHANGELOG.md (moves Unreleased to versioned section)
  5. Creates git commit with conventional commit message
  6. Creates git tag (vX.Y.Z)
  7. Pushes commit and tag to remote

${CYAN}Workflow:${NC}
  • Must be run from a clean git working directory
  • Requires Unreleased section in CHANGELOG.md
  • Creates atomic commit with both version.sh and CHANGELOG.md
  • Tags commit for GitHub releases
  • Automatically pushes to remote on current branch (unless --no-push)

EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        major|minor|patch)
            BUMP_TYPE="$1"
            shift
            ;;
        [0-9]*.[0-9]*.[0-9]*)
            BUMP_TYPE="specific"
            NEW_VERSION="$1"
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --no-commit)
            NO_COMMIT=true
            shift
            ;;
        --no-tag)
            NO_TAG=true
            shift
            ;;
        --no-push)
            NO_PUSH=true
            shift
            ;;
        --yes|-y)
            SKIP_CONFIRMATION=true
            shift
            ;;
        --help|-h)
            show_help
            ;;
        *)
            echo -e "${RED}Error: Unknown argument '$1'${NC}"
            echo "Run with --help for usage information"
            exit 1
            ;;
    esac
done

# Validate bump type provided
if [ -z "$BUMP_TYPE" ]; then
    echo -e "${RED}Error: Bump type required${NC}"
    echo "Usage: $0 [major|minor|patch|X.Y.Z] [options]"
    echo "Run with --help for more information"
    exit 1
fi

echo -e "${BLUE}${BOLD}=== AI Use Case CLI Version Bump ===${NC}"
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    exit 1
fi

# Get current branch early for use in messages throughout the script
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Check for uncommitted changes
if [ "$DRY_RUN" = false ] && [ -n "$(git status --porcelain)" ]; then
    echo -e "${RED}Error: Working directory has uncommitted changes${NC}"
    echo "Please commit or stash changes before bumping version"
    git status --short
    exit 1
fi

# Check if version.sh exists
if [ ! -f "$VERSION_FILE" ]; then
    echo -e "${RED}Error: version.sh not found at $VERSION_FILE${NC}"
    exit 1
fi

# Check if CHANGELOG.md exists
if [ ! -f "$CHANGELOG_FILE" ]; then
    echo -e "${RED}Error: CHANGELOG.md not found at $CHANGELOG_FILE${NC}"
    exit 1
fi

# Parse current version from version.sh
CURRENT_VERSION=$(grep '^export CLI_VERSION=' "$VERSION_FILE" | cut -d'"' -f2)
if [ -z "$CURRENT_VERSION" ]; then
    echo -e "${RED}Error: Could not parse current version from version.sh${NC}"
    exit 1
fi

echo -e "${CYAN}Current version:${NC} $CURRENT_VERSION"

# Calculate new version
if [ "$BUMP_TYPE" = "specific" ]; then
    # Validate version format
    if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "${RED}Error: Invalid version format '$NEW_VERSION'${NC}"
        echo "Version must be in format X.Y.Z (e.g., 3.2.0)"
        exit 1
    fi
else
    # Parse current version components
    IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

    # Bump version based on type
    case $BUMP_TYPE in
        major)
            MAJOR=$((MAJOR + 1))
            MINOR=0
            PATCH=0
            ;;
        minor)
            MINOR=$((MINOR + 1))
            PATCH=0
            ;;
        patch)
            PATCH=$((PATCH + 1))
            ;;
    esac

    NEW_VERSION="$MAJOR.$MINOR.$PATCH"
fi

echo -e "${CYAN}New version:${NC}     ${GREEN}${BOLD}$NEW_VERSION${NC}"
echo ""

# Check if CHANGELOG has Unreleased section with content
if ! grep -q "## \[Unreleased\]" "$CHANGELOG_FILE"; then
    echo -e "${YELLOW}Warning: No [Unreleased] section found in CHANGELOG.md${NC}"
    echo "The version bump will still proceed, but you should add changelog entries."
    echo ""
fi

# Preview changes
echo -e "${BOLD}Changes to be made:${NC}"
echo -e "  ${CYAN}1.${NC} Update version.sh: CLI_VERSION=\"${CURRENT_VERSION}\" -> \"${NEW_VERSION}\""
echo -e "  ${CYAN}2.${NC} Update CHANGELOG.md: Move [Unreleased] to [${NEW_VERSION}] with date"
if [ "$NO_COMMIT" = false ]; then
    echo -e "  ${CYAN}3.${NC} Create git commit: 'chore: bump version to ${NEW_VERSION}'"
    if [ "$NO_TAG" = false ]; then
        echo -e "  ${CYAN}4.${NC} Create git tag: v${NEW_VERSION}"
    fi
    if [ "$NO_PUSH" = false ]; then
        echo -e "  ${CYAN}5.${NC} Push to remote: origin/${CURRENT_BRANCH} with tags"
    fi
fi
echo ""

# Dry run - stop here
if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}[DRY RUN]${NC} No changes applied. Run without --dry-run to apply changes."
    exit 0
fi

# Confirmation prompt
if [ "$SKIP_CONFIRMATION" = false ]; then
    read -p "$(echo -e ${CYAN}Proceed with version bump? [y/N]:${NC} )" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Version bump cancelled${NC}"
        exit 0
    fi
fi

echo -e "${BLUE}Applying changes...${NC}"
echo ""

# Step 1: Update version.sh
echo -e "${CYAN}[1/5]${NC} Updating version.sh..."
# Use portable sed approach (works on both macOS and Linux)
TEMP_VERSION_FILE=$(mktemp)
sed "s/^export CLI_VERSION=\".*\"/export CLI_VERSION=\"${NEW_VERSION}\"/" "$VERSION_FILE" > "$TEMP_VERSION_FILE"
mv "$TEMP_VERSION_FILE" "$VERSION_FILE"
echo -e "${GREEN}✓${NC} version.sh updated"

# Step 2: Update CHANGELOG.md
echo -e "${CYAN}[2/5]${NC} Updating CHANGELOG.md..."
CURRENT_DATE=$(date +%Y-%m-%d)

# Create temporary file for CHANGELOG update
TEMP_FILE=$(mktemp)

# Process CHANGELOG.md
awk -v new_version="$NEW_VERSION" -v current_date="$CURRENT_DATE" '
/^## \[Unreleased\]/ {
    print "## [Unreleased]"
    print ""
    print "## [" new_version "] - " current_date
    next
}
{ print }
' "$CHANGELOG_FILE" > "$TEMP_FILE"

mv "$TEMP_FILE" "$CHANGELOG_FILE"
echo -e "${GREEN}✓${NC} CHANGELOG.md updated"

# Step 3: Commit changes
if [ "$NO_COMMIT" = false ]; then
    echo -e "${CYAN}[3/5]${NC} Creating git commit..."
    git add "$VERSION_FILE" "$CHANGELOG_FILE"
    git commit -m "chore: bump version to ${NEW_VERSION}" -m "Automated version bump from ${CURRENT_VERSION} to ${NEW_VERSION}.

Updates:
- version.sh: CLI_VERSION updated
- CHANGELOG.md: Unreleased section moved to ${NEW_VERSION}"
    echo -e "${GREEN}✓${NC} Commit created"

    # Step 4: Create tag
    if [ "$NO_TAG" = false ]; then
        echo -e "${CYAN}[4/5]${NC} Creating git tag..."
        git tag -a "v${NEW_VERSION}" -m "Release version ${NEW_VERSION}"
        echo -e "${GREEN}✓${NC} Tag v${NEW_VERSION} created"
    fi

    # Step 5: Push to remote
    if [ "$NO_PUSH" = false ]; then
        echo -e "${CYAN}[5/5]${NC} Pushing to remote..."

        # Push commit
        git push origin "$CURRENT_BRANCH"

        # Push tags if created
        if [ "$NO_TAG" = false ]; then
            git push origin --tags
        fi

        echo -e "${GREEN}✓${NC} Pushed to origin/$CURRENT_BRANCH"
    else
        echo -e "${YELLOW}[5/5]${NC} Skipped push (--no-push flag)"
    fi
else
    echo -e "${YELLOW}[3/5]${NC} Skipped commit (--no-commit flag)"
fi

echo ""
echo -e "${GREEN}${BOLD}✅ Version bump complete!${NC}"
echo ""
echo -e "${BOLD}Summary:${NC}"
echo -e "  Version: ${CURRENT_VERSION} → ${GREEN}${NEW_VERSION}${NC}"
echo -e "  Commit:  $(git rev-parse --short HEAD 2>/dev/null || echo 'N/A')"
if [ "$NO_TAG" = false ] && [ "$NO_COMMIT" = false ]; then
    echo -e "  Tag:     ${GREEN}v${NEW_VERSION}${NC}"
fi
echo ""

# Next steps
if [ "$NO_PUSH" = true ]; then
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  Run: ${CYAN}git push origin ${CURRENT_BRANCH} --tags${NC}"
    echo ""
elif [ "$NO_COMMIT" = true ]; then
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  1. Review changes: ${CYAN}git diff${NC}"
    echo -e "  2. Commit changes: ${CYAN}git add version.sh CHANGELOG.md && git commit${NC}"
    echo -e "  3. Tag release: ${CYAN}git tag -a v${NEW_VERSION} -m 'Release version ${NEW_VERSION}'${NC}"
    echo -e "  4. Push: ${CYAN}git push origin ${CURRENT_BRANCH} --tags${NC}"
    echo ""
fi

# Verification commands
echo -e "${BOLD}Verify:${NC}"
echo -e "  ${CYAN}./ai-use-case --version${NC}  # Should show: ai-use-case version ${NEW_VERSION}"
echo -e "  ${CYAN}git log -1${NC}               # View commit"
if [ "$NO_TAG" = false ] && [ "$NO_COMMIT" = false ]; then
    echo -e "  ${CYAN}git tag -l v${NEW_VERSION}${NC}     # Verify tag exists"
fi
echo ""
