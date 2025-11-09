# AI Use Case CLI - Claude Code Guide

Quick reference for AI assistants working with this repository. For comprehensive details, see [docs/CLAUDE.md](docs/CLAUDE.md).

## Repository Purpose

CLI tools for documenting AI-assisted development workflows, designed to help developers on a daily basis.

**Main Goals:**
- **Reduce cognitive overload**: Minimize the mental burden of documentation through guided templates
- **Build knowledge base**: Create a comprehensive repository of AI tool usage patterns and solutions
- **Enable learning**: Help teams learn from past AI-assisted sessions and improve over time
- **Streamline workflow**: Quick, template-based documentation that integrates seamlessly with development

Supports flexible documentation storage: local-only (no git) or private git repository.

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

**⚠️ CRITICAL**: When bumping versions, you MUST update ALL version references. See [docs/VERSION-UPDATE-CHECKLIST.md](docs/VERSION-UPDATE-CHECKLIST.md) for the complete checklist.

When adding features or fixing bugs:

1. **Update version** in `scripts/utils/version.sh` (line 21):
   - MAJOR: Breaking changes (X.0.0)
   - MINOR: New features (0.X.0)
   - PATCH: Bug fixes (0.0.X)

2. **Update ALL version references** (see checklist):
   - `README.md` (header on line ~4)
   - `README.md` (footer on line ~353 + date)
   - `CHANGELOG.md` (add new version section)

3. **Test**: Run `./ai-use-case --version`

See [docs/VERSION-MANAGEMENT.md](docs/VERSION-MANAGEMENT.md) for complete guide and [docs/VERSION-UPDATE-CHECKLIST.md](docs/VERSION-UPDATE-CHECKLIST.md) for verification checklist.

### Pre-PR Checklist

Before creating any PR:

- [ ] Created feature branch (not on `main`)
- [ ] **MANDATORY: Updated CHANGELOG.md** (non-negotiable for ALL changes)
- [ ] **MANDATORY: Updated README.md** (non-negotiable if user-facing changes)
- [ ] Updated version if adding features (scripts/utils/version.sh)
- [ ] Tested changes locally
- [ ] Updated all related documentation (docs/*, CLAUDE.md, CONTRIBUTING.md)
- [ ] Used conventional commit messages
- [ ] Reviewed HUB-SYNC-CHECKLIST.md if applicable

**⚠️ DOCUMENTATION REVISION RULE:**
Every code change MUST trigger a documentation review. At minimum:
- CHANGELOG.md MUST be updated (describe what changed)
- README.md MUST be reviewed and updated if user-facing functionality changed
- All related docs/* files MUST be updated if behavior/architecture changed

## Key Commands

**v3.1.0+: Hybrid approach - Standalone CLI + Claude Code integration**

### Standalone CLI Commands
```bash
ai-use-case --init              # Setup current project
ai-use-case config show         # Show hub configuration
ai-use-case config reconfigure  # Change hub mode (local/private)
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
bash ~/.local/share/ai-use-case-cli/scripts/project/setup-project.sh .
bash ~/.local/share/ai-use-case-cli/scripts/core/document-ai-session.sh .
bash ~/.local/share/ai-use-case-cli/scripts/core/sync-ai-use-cases.sh .
bash ~/.local/share/ai-use-case-cli/scripts/search/search-use-cases.sh <term>
bash ~/.local/share/ai-use-case-cli/scripts/search/stats-use-cases.sh
bash ~/.local/share/ai-use-case-cli/scripts/project/list-projects.sh
bash ~/.local/share/ai-use-case-cli/scripts/project/check-updates.sh
bash ~/.local/share/ai-use-case-cli/scripts/project/update-project.sh <path>
```

## File Structure

```
├── ai-use-case                    # Main CLI entry point with hybrid commands
├── scripts/
│   ├── core/                      # Core functionality
│   │   ├── document-ai-session.sh # Interactive documentation
│   │   ├── publish-confluence.sh  # Confluence publishing
│   │   └── sync-ai-use-cases.sh   # Hub synchronization
│   ├── project/                   # Project management
│   │   ├── setup-project.sh       # Project setup (includes registry)
│   │   ├── registry-manager.sh    # Project registry management (v3.1.0+)
│   │   ├── list-projects.sh       # Project listing
│   │   ├── check-updates.sh       # Check for outdated projects (v3.1.0+)
│   │   └── update-project.sh      # Update project CLI version (v3.1.0+)
│   ├── search/                    # Search and analytics
│   │   ├── search-use-cases.sh    # Search functionality
│   │   └── stats-use-cases.sh     # Statistics display
│   ├── hub/                       # Hub operations
│   │   ├── view-hub.sh            # Hub viewer
│   │   └── push-hub.sh            # Hub push automation
│   ├── install/                   # Installation
│   │   ├── install.sh             # Installation script
│   │   └── uninstall.sh           # Uninstallation script
│   └── utils/                     # Utilities
│       ├── bump-version.sh        # Version management
│       ├── version.sh             # Version configuration
│       ├── config-manager.sh      # Hub configuration (v3.2.0+)
│       └── hub-utils.sh           # Hub utilities (v3.2.0+)
├── .claude/commands/use-case/     # Slash commands for Claude Code
├── git-hooks/                     # Hook templates (pre-commit, post-commit)
└── docs/                          # Detailed documentation
  - `CLAUDE.md` - Comprehensive guide
  - `VERSION-MANAGEMENT.md` - Version bump guide
  - `HUB-SYNC-CHECKLIST.md` - Hub sync validation
- **v3.1.0+:** `~/.local/share/ai-use-case-cli/projects-registry.json` - Project registry database
- **v3.2.0+:** `~/.config/ai-use-case-cli/config.json` - Hub configuration

## Hub Configuration (v3.2.0+)

The CLI supports two hub modes for documentation storage:

### Hub Modes

1. **Local Only** (Default - No git repository)
   - Files stored in: `~/.local/share/ai-use-case-cli/hub/`
   - No version control, no remote sync
   - Best for: Personal use, quick local documentation
   - Git operations (push, remote sync) are disabled

2. **Private Git** (Your own repository)
   - Connect to your own private git repository
   - Full version control with your chosen remote
   - Best for: Private team documentation, company-internal use, version-controlled workflow
   - Requires: Git repository URL during setup

### Configuration

During first setup (`ai-use-case --init`), you'll be prompted to select a mode.

**Show current configuration:**
```bash
ai-use-case config show
```

**Reconfigure hub mode (change between local/private):**
```bash
ai-use-case config reconfigure
```

**Override hub location** (works with all modes):
```bash
export AI_USECASES_DIR="/custom/path/to/hub"
```

**Advanced (direct script access):**
```bash
# Show config
bash ~/.local/share/ai-use-case-cli/scripts/utils/config-manager.sh show

# Check mode
bash ~/.local/share/ai-use-case-cli/scripts/utils/config-manager.sh mode
```

## Automatic Documentation (Claude Code)

**v3.4.0+: Interactive session selection with automatic generation**

When `/use-case:document-session` is invoked:

1. **Detect undocumented work** (prioritized):
   ```bash
   # Find recent merged PRs (last 24 hours)
   gh pr list --limit 20 --state merged --json number,title,mergedAt,headRefName

   # Check recent commits
   git log --since="24 hours ago" --pretty=format:"%h - %s (%ar)"

   # List existing documentation
   ls -1 .usecase/cases/
   ```

2. **Present options to user**:
   - Priority 1: **Undocumented PRs** (implementation work) ⚠️
   - Priority 2: **Current conversation** (research session)
   - Priority 3: **Recent direct commits**
   - Use `AskUserQuestion` to let user select which session to document

3. **Auto-generate complete documentation** for selected session:
   - For PRs: Analyze PR metadata, commits, file changes
   - For current session: Extract from conversation context
   - Use git stats for metrics (files, lines, commits)
   - NO placeholders or TODOs
   - Follow template from CLI docs/ directory (TEMPLATE.md or TEMPLATE-RESEARCH.md)

4. **Detect session type**:
   - Implementation: Has code changes/commits (usually PRs)
   - Research: No code changes, exploration only (use `RESEARCH-XXX` tickets)

5. **Save and sync**:
   ```bash
   # Create file: .usecase/cases/YYYY-Www-MM-DD_TICKET-XXX_description.md
   git add .usecase/cases/...
   git commit -m "docs: AI session documentation"
   bash ~/.local/share/ai-use-case-cli/scripts/core/sync-ai-use-cases.sh .
   ```

**Benefits of interactive selection:**
- Ensures all PRs get documented, not just research sessions
- User controls documentation priority
- Can invoke multiple times to document several sessions
- Clear audit trail between PRs and their documentation

See [docs/CLAUDE.md](docs/CLAUDE.md) and [.claude/commands/use-case/document-session.md](.claude/commands/use-case/document-session.md) for complete workflow.

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
bash ~/.local/share/ai-use-case-cli/scripts/project/list-projects.sh --registry-only
```

**Find projects needing updates:**
```bash
bash ~/.local/share/ai-use-case-cli/scripts/project/check-updates.sh
```

**Update a specific project:**
```bash
bash ~/.local/share/ai-use-case-cli/scripts/project/update-project.sh /path/to/project
```

**Update all outdated projects:**
```bash
for p in $(bash ~/.local/share/ai-use-case-cli/scripts/project/check-updates.sh --paths-only); do
  bash ~/.local/share/ai-use-case-cli/scripts/project/update-project.sh "$p"
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
      "hubPath": ".usecase/cases"
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
# Hub location override (optional)
# Default for local-only mode: ~/.local/share/ai-use-case-cli/hub/
# Default for private git mode: Set during configuration
export AI_USECASES_DIR="/custom/path/to/hub"
```

## Never Do

- ❌ Commit directly to `main`
- ❌ **Skip CHANGELOG.md updates** (MANDATORY for all changes)
- ❌ **Skip README.md review** (MANDATORY for user-facing changes)
- ❌ Create PR without testing
- ❌ Create PR without updating documentation
- ❌ Forget version bump for new features
- ❌ Use placeholders in auto-generated docs
- ❌ Skip HUB-SYNC-CHECKLIST.md review

## Reference Documentation

- **[docs/CLAUDE.md](docs/CLAUDE.md)** - Comprehensive guide (724 lines)
- **[docs/VERSION-MANAGEMENT.md](docs/VERSION-MANAGEMENT.md)** - Version bump process
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines
- **[README.md](README.md)** - User-facing documentation

## Quick Reference

**Current Version**: Check `scripts/utils/version.sh` line 21
**Latest Changes**: See `CHANGELOG.md`
**Project Type**: Bash CLI tool with hub integration
**Main Branch**: `main` (protected, requires PRs – no direct commits allowed)
**Commit Style**: Conventional commits (feat:, fix:, docs:, etc.)

**📚 MANDATORY DOCUMENTATION RULE:**
- **CHANGELOG.md** → MUST update for ALL changes (no exceptions)
- **README.md** → MUST review/update for user-facing changes (no exceptions)
- **Related docs** → MUST update if behavior/architecture changes
- PRs without documentation updates will be rejected