# Features

Comprehensive guide to all AI Use Case CLI features.

## Table of Contents

- [Core Features](#core-features)
- [AI Assistant Integration](#ai-assistant-integration)
- [Documentation Management](#documentation-management)
- [Session Statistics and Tracking](#session-statistics-and-tracking)
- [Project Management](#project-management)
- [Monitoring and Observability](#monitoring-and-observability)
- [Publishing and Sharing](#publishing-and-sharing)
- [Intelligent Agents](#intelligent-agents)

## Core Features

### Hybrid Interface

**Description**: Use standalone CLI commands or AI assistant slash commands interchangeably.

**Benefits**:
- Choose the interface that fits your workflow
- CLI for automation and scripting
- Slash commands for interactive AI sessions
- Seamless switching between modes

**Usage**:
```bash
# CLI mode
ai-use-case --init
ai-use-case sync

# Slash command mode (in AI assistant)
/use-case:setup-project
/use-case:sync-usecases
```

**Available Since**: v3.1.0

### AI-Assisted Documentation

**Description**: Automatic context capture with GitHub Copilot, Claude Code, and other AI tools.

**How It Works**:
1. Work with AI assistant on code or research
2. Run `/use-case:document-session`
3. AI extracts conversation, commits, and metrics
4. Complete documentation generated automatically
5. Synced to hub via git hooks

**Benefits**:
- Zero manual documentation effort
- Consistent format across all sessions
- Captures context that would be lost
- Builds searchable knowledge base

**Key Features**:
- Interactive session selection
- Automatic git history extraction
- Template-based generation
- No placeholders or TODOs

**Available Since**: v1.0.0, Enhanced in v3.4.0

### Research & Implementation Sessions

**Description**: Support for both code changes and exploratory work.

**Implementation Sessions**:
- Document code changes with git statistics
- Include commit history and file diffs
- Project-specific ticket tracking
- Technical details and metrics

**Research Sessions**:
- Document exploration without code changes
- Auto-generated `RESEARCH-XXX` tickets
- Focus on analysis and decision-making
- Query refinement tracking

**When to Use Each**:
- **Implementation**: Bug fixes, features, refactoring (has commits)
- **Research**: Architecture evaluation, technology comparison, investigation

**Available Since**: v2.0.0

## AI Assistant Integration

### AI Agent Tracking

**Description**: Automatically track and document usage of specialized agents from any AI tool.

**Capabilities**:
- Detect agent invocations in conversation
- Extract agent names and purposes
- Track agent usage patterns
- Document agent contributions

**Supported Patterns**:
- Claude Code agents
- GitHub Copilot agents
- Custom agent frameworks
- Multi-agent workflows

**Benefits**:
- Understand which agents are most valuable
- Document agent-assisted work
- Track agent effectiveness
- Build agent usage knowledge base

**Available Since**: v3.10.0

### Template-Based Documentation

**Description**: Pre-built templates eliminate documentation paralysis.

**Available Templates**:
- Implementation sessions (TEMPLATE.md)
- Research sessions (TEMPLATE-RESEARCH.md)
- Custom templates (user-defined)

**Template Features**:
- Structured sections
- Metadata fields
- Git statistics placeholders
- Agent tracking sections

**Customization**:
Users can create custom templates by:
1. Copying existing templates
2. Modifying structure and fields
3. Placing in custom template directory
4. Configuring CLI to use custom location

**Available Since**: v1.0.0, Enhanced in v3.11.0

## Documentation Management

### Automatic Syncing

**Description**: Git hooks sync documentation to hub automatically after commits.

**How It Works**:
1. User commits code or documentation
2. Post-commit hook triggers
3. CLI syncs `.usecase/cases/` to hub
4. Hub organized by project, date, and topic

**Hub Modes**:
- **Local Only**: No git, stays on machine
- **Private Git**: Full version control with remote

**Benefits**:
- Never forget to sync documentation
- Consistent backup
- Team collaboration (with private git)
- Automatic organization

**Available Since**: v1.0.0

### Flexible Storage

**Description**: Choose between local-only or private git repository.

**Local Only Mode**:
- Storage: `~/.local/share/ai-use-case-cli/hub/`
- No git or version control
- Complete privacy
- Simple setup

**Private Git Mode**:
- Storage: Your git repository
- Full version control
- Remote synchronization
- Team collaboration

**Switching Modes**:
```bash
ai-use-case config reconfigure
```

**Migration**: CLI handles data migration when switching modes.

**Available Since**: v3.2.0

### Search & Statistics

**Description**: Find and analyze documented use cases.

**Search Capabilities**:
```bash
# Keyword search
ai-use-case search "authentication"

# Multi-term search
ai-use-case search "api database"
```

**Search Features**:
- Full-text search
- File name matching
- Context snippets
- Path filtering

**Statistics**:
```bash
ai-use-case stats
```

**Statistics Include**:
- Total use cases
- Session type breakdown
- Recent activity
- Storage metrics

**Available Since**: v1.0.0

## Session Statistics and Tracking

### Session Statistics Automation

**Description**: Automatic tracking of costs, tokens, and time for AI sessions.

**Components**:

**1. SessionEnd Hook**:
- Triggers after `/use-case:document-session`
- Extracts metrics automatically
- Stores in OpenTelemetry format
- No manual data entry required

**2. /cost Integration**:
- Reads cost data from AI assistant
- Calculates token usage
- Tracks spending per session
- Aggregates across projects

**3. OpenTelemetry Tracing**:
- Distributed tracing for CLI operations
- Performance metrics
- Usage patterns
- Error tracking

**Metrics Tracked**:
- Total tokens (input + output)
- Cost per session
- Time spent
- Commands executed
- Files modified

**Benefits**:
- Understand AI usage costs
- Track productivity metrics
- Identify expensive sessions
- Budget forecasting

**Available Since**: v3.12.0

### Session Data Extraction

**Description**: Extract git history, token usage, and metrics for reporting.

**Usage**:
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

**Extracted Data**:
- Commit history
- Files changed
- Lines added/removed
- Token usage (if available)
- Time ranges
- Author information

**Use Cases**:
- Weekly reports
- Performance analysis
- Project metrics
- Team productivity

**Available Since**: v3.4.0

## Project Management

### Project Registry

**Description**: Track and update all projects using the CLI.

**Registry Features**:
- Tracks project paths
- Monitors CLI versions
- Detects outdated installations
- Manages updates

**Commands**:
```bash
# List all projects
ai-use-case list-projects

# Check for updates
ai-use-case check-updates

# Update specific project
ai-use-case update-project /path/to/project

# Update current project
ai-use-case --init --update
```

**Registry Location**: `~/.local/share/ai-use-case-cli/projects-registry.json`

**Available Since**: v3.1.0

### Command Progress Tracking

**Description**: Visual real-time progress indicators for all commands.

**Features**:
- Real-time progress bars
- Step-by-step status updates
- Todo list integration
- Error highlighting

**Commands with Progress**:
- `--init` (setup)
- `sync` (synchronization)
- `update-project` (updates)
- `/use-case:document-session` (documentation)

**Benefits**:
- Visibility into long-running operations
- Clear feedback on current step
- Easy identification of stuck operations

**Available Since**: v3.8.0

## Monitoring and Observability

### OpenTelemetry Tracing

**Description**: Monitor CLI performance and usage with distributed tracing.

**Setup**:
```bash
# Quick setup
ai-use-case tracing init
ai-use-case tracing enable

# Check status
ai-use-case tracing status
```

**Metrics Collected**:
- Command execution times
- Operation durations
- Error rates
- Resource usage

**Integration**: Data sent to VS Code AI Toolkit's built-in tracing viewer.

**Benefits**:
- Performance monitoring
- Bottleneck identification
- Usage analysis
- Debugging support

**Available Since**: v3.6.0

**Learn More**: See [TRACING.md](TRACING.md)

## Publishing and Sharing

### Confluence Publishing

**Description**: Publish use cases to Confluence as child pages.

**Usage**:
```bash
# CLI
ai-use-case publish-confluence

# Slash command
/use-case:publish-confluence
```

**Prerequisites**:
- Atlassian MCP server configured
- Valid Confluence authentication
- Page creation permissions

**Features**:
- Interactive parent page selection
- Markdown to Confluence conversion
- Metadata preservation
- Batch publishing

**Benefits**:
- Share with non-technical stakeholders
- Integrate with team wiki
- Searchable in Confluence
- Access control via Confluence permissions

**Available Since**: v3.5.0

## Intelligent Agents

### Agent Framework

**Status**: Phase 1 Complete - Framework Operational

**Description**: AI-powered agents for quality review, pattern analysis, and organization.

**Current Status**:
- ✅ Agent registry system
- ✅ Agent invocation framework
- ✅ CLI integration (`ai-use-case agents`)
- ✅ Statistics and caching

**Commands**:
```bash
# Initialize agents
ai-use-case agents init

# List available agents
ai-use-case agents list

# Enable an agent
ai-use-case agents enable quality-reviewer

# View agent info
ai-use-case agents info quality-reviewer

# View statistics
ai-use-case agents stats
```

**Planned Agents** (Phase 2-5):
- **Quality Reviewer**: Documentation quality analysis
- **Pattern Analyzer**: Learn from past sessions
- **Session Selector**: Intelligent PR/commit analysis
- **Organization Intelligence**: Hub optimization

**Key Principles**:
- **Optional**: Agents are enhancements, not requirements
- **CLI Independent**: CLI works fully without agents
- **Zero Overhead**: < 10ms impact on existing commands
- **Opt-In**: Users explicitly enable agents

**Available Since**: v3.11.0 (framework), agents coming in future releases

**Learn More**: See [agents/framework/README.md](agents/framework/README.md)

## Feature Comparison Matrix

| Feature | Local Only | Private Git | Notes |
|---------|------------|-------------|-------|
| Documentation | ✅ | ✅ | Full support in both modes |
| Auto-sync | ✅ | ✅ | Git hooks in both modes |
| Version control | ❌ | ✅ | Only with private git |
| Remote backup | ❌ | ✅ | Requires git remote |
| Team sharing | ❌ | ✅ | Via git repository |
| Search | ✅ | ✅ | Full search in both |
| Statistics | ✅ | ✅ | Full stats in both |
| Tracing | ✅ | ✅ | Available in both |
| Confluence | ✅ | ✅ | Works with both modes |

## Version History

Summary of when major features were introduced:

- **v1.0.0**: Core documentation, auto-sync, search, stats
- **v2.0.0**: Research sessions, improved templates
- **v3.0.0**: Claude Code integration (breaking changes)
- **v3.1.0**: Hybrid CLI + Project Registry
- **v3.2.0**: Flexible storage (local/private git modes)
- **v3.4.0**: Interactive session selection, extraction
- **v3.5.0**: Confluence publishing
- **v3.6.0**: OpenTelemetry tracing
- **v3.8.0**: Command progress tracking
- **v3.9.0**: Development git hooks installer
- **v3.10.0**: Claude Agent usage tracking
- **v3.11.0**: Template-based docs, agent framework
- **v3.12.0**: Session statistics automation

For complete version history, see [CHANGELOG.md](../CHANGELOG.md).

## Related Documentation

- [README.md](../README.md) - Quick start and overview
- [USAGE-GUIDE.md](USAGE-GUIDE.md) - Detailed usage instructions
- [CONFIGURATION.md](CONFIGURATION.md) - Configuration options
- [TRACING.md](TRACING.md) - OpenTelemetry tracing setup
- [agents/](agents/) - AI agent framework documentation
