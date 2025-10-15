# AI Use Case CLI

Command-line tools for documenting AI-assisted development workflows across multiple projects.

## Features

- 🚀 **One-command installation** - Get started in seconds
- 📝 **Interactive documentation** - Guided prompts for capturing AI sessions
- 🔄 **Automatic syncing** - Git hooks sync docs to central hub automatically
- 🎯 **Project setup** - Configure any project repository in minutes
- 🔍 **Search & stats** - Find and analyze documented use cases
- 🎨 **VS Code integration** - Document sessions from your editor

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
ai-use-case sync                # Sync use cases to hub
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

### Workflow

1. **Setup**: `ai-use-case --init` creates `docs/ai-use-cases/` in your project
2. **Document**: Create markdown files following the naming convention
3. **Commit**: Git hooks automatically sync to the central hub
4. **Organize**: Hub organizes docs by project, date, and topic using symlinks

### File Naming Convention

```
YYYY-MM-DD_TICKET-XXXXX_brief-description.md
```

Example:
```
2025-10-14_PROJ-1234_implement-user-authentication.md
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
```

## Project Setup Details

When you run `ai-use-case --init` in a project, it:

1. ✅ Creates `docs/ai-use-cases/` directory
2. ✅ Installs git post-commit hook for auto-sync
3. ✅ Adds patterns to `.gitignore` for draft files
4. ✅ Performs initial sync to hub
5. ✅ Creates README in the use cases directory

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

## Requirements

- **OS**: Linux, macOS, WSL on Windows
- **Shell**: Bash 4.0+
- **Git**: For version control and hooks
- **Dependencies**: `realpath`, `find`, `grep` (standard Unix tools)

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
├── git-hooks/
│   └── post-commit          # Auto-sync hook template
├── vscode-extension/        # VS Code extension
├── .claude/                 # Claude Code configuration
├── CLAUDE.md                # Instructions for Claude Code
└── README.md                # This file
```

### Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

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
