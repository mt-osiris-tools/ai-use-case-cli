# Development Workflow Guide

Complete guide for contributing to AI Use Case CLI. For quick reference, see [CLAUDE.md](../CLAUDE.md).

## Branch-Based Workflow

**MANDATORY**: All changes require feature branches and pull requests. Never commit directly to `main`.

```bash
# 1. Create feature branch
git checkout -b feature/description
# or
git checkout -b fix/description

# 2. Make changes and commit
git commit -m "feat: description"

# 3. Push and create PR
git push -u origin feature/description
gh pr create --title "..." --body "..."
```

## Version Management

**⚠️ CRITICAL**: When bumping versions, you MUST update ALL version references. See [VERSION-UPDATE-CHECKLIST.md](VERSION-UPDATE-CHECKLIST.md) for the complete checklist.

### When to Bump Versions

1. **Update version** in `scripts/utils/version.sh` (line 21):
   - **MAJOR** (X.0.0): Breaking changes that require user action
   - **MINOR** (0.X.0): New features, backward compatible
   - **PATCH** (0.0.X): Bug fixes, no new features

2. **Update ALL version references** (see checklist):
   - `README.md` (header on line ~4)
   - `README.md` (footer on line ~353 + date)
   - `CHANGELOG.md` (add new version section)

3. **Test**: Run `./ai-use-case --version`

See [VERSION-MANAGEMENT.md](VERSION-MANAGEMENT.md) for complete guide and [VERSION-UPDATE-CHECKLIST.md](VERSION-UPDATE-CHECKLIST.md) for verification checklist.

## Pre-PR Checklist

Before creating any PR, verify ALL items:

- [ ] Created feature branch (not on `main`)
- [ ] **MANDATORY: Updated CHANGELOG.md** (non-negotiable for ALL changes)
- [ ] **MANDATORY: Updated README.md** (non-negotiable if user-facing changes)
- [ ] Updated version if adding features (scripts/utils/version.sh)
- [ ] Tested changes locally
- [ ] **Verified cross-platform compatibility** (if shell scripts modified)
- [ ] Updated all related documentation (docs/*, CLAUDE.md, CONTRIBUTING.md)
- [ ] Used conventional commit messages
- [ ] Reviewed HUB-SYNC-CHECKLIST.md if applicable

**⚠️ DOCUMENTATION REVISION RULE:**

Every code change MUST trigger a documentation review. At minimum:
- **CHANGELOG.md** MUST be updated (describe what changed)
- **README.md** MUST be reviewed and updated if user-facing functionality changed
- All related **docs/** files MUST be updated if behavior/architecture changed

PRs without proper documentation updates will be rejected.

## Automatic Documentation (Claude Code)

**v3.4.0+: Interactive session selection with automatic generation**

When `/use-case:document-session` is invoked:

### 1. Detect Undocumented Work

Find recent work that needs documentation (prioritized):

```bash
# Find recent merged PRs (last 24 hours)
gh pr list --limit 20 --state merged --json number,title,mergedAt,headRefName

# Check recent commits
git log --since="24 hours ago" --pretty=format:"%h - %s (%ar)"

# List existing documentation
ls -1 .usecase/cases/
```

### 2. Present Options to User

Use `AskUserQuestion` to let user select which session to document:

- **Priority 1**: Undocumented PRs (implementation work) ⚠️
- **Priority 2**: Current conversation (research session)
- **Priority 3**: Recent direct commits

### 3. Auto-Generate Complete Documentation

For selected session:

- **For PRs**: Analyze PR metadata, commits, file changes
- **For current session**: Extract from conversation context
- Use git stats for metrics (files changed, lines added/removed, commits)
- **NO placeholders or TODOs** - generate complete documentation
- Follow template from CLI docs/ directory (TEMPLATE.md or TEMPLATE-RESEARCH.md)

### 4. Detect Session Type

- **Implementation**: Has code changes/commits (usually PRs)
- **Research**: No code changes, exploration only (use `RESEARCH-XXX` tickets)

### 5. Save and Sync

```bash
# Create file: .usecase/cases/YYYY-Www-MM-DD_TICKET-XXX_description.md
git add .usecase/cases/...
git commit -m "docs: AI session documentation"
bash ~/.local/share/ai-use-case-cli/scripts/core/sync-ai-use-cases.sh .
```

### Benefits of Interactive Selection

- Ensures all PRs get documented, not just research sessions
- User controls documentation priority
- Can invoke multiple times to document several sessions
- Clear audit trail between PRs and their documentation

See [CLAUDE.md](../CLAUDE.md) and [.claude/commands/use-case/document-session.md](../.claude/commands/use-case/document-session.md) for complete workflow.

## Common Development Patterns

### Adding a New Feature

```bash
# 1. Create branch
git checkout -b feature/new-command

# 2. Implement feature
# - Edit ai-use-case script or related scripts
# - Test locally with ./ai-use-case

# 3. Update version (e.g., 3.4.0 -> 3.5.0)
# - Edit scripts/utils/version.sh line 21
# - Update README.md (header + footer)
# - Update CHANGELOG.md

# 4. Commit with conventional commit format
git add ai-use-case CHANGELOG.md README.md
git commit -m "feat: add new command

Implements X functionality that does Y.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# 5. Push and create PR
git push -u origin feature/new-command
gh pr create --title "feat: Add new command" --body "$(cat <<'EOF'
## Summary
- Implements new command functionality
- Updates documentation and version

## Test plan
- [ ] Run ./ai-use-case --help
- [ ] Test new command
- [ ] Verify version output

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

### Fixing a Bug

```bash
# Same workflow as above but:
# - Branch: fix/issue-description
# - Version: Patch bump (e.g., 3.4.0 -> 3.4.1)
# - Commit: "fix: ..." not "feat: ..."
```

### Documentation-Only Changes

```bash
# Branch: docs/description
# Version: No bump required (unless significant)
# Commit: "docs: improve installation guide"
```

## Cross-Platform Compatibility

**MANDATORY**: All shell scripts must work across macOS, Linux, and WSL environments. This is a fundamental requirement for the project.

### Platform-Specific Considerations

#### Error Handling

Always use robust error handling in shell scripts:

```bash
# ✅ Correct
set -euo pipefail

# ❌ Incorrect
set -e
```

**Flags:**

- `-e`: Exit on error
- `-u`: Exit if undefined variables are referenced
- `-o pipefail`: Fail if any command in a pipeline fails (not just the last one)

#### sed Command (In-Place Editing)

BSD sed (macOS) and GNU sed (Linux) have different syntax for in-place editing:

```bash
# ✅ Correct - Platform detection
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS (BSD sed)
    sed -i '' 's/old/new/' file.txt
else
    # Linux (GNU sed)
    sed -i 's/old/new/' file.txt
fi

# ❌ Incorrect - Linux-only
sed -i 's/old/new/' file.txt
```

**Key differences:**

- **macOS**: Requires empty string argument `''` after `-i`
- **Linux**: Does NOT require argument after `-i`

**Reference examples in codebase:**

- `scripts/project/setup-project.sh:493-503` - Multiple sed operations with platform detection
- `scripts/install-dev-hooks.sh:53-85` - Adding content to files with platform detection

#### File Paths

Always use forward slashes and handle spaces properly:

```bash
# ✅ Correct
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/subfolder"

# ❌ Incorrect - Hardcoded separators
cd $SCRIPT_DIR\subfolder
```

#### Testing Requirements

Before submitting PRs, test on multiple platforms when possible:

- **Linux**: Primary development environment
- **macOS**: Test sed, file operations, path handling
- **WSL**: Verify compatibility with Windows Subsystem for Linux

### Common Patterns

Refer to existing scripts for proven cross-platform patterns:

1. **setup-project.sh** - Comprehensive example with sed operations
2. **install-dev-hooks.sh** - Git hook installation with platform detection
3. **Other utils scripts** - Various file operations and error handling

### Pre-PR Validation

- [ ] Script uses `set -euo pipefail`
- [ ] sed operations include platform detection (if used)
- [ ] File paths use proper quoting and forward slashes
- [ ] Tested on Linux (minimum requirement)
- [ ] Tested on macOS (if possible)

## File Naming Convention

All use case documentation must follow:

```
YYYY-Www-MM-DD_TICKET-XXX_brief-description.md
```

**Format explanation:**
- `YYYY` = Year (e.g., 2025)
- `Www` = ISO 8601 week number (W01-W53)
- `MM` = Month (01-12)
- `DD` = Day (01-31)
- `TICKET-XXX` = Ticket identifier (e.g., HUB-123, RESEARCH-001)
- `brief-description` = Lowercase with hyphens

**Examples:**
- `2025-W44-10-31_HUB-123_add-version-command.md`
- `2025-W44-10-31_RESEARCH-001_evaluate-auth-approaches.md`
- `2025-W45-11-08_HUB-124_optimize-token-usage.md`

## Never Do

Critical mistakes to avoid:

- ❌ Commit directly to `main` (always use feature branches)
- ❌ **Skip CHANGELOG.md updates** (MANDATORY for all changes)
- ❌ **Skip README.md review** (MANDATORY for user-facing changes)
- ❌ Create PR without testing locally first
- ❌ Create PR without updating documentation
- ❌ Forget version bump for new features
- ❌ Use placeholders or TODOs in auto-generated docs
- ❌ Skip HUB-SYNC-CHECKLIST.md review for sync-related changes
- ❌ **Write platform-specific code** (use `set -euo pipefail` and platform detection for sed)

## Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>: <subject>

<body>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

## Related Documentation

- [COMMANDS.md](COMMANDS.md) - Command reference
- [VERSION-MANAGEMENT.md](VERSION-MANAGEMENT.md) - Version bump guide
- [VERSION-UPDATE-CHECKLIST.md](VERSION-UPDATE-CHECKLIST.md) - Verification checklist
- [HUB-SYNC-CHECKLIST.md](HUB-SYNC-CHECKLIST.md) - Hub sync validation
- [CLAUDE.md](../CLAUDE.md) - Main comprehensive guide
