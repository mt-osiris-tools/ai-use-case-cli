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

ai-use-case --init --update    # Update existing project installation
                               # - Refreshes Claude Code slash commands
                               # - Updates git hooks (pre-commit, post-commit)
                               # - Preserves existing documentation
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
- Config file: `$XDG_CONFIG_HOME/ai-use-case-cli/tracing.json` (default: `~/.config/ai-use-case-cli/tracing.json`)
- Environment variables: `AI_USECASE_TRACING_ENABLED`, `AI_USECASE_TRACING_ENDPOINT`, `AI_USECASE_TRACING_SAMPLING`
- See [docs/TRACING.md](TRACING.md) for complete guide

**AI Toolkit Integration:**
- Sends traces to `http://localhost:4318` by default
- View in VS Code AI Toolkit > Tracing
- Real-time performance monitoring

### Intelligent Agents (v3.11.0+)

Manage and invoke AI-powered agents for documentation analysis:

```bash
# Agent Registry Management
ai-use-case agents init         # Initialize agent registry
ai-use-case agents list         # List all available agents
ai-use-case agents list --enabled  # List only enabled agents
ai-use-case agents enable <id>  # Enable an agent
ai-use-case agents disable <id> # Disable an agent
ai-use-case agents info <id>    # Show detailed agent information
ai-use-case agents stats        # Show agent usage statistics

# Documentation Quality Review (Phase 2)
ai-use-case review-quality <file>  # Review single file quality
                               # - Quality scoring (0-10)
                               # - Category breakdown
                               # - Improvement suggestions

ai-use-case review-quality --batch '*.md'
                               # Batch review multiple files

ai-use-case review-quality --project <name>
                               # Review all files in a project

# Pattern Analysis (Phase 3)
ai-use-case analyze-patterns    # Analyze current project patterns
                               # - Pattern detection
                               # - Trend analysis
                               # - Recommendations

ai-use-case analyze-patterns --project <name>
                               # Analyze specific project from hub

ai-use-case analyze-patterns --hub
                               # Analyze entire hub

ai-use-case analyze-patterns --hub --compare
                               # Compare all projects in hub

ai-use-case analyze-patterns --period 6months
                               # Analyze specific time period
                               # Options: 1month, 3months, 6months, 1year
                               # Or: YYYY-MM-DD:YYYY-MM-DD

ai-use-case analyze-patterns --format json
                               # Output in JSON format
```

**Agent Configuration:**
- Registry file: `$XDG_CONFIG_HOME/ai-use-case-cli/agents.json` (default: `~/.config/ai-use-case-cli/agents.json`)
- Cache directory: `~/.cache/ai-use-case-cli/agents/`
- See [docs/agents/framework/README.md](agents/framework/README.md) for complete guide

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
                            # - v3.9.0+: Real-time TodoWrite progress tracking
                            # - v3.14.0+: --intelligent flag for AI-powered prioritization

/use-case:setup-project      # Setup project (alternative to --init)
/use-case:sync-usecases      # Sync to hub (alternative to sync)
/use-case:search-usecases    # Search use cases (alternative to search)
/use-case:publish-confluence # Publish to Confluence (alternative)
/use-case:quick-start        # Quick start guide

# v3.1.0+ Project Registry Commands
/use-case:list-projects      # List all registered projects with versions
/use-case:check-updates      # Check which projects need CLI updates
/use-case:update-project     # Update a project to latest CLI version

# v3.11.0+ Intelligent Agent Commands
/use-case:review-quality     # Review documentation quality with AI agent
                            # - Interactive file selection
                            # - Quality scoring and suggestions
                            # - Option to apply improvements

/use-case:analyze-patterns   # Analyze documentation patterns
                            # - Project or hub-wide analysis
                            # - Trend visualization
                            # - Prioritized recommendations

/use-case:optimize-organization  # Optimize hub organization (v3.15.0+)
                            # - Topic analysis (merge/split/rename)
                            # - Relationship mapping
                            # - Confidence-based recommendations
                            # - Dry-run first with user confirmation
```

### Intelligent Session Selection (v3.14.0+)

The `document-session` command supports an `--intelligent` flag that uses AI to analyze and prioritize sessions before documentation.

**Usage:**
```
/use-case:document-session --intelligent
```

**What it does:**
- Analyzes all PRs, commits, and conversations
- Assigns priority scores (0-10) to each session
- Groups sessions by priority level (HIGH/MEDIUM/LOW)
- Provides reasoning for each score
- Pre-extracts metadata (complexity, time saved, technologies)
- Recommends which sessions to document first

**Benefits:**
- **Better prioritization**: See which work is most valuable to document
- **Clear guidance**: HIGH/MEDIUM/LOW labels with recommendations
- **Faster documentation**: Metadata pre-extracted (ticket, complexity, time saved)
- **Informed decisions**: Understand why each session matters

**Trade-offs:**
- **Slower**: Adds 15-30 seconds for AI analysis
- **Token cost**: Uses ~500-1000 tokens per invocation
- **Requires Claude Code**: Uses Task tool with session-selector agent

**When to use:**
- You have multiple PRs/commits to choose from
- You want guidance on what's most valuable to document
- You want pre-populated metadata for faster documentation
- You're documenting after a sprint with many changes

**When to skip:**
- You already know exactly what to document
- You want the fastest possible workflow
- You're documenting immediately after a single PR
- You don't need prioritization guidance

**Example output:**
```
Analyzing sessions... ✓ Analysis complete

Found 5 sessions (2 HIGH, 2 MEDIUM, 1 LOW)

HIGH PRIORITY (Strongly recommend):
  🌟 [9.2] PR #123: Add JWT authentication system
      → 8 files changed, introduces authentication pattern
      → Estimated complexity: High (4-6h saved)
      → Recommendation: Document first - introduces reusable pattern

MEDIUM PRIORITY (Consider documenting):
  ⭐ [6.5] PR #120: Refactor database queries
      → 4 files changed, performance improvements
      → Recommendation: Document if time allows

(Recommendation: Start with PR #123 - highest value)
```

### Organization Optimization (v3.15.0+)

The `optimize-organization` command analyzes your hub's organization and suggests improvements for better documentation discoverability.

**Usage:**
```
/use-case:optimize-organization
```

**What it does:**
- Analyzes hub structure and all documentation files
- Detects suboptimal topic organization (fragmented or too broad)
- Maps relationships between documents (sequential, technical similarity, prerequisite, alternative)
- Provides prioritized recommendations (HIGH/MEDIUM/LOW)
- Suggests specific actions (merge topics, split topics, rename, add relationships)

**Benefits:**
- **Better discoverability**: Merge fragmented topics, split overly broad topics
- **Knowledge connections**: Map relationships between related documents
- **Confidence-based**: Only recommends changes with 0.7+ confidence
- **Safe workflow**: Always previews changes, requires confirmation
- **Preserves history**: Only updates symlinks, never modifies source files

**Features:**
- Analyzes 100+ documents in < 2 minutes
- Hub health scoring (0-10 scale)
- Dry-run first (preview recommendations before applying)
- Complete audit trail in `.meta/optimization-history.json`
- Backup creation before applying changes

**Example output:**
```
Organization Analysis Complete

Hub: ~/.local/share/ai-use-case-cli/hub
Analyzed: 127 documents across 12 projects

Key Findings:
✓ Strong: Consistent naming (98% compliance)
✓ Good: Clear topic structure (34 topics)
⚠ Opportunity: 3 topic groups could be merged
⚠ Info: 156 relationships detected

Recommendations:
  8 HIGH priority (+25% discoverability)
  12 MEDIUM priority
  10 LOW priority

What would you like to do?
1. Review all recommendations (detailed view)
2. Apply HIGH priority recommendations
3. Apply specific recommendations
4. Save and exit
```

**Workflow:**
1. Run analysis (read-only, 30-90 seconds)
2. Review recommendations with confidence scores and rationale
3. Select which recommendations to apply
4. Confirm changes (shows exact files affected)
5. Apply changes (symlinks updated, source files unchanged)
6. View results summary

**Phase 5.0 Scope:**
- ✅ Topic analysis (merge/split/rename)
- ✅ Relationship mapping
- ⏳ Tag suggestions (deferred to Phase 5.1)
- ⏳ Search optimization (deferred to Phase 5.1)
- ⏳ CLI wrapper: `ai-use-case optimize-organization` (deferred to Phase 5.1)

**Recommendation Types:**

**MERGE Topics** (HIGH priority: Confidence 0.90+; MEDIUM/LOW: lower confidence possible)
- Example: `auth` + `authentication` + `jwt-auth` → `authentication`
- When: Multiple topics covering same domain with 80%+ overlap
- Impact: Consolidates fragmented knowledge

**SPLIT Topics** (HIGH priority: Confidence 0.85+; MEDIUM/LOW: lower confidence possible)
- Example: `database-work` → `database-migrations` + `database-optimization` + `database-schema`
- When: Large topic (20+ docs) with low similarity (< 0.5)
- Impact: Better organization by intent

**RENAME Topics** (HIGH priority: Confidence 0.80+; MEDIUM/LOW: lower confidence possible)
- Example: `api-stuff` → `api-development`
- When: Topic name is vague or doesn't match content
- Impact: Better searchability

**ADD Relationships** (HIGH priority: Confidence varies by type - sequential 0.8+, prerequisite 0.75+, technical/alternative 0.7+; MEDIUM/LOW: lower confidence possible while still meeting each type's minimum)
- Sequential: TICKET-001 → TICKET-002 (builds upon, requires 0.8+)
- Technical: Similar technologies/patterns (requires 0.7+)
- Prerequisite: Frontend needs backend API (requires 0.75+)
- Alternative: OAuth vs JWT (different solutions, requires 0.7+)
- Impact: Makes knowledge connections explicit

**Note:** Confidence thresholds shown above are for HIGH priority recommendations. MEDIUM/LOW recommendations can use lower confidence when impact is lower. Type-specific relationship minimums still apply at all priorities (sequential >= 0.8, prerequisite >= 0.75, technical/alternative >= 0.7).

**When to use:**
- Hub has 20+ documents (analysis works best with more data)
- You want to improve documentation discoverability
- Topics feel disorganized or hard to navigate
- You're unsure what relationships exist between documents

**When to skip:**
- Hub is small (< 10 documents) - insufficient data
- Hub is already well-organized - no improvements needed
- You prefer manual organization

**Requirements:**
- Claude Code (uses Task tool with organization agent)
- Hub initialized with documentation
- Organization optimizer agent enabled (auto-enabled in v3.15.0+)

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
export XDG_CONFIG_HOME="$HOME/.config"
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
$XDG_CONFIG_HOME/ai-use-case-cli/config.json          # Hub configuration (default: $HOME/.config/ai-use-case-cli/config.json)
~/.local/share/ai-use-case-cli/hub/                   # Hub (local-only mode)
```

## Related Documentation

- [WORKFLOW.md](WORKFLOW.md) - Development workflow guide
- [CLAUDE.md](../CLAUDE.md) - Main comprehensive guide
- [VERSION-MANAGEMENT.md](VERSION-MANAGEMENT.md) - Version bump guide
- [HUB-SYNC-CHECKLIST.md](HUB-SYNC-CHECKLIST.md) - Hub sync validation
