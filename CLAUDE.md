# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This repository contains the **CLI tools** for documenting AI-assisted development workflows across multiple software projects. These are the command-line utilities that work together with a separate documentation hub repository.

**Architecture:**
- **This repo (ai-use-case-cli)**: CLI tools, scripts, VS Code extension
- **Hub repo (ai-use-case-hub)**: Central documentation storage with symlink-based organization

The CLI tools in this repository provide commands for setting up projects, documenting AI sessions, syncing documentation, and searching use cases.

## Installation for End Users

End users should install this CLI tool using:

```bash
curl -fsSL https://raw.githubusercontent.com/mt-osiris-tools/ai-use-case-cli/main/install.sh | bash
```

Or clone and install manually:

```bash
git clone https://github.com/mt-osiris-tools/ai-use-case-cli.git ~/.local/share/ai-use-case-cli
cd ~/.local/share/ai-use-case-cli
./install.sh
```

This creates a symlink at `~/.local/bin/ai-use-case` for global CLI access.

## What This Repository Contains

### Core CLI Tool

- **`ai-use-case`**: Main CLI entry point with unified command interface
  - `ai-use-case --init` - Setup a project
  - `ai-use-case document` - Document an AI session
  - `ai-use-case sync` - Sync to hub (auto-commits and pushes)
  - `ai-use-case push` - Manually commit and push hub changes
  - `ai-use-case search` - Search use cases
  - `ai-use-case stats` - Show statistics
  - `ai-use-case list` - List projects
  - `ai-use-case view` - Open hub in file explorer

### Shell Scripts

1. **`setup-project.sh`**: One-time setup for a project repository
   - Creates `docs/ai-use-cases/` directory in target project
   - Installs git post-commit hook
   - Adds `.gitignore` patterns for draft files
   - Performs initial sync to hub

2. **`sync-ai-use-cases.sh`**: Syncs documents from project to hub
   - Copies files from project's `docs/ai-use-cases/` to hub's `by-project/[project-name]/`
   - Creates symlinks in hub's `by-date/` based on YYYY-MM-DD prefix
   - Creates symlinks in hub's `by-topic/` based on topic slug
   - **Automatically commits changes to hub's git repository**
   - **Automatically pushes to remote repository** (if configured)
   - Idempotent - safe to run multiple times

3. **`document-ai-session.sh`**: Interactive AI session documentor
   - Guides you through documenting an AI-assisted coding session
   - Captures git changes, file modifications, timestamps
   - Auto-populates template with session data
   - Can be triggered from shell or VS Code extension
   - Integrates with existing sync workflow

4. **`install.sh`**: Installs the CLI tool globally
   - Creates symlink to `~/.local/bin/ai-use-case`
   - Optionally adds environment variables to shell profile
   - No system-wide changes - everything is user-scoped

5. **`uninstall.sh`**: Removes the CLI tool
   - Removes symlink from `~/.local/bin/`
   - Optionally removes the CLI directory
   - Optionally cleans shell profile entries

### Git Hook Template

- **`git-hooks/post-commit`**: Installed in each project's `.git/hooks/`
  - Detects when markdown files in `ai-use-cases/` directories are committed
  - Automatically triggers sync script to push docs to hub
  - Non-blocking - sync failures don't prevent commits

### VS Code Extension

- **`vscode-extension/`**: VS Code extension for one-click documentation
  - Triggered via Command Palette or keyboard shortcut (Ctrl+Alt+D)
  - Can be invoked from GitHub Copilot chat: `@workspace document my AI session`
  - Wraps the document-ai-session.sh script

### Claude Code Integration

- **`.claude/commands/`**: Slash commands for Claude Code
  - `/quick-start` - Get started guide
  - `/setup-project` - Setup a project
  - `/document-session` - Document an AI session (AUTOMATIC MODE)
  - `/sync-usecases` - Sync to hub
  - `/search-usecases` - Search use cases

## For Claude Code: Automatic Documentation

**IMPORTANT**: When the `/document-session` slash command is invoked in Claude Code, documentation should be **automatically generated** based on git history and conversation context. Do NOT run the interactive `document-ai-session.sh` script.

### Automatic vs Interactive Mode

The documentation system supports two modes:

**Automatic Mode (Claude Code):**
- Triggered by `/document-session` command in Claude Code
- Claude analyzes git history + conversation context
- Zero user prompts required
- Generates complete documentation with all sections filled
- Best for AI-assisted sessions where Claude has full context

**Interactive Mode (Manual Shell):**
- Triggered by `ai-use-case document` command in terminal
- User runs script directly without AI assistance
- Prompts user for all details interactively
- Best for manual documentation or when no AI context exists

### Automatic Documentation Workflow

When `/document-session` is invoked in Claude Code:

1. **Analyze Git History** (run commands in parallel):
   ```bash
   git log --since="24 hours ago" --pretty=format:"%h - %s (%ar)" | head -20
   git show --stat HEAD
   git diff HEAD~1..HEAD
   git status --short
   ```

2. **Extract Session Information** from:
   - Recent commit messages and descriptions
   - Conversation context with the user
   - Files changed and their purpose
   - Technical decisions and rationale discussed

3. **Auto-populate Documentation Fields**:
   - **Date**: Use today's date (YYYY-MM-DD format)
   - **Ticket**: Extract from commit messages or infer next number (e.g., HUB-XXX, PROJ-XXX)
   - **Brief description**: Summarize main work from commits and conversation
   - **AI Tool**: "Claude Code (Sonnet 4.5)"
   - **Complexity**: Assess from scope (Low: 1-3 files, Medium: 4-10, High: 10+)
   - **Time saved**: Estimate based on complexity (Low: 0.5-1h, Medium: 1-3h, High: 3-8h)
   - **TL;DR**: Summarize from conversation and commits
   - **Objective & Background**: Extract from conversation context
   - **Technical details**: Include git stats, file lists, code patterns
   - **Results**: Quantify files changed, commits made, outcomes achieved

4. **Generate Complete Documentation File**:
   - Create file in `docs/ai-use-cases/` with proper naming convention
   - Follow TEMPLATE.md structure from hub repository
   - Include all sections with real data (NO "TODO" or placeholders)
   - Use conversation context for qualitative insights
   - Use git data for quantitative metrics

5. **Commit and Sync**:
   ```bash
   git add docs/ai-use-cases/YYYY-MM-DD_TICKET-XXX_description.md
   git commit -m "docs: AI session YYYY-MM-DD - TICKET-XXX - Brief description

   [Details about what was documented...]

   🤖 Generated with [Claude Code](https://claude.com/claude-code)

   Co-Authored-By: Claude <noreply@anthropic.com>"

   # Sync to hub
   ai-use-case sync
   ```

### Key Principles for Claude Code

1. **Be Automatic**: Don't ask the user to fill anything - you have all the context
2. **Be Complete**: Generate comprehensive documentation with all sections filled
3. **Be Precise**: Use exact numbers from git (files, lines, commits)
4. **Be Contextual**: Use conversation history for qualitative insights
5. **Be Professional**: Follow template structure, use proper formatting

### Example Automatic Documentation

See the hub repository for examples:
- `2025-10-14_HUB-001_fix-color-encoding-in-cli-tools.md`
- `2025-10-14_HUB-002_update-github-organization-references.md`
- `2025-10-14_HUB-003_enable-automatic-ai-session-documentation.md`

All were auto-generated by Claude Code with complete sections and no placeholders.

## Documentation Hub Repository

The CLI tools sync documentation to a **separate hub repository** that provides:

- **`by-project/`**: Canonical storage - all actual markdown files
- **`by-date/`**: View layer - symlinks organized by YYYY/MM/
- **`by-topic/`**: View layer - symlinks organized by topic slug
- **`TEMPLATE.md`**: Comprehensive use case template
- **`QUICK-REFERENCE.md`**: Command reference guide
- **`CHANGELOG.md`**: Version history

The hub repository should be cloned separately:

```bash
cd ~/Documents
git clone https://github.com/mt-osiris-tools/ai-use-case-hub.git ai-use-case-hub
```

## File Naming Convention

All use case documents created by these tools MUST follow this pattern:
```
YYYY-MM-DD_TICKET-XXXXX_brief-description.md
```

**Examples:**
- `2025-10-13_LSFB-63055_add-environment-parameter-message-flow.md`
- `2025-10-14_PROJ-1234_implement-user-authentication.md`

**Parsing logic:**
- Date extraction: `^([0-9]{4})-([0-9]{2})-([0-9]{2})`
- Ticket and topic: `_([A-Z]+-[0-9]+)_(.+)\.md$`

The sync script uses regex to parse filenames and organize symlinks in the hub.

## Environment Variables

The scripts support these optional environment variables:

```bash
# Location of the documentation hub (not this CLI repo)
export AI_USECASES_DIR="$HOME/Documents/ai-use-case-hub"

# Path to the sync script (auto-detected if AI_USECASES_DIR is set)
export AI_USECASES_SYNC_SCRIPT="$AI_USECASES_DIR/sync-ai-use-cases.sh"
```

**Note**: If `AI_USECASES_DIR` is not set, scripts default to:
1. Directory where the script is located (for development)
2. `$HOME/Documents/ai-use-case-hub` (for installed hub)

## Common Commands (End User Perspective)

### Setting Up a New Project

```bash
cd /path/to/your/project
ai-use-case --init
```

This runs `setup-project.sh` which:
- Creates `docs/ai-use-cases/` in the project
- Installs post-commit hook
- Adds `.gitignore` patterns
- Runs initial sync to hub

### Documenting an AI Session

```bash
cd /path/to/your/project
ai-use-case document
```

This runs `document-ai-session.sh` which:
- Collects git changes and session statistics
- Guides you through interactive prompts
- Generates documentation using the hub's TEMPLATE.md
- Saves to `docs/ai-use-cases/` with proper naming
- Optionally commits and syncs automatically

### Manual Sync

```bash
cd /path/to/your/project
ai-use-case sync
```

This will:
1. Copy documentation files to the hub
2. Create appropriate symlinks
3. Commit changes to the hub's git repository
4. Push to the remote repository (if configured)

### Manual Push (Hub Only)

If you need to commit and push hub changes without syncing:

```bash
ai-use-case push
```

This interactively commits any uncommitted changes in the hub and pushes to the remote.

### Searching Use Cases

```bash
ai-use-case search authentication
```

### Viewing Statistics

```bash
ai-use-case stats
```

## Development Workflow

When developing or modifying this CLI tool repository:

### Script Development

All scripts are self-contained bash scripts with embedded documentation. They:
- Use `set -e` for fail-fast behavior
- Include color-coded output for user feedback
- Support both environment variables and auto-detection for paths
- Are idempotent where applicable

### Path Resolution Strategy

Scripts resolve paths in this priority order:
1. `AI_USECASES_DIR` environment variable (points to hub)
2. Script's own directory (for development and installed scenarios)
3. Default: `$HOME/Documents/ai-use-case-hub`

### Testing Changes

```bash
# Test CLI wrapper
./ai-use-case --help

# Test setup script
./setup-project.sh /tmp/test-project

# Test sync script
./sync-ai-use-cases.sh /tmp/test-project

# Test documentation script
./document-ai-session.sh /tmp/test-project
```

### VS Code Extension Development

```bash
cd vscode-extension
npm install
npm run compile
# Press F5 in VS Code to launch Extension Development Host
```

## Important Constraints

1. **This repo contains tools only** - no `by-project/`, `by-date/`, or `by-topic/` directories. Those are in the hub repository.

2. **Respect the naming convention** - the sync script regex depends on it:
   - Must start with YYYY-MM-DD
   - Must include TICKET-XXXXX format
   - Must have descriptive slug after ticket

3. **CLI tools are version controlled here** - Scripts, documentation, and extension code are tracked in this repository.

4. **Hub infrastructure is separate** - The documentation hub with its symlink architecture is a separate repository.

5. **Scripts must work in multiple contexts**:
   - Installed globally via symlink
   - Run directly from git clone
   - Called from VS Code extension
   - Invoked via Claude Code slash commands

## Workflow for Creating New Use Cases (User Perspective)

**Option 1: Automated (Recommended)**
1. Complete your AI-assisted coding session
2. Run `ai-use-case document` (or use VS Code command)
3. Follow interactive prompts
4. Script generates documentation, commits, and syncs automatically

**Option 2: Manual**
1. Navigate to your project
2. Create markdown file in `docs/ai-use-cases/` with proper naming
3. Document your AI-assisted work using the template
4. Commit the file with git
5. Post-commit hook automatically syncs to hub

**Result (both options):**
File appears in the hub at:
- `by-project/[project-name]/[filename].md` (actual file)
- `by-date/[year]/[month]/[project]_[filename].md` (symlink)
- `by-topic/[topic-slug]/[project]_[filename].md` (symlink)

## Key Files in This Repository

- **ai-use-case**: Main CLI entry point
- **setup-project.sh**: Project configuration script
- **sync-ai-use-cases.sh**: Synchronization script
- **document-ai-session.sh**: Interactive AI session documentor
- **install.sh**: Installation script
- **uninstall.sh**: Uninstallation script
- **git-hooks/post-commit**: Hook template for auto-sync
- **vscode-extension/**: VS Code extension for one-click documentation
- **README.md**: User-facing documentation
- **CLAUDE.md**: This file - guidance for Claude Code

## Troubleshooting

### CLI command not found

```bash
# Check if ~/.local/bin is in PATH
echo $PATH | grep ".local/bin"

# Add to shell profile if missing
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Hook not executing

```bash
# Check if executable
ls -la /path/to/project/.git/hooks/post-commit

# Make executable
chmod +x /path/to/project/.git/hooks/post-commit
```

### Sync failing

```bash
# Debug mode
bash -x ~/.local/bin/ai-use-case sync

# Check hub exists
ls ~/Documents/ai-use-case-hub
```

### Hub repository not found

```bash
# Clone the hub repository
cd ~/Documents
git clone https://github.com/mt-osiris-tools/ai-use-case-hub.git ai-use-case-hub
```

## Version Checking

The CLI includes automatic version checking to keep users informed of updates:

- **Automatic checks**: Runs once every 24 hours (cached in `~/.cache/ai-use-case-version-check`)
- **Non-blocking**: Executes in background, doesn't delay command execution
- **GitHub integration**: Fetches latest version from main branch via curl/wget
- **Smart caching**: Only checks GitHub once per day to reduce network traffic
- **Silent failures**: If GitHub is unreachable, continues without errors

When an update is detected, users see:
```
╭────────────────────────────────────────────────────╮
│ Update available: v2.2.0 (current: v2.1.0)        │
│ Run: cd ~/.local/share/ai-use-case-cli && git pull│
╰────────────────────────────────────────────────────╯
```

Implementation is in `ai-use-case:80-115` with the `check_for_updates()` function.

## Version History

- **v2.1.0**: Separated CLI tools from documentation hub, unified CLI interface, added automatic git push, version checking
- **v2.0.0**: Introduced symlink architecture (in hub repository)
- **v1.0.0**: Initial release with basic sync functionality

## Related Repositories

- **[ai-use-case-hub](https://github.com/mt-osiris-tools/ai-use-case-hub)** - Documentation hub with symlink-based organization
- **[claude-code](https://claude.com/code)** - AI coding assistant
- **[github-copilot](https://github.com/features/copilot)** - AI pair programmer
