# AI Use Case CLI - Intelligent Agents Guide

**Version:** 1.2.0 (Phase 1-3 - Agent Framework + Quality + Patterns)
**Feature ID:** FEATURE-002
**Status:** Phase 1-3 Complete (Quality Reviewer, Pattern Analyzer)

---

## Table of Contents

1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [Architecture](#architecture)
4. [Available Agents](#available-agents)
5. [Agent Management](#agent-management)
6. [Configuration](#configuration)
7. [Troubleshooting](#troubleshooting)
8. [Developer Guide](#developer-guide)

---

## Overview

The AI Use Case CLI now includes intelligent AI agents that provide context-aware automation for tasks requiring analysis, recommendations, and decision-making. This hybrid architecture combines:

- **Bash Scripts** - Reliable, fast, deterministic operations (file sync, git hooks, setup)
- **AI Agents** - Intelligent, context-aware analysis and recommendations

### Key Principles

✅ **Optional & Opt-In** - Agents are optional enhancements, not requirements
✅ **CLI Independence** - CLI works fully without agents enabled
✅ **User Controlled** - Explicit user action required to invoke agents
✅ **Graceful Degradation** - Clear messaging when agents unavailable
✅ **Statistics Tracking** - Monitor agent usage and effectiveness

### Phase 1: Agent Framework (Current)

Phase 1 provides the foundation for all intelligent agents:

- Agent registry system
- Agent invocation framework
- CLI integration (`ai-use-case agents` commands)
- Statistics and caching
- Configuration management

**Note:** Actual agent implementations (Quality Reviewer, Pattern Analyzer, etc.) will be added in Phases 2-5.

---

## Quick Start

### 1. Initialize Agent Registry

```bash
# Initialize the agent registry
ai-use-case agents init

# Registry created at: ~/.config/ai-use-case-cli/agents.json
```

### 2. List Available Agents

```bash
# List all agents
ai-use-case agents list

# List only enabled agents
ai-use-case agents list --enabled

# List only disabled agents
ai-use-case agents list --disabled
```

### 3. Enable an Agent

```bash
# Enable the quality reviewer agent
ai-use-case agents enable quality-reviewer

# Verify it's enabled
ai-use-case agents list --enabled
```

### 4. View Agent Information

```bash
# Show detailed information about an agent
ai-use-case agents info quality-reviewer

# Shows: name, description, capabilities, dependencies, statistics
```

### 5. View Statistics

```bash
# Overall statistics
ai-use-case agents stats

# Specific agent statistics
ai-use-case agents stats quality-reviewer
```

---

## Architecture

### Hybrid Model

```
┌─────────────────────────────────────────────────────────┐
│                 AI Use Case CLI                         │
│                                                         │
│  ┌───────────────────────────────────────────────┐    │
│  │  Core CLI (Bash Scripts)                      │    │
│  │  - Reliable, fast, deterministic              │    │
│  │  - No AI dependency                            │    │
│  │  - Works offline                               │    │
│  └───────────────────────────────────────────────┘    │
│                      │                                  │
│  ┌───────────────────┼──────────────────────────┐     │
│  │  Agent Framework   ▼                          │     │
│  │  ┌──────────────┐   ┌───────────────┐        │     │
│  │  │   Registry   │◄──┤    Invoker    │        │     │
│  │  │   (JSON)     │   │   (wrapper)   │        │     │
│  │  └──────────────┘   └───────┬───────┘        │     │
│  │                              │                 │     │
│  └──────────────────────────────┼─────────────────┘     │
│                                 │                       │
│  ┌──────────────────────────────┼─────────────────┐     │
│  │  Specialized Agents          ▼                 │     │
│  │  (Phase 2-5: To Be Implemented)                │     │
│  │  - Quality Reviewer                            │     │
│  │  - Pattern Analyzer                            │     │
│  │  - Session Selector                            │     │
│  │  - Organization Intelligence                   │     │
│  └────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────┘
```

### Components

#### 1. Agent Registry (`~/.config/ai-use-case-cli/agents.json`)

JSON-based registry tracking all available agents:

```json
{
  "agents": [
    {
      "id": "quality-reviewer",
      "name": "Documentation Quality Agent",
      "description": "Reviews documentation quality and provides suggestions",
      "subagent_type": "use-case-quality-agent",
      "enabled": false,
      "version": "1.0.0",
      "capabilities": ["quality-analysis", "completeness-check"],
      "dependencies": ["claude-code"],
      "statistics": {
        "invocations": 0,
        "successes": 0,
        "failures": 0,
        "last_invoked": null,
        "success_rate": 0.0
      }
    }
  ],
  "config": {
    "cache_results": true,
    "cache_duration": 3600,
    "default_timeout": 120
  }
}
```

#### 2. Agent Registry Manager (`scripts/agents/agent-registry.sh`)

Manages the agent registry:
- Initialize registry from template
- List, enable, disable agents
- Show agent information
- Register new agents
- Track statistics

#### 3. Agent Invoker (`scripts/agents/invoke-agent.sh`)

Invokes agents with:
- Validation (agent exists, enabled, dependencies met)
- Context preparation
- Cache management
- Statistics tracking
- Timeout handling

---

## Available Agents

### Currently Available

#### 1. Quality Reviewer ✅ (Phase 2 - Implemented)

**ID:** `quality-reviewer`
**Subagent Type:** `use-case-quality-agent`

**Purpose:** Analyzes documentation quality and provides improvement suggestions

**Capabilities:**
- Quality scoring (0-10) with weighted categories
- Completeness verification for all template sections
- Style review and formatting checks
- Actionable improvement suggestions with examples

**Usage:**
```bash
# Review single file
ai-use-case review-quality .usecase/cases/example.md

# Batch review all files
ai-use-case review-quality --batch '.usecase/cases/*.md'

# Review specific project from hub
ai-use-case review-quality --project my-project

# Claude Code slash command
/use-case:review-quality [file]
```

#### 2. Pattern Analyzer ✅ (Phase 3 - Implemented)

**ID:** `pattern-analyzer`
**Subagent Type:** `use-case-pattern-agent`

**Purpose:** Analyzes documentation patterns across projects and provides recommendations

**Capabilities:**
- Pattern detection across projects (session types, complexity, tools)
- Project classification by type and maturity
- Trend analysis (documentation frequency, quality trends)
- Prioritized recommendations for improvement
- Hub-wide analysis with project comparison

**Usage:**
```bash
# Analyze current project
ai-use-case analyze-patterns

# Analyze specific project from hub
ai-use-case analyze-patterns --project my-project

# Analyze entire hub with comparison
ai-use-case analyze-patterns --hub --compare

# Analyze specific time period
ai-use-case analyze-patterns --period 6months

# Claude Code slash command
/use-case:analyze-patterns [options]
```

#### 3. Session Selector ✅ (Phase 4 - Implemented)

**ID:** `session-selector`
**Subagent Type:** `use-case-session-selector-agent`
**Status:** Implemented (v3.14.0)

**Purpose:** Intelligently analyzes and prioritizes sessions for documentation

**Capabilities:**
- Smart PR analysis with documentation value scoring
- Commit grouping by time, files, and message similarity
- Priority scoring (0-10 scale) with HIGH/MEDIUM/LOW levels
- Context extraction for template pre-population
- Already documented session detection

**Usage:**
```bash
/use-case:document-session --intelligent
```

**Features:**
- Analyzes PRs, commits, and conversations
- Assigns priority scores and provides reasoning
- Pre-extracts metadata (ticket, complexity, time saved, technologies)
- Groups related commits into logical sessions
- Provides clear recommendations on what to document first

#### 4. Organization Optimizer ✅ (Phase 5 - Implemented)

**ID:** `organization-optimizer`
**Subagent Type:** `use-case-organization-agent`
**Status:** Implemented (v3.15.0)

**Purpose:** Analyzes hub organization and suggests improvements for better documentation discoverability

**Capabilities:**
- Topic analysis (merge/split/rename recommendations)
- Relationship mapping (sequential, technical similarity, prerequisite, alternative)
- Hub health scoring
- Confidence-based recommendation filtering

**Future (Phase 5.1):**
- Tag suggestions (technology, pattern, domain, team)
- Search optimization (keywords, cross-references)
- CLI wrapper script

**Usage:**
```bash
/use-case:optimize-organization
```

**Features:**
- Analyzes 100+ documents in < 2 minutes
- Detects topic organization issues (fragmentation, overly broad topics)
- Maps relationships between documents with 0.7+ confidence
- Dry-run first workflow (always requires user confirmation)
- Symlink-only updates (preserves git history)
- Complete audit trail in `.meta/optimization-history.json`

---

## Agent Management

### Listing Agents

```bash
# List all agents (shows enabled/disabled status)
ai-use-case agents list

# Filter by status
ai-use-case agents list --enabled
ai-use-case agents list --disabled
```

**Output:**
```
═══════════════════════════════════════════════
AI Use Case CLI - Available Agents
═══════════════════════════════════════════════

● quality-reviewer - enabled
   Name: Documentation Quality Agent
   Description: Reviews documentation quality and provides suggestions
   Invocations: 5

○ pattern-analyzer - disabled
   Name: Project Pattern Agent
   Description: Analyzes documentation patterns across projects
   Invocations: 0
```

### Enabling/Disabling Agents

```bash
# Enable an agent
ai-use-case agents enable quality-reviewer

# Disable an agent
ai-use-case agents disable quality-reviewer
```

### Viewing Agent Information

```bash
ai-use-case agents info quality-reviewer
```

**Output:**
```
═══════════════════════════════════════════════
Agent Information: quality-reviewer
═══════════════════════════════════════════════

Name: Documentation Quality Agent
Description: Reviews documentation quality and provides suggestions
Status: Enabled
Version: 1.0.0
Subagent Type: use-case-quality-agent

Capabilities:
  quality-analysis, completeness-check, style-review

Dependencies:
  claude-code

Statistics:
  Total Invocations: 5
  Successes: 4
  Failures: 1
  Success Rate: 80.0%
  Avg Duration: 12.3s
  Last Invoked: 2025-12-02T10:30:00Z
```

### Viewing Statistics

```bash
# Overall statistics
ai-use-case agents stats

# Specific agent statistics
ai-use-case agents stats quality-reviewer
```

### Registering New Agents

```bash
ai-use-case agents register my-agent \
  --name "My Custom Agent" \
  --subagent-type "my-agent-type" \
  --description "Custom agent description"
```

### Resetting Registry

```bash
# Reset registry to default (requires confirmation)
ai-use-case agents reset
```

**⚠️ Warning:** This removes all agent statistics and custom registrations.

---

## Configuration

### Registry Location

- **Registry File:** `~/.config/ai-use-case-cli/agents.json`
- **Cache Directory:** `~/.cache/ai-use-case-cli/agents/`

### Configuration Options

Edit `~/.config/ai-use-case-cli/agents.json`:

```json
{
  "config": {
    "auto_update": true,
    "cache_results": true,
    "cache_duration": 3600,
    "cache_directory": "~/.cache/ai-use-case-cli/agents",
    "default_timeout": 120,
    "max_parallel_agents": 1,
    "log_level": "info"
  }
}
```

**Options:**
- `cache_results` - Enable/disable result caching (default: true)
- `cache_duration` - Cache duration in seconds (default: 3600 = 1 hour)
- `default_timeout` - Default agent timeout in seconds (default: 120)
- `max_parallel_agents` - Max concurrent agents (default: 1)

### Manual Configuration

```bash
# View current configuration
cat ~/.config/ai-use-case-cli/agents.json | jq '.config'

# Edit configuration
vi ~/.config/ai-use-case-cli/agents.json
```

---

## Troubleshooting

### Agent Registry Not Found

**Problem:** `Error: Agent registry not initialized`

**Solution:**
```bash
ai-use-case agents init
```

### Agent Not Found

**Problem:** `Error: Agent 'agent-id' not found`

**Solution:**
```bash
# List available agents
ai-use-case agents list

# Use correct agent ID
```

### Agent Disabled

**Problem:** `Error: Agent 'agent-id' is disabled`

**Solution:**
```bash
# Enable the agent
ai-use-case agents enable agent-id
```

### Claude Code Not Available (Future Phases)

**Problem:** `Error: Claude Code not available`

**Solution:**
- Agents require Claude Code for AI capabilities
- CLI works normally without agents
- Install Claude Code: https://claude.com/claude-code

### Permission Issues

**Problem:** Permission denied on registry file

**Solution:**
```bash
# Fix registry permissions
chmod 600 ~/.config/ai-use-case-cli/agents.json

# Recreate registry if needed
rm ~/.config/ai-use-case-cli/agents.json
ai-use-case agents init
```

### Cache Issues

**Problem:** Stale cached results

**Solution:**
```bash
# Clear agent cache
rm -rf ~/.cache/ai-use-case-cli/agents/

# Invoke with --no-cache flag (when agent implementations available)
```

---

## Developer Guide

### Agent Framework Architecture

#### Registry Manager (`agent-registry.sh`)

**Functions:**
- `init_registry()` - Initialize registry from template
- `list_agents(filter)` - List agents with optional filter
- `enable_agent(id)` - Enable an agent
- `disable_agent(id)` - Disable an agent
- `show_agent_info(id)` - Show detailed agent info
- `register_agent(id, name, type, desc)` - Register new agent
- `show_stats(id?)` - Show statistics
- `reset_registry()` - Reset to default

**Usage in Scripts:**
```bash
source "$SCRIPT_DIR/scripts/agents/agent-registry.sh"

# Use functions directly
init_registry
enable_agent "quality-reviewer"
```

#### Agent Invoker (`invoke-agent.sh`)

**Functions:**
- `validate_agent(id)` - Validate agent exists and is enabled
- `invoke_agent(id, params)` - Invoke agent with parameters
- `check_cache(id, key)` - Check for cached results
- `save_cache(id, key, result)` - Save results to cache
- `update_statistics(id, success, duration)` - Update agent stats

**Usage in Scripts:**
```bash
source "$SCRIPT_DIR/scripts/agents/invoke-agent.sh"

# Invoke agent
invoke_agent "quality-reviewer" --file "path/to/file.md"
```

### Creating New Agents (Phase 2+)

**Step 1: Register the Agent**

```bash
ai-use-case agents register my-agent \
  --name "My Custom Agent" \
  --subagent-type "my-custom-agent" \
  --description "Agent description"
```

**Step 2: Create Agent Prompt**

Create `.claude/agents/my-custom-agent.md` with:
- Agent purpose and capabilities
- Input/output specifications
- Examples and instructions

**Step 3: Create CLI Wrapper** (Optional)

Create `scripts/agents/my-agent.sh` for custom CLI commands.

**Step 4: Test**

```bash
# Enable agent
ai-use-case agents enable my-agent

# Test invocation
./scripts/agents/invoke-agent.sh my-agent --test-param value
```

### Testing

**Unit Testing:**
```bash
# Test registry operations
bash scripts/agents/agent-registry.sh init
bash scripts/agents/agent-registry.sh list
bash scripts/agents/agent-registry.sh enable quality-reviewer

# Test invoker
bash scripts/agents/invoke-agent.sh quality-reviewer --file test.md
```

**Integration Testing:**
```bash
# Test via CLI
ai-use-case agents list
ai-use-case agents enable quality-reviewer
ai-use-case agents info quality-reviewer
```

---

## Roadmap

### Phase 1: Agent Framework ✅ (Complete)
- ✅ Agent registry system
- ✅ Agent invocation framework
- ✅ CLI integration
- ✅ Statistics and caching

### Phase 2: Quality Reviewer ✅ (Complete - v3.11.0)
- ✅ Documentation quality analysis
- ✅ Quality scoring (0-10) with weighted categories
- ✅ CLI command: `ai-use-case review-quality`
- ✅ Slash command: `/use-case:review-quality`
- ✅ Batch and project modes

### Phase 3: Pattern Analyzer ✅ (Complete)
- ✅ Pattern detection across projects
- ✅ Project classification and maturity assessment
- ✅ Trend analysis (frequency, quality)
- ✅ Prioritized recommendations
- ✅ CLI command: `ai-use-case analyze-patterns`
- ✅ Slash command: `/use-case:analyze-patterns`
- ✅ Hub-wide analysis with comparison

### Phase 4: Session Selector ✅ (Complete - v3.14.0)
- ✅ Intelligent PR analysis with documentation value scoring
- ✅ Commit grouping by time, files, and message similarity
- ✅ Priority scoring (0-10 scale)
- ✅ Context extraction for template pre-population
- ✅ CLI integration via `--intelligent` flag
- ✅ Already documented session detection

### Phase 5: Organization Intelligence ✅ (Complete - v3.15.0)
- ✅ Hub organization analysis
- ✅ Topic clustering (merge/split/rename recommendations)
- ✅ Relationship mapping (sequential, technical similarity, prerequisite, alternative)
- ✅ Slash command: `/use-case:optimize-organization`
- ✅ Dry-run first workflow with user confirmation
- ✅ Confidence-based filtering (0.7+ threshold)
- ⏳ Tag suggestions (deferred to Phase 5.1)
- ⏳ Search optimization (deferred to Phase 5.1)
- ⏳ CLI wrapper script (deferred to Phase 5.1)

---

## Resources

- **Feature Plan:** [docs/features/intelligent-agents-integration/01-feature-plan.md](../../features/intelligent-agents-integration/01-feature-plan.md)
- **Requirements:** [docs/features/intelligent-agents-integration/02-requirements.md](../../features/intelligent-agents-integration/02-requirements.md)
- **Implementation Checklist:** [docs/features/intelligent-agents-integration/03-implementation-checklist.md](../../features/intelligent-agents-integration/03-implementation-checklist.md)
- **Quick Start:** [docs/features/intelligent-agents-integration/QUICKSTART.md](../../features/intelligent-agents-integration/QUICKSTART.md)

---

## Support

- **Issues:** Report at https://github.com/mt-osiris-tools/ai-use-case-cli/issues
- **Feature Requests:** Tag with `[FEATURE-002]` or `agents`
- **Questions:** Reference this guide in discussions

---

**Last Updated:** 2025-12-07
**Version:** 1.2.0 (Phase 1-3 Complete)
**Status:** Agent Framework + Quality Reviewer + Pattern Analyzer Operational
