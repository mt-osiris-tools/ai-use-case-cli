# AI Use Case CLI

**v3.1.0** - Hybrid CLI and Claude Code integration for documenting AI-assisted development workflows.

> **✨ NEW in v3.1.0**: Standalone CLI commands are back! Use either traditional bash commands or Claude Code slash commands - whatever fits your workflow best.

## Why This Tool?

**Help developers on a daily basis** by making AI session documentation effortless:

- **Reduce cognitive overload**: Pre-built templates eliminate the "what should I document?" paralysis
- **Build a knowledge base**: Create a searchable repository of successful AI interactions and solutions
- **Learn and improve**: Reference past sessions to understand what works and replicate success patterns
- **Stay organized**: Automatic syncing and categorization keeps your AI work documented and accessible

Documentation shouldn't be a burden—it should be a valuable asset that grows your team's AI expertise.

## Features

- 🎯 **Hybrid interface** - Use standalone CLI commands or Claude Code slash commands
- 🚀 **Claude Code integration** - AI-assisted documentation with automatic context capture
- 📝 **Quick CLI commands** - Fast bash commands for sync, search, stats, and more
- 🔬 **Research session support** - Document exploratory sessions without code changes
- 🔄 **Automatic syncing** - Git hooks sync docs to central hub automatically
- 🗂️ **Project registry** - Track and update all projects using the CLI
- 🔍 **Search & stats** - Find and analyze documented use cases
- 📤 **Confluence publishing** - Publish use cases to Confluence as child pages
- 🛠️ **Direct script access** - Advanced users can call scripts directly

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/mt-osiris-tools/ai-use-case-cli/main/install.sh | bash
```

Or clone and install manually:

```bash
git clone https://github.com/mt-osiris-tools/ai-use-case-cli.git ~/.local/share/ai-use-case-cli
cd ~/.local/share/ai-use-case-cli
./install.sh
```

## What Gets Installed

- Creates symlink to `~/.local/bin/ai-use-case` for global CLI access
- Optionally adds environment variables to your shell profile
- No system-wide changes - everything is user-scoped

## Usage

### Quick Start

**v3.1.0** offers flexibility - use either standalone commands or Claude Code integration:

1. **Setup a project**:
   ```bash
   ai-use-case --init
   # OR: /use-case:setup-project (in Claude Code)
   ```

2. **Work on your code**

3. **Document your session**:
   ```bash
   # With Claude Code (recommended for automatic capture):
   /use-case:document-session

   # Standalone interactive mode:
   ai-use-case document  # Redirects to Claude Code for best experience
   ```

4. **Other operations**:
   ```bash
   ai-use-case sync                  # Sync to hub
   ai-use-case search "authentication"  # Search use cases
   ai-use-case list                  # List all projects
   ai-use-case stats                 # View statistics
   ```

### Standalone CLI Commands

| Command | Description |
|---------|-------------|
| `ai-use-case --init` | Setup current project for AI use case tracking |
| `ai-use-case sync` | Sync use cases from project to hub |
| `ai-use-case search <term>` | Search documented use cases by keyword |
| `ai-use-case list` | List all registered projects |
| `ai-use-case stats` | View use case statistics |
| `ai-use-case view` | Open hub directory in file explorer |
| `ai-use-case push` | Push hub changes to remote repository |
| `ai-use-case publish-confluence` | Publish use case to Confluence |
| `ai-use-case uninstall` | Uninstall the CLI tool |
| `ai-use-case --version` | Show version information |
| `ai-use-case --help` | Show help message |

**Project Registry Commands (v3.1.0+):**

| Command | Description |
|---------|-------------|
| `ai-use-case list-projects` | List registered projects with versions |
| `ai-use-case check-updates` | Check which projects need CLI updates |
| `ai-use-case update-project <path>` | Update project to latest CLI version |

### Claude Code Slash Commands

For AI-assisted documentation with automatic context capture:

| Command | Description |
|---------|-------------|
| `/use-case:document-session` | Automatically document AI-assisted session (recommended) |
| `/use-case:setup-project` | Setup current project (alternative to `--init`) |
| `/use-case:sync-usecases` | Sync use cases from project to hub |
| `/use-case:search-usecases` | Search documented use cases by keyword |
| `/use-case:publish-confluence` | Publish use case to Confluence |
| `/use-case:quick-start` | Show quick start guide |
| `/use-case:list-projects` | List registered projects with versions |
| `/use-case:check-updates` | Check which projects need CLI updates |
| `/use-case:update-project` | Update a project to latest CLI version |

### Direct Script Access (Advanced)

For power users or automation, scripts can be called directly:

```bash
# Setup project
bash ~/.local/share/ai-use-case-cli/setup-project.sh .

# Document session (interactive)
bash ~/.local/share/ai-use-case-cli/document-ai-session.sh .

# Sync to hub
bash ~/.local/share/ai-use-case-cli/sync-ai-use-cases.sh .

# Search use cases
bash ~/.local/share/ai-use-case-cli/search-use-cases.sh <keyword>

# Show statistics
bash ~/.local/share/ai-use-case-cli/stats-use-cases.sh

# List projects
bash ~/.local/share/ai-use-case-cli/list-projects.sh

# View hub
bash ~/.local/share/ai-use-case-cli/view-hub.sh

# Push hub changes
bash ~/.local/share/ai-use-case-cli/push-hub.sh

# Publish to Confluence
bash ~/.local/share/ai-use-case-cli/publish-confluence.sh <file> <parent-page-url>
```

## How It Works

### Architecture

The AI Use Case CLI works with a separate documentation hub repository:

- **CLI Tools** (this repo): Scripts for documenting and managing use cases
- **Documentation Hub**: Central storage for all use case documents
  - Default location: `~/Documents/ai-use-case-hub`
  - Configured via `AI_USECASES_DIR` environment variable
  - Repository: [ai-use-case-hub](https://github.com/mt-osiris-tools/ai-use-case-hub)
  - Git tracking: `by-project/` files are versioned; `by-date/` and `by-topic/` symlinks are not

### Workflow

1. **Setup**: `/use-case:setup-project` (in Claude Code) creates `docs/ai-use-cases/` in your project
2. **Document**: `/use-case:document-session` automatically captures session details
3. **Commit**: Git hooks automatically sync to the central hub
4. **Push**: Changes are automatically committed and pushed to the hub repository
5. **Organize**: Hub organizes docs by project, date, and topic using symlinks

### Git Integration

The sync process now automatically:
- ✅ Copies files to the hub's `by-project/` directory (tracked in git)
- ✅ Creates symlinks in `by-date/` and `by-topic/` (not tracked - excluded via .gitignore)
- ✅ **Commits changes to the hub's git repository**
- ✅ **Pushes to the remote repository** (if configured)

This ensures all documented use cases are automatically backed up and shared across your team. The hub's architecture keeps actual files in `by-project/` under version control, while symlink directories remain local-only for efficient organization.

### File Naming Convention

```
YYYY-Www-MM-DD_TICKET-XXXXX_brief-description.md
```

Where `Www` is the ISO 8601 week number (W01-W53).

**Implementation Session Examples:**
```
2025-W42-10-14_PROJ-1234_implement-user-authentication.md
2025-W42-10-14_HUB-001_fix-color-encoding-in-cli-tools.md
```

**Research Session Examples:**
```
2025-W43-10-20_RESEARCH-001_evaluate-database-migration-strategies.md
2025-W43-10-20_RESEARCH-002_compare-authentication-approaches.md
```

The `RESEARCH-XXX` format is auto-generated for research sessions, or you can specify your own ticket format.

### Session Types

The CLI supports two types of AI sessions:

#### 1. Implementation Sessions (🎯 Code Changes)

For sessions that involve actual code modifications:
- Requires git commits and file changes
- Captures git statistics (files changed, lines added/removed)
- Includes code snippets and technical implementation details
- Uses project-specific tickets (e.g., `PROJ-1234`, `HUB-001`)

**When to use:**
- Implementing new features
- Fixing bugs
- Refactoring code
- Writing tests

#### 2. Research Sessions (🔬 Exploration)

For exploratory sessions without code changes:
- No git commits required
- Focuses on query refinement and decision-making
- Documents insights, approaches evaluated, and recommendations
- Uses `RESEARCH-XXX` tickets (auto-generated)

**When to use:**
- Exploring architectural approaches
- Evaluating multiple technical solutions
- Understanding existing codebases
- Making technology or design decisions
- Investigating issues before implementing fixes
- Back-and-forth conversations to refine complex queries

**Example research session workflow:**
```bash
# Start exploring with Claude Code
# Discuss approaches, refine queries, evaluate options
# No code changes made

# Document the research session
ai-use-case document
# > Select "Research" as session type
# > CLI auto-generates RESEARCH-001 ticket
# > Captures query evolution and insights
```

## Configuration

### Environment Variables

```bash
# Set custom hub location (optional)
export AI_USECASES_DIR="$HOME/Documents/ai-use-case-hub"

# Add to PATH (usually handled by install script)
export PATH="$HOME/.local/bin:$PATH"
```

Add these to your `~/.bashrc` or `~/.zshrc` for persistence.

### Hub Location

The CLI expects a documentation hub at `$AI_USECASES_DIR` or `~/Documents/ai-use-case-hub`.

To set up the hub:

```bash
cd ~/Documents
git clone https://github.com/mt-osiris-tools/ai-use-case-hub.git ai-use-case-hub
cd ai-use-case-hub

# Configure git remote if not already set
git remote add origin <your-hub-repository-url>
```

**Important**: Configure your hub's git remote to enable automatic pushing:
- The sync script will automatically commit and push changes
- Without a remote, changes are committed locally only
- Use `ai-use-case push` to manually sync uncommitted changes

## Project Setup Details

When you run `/use-case:setup-project` in Claude Code, it:

1. ✅ Creates `docs/ai-use-cases/` directory
2. ✅ Installs git **pre-commit hook** for branch protection
3. ✅ Installs git **post-commit hook** for auto-sync
4. ✅ Adds patterns to `.gitignore` for draft files
5. ✅ Performs initial sync to hub
6. ✅ Creates README in the use cases directory

### Branch Protection

The pre-commit hook **prevents direct commits to main/master branches**, enforcing a branch-based workflow:

```bash
# ❌ This will be blocked
git checkout main
git commit -m "direct commit to main"

# ✅ This is the correct workflow
git checkout -b feature/my-feature
git commit -m "commit to feature branch"
```

The hook provides clear guidance on creating feature branches with conventional naming:
- `feature/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation changes
- `refactor/description` - Code refactoring
- `test/description` - Test additions/changes

**Bypass (not recommended):** Use `git commit --no-verify` to bypass the hook in exceptional cases.

## Documentation Template

Use cases should capture:

- **Business Context**: Why the work was needed
- **Workflow Steps**: How you accomplished the task
- **Technical Details**: Tools, code patterns, key insights
- **Results & Impact**: Metrics, outcomes, success criteria
- **Key Learnings**: What worked, what didn't, improvements
- **Replicability**: How others can apply this workflow

See the [template](https://github.com/mt-osiris-tools/ai-use-case-hub/blob/main/TEMPLATE.md) for full structure.

## Migration Guide

### v3.1.0 - Standalone Commands Restored

**Good news!** v3.1.0 restores all standalone CLI commands while keeping Claude Code integration. No migration needed if you're upgrading from v2.x - your old commands still work!

**Available in v3.1.0:**
```bash
# All v2.x commands work again:
ai-use-case --init
ai-use-case sync
ai-use-case search authentication
```

**Plus Claude Code integration (optional):**
```
/use-case:document-session    # Automatic documentation with AI context
/use-case:sync-usecases
/use-case:search-usecases
```

**For Advanced Users:**
```bash
bash ~/.local/share/ai-use-case-cli/document-ai-session.sh
bash ~/.local/share/ai-use-case-cli/sync-ai-use-cases.sh
bash ~/.local/share/ai-use-case-cli/search-use-cases.sh authentication
```

### v3.0.0 Note

v3.0.0 briefly removed standalone commands. If you're on v3.0.0, upgrade to v3.1.0 to get them back!

### Why v3.1.0 is Best of Both Worlds

- ✅ **Standalone commands**: Fast, scriptable, works anywhere
- ✅ **Claude Code integration**: Automatic context capture for documentation
- ✅ **Flexibility**: Choose the interface that fits your workflow
- ✅ **Project registry**: Track all projects using the CLI

### Checking Your Version

```bash
ai-use-case --version
# Output: ai-use-case version 3.1.0
```

To update:
```bash
cd ~/.local/share/ai-use-case-cli && git pull
# OR: Simply re-run the install script
curl -fsSL https://raw.githubusercontent.com/mt-osiris-tools/ai-use-case-cli/main/install.sh | bash
```

## Uninstall

```bash
cd ~/.local/share/ai-use-case-cli
./uninstall.sh
```

This removes:
- Symlink from `~/.local/bin/`
- Optionally removes the CLI directory
- Optionally cleans shell profile entries

Note: Project-level setups (`docs/ai-use-cases/` and git hooks) remain intact in your projects.

## Examples

### Document a Bug Fix Session

In Claude Code, after fixing a bug:

```
/use-case:document-session
```

Claude Code automatically:
- Extracts ticket from commits
- Analyzes git changes (files, lines, commits)
- Captures conversation insights
- Generates complete documentation
- Syncs to hub

### Search for Similar Work

In Claude Code:

```
/use-case:search-usecases
```

Then specify your search term when prompted. Claude Code will search across all documented use cases and present results.

### Publish to Confluence

In Claude Code:

```
/use-case:publish-confluence
```

Follow the prompts to:
- Select the use case file
- Specify parent page URL
- Optionally customize the title
- Preview before publishing

**Prerequisites for Confluence publishing:**
- Atlassian MCP server configured in Claude Code
- Valid Confluence authentication
- Permission to create pages in the target space

## Requirements

- **OS**: Linux, macOS, WSL on Windows
- **Shell**: Bash 4.0+
- **Git**: For version control and hooks
- **Dependencies**: `realpath`, `find`, `grep` (standard Unix tools)

## Updates

To update to the latest version:

```bash
cd ~/.local/share/ai-use-case-cli
git pull
```

Check your current version:

```bash
ai-use-case --version
# Output: ai-use-case version 3.0.0
```

## Troubleshooting

### CLI command not found

```bash
# Check if ~/.local/bin is in PATH
echo $PATH | grep ".local/bin"

# Add to shell profile if missing
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Hook not syncing

```bash
# Check hook is executable
ls -la /path/to/project/.git/hooks/post-commit

# Make executable if needed
chmod +x /path/to/project/.git/hooks/post-commit

# Test manual sync in Claude Code
/use-case:sync-usecases

# Or call script directly
bash ~/.local/share/ai-use-case-cli/sync-ai-use-cases.sh /path/to/project
```

### Colors not rendering

If you see literal escape sequences like `\033[0;32m`, your terminal might not support ANSI colors or the scripts need updating. All scripts in v2.1+ use proper `$'...'` syntax for color variables.

## Development

### File Structure

```
ai-use-case-cli/
├── ai-use-case              # Main entry point (shows deprecation notice)
├── install.sh               # Installation script
├── uninstall.sh             # Uninstallation script
├── setup-project.sh         # Project setup automation
├── sync-ai-use-cases.sh     # Sync logic
├── document-ai-session.sh   # Interactive documentor
├── publish-confluence.sh    # Confluence publishing script
├── search-use-cases.sh      # Search functionality
├── stats-use-cases.sh       # Statistics display
├── list-projects.sh         # Project listing
├── view-hub.sh              # Hub viewer
├── push-hub.sh              # Hub push automation
├── git-hooks/
│   ├── pre-commit           # Branch protection hook
│   └── post-commit          # Auto-sync hook template
├── .claude/
│   └── commands/use-case/
│       ├── document-session.md    # Document AI session
│       ├── sync-usecases.md       # Sync to hub
│       ├── setup-project.md       # Setup project
│       ├── search-usecases.md     # Search use cases
│       ├── publish-confluence.md  # Publish to Confluence
│       └── quick-start.md         # Quick start guide
├── docs/
│   ├── CLAUDE.md            # Instructions for Claude Code
│   ├── CONFLUENCE-DESIGN.md # Confluence feature design
│   ├── HUB-SYNC-CHECKLIST.md # Hub synchronization guide
│   ├── VERSION-MANAGEMENT.md # Version management guide
│   └── ...                  # Other documentation
└── README.md                # This file
```

### Contributing

We welcome contributions! This project follows a branch-based workflow with pull requests.

**Quick Start:**

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes and commit (`git commit -m 'feat: Add amazing feature'`)
4. Update CHANGELOG.md under `## [Unreleased]`
5. Test your changes locally
6. Push to your fork (`git push origin feature/amazing-feature`)
7. Open a Pull Request

**Important:**
- All changes require a pull request (no direct commits to `main`)
- Use conventional commit messages (`feat:`, `fix:`, `docs:`, etc.)
- Update CHANGELOG.md with all changes
- Test changes before submitting PR

For complete guidelines, see [CONTRIBUTING.md](./CONTRIBUTING.md).

For GitHub branch protection setup, see [BRANCH-PROTECTION-SETUP.md](./docs/BRANCH-PROTECTION-SETUP.md).

## License

MIT License - see LICENSE file for details

## Related Projects

- **[ai-use-case-hub](https://github.com/mt-osiris-tools/ai-use-case-hub)** - Documentation hub repository
- **[claude-code](https://claude.com/code)** - AI coding assistant
- **[github-copilot](https://github.com/features/copilot)** - AI pair programmer

## Support

- **Issues**: [GitHub Issues](https://github.com/mt-osiris-tools/ai-use-case-cli/issues)
- **Discussions**: [GitHub Discussions](https://github.com/mt-osiris-tools/ai-use-case-cli/discussions)
- **Documentation**: [Quick Reference](https://github.com/mt-osiris-tools/ai-use-case-hub/blob/main/QUICK-REFERENCE.md)

---

**Version**: 3.0.0
**Last Updated**: 2025-11-02

**Major Changes in v3.0.0**: Standalone CLI commands removed in favor of Claude Code slash commands. See [Migration Guide](#migration-from-v2x-to-v3x) for details.
