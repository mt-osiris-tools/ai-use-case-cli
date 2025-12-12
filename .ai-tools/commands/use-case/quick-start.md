# Quick Start - Setup AI Use Cases CLI

You are helping the user get started with the AI Use Cases CLI for the first time.

## Your Task

Guide the user through the complete setup process, from installation to documenting their first session.

## Steps

### 1. Check if CLI is Already Installed

```bash
which ai-use-case && echo "✅ CLI installed" || echo "❌ CLI not found"
```

### 2. If Not Installed, Install the CLI

```bash
curl -fsSL https://raw.githubusercontent.com/mt-osiris-tools/ai-use-case-cli/main/install.sh | bash
```

The installer will:
- Clone CLI tools (default: `~/.local/share/ai-use-case-cli`, customizable via `AI_USECASES_CLI_ROOT`)
- Create symlink at `~/.local/bin/ai-use-case`
- Add `~/.local/bin` to PATH if needed
- Optionally set up the documentation hub

### 3. Reload Shell (if needed)

```bash
source ~/.bashrc  # or source ~/.zshrc
```

### 4. Verify Installation

```bash
ai-use-case --version
ai-use-case --help
```

### 5. Setup Current Project

If the user is in a project directory:

```bash
# Verify we're in a git repo
git rev-parse --show-toplevel

# Run setup
ai-use-case --init
```

### 6. Explain What Was Set Up

Tell the user:
- ✅ `.usecase/cases/` directory created in their project
- ✅ Git post-commit hook installed for auto-syncing
- ✅ Slash commands copied to `.ai-tools/commands/use-case/` (11 commands)
- ✅ `.claude/commands/` symlink created for Claude Code discovery
- ✅ `.gitignore` patterns added for draft files
- ✅ CLI tools ready for use

**Slash Command Discovery:**
- Commands stored in `.ai-tools/commands/use-case/` (AI-tool-agnostic)
- Symlink at `.claude/commands/` enables Claude Code to find them
- Verify: `ls -la .claude/commands` should show symlink → `../.ai-tools/commands`

### 7. Show Available Commands

CLI Commands:
- `ai-use-case document` - Document an AI session interactively
- `ai-use-case sync` - Manually sync to hub
- `ai-use-case search <term>` - Search documented use cases
- `ai-use-case stats` - View statistics
- `ai-use-case list` - List all projects
- `ai-use-case view` - Open hub in file explorer

Claude Code Slash Commands:
- `/use-case/document-session` - Document an AI session
- `/use-case/setup-project` - Setup another project
- `/use-case/sync-usecases` - Manual sync
- `/use-case/search-usecases` - Search past use cases
- `/use-case/publish-confluence` - Publish to Confluence

VS Code Extension:
- `Ctrl+Alt+D` / `Cmd+Alt+D` - Document session
- Command Palette → "AI Session: Document AI Session"
- GitHub Copilot Chat → `@workspace document my AI session`

### 8. Suggest First Documentation

Offer to help them document:
- Their current work session
- A recent completed task
- A test session to learn the workflow

Run: `ai-use-case document`

## Key Points to Emphasize

1. **Two-Repository Architecture:**
   - CLI tools (ai-use-case-cli) - Commands and scripts
   - Documentation hub (ai-use-case-hub) - Central storage
   - Hub location: `~/.local/share/ai-use-case-cli/hub` (or `$AI_USECASES_DIR`)

2. **Automatic Syncing:**
   - Happens on every git commit
   - Files copied from project to hub
   - Organized by project, date, and topic automatically

3. **Documentation Format:**
   - Filename: `YYYY-MM-DD_TICKET-XXXXX_description.md`
   - Template-based content
   - Captures time saved, tools used, results

4. **AI Tool Integration:**
   - Works with Claude Code
   - Works with GitHub Copilot
   - Works with both together
   - Documents which tool was used

## Troubleshooting Common Issues

### CLI command not found

```bash
# Check PATH
echo $PATH | grep ".local/bin"

# Add to PATH manually
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Not a git repository

```bash
cd /path/to/project
git init
git add .
git commit -m "Initial commit"
```

### Hub not set up

The CLI will work even without the hub, but to enable syncing:

```bash
# Hub is created automatically at ~/.local/share/ai-use-case-cli/hub
# Or set a custom location:
export AI_USECASES_DIR="$HOME/my-custom-hub-location"
```

Or re-run the installer and answer 'Y' to set up the hub.

### VS Code extension not working

- Install extension: `code --install-extension "${AI_USECASES_CLI_ROOT:-~/.local/share/ai-use-case-cli}/vscode-extension"`
- Check Settings → AI Session Documentor
- Ensure CLI is in PATH
- Reload VS Code window

## Next Steps

After setup, suggest:
1. Document current session: `ai-use-case document`
2. View statistics: `ai-use-case stats`
3. Set up additional projects: `ai-use-case --init` in each repo
4. Install VS Code extension (optional)
5. Explore slash commands in Claude Code

## Success Criteria

User should have:
- ✅ CLI installed and in PATH
- ✅ Current project set up (if applicable)
- ✅ Understanding of how syncing works
- ✅ Knowledge of how to document future sessions
- ✅ Awareness of available commands
- ✅ Hub repository set up (optional but recommended)
