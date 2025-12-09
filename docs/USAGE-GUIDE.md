# Usage Guide

Complete guide for using AI Use Case CLI in your daily workflow.

## Table of Contents

- [Slash Commands for AI Coding Assistants](#slash-commands-for-ai-coding-assistants)
- [Core Commands](#core-commands)
- [Session Types](#session-types)
- [File Naming Convention](#file-naming-convention)
- [Workflow Details](#workflow-details)

## Slash Commands for AI Coding Assistants

This CLI provides slash commands for AI coding assistants like Claude Code, OpenAI Codex CLI, and GitHub Copilot. After running `ai-use-case --init`, slash commands are automatically available in your project.

### How It Works

**AI-Tool-Agnostic Design:**
- Commands are stored in `.ai-tools/commands/use-case/` (source of truth)
- Tool-specific integrations provide compatibility layers

**Claude Code Integration:**
- A subdirectory symlink at `.claude/commands/use-case/` points to `../../.ai-tools/commands/use-case/`
- Preserves any custom commands you add to `.claude/commands/`
- Commands are invoked as `/use-case:command-name`

**OpenAI Codex CLI Integration:**
- Codex-specific wrappers in `.codex/prompts/` with YAML frontmatter
- Uses hybrid parameters (optional with interactive fallback)
- Commands are invoked as `/prompts:use-case-command-name`

### Setup

```bash
# Claude Code (automatic with --init)
ai-use-case --init

# OpenAI Codex CLI (separate setup)
ai-use-case --setup-codex
```

### Verification

**Claude Code:**
```bash
ls -la .claude/commands/use-case    # Should show: use-case → ../../.ai-tools/commands/use-case
ls .ai-tools/commands/use-case/     # Should list all available commands
```

**OpenAI Codex CLI:**
```bash
ls .codex/prompts/                  # Should list Codex prompt files
```

## Core Commands

Use standalone CLI, Claude Code slash commands, or Codex CLI prompts—whatever fits your workflow:

| Task | CLI Command | Claude Code | Codex CLI |
|------|-------------|-------------|-----------|
| Setup project | `ai-use-case --init` | `/use-case:setup-project` | |
| Update project installation | `ai-use-case --init --update` | | |
| Setup Codex CLI | `ai-use-case --setup-codex` | | |
| Show hub config | `ai-use-case config show` | | |
| Reconfigure hub | `ai-use-case config reconfigure` | | |
| Document session | N/A – use AI assistant | `/use-case:document-session` | `/prompts:use-case-document-session` |
| Sync to hub | `ai-use-case sync` | `/use-case:sync-usecases` | |
| Search use cases | `ai-use-case search <term>` | `/use-case:search-usecases` | |
| View statistics | `ai-use-case stats` | | |
| Extract session data | `ai-use-case extract [hours] [format]` | `/use-case:extract-session` | |
| List projects | `ai-use-case list-projects` | `/use-case:list-projects` | |
| Check for updates | `ai-use-case check-updates` | `/use-case:check-updates` | |
| Update project | `ai-use-case update-project <path>` | `/use-case:update-project` | |
| Reset configuration | `ai-use-case reset [options]` | | |
| Publish to Confluence | `ai-use-case publish-confluence` | `/use-case:publish-confluence` | `/prompts:use-case-publish-confluence` |
| View hub | `ai-use-case view` | | |
| Push hub changes | `ai-use-case push` | | |
| Initialize tracing | `ai-use-case tracing init` | | |
| Configure tracing | `ai-use-case tracing configure` | | |
| View tracing status | `ai-use-case tracing status` | | |

### Additional Commands

```bash
ai-use-case --version     # Show version information
ai-use-case --help        # Show help message
ai-use-case uninstall     # Uninstall the CLI tool
```

## Session Types

The CLI supports two types of AI sessions:

### Implementation Sessions

**Purpose**: Document code changes and feature implementations

**Characteristics**:
- Captures git statistics (files changed, lines added/removed)
- Includes code snippets and technical details
- Uses project-specific tickets (e.g., `PROJ-1234`)
- Automatically extracts commit information

**When to Use**:
- Bug fixes
- New feature implementations
- Refactoring work
- Any session that produces commits

**Example Tickets**: `PROJ-1234`, `FEATURE-001`, `BUG-456`

### Research Sessions

**Purpose**: Document exploration and decision-making without code changes

**Characteristics**:
- No code changes required
- Documents query refinement and decision-making
- Auto-generates `RESEARCH-XXX` tickets
- Focuses on analysis and investigation

**When to Use**:
- Evaluating architectures or design patterns
- Comparing solution approaches
- Understanding existing codebases
- Investigating issues before fixing
- Technology research and evaluation

**Example Tickets**: `RESEARCH-001`, `RESEARCH-002`

## File Naming Convention

All use case documentation follows this strict format:

```
YYYY-Www-MM-DD_TICKET-XXXXX_brief-description.md
```

### Format Components

- **YYYY**: Four-digit year (e.g., `2025`)
- **Www**: ISO 8601 week number (`W01` through `W53`)
- **MM**: Two-digit month (`01` through `12`)
- **DD**: Two-digit day (`01` through `31`)
- **TICKET-XXXXX**: Project ticket or `RESEARCH-XXX` for research sessions
- **brief-description**: Lowercase with hyphens, no spaces

### Examples

**Implementation sessions**:
```
2025-W44-11-03_PROJ-1234_implement-user-authentication.md
2025-W49-12-07_FEATURE-123_add-session-statistics.md
2025-W50-12-15_BUG-789_fix-token-calculation.md
```

**Research sessions**:
```
2025-W44-11-03_RESEARCH-001_evaluate-database-strategies.md
2025-W49-12-07_RESEARCH-002_compare-authentication-methods.md
```

## Workflow Details

### Document Session Workflow

The `/use-case:document-session` command provides an interactive workflow with real-time progress tracking.

#### Step 1: Pre-flight Checklist

Automatically checks:
- Git user configuration (name and email)
- Current branch status
- Pending changes

#### Step 2: Scan Options

Choose what to analyze:
- **Conversation only**: Current AI assistant conversation
- **Git history only**: Recent commits and changes
- **Both**: Comprehensive analysis (recommended)

#### Step 3: Session Selection

Interactive selection from:
1. **Priority 1**: Undocumented merged PRs (implementation work) ⚠️
2. **Priority 2**: Current conversation (research or implementation)
3. **Priority 3**: Recent direct commits

#### Step 4: Automatic Generation

The AI assistant:
- Analyzes selected work (PR metadata, commits, conversation)
- Extracts git statistics (files changed, lines added/removed)
- Generates complete documentation (no placeholders)
- Follows appropriate template (implementation or research)

#### Step 5: Save and Sync

- Creates file in `.usecase/cases/` with proper naming
- Commits documentation to git
- Syncs to hub automatically (via git hooks)

### Search and Statistics

#### Search Use Cases

```bash
# Search by keyword
ai-use-case search "authentication"

# Search with multiple terms
ai-use-case search "api database"
```

Results show:
- Matching file names
- File paths
- Relevant context snippets

#### View Statistics

```bash
ai-use-case stats
```

Shows:
- Total use cases documented
- Breakdown by session type
- Recent activity
- Storage location and size

### Extract Session Data

Export git history and metrics for reporting:

```bash
# Extract last 24 hours (default)
ai-use-case extract

# Extract last 7 days
ai-use-case extract 168

# Export as JSON
ai-use-case extract 24 json

# Export as CSV
ai-use-case extract 24 csv
```

Output includes:
- Commit history
- Files changed
- Lines added/removed
- Token usage (if available)
- Time ranges

### Publishing to Confluence

Publish use cases as child pages in Confluence:

```bash
# Interactive prompt for all options
ai-use-case publish-confluence

# Or via slash command in AI assistant
/use-case:publish-confluence
```

**Prerequisites**:
- Atlassian MCP server configured
- Valid Confluence authentication
- Page creation permissions

**What Gets Published**:
- Use case documentation formatted for Confluence
- Created as child pages under selected parent
- Preserves markdown formatting
- Includes metadata and links

### Project Registry Management

#### List Projects

```bash
ai-use-case list-projects
```

Shows all registered projects with:
- Project path
- Installed CLI version
- Last update date
- Status (up-to-date or needs update)

#### Check for Updates

```bash
ai-use-case check-updates
```

Identifies projects using older CLI versions.

#### Update Project

```bash
# Update specific project
ai-use-case update-project /path/to/project

# Update current project
ai-use-case --init --update
```

Updates:
- Slash commands to latest versions
- Git hooks (pre-commit and post-commit)
- Preserves existing documentation

## Related Documentation

- [README.md](../README.md) - Quick start and overview
- [CONFIGURATION.md](CONFIGURATION.md) - Configuration options
- [FEATURES.md](FEATURES.md) - Feature descriptions
- [TRACING.md](TRACING.md) - OpenTelemetry tracing setup
- [agents/](agents/) - AI agent framework documentation
- [WORKFLOW.md](WORKFLOW.md) - Development workflow for contributors
