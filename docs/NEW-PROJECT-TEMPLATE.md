# New Project Setup Template

This document provides a complete setup template to replicate the git workflow, commit standards, and AI assistant guidelines used in the AI Use Case CLI project into any new repository.

## Overview

This template establishes:
- **Branch-based workflow** with protected main branch
- **Git hooks** to enforce commit standards
- **Claude Code integration** with project-specific instructions
- **Documentation standards** and PR checklists
- **Conventional commits** for clear change history

## Quick Setup Guide

### 1. Copy CLAUDE.md to Your Repository

Create `CLAUDE.md` in your repository root with project-specific instructions for AI assistants:

```markdown
# [Your Project Name] - Claude Code Guide

## Repository Purpose

[Brief description of what this repository does and its main goals]

## Critical Rules

### 🚨 Mandatory Workflow

1. **Branch-based only** - Never commit directly to `main`
2. **Documentation** - MUST update CHANGELOG.md and README.md for all changes
3. **Testing** - All changes must be tested locally before creating PR

```bash
# Standard workflow
git checkout -b feature/description
# ... make changes ...
git commit -m "feat: description"
git push -u origin feature/description
gh pr create
```

### 📋 Pre-PR Checklist

- [ ] Created feature branch (not on `main`)
- [ ] **MANDATORY: Updated CHANGELOG.md**
- [ ] **MANDATORY: Updated README.md** (if user-facing changes)
- [ ] Tested changes locally
- [ ] Updated all related documentation

## Branch Naming Convention

Use consistent branch naming:

- `feature/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation changes
- `refactor/description` - Code refactoring
- `test/description` - Test additions/changes

## Commit Message Format

Use conventional commits for clear change history:

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `refactor:` - Code refactoring
- `test:` - Test changes
- `chore:` - Maintenance tasks

Example:
```bash
git commit -m "feat: add user authentication" \
  -m "Implements JWT-based authentication with refresh tokens. Updates API endpoints to require authentication."
```

## Never Do

- ❌ Commit directly to `main`
- ❌ Skip CHANGELOG.md updates (MANDATORY)
- ❌ Skip README.md review (MANDATORY for user-facing changes)
- ❌ Create PR without testing
- ❌ Use vague commit messages

## Quick Reference

**Main Branch**: `main` (protected, requires PRs)
**Commit Style**: Conventional commits (feat:, fix:, docs:)

**📚 Documentation:**
- **README.md** - User-facing documentation
- **CHANGELOG.md** - Version history and changes
- **CONTRIBUTING.md** - Contribution guidelines
```

### 2. Install Git Hooks

#### Pre-Commit Hook (Blocks Direct Commits to Main)

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Git Pre-Commit Hook for Branch Protection
# Prevents direct commits to main/master branches
#
# This hook is triggered before a commit is created

# Get current branch name
BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null)

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check if committing to protected branch
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
    echo ""
    # Dynamically size the error message box to fit the branch name
    BLOCKED_MSG="⚠️  COMMIT BLOCKED: Cannot commit directly to '$BRANCH' branch"
    BOX_WIDTH=$(( ${#BLOCKED_MSG} + 4 )) # 2 spaces padding on each side
    # Build top border
    printf "${RED}╭"
    for ((i=0; i<$BOX_WIDTH; i++)); do printf "─"; done
    printf "╮${NC}\n"
    # Print message line
    printf "${RED}│  %s  │${NC}\n" "$BLOCKED_MSG"
    # Build bottom border
    printf "${RED}╰"
    for ((i=0; i<$BOX_WIDTH; i++)); do printf "─"; done
    printf "╯${NC}\n"
    echo ""
    echo -e "${YELLOW}This project uses branch-based workflow for better collaboration.${NC}"
    echo ""
    echo -e "Please create a feature branch instead:"
    echo ""
    echo -e "  ${GREEN}git checkout -b feature/your-feature-name${NC}"
    echo -e "  ${GREEN}git commit -m \"your commit message\"${NC}"
    echo ""
    echo "Branch naming conventions:"
    echo "  • feature/description  - New features"
    echo "  • fix/description      - Bug fixes"
    echo "  • docs/description     - Documentation changes"
    echo "  • refactor/description - Code refactoring"
    echo "  • test/description     - Test additions/changes"
    echo ""
    echo -e "${YELLOW}To bypass this check (not recommended):${NC}"
    echo -e "  git commit --no-verify -m \"your message\""
    echo ""

    exit 1
fi

# Allow commit to proceed
exit 0
```

Make it executable:
```bash
chmod +x .git/hooks/pre-commit
```

#### Commit-Msg Hook (Optional - Validates Commit Format)

Create `.git/hooks/commit-msg` to enforce conventional commit format:

```bash
#!/bin/bash
# Git Commit-Msg Hook for Conventional Commits
# Validates commit message format
#
# This hook is triggered before the commit message is finalized

COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Conventional commit pattern
# Format: type(optional-scope): description
PATTERN="^(feat|fix|docs|style|refactor|perf|test|chore|build|ci|revert)(\(.+\))?: .{1,}"

# Check if commit message matches pattern
if ! echo "$COMMIT_MSG" | grep -qE "$PATTERN"; then
    echo ""
    echo -e "${RED}╭────────────────────────────────────────────────────────╮${NC}"
    echo -e "${RED}│  ⚠️  INVALID COMMIT MESSAGE FORMAT                    │${NC}"
    echo -e "${RED}╰────────────────────────────────────────────────────────╯${NC}"
    echo ""
    echo -e "${YELLOW}Commit messages must follow conventional commit format:${NC}"
    echo ""
    echo -e "  ${GREEN}type(optional-scope): description${NC}"
    echo ""
    echo "Valid types:"
    echo "  • feat:     New feature"
    echo "  • fix:      Bug fix"
    echo "  • docs:     Documentation changes"
    echo "  • style:    Code style changes (formatting, etc.)"
    echo "  • refactor: Code refactoring"
    echo "  • perf:     Performance improvements"
    echo "  • test:     Test additions/changes"
    echo "  • chore:    Maintenance tasks"
    echo "  • build:    Build system changes"
    echo "  • ci:       CI/CD changes"
    echo "  • revert:   Revert previous commit"
    echo ""
    echo "Examples:"
    echo -e "  ${GREEN}feat: add user authentication${NC}"
    echo -e "  ${GREEN}fix: resolve memory leak in parser${NC}"
    echo -e "  ${GREEN}docs: update installation guide${NC}"
    echo -e "  ${GREEN}refactor(api): simplify error handling${NC}"
    echo ""
    echo "Your commit message:"
    echo -e "  ${RED}$COMMIT_MSG${NC}"
    echo ""
    echo -e "${YELLOW}To bypass this check (not recommended):${NC}"
    echo -e "  git commit --no-verify -m \"your message\""
    echo ""

    exit 1
fi

# Allow commit to proceed
exit 0
```

Make it executable:
```bash
chmod +x .git/hooks/commit-msg
```

### 3. Create CONTRIBUTING.md

Add contribution guidelines to your repository:

```markdown
# Contributing to [Your Project Name]

Thank you for contributing! This document outlines the development workflow and contribution guidelines.

## Development Workflow

All changes to this repository **must** follow a branch-based workflow with pull requests. Direct commits to the `main` branch are not allowed.

### Branch Naming Convention

Use the following format for all feature branches:

- `feature/` - New features or enhancements
- `fix/` - Bug fixes
- `docs/` - Documentation-only changes
- `refactor/` - Code refactoring without behavior changes
- `test/` - Adding or updating tests

**Examples:**
- `feature/add-user-auth`
- `fix/memory-leak-parser`
- `docs/update-api-guide`

### Pull Request Workflow

#### Step 1: Create a Branch

```bash
git checkout -b feature/your-feature-description
```

#### Step 2: Make Your Changes

Implement your changes following the requirements checklist below.

#### Step 3: Commit Your Changes

Use conventional commit messages:

```bash
git add .
git commit -m "feat: add user authentication" \
  -m "Implements JWT-based authentication with refresh tokens."
```

#### Step 4: Push Your Branch

```bash
git push -u origin feature/your-feature-description
```

#### Step 5: Create Pull Request

Create a PR on GitHub with:
- Clear title describing the change
- Description explaining what and why
- Reference to related issues (if any)
- Screenshots or examples (if applicable)

### PR Requirements Checklist

Before creating a pull request, ensure you have completed:

- [ ] **MANDATORY: Update CHANGELOG.md** - Add entry under "Unreleased" section
- [ ] **MANDATORY: Review and update README.md** - Update if any user-facing functionality changed
- [ ] **Test changes locally** - Verify everything works
- [ ] **Update all related documentation** - Update docs if behavior changes

**⚠️ DOCUMENTATION REVISION RULE (NON-NEGOTIABLE):**

Every code change MUST trigger a documentation review:

1. **CHANGELOG.md** - MUST be updated for ALL changes
   - Describe what changed, why, and any breaking changes
   - Add entry under `## [Unreleased]` section

2. **README.md** - MUST be reviewed and updated if user-facing changes
   - New features → add to feature list and usage section
   - Changed commands → update command examples
   - New options/flags → document in usage section

#### CHANGELOG.md Format

Add your changes under the `## [Unreleased]` section:

```markdown
## [Unreleased]

### Added
- User authentication with JWT tokens

### Changed
- Improved error handling in API endpoints

### Fixed
- Memory leak in request parser
```

#### Testing

Test your changes thoroughly before creating a PR.

## Working with Claude Code

When using Claude Code (Anthropic's AI coding assistant) in this repository:

### Claude Code Guidelines

Claude Code is instructed to:
- Always create a feature branch (never commit directly to main)
- Follow the `feature/description` naming convention
- Make atomic commits with conventional commit messages
- Update CHANGELOG.md with all changes
- Test changes before creating PR
- Update documentation as needed
- Ask before creating the pull request

## Branch Protection Rules

To enforce this workflow on GitHub, configure branch protection for `main`:

### GitHub Settings > Branches > Add rule

**Branch name pattern:** `main`

**Required settings:**
- ✅ Require a pull request before merging
  - ✅ Require approvals: 1 (or 0 for solo development)
- ✅ Require status checks to pass before merging (if you add CI/CD)
- ✅ Require branches to be up to date before merging
- ✅ Do not allow bypassing the above settings

**Optional but recommended:**
- ✅ Require linear history (no merge commits, use rebase or squash)
- ✅ Require signed commits
- ✅ Include administrators (enforces rules even for repo admins)

## Code Review Guidelines

When reviewing pull requests:

### For Reviewers

- **Functionality**: Does it work as intended?
- **Testing**: Has it been tested locally?
- **Documentation**: Are docs updated?
- **Changelog**: Is CHANGELOG.md updated?
- **Code quality**: Is the code clean and maintainable?
- **Breaking changes**: Are they necessary and documented?

### For Authors

- Respond to feedback promptly
- Keep PRs focused and atomic (one feature/fix per PR)
- Update your PR based on review comments
- Squash/rebase before merge if requested

## Questions or Issues?

- **Bugs**: Open an issue with reproduction steps
- **Features**: Open an issue for discussion before implementing
- **Questions**: Use GitHub Discussions or open an issue
```

### 4. Create CHANGELOG.md

Initialize a CHANGELOG.md in your repository:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project setup

## [1.0.0] - 2025-XX-XX

### Added
- Initial release
```

### 5. Add Global Claude Code Rules (Optional)

Create or update `~/.claude/CLAUDE.md` in your home directory to apply rules across all projects:

```markdown
- Always create a new branch for any changes. Direct commits to the main branch are not allowed.
```

## Implementation Checklist

Use this checklist when setting up a new repository:

- [ ] Create `CLAUDE.md` in repository root (customize for your project)
- [ ] Install `.git/hooks/pre-commit` hook to block main branch commits
- [ ] (Optional) Install `.git/hooks/commit-msg` hook to enforce conventional commits
- [ ] Make hooks executable: `chmod +x .git/hooks/pre-commit .git/hooks/commit-msg`
- [ ] Create `CONTRIBUTING.md` with contribution guidelines
- [ ] Create `CHANGELOG.md` for tracking changes
- [ ] (Optional) Add `~/.claude/CLAUDE.md` for global AI assistant rules
- [ ] Configure GitHub branch protection rules for `main` branch
- [ ] Test the setup by attempting to commit to main (should be blocked)
- [ ] Create a test feature branch and verify workflow

## Automated Setup Script

For quick setup, you can create a script to automate the installation:

```bash
#!/bin/bash
# setup-git-workflow.sh - Automated git workflow setup

set -e

echo "Setting up git workflow for this repository..."

# Create pre-commit hook
echo "Installing pre-commit hook..."
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Git Pre-Commit Hook for Branch Protection
# [Insert full pre-commit hook content from above]
EOF
chmod +x .git/hooks/pre-commit

# Create commit-msg hook
echo "Installing commit-msg hook..."
cat > .git/hooks/commit-msg << 'EOF'
#!/bin/bash
# Git Commit-Msg Hook for Conventional Commits
# [Insert full commit-msg hook content from above]
EOF
chmod +x .git/hooks/commit-msg

# Create CLAUDE.md if it doesn't exist
if [ ! -f CLAUDE.md ]; then
    echo "Creating CLAUDE.md..."
    cat > CLAUDE.md << 'EOF'
# [Your Project Name] - Claude Code Guide

[Insert CLAUDE.md template from above]
EOF
fi

# Create CONTRIBUTING.md if it doesn't exist
if [ ! -f CONTRIBUTING.md ]; then
    echo "Creating CONTRIBUTING.md..."
    cat > CONTRIBUTING.md << 'EOF'
# Contributing to [Your Project Name]

[Insert CONTRIBUTING.md template from above]
EOF
fi

# Create CHANGELOG.md if it doesn't exist
if [ ! -f CHANGELOG.md ]; then
    echo "Creating CHANGELOG.md..."
    cat > CHANGELOG.md << 'EOF'
# Changelog

[Insert CHANGELOG.md template from above]
EOF
fi

echo ""
echo "✓ Git workflow setup complete!"
echo ""
echo "Next steps:"
echo "1. Review and customize CLAUDE.md for your project"
echo "2. Review and customize CONTRIBUTING.md"
echo "3. Configure GitHub branch protection for 'main' branch"
echo "4. Test by attempting to commit to main (should be blocked)"
echo ""
```

Save as `setup-git-workflow.sh`, make executable, and run:

```bash
chmod +x setup-git-workflow.sh
./setup-git-workflow.sh
```

## Testing Your Setup

After setup, verify everything works:

### 1. Test Pre-Commit Hook

Try committing to main (should be blocked):
```bash
git checkout main
echo "test" >> test.txt
git add test.txt
git commit -m "test: should be blocked"
# Should display error message and block commit
```

### 2. Test Feature Branch Workflow

Create a feature branch (should succeed):
```bash
git checkout -b feature/test-workflow
echo "test" >> test.txt
git add test.txt
git commit -m "feat: test workflow setup"
# Should succeed
```

### 3. Test Commit Message Format (if using commit-msg hook)

Try invalid commit message (should be blocked):
```bash
git commit --allow-empty -m "invalid message format"
# Should display error about conventional commit format
```

Try valid commit message (should succeed):
```bash
git commit --allow-empty -m "feat: valid commit message"
# Should succeed
```

## Customization Guide

### Customize Branch Protection

Edit `.git/hooks/pre-commit` to protect additional branches:

```bash
# Change this line:
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then

# To protect more branches:
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ] || [ "$BRANCH" = "production" ]; then
```

### Customize Commit Types

Edit `.git/hooks/commit-msg` to add custom commit types:

```bash
# Change this line:
PATTERN="^(feat|fix|docs|style|refactor|perf|test|chore|build|ci|revert)(\(.+\))?: .{1,}"

# To add custom types:
PATTERN="^(feat|fix|docs|style|refactor|perf|test|chore|build|ci|revert|release|hotfix)(\(.+\))?: .{1,}"
```

### Customize CLAUDE.md

Update `CLAUDE.md` to include:
- Project-specific file structure
- Custom commands and workflows
- Technology-specific guidelines
- Project-specific rules and conventions

## Benefits of This Approach

1. **Enforced Standards**: Git hooks prevent accidental main branch commits
2. **Clear History**: Conventional commits create readable git history
3. **Better Collaboration**: Branch-based workflow enables code review
4. **AI Integration**: Claude Code automatically follows project standards
5. **Documentation**: Mandatory CHANGELOG and README updates
6. **Quality Control**: PR checklist ensures completeness

## Troubleshooting

### Git hooks not triggering

Ensure hooks are executable:
```bash
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/commit-msg
```

### Need to bypass hooks temporarily

Use `--no-verify` flag (not recommended):
```bash
git commit --no-verify -m "emergency fix"
```

### Hooks not working on Windows

Ensure you're using Git Bash or WSL, and hooks have Unix line endings (LF, not CRLF).

### GitHub still allows direct commits

Configure branch protection rules in GitHub repository settings.

## Additional Resources

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [Semantic Versioning](https://semver.org/)
- [GitHub Branch Protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)

## Support

For questions or issues with this template:
- Review the AI Use Case CLI repository for examples
- Open an issue for clarification
- Consult the CLAUDE.md and CONTRIBUTING.md in the source repository
