# AI Use Case CLI - Claude Code Guide

Quick reference for AI assistants working with this repository. For comprehensive details, see [docs/CLAUDE.md](docs/CLAUDE.md).

## Repository Purpose

CLI tools for documenting AI-assisted development workflows, designed to help developers on a daily basis.

**Main Goals:**
- **Reduce cognitive overload**: Minimize the mental burden of documentation through guided templates
- **Build knowledge base**: Create a comprehensive repository of AI tool usage patterns and solutions
- **Enable learning**: Help teams learn from past AI-assisted sessions and improve over time
- **Streamline workflow**: Quick, template-based documentation that integrates seamlessly with development

Works with a separate [hub repository](https://github.com/mt-osiris-tools/ai-use-case-hub) for centralized documentation storage.

## Critical Requirements

### Branch-Based Workflow

**MANDATORY**: All changes require feature branches and pull requests. Never commit directly to `main`.

```bash
# 1. Create feature branch
git checkout -b feature/description

# 2. Make changes and commit
git commit -m "feat: description"

# 3. Push and create PR
git push -u origin feature/description
gh pr create --title "..." --body "..."
```

### Version Management

When adding features or fixing bugs:

1. **Update version** in `ai-use-case` (line 73):
   - MAJOR: Breaking changes (X.0.0)
   - MINOR: New features (0.X.0)
   - PATCH: Bug fixes (0.0.X)

2. **Update CHANGELOG.md**: Add entry under appropriate version section

3. **Test**: Run `./ai-use-case --version` and `./ai-use-case version`

See [docs/VERSION-MANAGEMENT.md](docs/VERSION-MANAGEMENT.md) for complete guide.

### Pre-PR Checklist

Before creating any PR:

- [ ] Created feature branch (not on `main`)
- [ ] Updated CHANGELOG.md
- [ ] Updated version if adding features
- [ ] Tested changes locally
- [ ] Updated README.md or docs if behavior changed
- [ ] Used conventional commit messages
- [ ] Reviewed HUB-SYNC-CHECKLIST.md if applicable

## Key Commands

```bash
ai-use-case --init          # Setup project
ai-use-case document        # Document AI session (interactive)
ai-use-case sync            # Sync to hub (auto-commits/pushes)
ai-use-case update          # Update CLI to latest version
ai-use-case version         # Detailed version info with update check
ai-use-case --version       # Quick version number
ai-use-case search <term>   # Search use cases
ai-use-case stats           # Show statistics
```

## File Structure

- `ai-use-case` - Main CLI entry point (version on line 73)
- `setup-project.sh` - Project setup script
- `sync-ai-use-cases.sh` - Hub synchronization
- `document-ai-session.sh` - Interactive documentation
- `git-hooks/` - Hook templates (pre-commit, post-commit)
- `docs/` - Detailed documentation
  - `CLAUDE.md` - Comprehensive guide
  - `VERSION-MANAGEMENT.md` - Version bump guide
  - `HUB-SYNC-CHECKLIST.md` - Hub sync validation

## Automatic Documentation (Claude Code)

When `/use-case/document-session` is invoked:

1. **Analyze git history** (parallel):
   ```bash
   git log --since="24 hours ago" --pretty=format:"%h - %s (%ar)"
   git show --stat HEAD
   git diff HEAD~1..HEAD
   ```

2. **Auto-generate complete documentation**:
   - Extract data from commits and conversation context
   - Use git stats for metrics (files, lines, commits)
   - NO placeholders or TODOs
   - Follow template from hub repository

3. **Detect session type**:
   - Implementation: Has code changes/commits
   - Research: No code changes, exploration only (use `RESEARCH-XXX` tickets)

4. **Save and sync**:
   ```bash
   # Create file: docs/ai-use-cases/YYYY-MM-DD_TICKET-XXX_description.md
   git add docs/ai-use-cases/...
   git commit -m "docs: AI session documentation"
   ai-use-case sync
   ```

See [docs/CLAUDE.md:112-299](docs/CLAUDE.md) for complete automatic documentation workflow.

## Common Patterns

### Adding a New Feature

```bash
# 1. Create branch
git checkout -b feature/new-command

# 2. Implement feature
# - Edit ai-use-case script
# - Test locally

# 3. Update version (e.g., 2.3.0 -> 2.4.0)
# - Edit ai-use-case line 73
# - Update CHANGELOG.md

# 4. Commit and PR
git add ai-use-case CHANGELOG.md README.md
git commit -m "feat: add new command

Implements X functionality that does Y.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

git push -u origin feature/new-command
gh pr create --title "..." --body "..."
```

### Fixing a Bug

```bash
# Same as above but:
# - Branch: fix/issue-description
# - Version: Patch bump (e.g., 2.3.0 -> 2.3.1)
# - Commit: "fix: ..." not "feat: ..."
```

## File Naming Convention

All documentation must follow:
```
YYYY-Www-MM-DD_TICKET-XXX_brief-description.md
```

Where:
- `YYYY` = Year (e.g., 2025)
- `Www` = ISO 8601 week number (W01-W53)
- `MM` = Month (01-12)
- `DD` = Day (01-31)
- `TICKET-XXX` = Ticket identifier
- `brief-description` = Lowercase with hyphens

Examples:
- `2025-W44-10-31_HUB-123_add-version-command.md`
- `2025-W44-10-31_RESEARCH-001_evaluate-auth-approaches.md`

## Environment Variables

```bash
# Hub location (defaults to ~/Documents/ai-use-case-hub)
export AI_USECASES_DIR="$HOME/Documents/ai-use-case-hub"
```

## Never Do

- ❌ Commit directly to `main`
- ❌ Skip CHANGELOG.md updates
- ❌ Create PR without testing
- ❌ Forget version bump for new features
- ❌ Use placeholders in auto-generated docs
- ❌ Skip HUB-SYNC-CHECKLIST.md review

## Reference Documentation

- **[docs/CLAUDE.md](docs/CLAUDE.md)** - Comprehensive guide (724 lines)
- **[docs/VERSION-MANAGEMENT.md](docs/VERSION-MANAGEMENT.md)** - Version bump process
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines
- **[README.md](README.md)** - User-facing documentation
- **[Hub Repository](https://github.com/mt-osiris-tools/ai-use-case-hub)** - Documentation templates

## Quick Reference

**Current Version**: Check `ai-use-case` line 73
**Latest Changes**: See `CHANGELOG.md`
**Project Type**: Bash CLI tool with hub integration
**Main Branch**: `main` (protected, requires PRs)
**Commit Style**: Conventional commits (feat:, fix:, docs:, etc.)
