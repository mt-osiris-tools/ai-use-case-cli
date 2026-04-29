# Quick Start: Intelligent Agents Integration

**Feature ID:** FEATURE-002
**For:** Developers implementing or contributing to this feature
**Time to Read:** 10 minutes

---

## What This Feature Adds

This feature adds intelligent AI agents to the AI Use Case CLI, enabling:

- **Documentation Quality Review** - Automated quality scoring and improvement suggestions
- **Pattern Analysis** - Learn from past sessions to replicate success
- **Intelligent Session Selection** - Smarter PR/commit analysis for documentation
- **Hub Organization** - Intelligent recommendations for better organization

**Architecture:** Hybrid approach - bash scripts for reliability, AI agents for intelligence

---

## Prerequisites

Before starting implementation:

- [ ] Read [01-feature-plan.md](./01-feature-plan.md) - Understand the vision and architecture
- [ ] Read [02-requirements.md](./02-requirements.md) - Know what needs to be built
- [ ] Review [03-implementation-checklist.md](./03-implementation-checklist.md) - See the full task breakdown
- [ ] Understand existing Claude Code agent system (Task tool with subagent_type)
- [ ] Familiar with bash scripting and jq for JSON manipulation

---

## 5-Minute Overview

### What You're Building

```
┌─────────────────────────────────────────────────────────────┐
│                    AI Use Case CLI                          │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Core Scripts (existing)                              │  │
│  │  - setup, sync, document, search                      │  │
│  │  - Unchanged, remains reliable and fast               │  │
│  └──────────────────────────────────────────────────────┘  │
│                           │                                  │
│  ┌────────────────────────┼──────────────────────────────┐  │
│  │  Agent Framework (NEW)  ▼                             │  │
│  │  ┌─────────────┐   ┌──────────────┐                  │  │
│  │  │  Registry   │   │   Invoker    │                  │  │
│  │  │  (JSON)     │◄──┤  (wrapper)   │                  │  │
│  │  └─────────────┘   └───────┬──────┘                  │  │
│  │                             │                          │  │
│  └─────────────────────────────┼──────────────────────────┘  │
│                                │                              │
│  ┌─────────────────────────────┼──────────────────────────┐  │
│  │  Specialized Agents (NEW)   ▼                          │  │
│  │  - Quality Reviewer                                    │  │
│  │  - Pattern Analyzer                                    │  │
│  │  - Session Selector                                    │  │
│  │  - Organization Intelligence                           │  │
│  └────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Key Files to Create

```
NEW Structure:
scripts/agents/
├── agents-template.json           # Registry schema
├── agent-registry.sh               # Registry manager
├── invoke-agent.sh                 # Agent invoker
├── quality-agent.sh                # Quality wrapper
├── pattern-agent.sh                # Pattern wrapper
└── organization-agent.sh           # Organization wrapper

.claude/agents/
├── use-case-quality-agent.md       # Quality agent prompt
├── use-case-pattern-agent.md       # Pattern agent prompt
├── use-case-session-selector-agent.md  # Session selector prompt
└── use-case-organization-agent.md  # Organization agent prompt

.claude/commands/use-case/
├── review-quality.md               # Quality review command
├── analyze-patterns.md             # Pattern analysis command
└── optimize-organization.md        # Organization command

docs/
└── AGENTS.md                       # Comprehensive agent documentation
```

### Modified Files

```
MODIFIED:
- ai-use-case                       # Add agent commands
- .claude/commands/use-case/document-session.md  # Add --intelligent
- README.md                         # Add agents section
- CHANGELOG.md                      # Document all changes
- docs/COMMANDS.md                  # Add agent commands
- docs/CLAUDE.md                    # Add agent info
```

---

## Implementation Phases

### Phase 1: Agent Framework (Week 1) 🔧

**Goal:** Build the foundation for all agents

**What to Build:**
1. JSON-based agent registry system
2. Agent registry manager (list, enable, disable, register)
3. Agent invoker (wrapper for Claude Code Task tool)
4. CLI integration (`ai-use-case agents` subcommand)
5. Documentation (docs/AGENTS.md)

**Start Here:**
```bash
# 1. Create directory structure
mkdir -p scripts/agents
mkdir -p .claude/agents

# 2. Create registry template
vim scripts/agents/agents-template.json
# (Define JSON schema - see requirements)

# 3. Implement registry manager
vim scripts/agents/agent-registry.sh
# Functions: init_registry, list_agents, enable_agent, disable_agent, show_agent_info

# 4. Test
./scripts/agents/agent-registry.sh init
./scripts/agents/agent-registry.sh list
```

**Success Criteria:**
- ✅ Registry exists at `${XDG_CONFIG_HOME:-$HOME/.config}/ai-use-case-cli/agents.json`
- ✅ Can list, enable, disable agents via CLI
- ✅ Framework adds < 10ms overhead

### Phase 2: Quality Agent (Week 2) 📊

**Goal:** First functional agent - documentation quality review

**What to Build:**
1. Quality agent prompt (`.claude/agents/use-case-quality-agent.md`)
2. Quality agent CLI wrapper (`scripts/agents/quality-agent.sh`)
3. CLI command (`ai-use-case review-quality`)
4. Slash command (`/use-case:review-quality`)

**Start Here:**
```bash
# 1. Write agent prompt
vim .claude/agents/use-case-quality-agent.md
# Define: purpose, scoring criteria, output format, examples

# 2. Implement wrapper
vim scripts/agents/quality-agent.sh
# Functions: validate_file, review_file, review_batch, format_output

# 3. Add to CLI
# Edit ai-use-case: add review-quality case

# 4. Test
ai-use-case review-quality .usecase/cases/example.md
```

**Success Criteria:**
- ✅ Reviews single file in < 30 seconds
- ✅ Provides score 0-10 with breakdown
- ✅ Gives 3+ actionable improvements
- ✅ Works in both CLI and slash command

### Phase 3: Pattern Agent (Week 3) 📈

**Goal:** Learn from documentation history

**What to Build:**
1. Pattern agent prompt
2. Pattern agent CLI wrapper
3. CLI command (`ai-use-case analyze-patterns`)
4. Slash command (`/use-case:analyze-patterns`)

**Start Here:**
```bash
# 1. Write agent prompt
vim .claude/agents/use-case-pattern-agent.md
# Define: pattern detection, classification, recommendations, trends

# 2. Implement wrapper
vim scripts/agents/pattern-agent.sh
# Functions: analyze_project, analyze_hub, filter_by_period

# 3. Test with real hub data
ai-use-case analyze-patterns --project ai-use-case-cli
```

**Success Criteria:**
- ✅ Identifies 3+ pattern categories
- ✅ Provides contextual recommendations
- ✅ Shows trend analysis
- ✅ Works with 50+ documents

### Phase 4: Enhanced Session Selector (Week 4) 🎯

**Goal:** Smarter session selection for documentation

**What to Build:**
1. Session selector agent prompt
2. Enhance existing `/use-case:document-session` with `--intelligent` flag

**Start Here:**
```bash
# 1. Write agent prompt
vim .claude/agents/use-case-session-selector-agent.md
# Define: PR analysis, commit grouping, priority scoring, context extraction

# 2. Enhance document-session command
vim .claude/commands/use-case/document-session.md
# Add: --intelligent flag, smart PR analysis, commit grouping, priority display

# 3. Test
/use-case:document-session --intelligent
```

**Success Criteria:**
- ✅ Scores PRs by documentation value
- ✅ Groups related commits intelligently
- ✅ Pre-populates more context
- ✅ Recommends priority sessions

### Phase 5: Organization Agent (Week 5) 🗂️

**Goal:** Optimize hub organization

**What to Build:**
1. Organization agent prompt
2. Organization agent CLI wrapper
3. CLI command (`ai-use-case optimize-organization`)
4. Slash command (`/use-case:optimize-organization`)

**Start Here:**
```bash
# 1. Write agent prompt
vim .claude/agents/use-case-organization-agent.md
# Define: topic analysis, relationship mapping, tag suggestions, search optimization

# 2. Implement wrapper
vim scripts/agents/organization-agent.sh
# Functions: analyze_hub_organization, dry_run_mode, auto_apply_mode

# 3. Test (carefully with --dry-run!)
ai-use-case optimize-organization --dry-run
```

**Success Criteria:**
- ✅ Suggests topic improvements
- ✅ Identifies related sessions
- ✅ Recommends tags
- ✅ Provides actionable optimization

---

## Common Tasks

### Creating a New Agent

1. **Design the Agent**
   ```markdown
   # Agent Design Template

   Name: [Agent Name]
   Purpose: [What problem does it solve?]
   Input: [What data does it need?]
   Output: [What does it return?]
   Capabilities: [What can it do?]
   Dependencies: [What does it need?]
   ```

2. **Write the Prompt**
   ```bash
   vim .claude/agents/use-case-your-agent.md

   # Include:
   # - Clear purpose statement
   # - Detailed instructions
   # - Input/output schemas
   # - Examples (good and bad)
   # - Edge cases to handle
   ```

3. **Create CLI Wrapper**
   ```bash
   vim scripts/agents/your-agent.sh

   # Template structure:
   #!/bin/bash
   set -e

   # Source dependencies
   source "$(dirname "$0")/invoke-agent.sh"

   # Add usage function
   # Implement main functions
   # Add error handling
   # Format output
   ```

4. **Register the Agent**
   ```bash
   ai-use-case agents register your-agent \
     --subagent-type "use-case-your-agent" \
     --description "Your agent description"
   ```

5. **Test Thoroughly**
   ```bash
   # Test basic invocation
   ai-use-case agents invoke your-agent --test-param value

   # Test error cases
   ai-use-case agents invoke your-agent --invalid-param

   # Test with real data
   ai-use-case agents invoke your-agent --real-data path
   ```

### Testing Your Changes

**Unit Testing:**
```bash
# Test individual functions
bash -x scripts/agents/agent-registry.sh init
bash -x scripts/agents/agent-registry.sh list

# Test error handling
bash -x scripts/agents/quality-agent.sh /nonexistent/file.md
```

**Integration Testing:**
```bash
# Test full workflow
ai-use-case agents list
ai-use-case agents enable quality-reviewer
ai-use-case review-quality test-file.md
ai-use-case agents disable quality-reviewer
```

**Regression Testing:**
```bash
# Verify no breaking changes
ai-use-case --init /tmp/test-project
ai-use-case sync
ai-use-case search test
ai-use-case stats

# Should all work as before
```

### Debugging Agent Issues

**Check Agent Registry:**
```bash
# View registry
cat "${XDG_CONFIG_HOME:-$HOME/.config}/ai-use-case-cli/agents.json" | jq '.'

# Verify agent enabled
jq '.agents[] | select(.id=="quality-reviewer") | .enabled' \
  "${XDG_CONFIG_HOME:-$HOME/.config}/ai-use-case-cli/agents.json"
```

**Test Agent Invocation:**
```bash
# Debug mode
bash -x ./scripts/agents/invoke-agent.sh quality-reviewer \
  --file test.md 2>&1 | tee debug.log

# Check statistics
jq '.agents[] | select(.id=="quality-reviewer") | .statistics' \
  "${XDG_CONFIG_HOME:-$HOME/.config}/ai-use-case-cli/agents.json"
```

**Verify Claude Code Connection:**
```bash
# Test if Claude Code available
command -v claude || echo "Claude Code not found"

# Test basic agent call (if claude CLI exists)
# (Actual implementation may vary)
```

---

## Development Tips

### Best Practices

1. **Keep Agents Optional**
   - CLI must work without agents
   - Graceful degradation always
   - Clear messaging when unavailable

2. **Make Agents Fast**
   - Show progress immediately (< 2s)
   - Cache results when appropriate
   - Don't block CLI for agent checks

3. **Write Clear Prompts**
   - Be specific about expectations
   - Include concrete examples
   - Define output schemas precisely

4. **Test with Real Data**
   - Use actual hub data for testing
   - Test with edge cases
   - Verify recommendations are useful

5. **Document Everything**
   - Every function has a comment
   - Every agent has documentation
   - Every command has examples

### Common Pitfalls

❌ **Don't:**
- Make CLI dependent on agents
- Add agents for simple operations
- Modify files without user approval
- Skip backward compatibility testing
- Forget to update documentation

✅ **Do:**
- Keep clear separation between scripts and agents
- Test with agents enabled and disabled
- Provide meaningful progress indicators
- Handle all error cases gracefully
- Update CHANGELOG.md for every change

---

## Resources

### Documentation

- [Feature Plan](./01-feature-plan.md) - High-level design and rationale
- [Requirements](./02-requirements.md) - Detailed requirements
- [Implementation Checklist](./03-implementation-checklist.md) - Step-by-step tasks
- [C4 Diagrams](../../diagrams/) - Architecture visualization
- [CLAUDE.md](../../../CLAUDE.md) - Claude Code integration guide

### Examples

- Existing feature: `docs/features/claude-agents-tracking/`
- Existing agents: Look at Claude Code built-in agents (Explore, Plan, etc.)
- Similar tools: Research how other CLIs integrate AI features

### Getting Help

- Review existing code patterns in `scripts/`
- Check `docs/WORKFLOW.md` for development workflow
- Read `CONTRIBUTING.md` for contribution guidelines
- Test thoroughly before creating PR

---

## Quick Reference Commands

```bash
# Feature Branch
git checkout -b feature/intelligent-agents-integration

# Create Directory Structure
mkdir -p scripts/agents .claude/agents

# Test Agent Registry
./scripts/agents/agent-registry.sh init
./scripts/agents/agent-registry.sh list

# Test Quality Agent
ai-use-case review-quality .usecase/cases/example.md

# Test Pattern Agent
ai-use-case analyze-patterns --project test

# Debug
bash -x ./scripts/agents/invoke-agent.sh agent-id --debug

# Commit
git add -A
git commit -m "feat(agents): [description]"

# Create PR
git push -u origin feature/intelligent-agents-integration
gh pr create --title "feat: Add intelligent agents integration" \
  --body-file pr-template.md
```

---

## Next Steps

1. ✅ Read this QUICKSTART (you're here!)
2. ⏳ Review [01-feature-plan.md](./01-feature-plan.md) in detail
3. ⏳ Review [02-requirements.md](./02-requirements.md)
4. ⏳ Start Phase 1: Create agent framework
5. ⏳ Follow [03-implementation-checklist.md](./03-implementation-checklist.md)

---

**Questions? Issues?**
- Create issue in repository with [FEATURE-002] prefix
- Reference this feature plan in discussions
- Tag maintainers for guidance

**Ready to start? Begin with Phase 1 in the Implementation Checklist!** 🚀
