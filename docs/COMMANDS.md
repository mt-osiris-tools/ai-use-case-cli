# Command Reference

Complete command reference for AI Use Case CLI. For quick reference, see [CLAUDE.md](../CLAUDE.md).

## Overview

**v3.1.0+: Hybrid approach** - Standalone CLI + Claude Code integration

The CLI provides three ways to interact:
1. **Standalone CLI commands** - Traditional command-line interface
2. **Claude Code slash commands** - AI-assisted with automatic context
3. **Direct script access** - Advanced usage for scripting

## Standalone CLI Commands

Main entry point: `ai-use-case` (or `~/.local/bin/ai-use-case`)

### Project Setup

```bash
ai-use-case --init              # Setup current project
                               # - Creates .usecase/ directory
                               # - Registers project in registry
                               # - Prompts for hub configuration
```

### Configuration Management (v3.2.0+)

```bash
ai-use-case config show         # Show current hub configuration
ai-use-case config reconfigure  # Change hub mode (local/private)
```

### Documentation Commands

```bash
ai-use-case sync                # Sync use cases to hub
                               # - Copies from .usecase/cases/ to hub
                               # - Deduplicates entries
                               # - Updates index
```

### Search and Analytics

```bash
ai-use-case search <term>       # Search documented use cases
                               # - Searches titles and content
                               # - Shows matching files with context

ai-use-case stats               # View statistics
                               # - Total use cases
                               # - By project
                               # - Recent activity
```

### Project Registry (v3.1.0+)

```bash
ai-use-case list                # List all registered projects
ai-use-case list-projects       # Same as list
ai-use-case check-updates       # Check which projects need CLI updates
ai-use-case update-project <path> # Update a project to latest CLI version
```

### Hub Operations

```bash
ai-use-case view                # Open hub in file explorer
ai-use-case push                # Push hub changes to remote (private git only)
```

### Publishing

```bash
ai-use-case publish-confluence  # Publish to Confluence
                               # - Requires MCP server configured
                               # - Converts markdown to Confluence format
```

### Tracing and Monitoring (v3.6.0+)

```bash
ai-use-case tracing configure   # Interactive tracing configuration
                               # - Set OTLP endpoint
                               # - Configure sampling ratio
                               # - Test AI Toolkit connection

ai-use-case tracing status      # Show tracing system status
                               # - Check dependencies installed
                               # - Show configuration
                               # - Verify connectivity

ai-use-case tracing enable      # Enable tracing
ai-use-case tracing disable     # Disable tracing

ai-use-case tracing install-deps # Install OpenTelemetry dependencies
                               # - pip install opentelemetry packages
                               # - User-level installation

ai-use-case tracing test        # Test tracing functionality
                               # - Send test traces
                               # - Verify export works

ai-use-case tracing show        # Show current configuration
                               # - Display config file
                               # - Show environment variables

ai-use-case tracing set <key> <value>
                               # Set configuration value
                               # - sampling_ratio: 0.0-1.0
                               # - endpoint: OTLP URL
                               # - export_timeout: seconds
```

**Configuration:**
- Config file: `~/.config/ai-use-case-cli/tracing.json`
- Environment variables: `AI_USECASE_TRACING_ENABLED`, `AI_USECASE_TRACING_ENDPOINT`, `AI_USECASE_TRACING_SAMPLING`
- See [docs/TRACING.md](TRACING.md) for complete guide

**AI Toolkit Integration:**
- Sends traces to `http://localhost:4318` by default
- View in VS Code AI Toolkit > Tracing
- Real-time performance monitoring

### Utility Commands

```bash
ai-use-case --version           # Show version
ai-use-case --help              # Show help
ai-use-case uninstall           # Uninstall the CLI
```

## Claude Code Slash Commands

For AI-assisted documentation with automatic context capture:

```
/use-case:document-session   # Document AI session
                            # - Interactive session selection
                            # - Auto-generates complete documentation
                            # - NO placeholders

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

## Direct Script Access (Advanced)

For scripting or advanced automation:

```bash
# Project setup
bash ~/.local/share/ai-use-case-cli/scripts/project/setup-project.sh .

# Documentation
bash ~/.local/share/ai-use-case-cli/scripts/core/document-ai-session.sh .
bash ~/.local/share/ai-use-case-cli/scripts/core/sync-ai-use-cases.sh .

# Search
bash ~/.local/share/ai-use-case-cli/scripts/search/search-use-cases.sh <term>
bash ~/.local/share/ai-use-case-cli/scripts/search/stats-use-cases.sh

# Project registry
bash ~/.local/share/ai-use-case-cli/scripts/project/list-projects.sh
bash ~/.local/share/ai-use-case-cli/scripts/project/check-updates.sh
bash ~/.local/share/ai-use-case-cli/scripts/project/update-project.sh <path>

# Configuration (v3.2.0+)
bash ~/.local/share/ai-use-case-cli/scripts/utils/config-manager.sh show
bash ~/.local/share/ai-use-case-cli/scripts/utils/config-manager.sh mode
```

## Hub Configuration (v3.2.0+)

The CLI supports two hub modes for documentation storage:

### Hub Modes

#### 1. Local Only (Default)

**No git repository required**

- Files stored in: `~/.local/share/ai-use-case-cli/hub/`
- No version control, no remote sync
- Best for: Personal use, quick local documentation
- Git operations (push, remote sync) are disabled

#### 2. Private Git

**Your own repository**

- Connect to your own private git repository
- Full version control with your chosen remote
- Best for: Private team documentation, company-internal use, version-controlled workflow
- Requires: Git repository URL during setup

### Configuration Commands

**During first setup** (`ai-use-case --init`), you'll be prompted to select a mode.

**Show current configuration:**
```bash
ai-use-case config show
```

**Reconfigure hub mode** (change between local/private):
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

## Project Registry (v3.1.0+)

The CLI maintains a registry of all projects using the tool for better version management.

### How It Works

1. **Automatic Registration**: When you run `setup-project.sh`, the project is automatically registered
2. **Version Tracking**: Each project's CLI version is tracked
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

## Environment Variables

### Hub Location Override

Override the default hub location (works with all modes):

```bash
# Default for local-only mode
export AI_USECASES_DIR="~/.local/share/ai-use-case-cli/hub/"

# Default for private git mode
# Set during configuration

# Custom location
export AI_USECASES_DIR="/custom/path/to/hub"
```

### Other Variables

```bash
# CLI installation directory (advanced)
export AI_USE_CASE_CLI_HOME="~/.local/share/ai-use-case-cli"

# Configuration directory (advanced)
export XDG_CONFIG_HOME="~/.config"
```

## File Locations

### Project Files

```
<project-root>/
├── .usecase/
│   └── cases/                  # Use case documentation
│       └── YYYY-Www-MM-DD_TICKET-XXX_description.md
└── CLAUDE.md                   # Project instructions (optional)
```

### System Files

```
~/.local/bin/ai-use-case                              # CLI entry point
~/.local/share/ai-use-case-cli/                       # CLI installation
~/.local/share/ai-use-case-cli/projects-registry.json # Project registry
~/.config/ai-use-case-cli/config.json                 # Hub configuration
~/.local/share/ai-use-case-cli/hub/                   # Hub (local-only mode)
```

## Related Documentation

- [WORKFLOW.md](WORKFLOW.md) - Development workflow guide
- [CLAUDE.md](../CLAUDE.md) - Main comprehensive guide
- [VERSION-MANAGEMENT.md](VERSION-MANAGEMENT.md) - Version bump guide
- [HUB-SYNC-CHECKLIST.md](HUB-SYNC-CHECKLIST.md) - Hub sync validation
