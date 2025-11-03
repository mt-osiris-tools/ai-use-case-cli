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

1. **Update version** in `ai-use-case` (line 19):
   - MAJOR: Breaking changes (X.0.0)
   - MINOR: New features (0.X.0)
   - PATCH: Bug fixes (0.0.X)

2. **Update CHANGELOG.md**: Add entry under appropriate version section

3. **Test**: Run `./ai-use-case --version`

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

**v3.1.0+: Hybrid approach - Standalone CLI + Claude Code integration**

### Standalone CLI Commands
```bash
ai-use-case --init              # Setup current project
ai-use-case sync                # Sync use cases to hub
ai-use-case search <term>       # Search documented use cases
ai-use-case list                # List all registered projects
ai-use-case stats               # View statistics
ai-use-case view                # Open hub in file explorer
ai-use-case push                # Push hub changes to remote
ai-use-case publish-confluence  # Publish to Confluence
ai-use-case uninstall           # Uninstall the CLI
ai-use-case --version           # Show version
ai-use-case --help              # Show help

# v3.1.0+ Project Registry Commands
ai-use-case list-projects       # List registered projects with versions
ai-use-case check-updates       # Check which projects need CLI updates
ai-use-case update-project <path> # Update a project to latest CLI version
```

### Claude Code Slash Commands
For AI-assisted documentation with automatic context capture:
```
/use-case:document-session   # Document AI session (automatic, AI-context aware)
/use-case:setup-project      # Setup project (alternative to --init)
/use-case:sync-usecases      # Sync to hub (alternative to sync)
/use-case:search-usecases    # Search use cases (alternative to search)
/use-case:publish-confluence # Publish to Confluence (alternative)
/use-case:quick-start        # Quick start guide

# v3.1.0+ Project Registry Commands
/use-case:list-projects      # List all registered projects with versions
/use-case:check-updates      # Check which projects need CLI updates
/use-case:update-project     # Update a project to latest CLI version
```

**Direct script access (advanced):**
```bash
bash ~/.local/share/ai-use-case-cli/setup-project.sh .
bash ~/.local/share/ai-use-case-cli/document-ai-session.sh .
bash ~/.local/share/ai-use-case-cli/sync-ai-use-cases.sh .
bash ~/.local/share/ai-use-case-cli/search-use-cases.sh <term>
bash ~/.local/share/ai-use-case-cli/stats-use-cases.sh
bash ~/.local/share/ai-use-case-cli/list-projects.sh
bash ~/.local/share/ai-use-case-cli/check-updates.sh
bash ~/.local/share/ai-use-case-cli/update-project.sh <path>
```

## File Structure

- `ai-use-case` - Main CLI entry point with hybrid commands (version on line 19)
- `setup-project.sh` - Project setup script (now includes registry)
- `sync-ai-use-cases.sh` - Hub synchronization
- `document-ai-session.sh` - Interactive documentation
- `search-use-cases.sh` - Search functionality
- `stats-use-cases.sh` - Statistics display
- `list-projects.sh` - Project listing (enhanced with registry in v3.1.0)
- `view-hub.sh` - Hub viewer
- `push-hub.sh` - Hub push automation
- `publish-confluence.sh` - Confluence publishing
- **v3.1.0+:** `registry-manager.sh` - Project registry management
- **v3.1.0+:** `check-updates.sh` - Check for outdated projects
- **v3.1.0+:** `update-project.sh` - Update project CLI version
- `.claude/commands/use-case/` - Slash commands for Claude Code
- `git-hooks/` - Hook templates (pre-commit, post-commit)
- `docs/` - Detailed documentation
  - `CLAUDE.md` - Comprehensive guide
  - `VERSION-MANAGEMENT.md` - Version bump guide
  - `HUB-SYNC-CHECKLIST.md` - Hub sync validation
- **v3.1.0+:** `~/.local/share/ai-use-case-cli/projects-registry.json` - Project registry database

## Automatic Documentation (Claude Code)

When `/use-case:document-session` is invoked:

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
   bash ~/.local/share/ai-use-case-cli/sync-ai-use-cases.sh .
   ```

See [docs/CLAUDE.md](docs/CLAUDE.md) and [.claude/commands/use-case/document-session.md](.claude/commands/use-case/document-session.md) for complete automatic documentation workflow.

## Project Registry (v3.1.0+)

The CLI now maintains a registry of all projects using the tool, enabling better version management and updates.

### How It Works

1. **Automatic Registration**: When you run `setup-project.sh`, the project is automatically registered
2. **Version Tracking**: Each project's CLI version is tracked in the registry
3. **Update Management**: Easily identify and update projects with outdated CLI versions

### Registry Location

```bash
~/.local/share/ai-use-case-cli/projects-registry.json
```

### Common Workflows

**Check all registered projects:**
```bash
bash ~/.local/share/ai-use-case-cli/list-projects.sh --registry-only
```

**Find projects needing updates:**
```bash
bash ~/.local/share/ai-use-case-cli/check-updates.sh
```

**Update a specific project:**
```bash
bash ~/.local/share/ai-use-case-cli/update-project.sh /path/to/project
```

**Update all outdated projects:**
```bash
for p in $(bash ~/.local/share/ai-use-case-cli/check-updates.sh --paths-only); do
  bash ~/.local/share/ai-use-case-cli/update-project.sh "$p"
done
```

### Registry Data Structure

```json
{
  "version": "1.0.0",
  "lastUpdated": "2025-11-02T10:30:00Z",
  "projects": {
    "/full/path/to/project": {
      "name": "project-name",
      "version": "3.1.0",
      "installedAt": "2025-11-02T10:30:00Z",
      "lastUpdated": "2025-11-02T10:30:00Z",
      "hubPath": "docs/ai-use-cases"
    }
  }
}
```

## Common Patterns

### Adding a New Feature

```bash
# 1. Create branch
git checkout -b feature/new-command

# 2. Implement feature
# - Edit ai-use-case script
# - Test locally

# 3. Update version (e.g., 3.0.0 -> 3.1.0)
# - Edit ai-use-case line 19
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

**Current Version**: Check `ai-use-case` line 19
**Latest Changes**: See `CHANGELOG.md`
**Project Type**: Bash CLI tool with hub integration
**Main Branch**: `main` (protected, requires PRs)
**Commit Style**: Conventional commits (feat:, fix:, docs:, etc.)
**Documentation Updates**: Always verify if we need to update the documentation, README, CHANGELOG and all related documentation
**Branching Policy**: Always create a new branch for any changes. Direct commits to the main branch are not allowed.