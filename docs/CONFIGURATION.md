# Configuration Guide

Complete guide for configuring AI Use Case CLI to fit your workflow.

## Table of Contents

- [Hub Configuration](#hub-configuration)
- [Environment Variables](#environment-variables)
- [Tracing and Monitoring](#tracing-and-monitoring)
- [Project Registry](#project-registry)
- [Git Hooks](#git-hooks)
- [Advanced Configuration](#advanced-configuration)

## Hub Configuration

When you run `ai-use-case --init` for the first time, you'll choose how to store your documentation.

### Hub Modes

#### 1. Local Only (Default)

**Description**: Store documentation locally without version control.

**Storage Location**: `~/.local/share/ai-use-case-cli/hub/`

**Characteristics**:
- No git repository
- No remote synchronization
- No version control
- Complete privacy - everything stays on your machine

**Best For**:
- Personal documentation
- Quick local reference
- Privacy-sensitive environments
- Simple setup without git

**Setup**:
```bash
ai-use-case --init
# Select "Local Only" when prompted
```

#### 2. Private Git

**Description**: Connect to your own private git repository with full version control.

**Storage Location**: Your chosen git repository path

**Characteristics**:
- Full git version control
- Remote synchronization to your chosen remote
- Commit history and rollback capability
- You control repository access and permissions

**Best For**:
- Team documentation sharing
- Version-controlled workflow
- Backup to remote repository
- Collaborative environments

**Setup**:
```bash
ai-use-case --init
# Select "Private Git" when prompted
# Provide your repository URL when asked
```

### Managing Configuration

View current configuration:
```bash
ai-use-case config show
```

Output shows:
- Current hub mode (local or private git)
- Hub location path
- Git repository status (if applicable)
- Last sync information

Change hub mode:
```bash
ai-use-case config reconfigure
```

This allows you to:
- Switch from local-only to private git
- Switch from private git to local-only
- Change git repository URL
- Migrate existing documentation

### Reset Configuration

Start fresh or fix configuration issues:

```bash
# Preview what would be reset (dry-run)
ai-use-case reset --config --dry-run

# Reset only configuration files
ai-use-case reset --config

# Reset tracing setup
ai-use-case reset --tracing

# Reset project registry
ai-use-case reset --registry

# Reset everything (prompts for confirmation)
ai-use-case reset --all

# See all options
ai-use-case reset --help
```

**Important**: The hub directory is protected and requires explicit `--hub` flag to delete (only works in local-only mode).

## Environment Variables

### CLI Installation Directory

Override the CLI installation location:

```bash
# Default location
export AI_USECASES_CLI_ROOT="$HOME/.local/share/ai-use-case-cli"

# Custom location
export AI_USECASES_CLI_ROOT="$HOME/custom/path/ai-use-case-cli"
```

**When to Use**:
- Custom installation paths
- Multiple CLI versions
- Non-standard directory structures

### Hub Directory

Override the hub storage location:

```bash
# Default for local mode
export AI_USECASES_DIR="$HOME/.local/share/ai-use-case-cli/hub"

# Custom location
export AI_USECASES_DIR="$HOME/Documents/my-custom-hub"
```

**When to Use**:
- Custom hub locations
- Shared network storage
- Different disk partitions

**Note**: Works with both local-only and private git modes.

### PATH Configuration

Ensure CLI is accessible from anywhere:

```bash
# Add to PATH
export PATH="$HOME/.local/bin:$PATH"
```

**Make Persistent**:

Add to your shell profile:

```bash
# For bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# For zsh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## Tracing and Monitoring

Monitor CLI performance and usage with OpenTelemetry tracing.

### Quick Setup (Recommended)

One-command initialization:
```bash
# Initialize config + install dependencies
ai-use-case tracing init

# Enable tracing
ai-use-case tracing enable

# Verify it works
ai-use-case tracing test
```

### Manual Setup

Step-by-step installation:

```bash
# 1. Install dependencies
ai-use-case tracing install-deps

# 2. Configure interactively
ai-use-case tracing configure

# 3. Enable tracing
ai-use-case tracing enable
```

### Tracing Commands

Check status:
```bash
ai-use-case tracing status
```

Enable/disable:
```bash
# Enable tracing
ai-use-case tracing enable

# Disable tracing
ai-use-case tracing disable
```

Test configuration:
```bash
ai-use-case tracing test
```

### AI Toolkit Integration

Tracing data is automatically sent to VS Code AI Toolkit's built-in tracing viewer for:
- Real-time monitoring
- Performance analysis
- Usage patterns
- Command metrics

### What Gets Traced

- Command execution times
- CLI operations (init, sync, search, etc.)
- Git operations
- Hub synchronization
- Error tracking
- Performance metrics

**Learn More**: See [TRACING.md](TRACING.md) for comprehensive setup and usage instructions.

## Project Registry

The CLI maintains a registry of all projects using the tool for version management.

### Registry Location

```
~/.local/share/ai-use-case-cli/projects-registry.json
```

### Registry Structure

```json
{
  "projects": [
    {
      "path": "/path/to/project",
      "version": "3.12.0",
      "last_updated": "2025-12-07T10:00:00Z",
      "status": "up-to-date"
    }
  ]
}
```

### Managing Projects

List all projects:
```bash
ai-use-case list-projects
```

Check for updates:
```bash
ai-use-case check-updates
```

Update specific project:
```bash
ai-use-case update-project /path/to/project
```

Refresh current project:
```bash
ai-use-case --init --update
```

### What Gets Updated

When updating a project:
- Slash commands (`.ai-tools/commands/` and `.claude/commands/`)
- Git hooks (`.git/hooks/pre-commit` and `post-commit`)
- Symlinks and directory structure
- **Preserved**: Existing `.usecase/cases/` documentation

### When to Update

- After updating the CLI (`git pull` in CLI directory)
- When new slash commands are added
- When git hooks receive bug fixes
- If setup warnings suggest using `--update`

## Git Hooks

The CLI installs git hooks for automatic documentation synchronization.

### Installed Hooks

**Post-Commit Hook** (`.git/hooks/post-commit`):
- Triggers after every commit
- Syncs `.usecase/cases/` to hub
- Runs silently in background
- Only activates if documentation exists

**Pre-Commit Hook** (`.git/hooks/pre-commit`):
- Prevents direct commits to `main` branch (if configured)
- Validates documentation format
- Checks for required files

### Hook Configuration

Hooks are automatically installed during project setup:
```bash
ai-use-case --init
```

Verify hooks are installed:
```bash
ls -la .git/hooks/
# Should show: post-commit, pre-commit (executable)
```

Re-install hooks:
```bash
ai-use-case --init --update
```

### Customizing Hooks

You can customize hooks by editing:
- `.git/hooks/post-commit`
- `.git/hooks/pre-commit`

**Note**: Custom changes will be preserved during updates unless hooks are explicitly overwritten.

## Advanced Configuration

### Custom Templates

Override default documentation templates:

1. Copy templates from CLI:
   ```bash
   cp ~/.local/share/ai-use-case-cli/templates/* /your/custom/path/
   ```

2. Modify templates as needed

3. Point CLI to custom templates:
   ```bash
   export AI_USECASES_TEMPLATES="/your/custom/path"
   ```

### Multiple Hub Repositories

Manage different hubs for different project types:

```bash
# Personal projects
export AI_USECASES_DIR="$HOME/personal-hub"
ai-use-case --init

# Work projects
export AI_USECASES_DIR="$HOME/work-hub"
ai-use-case --init
```

Switch between hubs by changing the environment variable.

### CI/CD Integration

Use the CLI in automated workflows:

```bash
# Non-interactive mode
ai-use-case --init --yes --mode local-only

# Sync in CI
ai-use-case sync --force

# Extract data for reporting
ai-use-case extract 720 json > report.json
```

### Session Statistics Configuration

Configure automatic session tracking:

**SessionEnd Hook**:
- Automatically runs after `/use-case:document-session`
- Extracts cost, token, and timing data
- Stores in OpenTelemetry format

**Cost Integration**:
- `/cost` command integration for usage tracking
- Automatic token calculation
- Cost reporting

For details, see [Session Statistics](FEATURES.md#session-statistics-automation).

## Troubleshooting Configuration

### CLI Command Not Found

```bash
# Check PATH
echo $PATH | grep ".local/bin"

# Add if missing
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Verify symlink exists
ls -la ~/.local/bin/ai-use-case
```

### Hooks Not Working

```bash
# Check hook permissions
ls -la /path/to/project/.git/hooks/post-commit
chmod +x /path/to/project/.git/hooks/post-commit

# Test manual sync
ai-use-case sync

# Re-install hooks
ai-use-case --init --update
```

### Hub Not Syncing

```bash
# Check hub configuration
ai-use-case config show

# Verify git status (if using private git mode)
cd $(ai-use-case config show | grep "Hub location" | cut -d: -f2)
git status

# Manual sync
ai-use-case sync
```

### Wrong Hub Location

```bash
# Check current configuration
ai-use-case config show

# Reconfigure
ai-use-case config reconfigure

# Or reset and start fresh
ai-use-case reset --config
ai-use-case --init
```

## Related Documentation

- [README.md](../README.md) - Quick start and overview
- [USAGE-GUIDE.md](USAGE-GUIDE.md) - Detailed usage instructions
- [FEATURES.md](FEATURES.md) - Feature descriptions
- [TRACING.md](TRACING.md) - OpenTelemetry tracing details
- [WORKFLOW.md](WORKFLOW.md) - Development workflow for contributors
