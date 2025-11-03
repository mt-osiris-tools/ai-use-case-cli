# AI Use Case CLI

Command-line tools for documenting AI-assisted development workflows across multiple projects.

## Why This Tool?

**Help developers on a daily basis** by making AI session documentation effortless:

- **Reduce cognitive overload**: Pre-built templates eliminate the "what should I document?" paralysis
- **Build a knowledge base**: Create a searchable repository of successful AI interactions and solutions
- **Learn and improve**: Reference past sessions to understand what works and replicate success patterns
- **Stay organized**: Automatic syncing and categorization keeps your AI work documented and accessible

Documentation shouldn't be a burden—it should be a valuable asset that grows your team's AI expertise.

## Features

- 🚀 **One-command installation** - Get started in seconds
- 📝 **Interactive documentation** - Guided prompts for capturing AI sessions
- 🔬 **Research session support** - Document exploratory sessions without code changes
- 🔄 **Automatic syncing** - Git hooks sync docs to central hub automatically
- 🎯 **Project setup** - Configure any project repository in minutes
- 🔍 **Search & stats** - Find and analyze documented use cases
- 🎨 **VS Code integration** - Document sessions from your editor
- 📤 **Confluence publishing** - Publish use cases to Confluence as child pages
- 🔔 **Update notifications** - Automatic version checking with smart caching

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

### First Time Setup

1. **Setup a project** for AI use case documentation:
   ```bash
   cd /path/to/your-project
   ai-use-case --init
   ```

2. **Work on your code** with AI assistance (Claude Code, GitHub Copilot, etc.)

3. **Document your session**:
   ```bash
   ai-use-case document
   ```

4. **View your documented cases**:
   ```bash
   ai-use-case stats
   ai-use-case search <keyword>
   ```

### Available Commands

```bash
ai-use-case --init              # Setup current project
ai-use-case document            # Document an AI session (interactive)
ai-use-case sync                # Sync use cases to hub (auto-commits/pushes)
ai-use-case push                # Manually commit and push hub changes
ai-use-case publish-confluence  # Publish use case to Confluence as child page
ai-use-case search <term>       # Search documented use cases
ai-use-case view                # Open hub in file explorer
ai-use-case list                # List all projects with use cases
ai-use-case stats               # Show statistics
ai-use-case --help              # Show all commands
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

1. **Setup**: `ai-use-case --init` creates `docs/ai-use-cases/` in your project
2. **Document**: Create markdown files following the naming convention
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

When you run `ai-use-case --init` in a project, it:

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

## VS Code Integration

Install the VS Code extension for one-click documentation:

```bash
code --install-extension ~/.local/share/ai-use-case-cli/vscode-extension
```

**Usage:**
- Command Palette: `AI Session: Document AI Session`
- Keyboard: `Ctrl+Alt+D` (Windows/Linux) or `Cmd+Alt+D` (Mac)
- Copilot Chat: `@workspace document my AI session`

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

### Document a Bug Fix

```bash
cd ~/projects/my-app
# Fix a bug with AI assistance
ai-use-case document

# Follow prompts:
# - Ticket: BUG-123
# - Description: Fix authentication timeout
# - AI Tool: Claude Code (Sonnet 4.5)
# - Complexity: Medium
# - Time saved: 1.5 hours
```

### Search for Similar Work

```bash
ai-use-case search authentication
# Returns all use cases related to authentication

ai-use-case search "react hooks"
# Search for React hooks patterns
```

### View Statistics

```bash
ai-use-case stats
# Shows:
# - Total use cases documented
# - Projects tracked
# - Time saved across all sessions
# - Most common AI tools used
```

### Push Hub Changes

If you have uncommitted changes in your hub repository:

```bash
ai-use-case push
# Interactively commits and pushes hub changes to remote
# Useful when sync didn't auto-push or for manual updates
```

### Publish to Confluence

Publish AI use case documentation to Confluence as a child page:

```bash
ai-use-case publish-confluence \
  docs/ai-use-cases/2025-W42-10-16_PROJ-123_auth.md \
  https://company.atlassian.net/wiki/spaces/DOCS/pages/123456/Parent

# With custom title
ai-use-case publish-confluence \
  --title "PROJ-123: Complete Authentication Implementation" \
  docs/ai-use-cases/2025-W42-10-16_PROJ-123_auth.md \
  https://company.atlassian.net/wiki/spaces/DOCS/pages/123456/Parent

# Dry run (preview without publishing)
ai-use-case publish-confluence --dry-run \
  docs/ai-use-cases/2025-W42-10-16_PROJ-123_auth.md \
  https://company.atlassian.net/wiki/spaces/DOCS/pages/123456/Parent
```

**Prerequisites for Confluence publishing:**
- Atlassian MCP server configured in Claude Code
- Valid Confluence authentication (SSE or Personal Access Token)
- Permission to create pages in the target Confluence space
- The command provides instructions for using with Claude Code's MCP integration

**Note:** This feature requires Claude Code with Atlassian MCP. The command validates your inputs and provides instructions for completing the publish via Claude Code.

## Requirements

- **OS**: Linux, macOS, WSL on Windows
- **Shell**: Bash 4.0+
- **Git**: For version control and hooks
- **Dependencies**: `realpath`, `find`, `grep` (standard Unix tools)

## Updates

The CLI automatically checks for updates once every 24 hours. If a new version is available, you'll see a notification message:

```
╭────────────────────────────────────────────────────╮
│ Update available: v2.2.0 (current: v2.1.0)        │
│ Run: cd ~/.local/share/ai-use-case-cli && git pull│
╰────────────────────────────────────────────────────╯
```

To update manually:

```bash
cd ~/.local/share/ai-use-case-cli
git pull
```

The version check is:
- **Non-blocking** - Runs in background, doesn't slow down commands
- **Cached** - Only checks once per 24 hours to minimize network calls
- **Silent on failure** - If GitHub is unreachable, commands work normally

To force a version check:

```bash
rm ~/.cache/ai-use-case-version-check
ai-use-case --version
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

# Test manual sync
ai-use-case sync /path/to/project
```

### Colors not rendering

If you see literal escape sequences like `\033[0;32m`, your terminal might not support ANSI colors or the scripts need updating. All scripts in v2.1+ use proper `$'...'` syntax for color variables.

## Development

### File Structure

```
ai-use-case-cli/
├── ai-use-case              # Main CLI entry point
├── install.sh               # Installation script
├── uninstall.sh             # Uninstallation script
├── setup-project.sh         # Project setup automation
├── sync-ai-use-cases.sh     # Sync logic
├── document-ai-session.sh   # Interactive documentor
├── publish-confluence.sh    # Confluence publishing script
├── git-hooks/
│   ├── pre-commit           # Branch protection hook
│   └── post-commit          # Auto-sync hook template
├── vscode-extension/        # VS Code extension
├── .claude/
│   └── commands/
│       ├── publish-confluence.md  # Claude Code slash command
│       └── ...              # Other slash commands
├── docs/
│   ├── CLAUDE.md            # Instructions for Claude Code
│   ├── CONFLUENCE-DESIGN.md # Confluence feature design
│   ├── HUB-SYNC-CHECKLIST.md # Hub synchronization guide
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

**Version**: 2.1.0
**Last Updated**: 2025-10-14
