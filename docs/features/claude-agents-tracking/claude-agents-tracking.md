# Feature Plan: Claude Agents Usage Tracking

**Feature ID:** FEATURE-001
**Created:** 2025-12-01
**Status:** Planning
**Priority:** Medium
**Complexity:** Medium

---

## Overview

Add tracking and documentation of Claude agent usage (Task tool with specialized subagents) to AI session documentation. This will provide visibility into which specialized AI capabilities were leveraged during a session.

## Problem Statement

Currently, AI session documentation tracks:
- Tool usage (Read, Write, Edit, Bash, Grep, etc.)
- Token usage and costs
- User interactions and prompts

However, it **does not track** when specialized Claude agents are used via the Task tool, such as:
- Explore agent (codebase exploration)
- Plan agent (architecture planning)
- general-purpose agent (complex multi-step tasks)
- code-reviewer agent (code review)
- Other specialized agents

This missing information makes it harder to:
1. Understand the complexity of AI-assisted sessions
2. Identify which agent types provide the most value
3. Replicate successful workflows that leveraged specific agents
4. Track the evolution of agent usage patterns over time

## Goals

### Primary Goals
1. **Track agent invocations** - Document which agents were used and how many times
2. **Capture agent context** - Record what each agent was used for
3. **Measure agent effectiveness** - Note outcomes and value provided
4. **Auto-detection** - Automatically detect and document agent usage in Claude Code sessions
5. **Manual input support** - Allow users to manually document agent usage in interactive mode

### Non-Goals
- Tracking agent internal operations or token usage (already covered by overall metrics)
- Real-time agent monitoring during execution
- Agent performance benchmarking or optimization

## Success Criteria

1. ✅ Templates include a "Claude Agents Used" section
2. ✅ Automatic documentation detects agent usage from conversation history
3. ✅ Interactive mode prompts users for agent usage information
4. ✅ Documentation shows which agents were used, how many times, and for what purpose
5. ✅ Existing documentation workflows remain unchanged for non-agent sessions

## Proposed Solution

### 1. Template Updates

Add a new subsection in both templates (TEMPLATE.md and TEMPLATE-RESEARCH.md):

**Location:** Under "## 🤖 AI Interaction Metrics" section, after "Tool Usage Breakdown"

**Structure:**
```markdown
### Claude Agents Used

- **Explore Agent:** X invocations
  - **Purpose:** Codebase exploration, finding patterns in large codebases
  - **Key Findings:** [What the agent discovered or helped with]
  - **Value:** [Impact on the session - saved time, provided insights, etc.]

- **Plan Agent:** X invocations
  - **Purpose:** Architecture planning, implementation strategy design
  - **Output:** [What plans or strategies were generated]
  - **Value:** [How it helped the implementation]

- **General-Purpose Agent:** X invocations
  - **Purpose:** [Specific multi-step tasks handled]
  - **Outcome:** [What was accomplished]
  - **Value:** [Contribution to session success]

- **[Other Agent]:** X invocations
  - **Purpose:** [What this agent was used for]
  - **Outcome:** [Results]
  - **Value:** [Impact]

**Agent Effectiveness Summary:**
- Total agent invocations: X
- Most valuable agent: [Agent name and why]
- Time saved by agents: ~X hours
```

### 2. Automatic Detection (Claude Code)

**File:** `.claude/commands/use-case/document-session.md`

**Detection Logic:**
When `/use-case:document-session` runs, Claude analyzes the conversation history to:
1. Identify all Task tool invocations
2. Extract the `subagent_type` parameter from each call
3. Count frequency by agent type
4. Extract the `prompt` parameter to understand purpose/context
5. Note the outcomes based on subsequent conversation

**Implementation in slash command:**
```markdown
### Step X: Detect Agent Usage (During Session Analysis Phase)

Analyze the conversation history for Task tool usage:
- Search for all `<invoke name="Task">` blocks
- Extract `subagent_type` parameter from each
- Count invocations per agent type
- Extract `prompt` to understand context/purpose
- Note outcomes from conversation following agent execution

**Agent Types to Detect:**
- Explore: Codebase exploration agent
- Plan: Architecture/implementation planning agent
- general-purpose: Multi-step task agent
- code-reviewer: Code review agent
- [Any other custom agent types]

**Information to Extract:**
- Agent type
- Number of invocations
- Purpose (from prompt parameter)
- Outcome (from conversation context)
- Value/impact (inferred from user's reactions/follow-ups)
```

### 3. Interactive Mode Support

**File:** `scripts/core/document-ai-session.sh`

**New Prompts (after AI tool selection):**

```bash
# Claude Agents Usage (new section around line 530)
echo ""
echo -e "${CYAN}Claude Agents Usage:${NC}"
read -p "Were any Claude agents used during this session? (y/N): " AGENTS_USED
AGENTS_USED=${AGENTS_USED:-n}

if [[ "$AGENTS_USED" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Which agents were used? (comma-separated)"
    echo "Options: Explore, Plan, general-purpose, code-reviewer, other"
    read -p "Agents: " AGENTS_LIST

    # For each agent, collect details
    IFS=',' read -ra AGENT_ARRAY <<< "$AGENTS_LIST"
    for agent in "${AGENT_ARRAY[@]}"; do
        agent=$(echo "$agent" | xargs) # trim whitespace
        echo ""
        echo "Details for: $agent"
        read -p "  Number of invocations: " AGENT_COUNT
        read -p "  Purpose (what was it used for?): " AGENT_PURPOSE
        read -p "  Key outcome or value: " AGENT_VALUE

        # Store in variables for template generation
        # (Implementation details TBD)
    done
fi
```

### 4. Documentation Generation

Both automatic and interactive modes will populate the new template section with:
- List of agents used
- Invocation counts
- Purpose/context for each
- Outcomes and value provided
- Summary of agent effectiveness

## Technical Architecture

### Components Affected

1. **Templates** (2 files)
   - `docs/TEMPLATE.md` - Implementation session template
   - `docs/TEMPLATE-RESEARCH.md` - Research session template

2. **Automatic Documentation** (1 file)
   - `.claude/commands/use-case/document-session.md` - Claude Code slash command

3. **Interactive Documentation** (1 file)
   - `scripts/core/document-ai-session.sh` - Interactive shell script

4. **Documentation** (2-3 files)
   - `CHANGELOG.md` - Record the feature addition
   - `README.md` - Update feature list
   - `docs/CLAUDE.md` - Update guidance (if needed)

### Data Flow

**Automatic Mode (Claude Code):**
```
User invokes /use-case:document-session
    ↓
Claude analyzes conversation history
    ↓
Detects Task tool invocations
    ↓
Extracts agent types, counts, context
    ↓
Generates documentation with agent section populated
    ↓
Saves to .usecase/cases/
```

**Interactive Mode (Shell):**
```
User runs: ai-use-case document
    ↓
Script prompts: "Were agents used?"
    ↓
If yes: Collect agent details interactively
    ↓
Generate documentation with agent section
    ↓
Save to .usecase/cases/
```

## Implementation Phases

### Phase 1: Template Updates (Week 1)
- Update TEMPLATE.md with new section
- Update TEMPLATE-RESEARCH.md with new section
- Document the new section in template documentation

### Phase 2: Interactive Mode Support (Week 1-2)
- Add prompts to document-ai-session.sh
- Implement data collection logic
- Update template generation to include agent data
- Test with manual sessions

### Phase 3: Automatic Detection (Week 2-3)
- Update document-session.md slash command
- Implement conversation history parsing
- Extract agent usage information
- Populate agent section automatically
- Test with various agent usage patterns

### Phase 4: Testing & Documentation (Week 3-4)
- End-to-end testing of both modes
- Update CHANGELOG.md
- Update README.md
- Update CLAUDE.md if needed
- Create example documentation showing agent tracking

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Conversation history parsing is complex | Medium | Medium | Start with simple regex patterns, iterate based on real usage |
| Users may not remember which agents were used | Low | Medium | Make interactive prompts optional, provide examples |
| Agent names/types may change over time | Low | Low | Use flexible matching, document known agent types |
| Adds complexity to documentation process | Medium | Low | Keep section optional, auto-populate when possible |
| Breaking changes to existing workflows | High | Low | Ensure backward compatibility, make agent section optional |

## Future Enhancements

**Phase 2 (Future):**
- Agent performance metrics (time per agent, success rates)
- Agent recommendation system (suggest agents for similar tasks)
- Agent usage analytics across all sessions
- Integration with Claude Code's native agent tracking (if available)

## Related Documentation

- [AI_SESSION_STATISTICS_GUIDE.md](../AI_SESSION_STATISTICS_GUIDE.md) - General metrics guidance
- [CAPTURING_USER_QUERIES.md](../CAPTURING_USER_QUERIES.md) - Query documentation patterns
- [TEMPLATE.md](../TEMPLATE.md) - Implementation session template
- [TEMPLATE-RESEARCH.md](../TEMPLATE-RESEARCH.md) - Research session template

## References

- Claude Code Task tool documentation
- Existing tool usage tracking implementation
- Current template structure and conventions

---

**Next Steps:**
1. ✅ Create feature plan (this document)
2. ⏳ Generate detailed requirements
3. ⏳ Create implementation checklist
4. ⏳ Begin Phase 1: Template updates
