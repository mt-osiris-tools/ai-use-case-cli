# GitHub Copilot Integration Guide

## Overview

The AI Use Case CLI provides seamless integration with GitHub Copilot through custom prompts in VS Code. This allows you to document AI coding sessions, search past use cases, and manage your documentation directly from GitHub Copilot Chat.

## Features

- **Custom Prompts**: 5 core prompts accessible via `/` in Copilot Chat
- **Workspace-Specific**: Prompts configured per project in `.github/prompts/use-case/`
- **Automatic Updates**: Symlinks ensure prompts stay current with CLI updates
- **Multi-Agent Support**: Works alongside Claude Code and Codex integrations

## Setup

### Prerequisites

- **VS Code**: Version with GitHub Copilot support
- **GitHub Copilot**: Active GitHub Copilot subscription
- **ai-use-case CLI**: Installed and configured

### Option 1: During Initial Project Setup

When running `ai-use-case --init`, select GitHub Copilot from the agent menu:

```bash
cd your-project
ai-use-case --init
```

**Agent Selection Menu**:
```
=== AI Agent Configuration ===

Which AI coding agent(s) would you like to configure for this project?

  1. Claude Code (default)
  2. GitHub Copilot
  3. Codex
  4. Multiple agents
  5. None

Select option (1-5) [1]: 2
```

### Option 2: Add to Existing Project

If you've already initialized your project, add Copilot integration:

```bash
ai-use-case --setup-copilot
```

### Option 3: Multiple Agents

To use GitHub Copilot alongside Claude Code or Codex:

```bash
ai-use-case --init
# Select option 4 (Multiple agents)
# Enter: 1 2 (for Claude Code + Copilot)
```

## What Gets Set Up

The setup creates:

```
your-project/
├── .github/
│   └── prompts/
│       └── use-case/              # Symlink to CLI prompts
│           ├── document-session.prompt.md
│           ├── setup-project.prompt.md
│           ├── sync-usecases.prompt.md
│           ├── search-usecases.prompt.md
│           └── quick-start.prompt.md
└── .vscode/
    └── settings.json              # Copilot configuration
```

**Symlink Architecture**:
- Project prompts symlink to `~/.local/share/ai-use-case-cli/.github/prompts/use-case/`
- CLI updates automatically propagate to all projects
- No manual file copying required

**VS Code Configuration**:
- `.vscode/settings.json` is created/updated with required Copilot settings
- Enables custom prompts via `chat.promptFiles: true`
- Configures prompt location via `chat.promptFilesLocations`

## Available Prompts

### 1. `/use-case:document-session`

**Purpose**: Document your current AI coding session automatically

**What it does**:
- Analyzes git history for recent commits
- Detects merged PRs from last 24 hours
- Evaluates current conversation for documentation value
- Generates comprehensive markdown documentation
- Syncs to your documentation hub

**Usage**:
1. Open Copilot Chat (Ctrl+Alt+I / Cmd+Alt+I)
2. Type: `/use-case:document-session`
3. Choose what to document (PR, commits, or research session)
4. AI generates complete documentation automatically

**Example**:
```
You: /use-case:document-session
Copilot: I'll help document your AI session...
         [Analyzes recent work and presents options]
```

### 2. `/use-case:setup-project`

**Purpose**: Initialize another project with ai-use-case documentation

**What it does**:
- Guides through project setup
- Configures `.usecase/cases/` directory
- Installs git hooks for auto-syncing
- Sets up agent integrations

**Usage**:
```
/use-case:setup-project
```

### 3. `/use-case:sync-usecases`

**Purpose**: Manually sync documentation to hub

**What it does**:
- Copies use case files from project to hub
- Organizes by project, date, and topic
- Updates symlinks
- Shows sync statistics

**Usage**:
```
/use-case:sync-usecases
```

**When to use**:
- After creating documentation manually
- To verify auto-sync is working
- When troubleshooting sync issues

### 4. `/use-case:search-usecases`

**Purpose**: Search your documented use cases

**What it does**:
- Searches by keyword, topic, or date
- Shows matching files
- Can read full content
- Provides analysis of patterns

**Usage**:
```
You: /use-case:search-usecases
Copilot: What would you like to search for?
You: authentication patterns
Copilot: [Shows matching use cases and offers to read them]
```

### 5. `/use-case:quick-start`

**Purpose**: First-time setup guide

**What it does**:
- Checks if CLI is installed
- Guides through installation if needed
- Explains core concepts
- Shows available commands

**Usage**:
```
/use-case:quick-start
```

## Usage in VS Code

### Accessing Prompts

1. **Open Copilot Chat**:
   - Keyboard: `Ctrl+Alt+I` (Windows/Linux) or `Cmd+Alt+I` (Mac)
   - Or: View → Command Palette → "GitHub Copilot: Open Chat"

2. **Type `/` to see available prompts**:
   - Scroll to find `/use-case:*` prompts
   - Or type `/use-case:` to filter

3. **Select and execute**:
   - Click on prompt or press Enter
   - Follow interactive prompts

### Tips for Best Results

**Be Specific**: When documenting, select specific PRs or commits rather than "everything"

**Use Regularly**: Document sessions while context is fresh (within 24 hours)

**Follow Naming**: Use the suggested filename format: `YYYY-Www-MM-DD_TICKET-XXX_description.md`

**Review Before Committing**: Check generated documentation before committing (implementation sessions)

**Combine Agents**: Use both Claude Code and Copilot for different aspects of your workflow

## Architecture

### How It Works

1. **Prompt Discovery**: VS Code reads `.github/prompts/use-case/*.prompt.md` files
2. **Symlink Resolution**: Prompts are symlinked to CLI installation
3. **Invocation**: User types `/use-case:` in Copilot Chat
4. **Execution**: Copilot processes prompt instructions
5. **Tool Usage**: Copilot uses bash commands, file operations, and AI analysis

### File Format

Each prompt file uses this structure:

```markdown
---
description: One-line description for menu
---

# Prompt Title

Your task instructions here...

## Steps
...
```

**YAML Frontmatter**:
- `description`: Shown in VS Code's prompt menu
- Additional fields (agent, tools, model) are optional

**Body**:
- Markdown formatting
- Detailed instructions for the AI
- Step-by-step workflows
- Examples and best practices

### Update Mechanism

**Automatic Updates**:
1. CLI update brings new prompt versions
2. Symlinks point to updated files
3. Projects see new versions immediately
4. No manual intervention required

**Reload VS Code**: After CLI updates, reload VS Code window:
- Command Palette → "Developer: Reload Window"
- Or restart VS Code

## Troubleshooting

### Prompts Not Appearing

**Symptoms**: `/use-case:*` prompts don't show in Copilot Chat

**Solutions**:

1. **Verify VS Code Settings** (Most Common Issue):

   GitHub Copilot requires VS Code settings to enable custom prompts.

   Check if `.vscode/settings.json` contains:
   ```json
   {
     "chat.promptFiles": true,
     "chat.promptFilesLocations": {
       ".github/prompts": true
     }
   }
   ```

   **Auto-fix**: Re-run setup to auto-configure:
   ```bash
   ai-use-case --setup-copilot
   ```

   **Manual fix**: Add the above settings to `.vscode/settings.json`

2. **Reload VS Code Window**:
   ```
   Ctrl+Shift+P → "Developer: Reload Window"
   ```

2. **Verify Symlink**:
   ```bash
   ls -la .github/prompts/use-case
   # Should show: use-case -> ../../../../.../.github/prompts/use-case
   ```

3. **Check CLI Installation**:
   ```bash
   ls ~/.local/share/ai-use-case-cli/.github/prompts/use-case/
   # Should show 5 .prompt.md files
   ```

4. **Re-run Setup**:
   ```bash
   ai-use-case --setup-copilot
   ```

### Symlink Broken

**Symptoms**: Symlink points to wrong location or is broken

**Solutions**:

1. **Remove and Recreate**:
   ```bash
   rm .github/prompts/use-case
   ai-use-case --setup-copilot
   ```

2. **Check CLI Location**:
   ```bash
   echo $AI_USECASES_CLI_ROOT
   which ai-use-case
   ```

3. **Manual Symlink** (if needed):
   ```bash
   ln -s ~/.local/share/ai-use-case-cli/.github/prompts/use-case .github/prompts/use-case
   ```

### Prompts Execute But Fail

**Symptoms**: Prompts appear but commands fail to execute

**Possible Causes**:

1. **Git not configured**:
   ```bash
   git config --global user.email
   git config --global user.name
   ```

2. **CLI not in PATH**:
   ```bash
   which ai-use-case
   # Should show: /home/user/.local/bin/ai-use-case
   ```

3. **Project not initialized**:
   ```bash
   ai-use-case --init
   ```

4. **Hub not set up**:
   ```bash
   ai-use-case config show
   ```

### GitHub CLI Not Available

**Symptoms**: PR detection skipped, only commits shown

**Solution**: Install and authenticate GitHub CLI:

```bash
# Install gh (varies by OS)
# macOS:
brew install gh

# Ubuntu/Debian:
sudo apt install gh

# Authenticate:
gh auth login
```

**Note**: GitHub CLI is optional. The CLI works without it, but PR detection is disabled.

## Comparison with Other Agents

### GitHub Copilot vs Claude Code

| Feature | GitHub Copilot | Claude Code |
|---------|----------------|-------------|
| **Location** | `.github/prompts/` | `.claude/commands/` |
| **Format** | `.prompt.md` | `.md` |
| **Scope** | Workspace-specific | Workspace-specific |
| **Update Method** | Symlinks | Symlinks |
| **Invocation** | `/use-case:name` | `/use-case:name` |
| **IDE Integration** | VS Code only | VS Code, CLI, API |

### GitHub Copilot vs Codex

| Feature | GitHub Copilot | Codex |
|---------|----------------|-------|
| **Location** | `.github/prompts/` | `~/.codex/prompts/` |
| **Format** | `.prompt.md` | `.md` (YAML frontmatter) |
| **Scope** | Per-project | Global (user-wide) |
| **Update Method** | Symlinks | Copy files |
| **Invocation** | `/use-case:name` | `/prompts:use-case-name` |
| **Parameters** | Interactive | Hybrid (optional params) |

### Using Multiple Agents

**Best Practices**:

- **Claude Code**: Deep code analysis, complex refactoring
- **GitHub Copilot**: Quick documentation, inline suggestions
- **Codex**: Cross-project workflows, global prompts

**Setup All Three**:
```bash
ai-use-case --init
# Select option 4 (Multiple agents)
# Enter: 1 2 3 (Claude + Copilot + Codex)
```

## Advanced Configuration

### Custom Installation Location

If you installed the CLI in a custom location:

```bash
export AI_USECASES_CLI_ROOT="/custom/path/to/cli"
ai-use-case --setup-copilot
```

### Per-Project Customization

**Not Recommended**: While you can break the symlink and create custom prompts, you'll lose automatic updates.

**Alternative**: Contribute improvements back to the CLI repository.

### Adding Your Own Prompts

To add custom prompts alongside use-case prompts:

1. Create additional prompt files in `.github/prompts/`:
   ```bash
   touch .github/prompts/my-custom-prompt.prompt.md
   ```

2. Add YAML frontmatter and instructions:
   ```markdown
   ---
   description: My custom workflow
   ---

   # My Custom Prompt
   ...
   ```

3. Access via `/my-custom-prompt` in Copilot Chat

**Note**: Custom prompts should NOT be in the `use-case/` subdirectory (that's a symlink).

## Best Practices

### Documentation Workflow

1. **Work on Feature**: Code as usual with Copilot assistance
2. **Commit Changes**: Make normal git commits
3. **Document Session**: Run `/use-case:document-session` within 24 hours
4. **Select What to Document**: Choose PR, commits, or research session
5. **Review Generated Doc**: Check accuracy and completeness
6. **Commit Documentation**: Git commit triggers auto-sync to hub

### Organizing Use Cases

**Filename Convention**:
```
YYYY-Www-MM-DD_TICKET-XXX_brief-description.md
```

**Examples**:
```
2025-W50-12-14_FEAT-123_add-copilot-prompts.md
2025-W50-12-15_RESEARCH-001_evaluate-auth-strategies.md
```

**Hub Organization**:
- `by-project/your-project/` - All use cases for your project
- `by-date/2025/12/` - Use cases by month
- `by-topic/feature-development/` - Use cases by topic

### Search Strategy

**By Keyword**:
```
/use-case:search-usecases
> Search for: "authentication"
```

**By Project**:
```bash
ls ~/.local/share/ai-use-case-cli/hub/by-project/my-app/
```

**By Date**:
```bash
ls ~/.local/share/ai-use-case-cli/hub/by-date/2025/12/
```

**By Topic**:
```bash
ls ~/.local/share/ai-use-case-cli/hub/by-topic/
```

## Migration Guide

### From Claude Code Only

If you currently use Claude Code and want to add Copilot:

```bash
# In your project:
ai-use-case --setup-copilot

# Verify both work:
ls -la .claude/commands/use-case  # Claude Code symlink
ls -la .github/prompts/use-case   # Copilot symlink
```

**Both agents now have access to the same commands!**

### From Codex Only

If you currently use Codex and want to add Copilot:

```bash
ai-use-case --setup-copilot
```

**Difference**: Codex prompts are global (`~/.codex/prompts/`), Copilot prompts are per-project (`.github/prompts/`).

### From No Agent

If you haven't configured any agent yet:

```bash
ai-use-case --init
# Select GitHub Copilot during setup
```

## Examples

### Example 1: Document a Feature Implementation

```
You: /use-case:document-session

Copilot: I'll help you document an AI session. Let me check your recent work...

         What would you like to document?
         1. PR #45: Add GitHub Copilot custom prompts
         2. Current conversation
         3. Both

You: 1

Copilot: [Analyzes PR, generates documentation]
         ✅ Documentation created:
            .usecase/cases/2025-W50-12-14_FEAT-045_github-copilot-prompts.md

         Summary:
         - 12 files changed
         - 850 lines added
         - Time saved: ~3 hours
```

### Example 2: Search Past Use Cases

```
You: /use-case:search-usecases

Copilot: What would you like to search for?

You: Show me authentication-related use cases from the last 3 months

Copilot: Found 4 authentication use cases:
         1. 2025-W48-12-01_SEC-078_implement-jwt-auth.md
         2. 2025-W47-11-24_SEC-072_add-oauth-integration.md
         3. 2025-W45-11-10_RESEARCH-003_evaluate-auth-strategies.md
         4. 2025-W43-10-28_SEC-065_fix-session-expiry.md

         Would you like me to read any of these?
```

### Example 3: Sync Documentation

```
You: /use-case:sync-usecases

Copilot: Let me sync your use cases to the hub...

         Files to sync:
         - 2025-W50-12-14_FEAT-045_github-copilot-prompts.md
         - 2025-W50-12-13_FEAT-044_update-agent-selection.md

         Running: ai-use-case sync

         ✅ Synced 2 files to:
            - by-project/ai-use-case-cli/
            - by-date/2025/12/
            - by-topic/feature-development/
```

## FAQ

**Q: Do I need GitHub Copilot Pro?**
A: Any GitHub Copilot subscription works (Individual, Business, or Enterprise).

**Q: Can I use this outside of VS Code?**
A: The prompts are VS Code-specific. Use Claude Code or Codex integrations for CLI usage.

**Q: Will prompts work in GitHub.com?**
A: No, these are VS Code custom prompts, not GitHub Copilot Chat on github.com.

**Q: How do I update prompts after CLI updates?**
A: Prompts auto-update via symlinks. Just reload VS Code window.

**Q: Can I modify the prompts?**
A: You can, but you'll lose auto-updates. Contribute changes to the CLI repo instead.

**Q: Do prompts require internet?**
A: Yes, Copilot Chat requires connection to GitHub services.

**Q: Is my code sent to GitHub?**
A: Only what Copilot normally sends. Prompts run locally and use local CLI tools.

## Support

### Getting Help

- **GitHub Issues**: [Report bugs or request features](https://github.com/mt-osiris-tools/ai-use-case-cli/issues)
- **Discussions**: [Ask questions](https://github.com/mt-osiris-tools/ai-use-case-cli/discussions)
- **Documentation**: [Full docs](https://github.com/mt-osiris-tools/ai-use-case-cli/tree/main/docs)

### Contributing

Found an issue or want to improve the prompts?

1. Fork the repository
2. Edit prompts in `.github/prompts/use-case/`
3. Test locally
4. Submit a pull request

See [CONTRIBUTING.md](../../../CONTRIBUTING.md) for guidelines.

## Related Documentation

- [Main README](../../../README.md) - Overview and quick start
- [Claude Code Integration](../claude/GUIDE.md) - Claude Code setup
- [Codex Integration](../../USAGE-GUIDE.md#codex-integration) - Codex setup
- [Template Guide](../../TEMPLATE.md) - Documentation template format
- [Workflow Guide](../../WORKFLOW.md) - Full workflow documentation

## Changelog

See [CHANGELOG.md](../../../CHANGELOG.md) for version history and updates to Copilot integration.

---

**Ready to start documenting with GitHub Copilot?**

```bash
ai-use-case --setup-copilot
```

Then open VS Code Copilot Chat and type `/use-case:` to begin!
