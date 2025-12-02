# Requirements: Claude Agents Usage Tracking

**Feature ID:** FEATURE-001
**Requirements Version:** 1.0
**Created:** 2025-12-01
**Last Updated:** 2025-12-01

---

## Table of Contents

1. [Functional Requirements](#functional-requirements)
2. [Non-Functional Requirements](#non-functional-requirements)
3. [User Stories](#user-stories)
4. [Acceptance Criteria](#acceptance-criteria)
5. [Data Requirements](#data-requirements)
6. [Interface Requirements](#interface-requirements)
7. [Constraints](#constraints)

---

## Functional Requirements

### FR-1: Template Structure

**Priority:** High
**Status:** Required

#### FR-1.1: Implementation Template Updates
- **Requirement:** The TEMPLATE.md file MUST include a new "Claude Agents Used" subsection
- **Location:** Under "## 🤖 AI Interaction Metrics", after "### Tool Usage Breakdown"
- **Content:** Section must support multiple agent entries with structured fields

#### FR-1.2: Research Template Updates
- **Requirement:** The TEMPLATE-RESEARCH.md file MUST include the same "Claude Agents Used" subsection
- **Location:** Under "## 🤖 AI Interaction Metrics", after "### Tool Usage (if applicable)"
- **Content:** Identical structure to implementation template

#### FR-1.3: Optional Section
- **Requirement:** The agents section MUST be optional - if no agents were used, it can be omitted or marked as "None"
- **Rationale:** Many sessions won't use specialized agents

### FR-2: Agent Information Capture

**Priority:** High
**Status:** Required

#### FR-2.1: Agent Type
- **Requirement:** System MUST capture the agent type/name (e.g., "Explore", "Plan", "general-purpose")
- **Source:** From `subagent_type` parameter in Task tool calls (automatic) or user input (interactive)

#### FR-2.2: Invocation Count
- **Requirement:** System MUST track how many times each agent type was invoked
- **Format:** Integer count (e.g., "3 invocations")

#### FR-2.3: Purpose/Context
- **Requirement:** System MUST capture why the agent was used
- **Source:** From `prompt` parameter (automatic) or user description (interactive)
- **Format:** Brief description (1-2 sentences)

#### FR-2.4: Key Findings/Output
- **Requirement:** System MUST document what the agent produced or discovered
- **Source:** From conversation context (automatic) or user input (interactive)
- **Format:** Summary or bullet points

#### FR-2.5: Value/Impact
- **Requirement:** System MUST capture the value the agent provided
- **Examples:** "Saved 2 hours of manual exploration", "Identified critical architectural issue"
- **Format:** Brief statement

#### FR-2.6: Agent Effectiveness Summary
- **Requirement:** System MUST generate a summary section with:
  - Total agent invocations count
  - Most valuable agent (and why)
  - Estimated time saved by agents (optional)

### FR-3: Automatic Detection (Claude Code)

**Priority:** High
**Status:** Required

#### FR-3.1: Conversation History Analysis
- **Requirement:** When `/use-case:document-session` runs, system MUST analyze full conversation history
- **Scope:** From session start to documentation generation

#### FR-3.2: Task Tool Detection
- **Requirement:** System MUST identify all instances of Task tool invocations
- **Pattern:** Search for `<invoke name="Task">` blocks in conversation

#### FR-3.3: Agent Type Extraction
- **Requirement:** System MUST extract `subagent_type` parameter from each Task invocation
- **Handling:** Support all known agent types (Explore, Plan, general-purpose, etc.)
- **Fallback:** If unknown type, list as "Custom Agent: [type]"

#### FR-3.4: Context Extraction
- **Requirement:** System MUST extract the `prompt` parameter to understand agent purpose
- **Processing:** Summarize if prompt is very long (>100 words)

#### FR-3.5: Outcome Inference
- **Requirement:** System MUST infer agent outcomes from conversation context
- **Method:** Analyze user's responses and follow-up actions after agent execution
- **Indicators:** Look for positive feedback, task completion, or issues resolved

#### FR-3.6: Zero-Prompt Generation
- **Requirement:** Automatic mode MUST NOT prompt user for any agent information
- **Rationale:** Full automation is the goal for Claude Code sessions

### FR-4: Interactive Mode Support

**Priority:** Medium
**Status:** Required

#### FR-4.1: Agent Usage Prompt
- **Requirement:** Script MUST ask "Were any Claude agents used during this session? (y/N)"
- **Default:** No (N)
- **Location:** After AI tool selection prompts

#### FR-4.2: Agent List Collection
- **Requirement:** If user answers "yes", script MUST prompt for comma-separated list of agents
- **Format:** "Explore, Plan, general-purpose, code-reviewer, other"
- **Validation:** Accept any input, trim whitespace

#### FR-4.3: Per-Agent Details
- **Requirement:** For each agent in the list, script MUST collect:
  - Number of invocations (integer)
  - Purpose (text)
  - Key outcome/value (text)

#### FR-4.4: Optional Participation
- **Requirement:** User MUST be able to skip agent documentation by answering "no" or pressing Enter
- **Behavior:** Section is omitted from generated documentation

### FR-5: Documentation Generation

**Priority:** High
**Status:** Required

#### FR-5.1: Template Population (Automatic)
- **Requirement:** System MUST populate the "Claude Agents Used" section with detected agent data
- **Format:** Follow template structure exactly
- **Completeness:** All detected agents MUST be included

#### FR-5.2: Template Population (Interactive)
- **Requirement:** System MUST populate the section with user-provided agent data
- **Format:** Follow template structure exactly
- **Validation:** Basic validation (non-empty fields)

#### FR-5.3: No Agents Case
- **Requirement:** If no agents were used:
  - **Option 1:** Omit the section entirely
  - **Option 2:** Include section with "None - no specialized agents used"
- **Decision:** TBD during implementation

#### FR-5.4: Backward Compatibility
- **Requirement:** Documentation generation MUST work identically for sessions without agent usage
- **Rationale:** Existing workflows must not break

---

## Non-Functional Requirements

### NFR-1: Performance

#### NFR-1.1: Automatic Detection Performance
- **Requirement:** Agent detection MUST NOT add more than 5 seconds to documentation generation time
- **Rationale:** Keep process fast and responsive

#### NFR-1.2: Interactive Mode Performance
- **Requirement:** Additional prompts MUST NOT significantly impact user experience
- **Target:** <30 seconds for complete agent information entry

### NFR-2: Usability

#### NFR-2.1: Clear Prompts
- **Requirement:** All interactive prompts MUST be clear and include examples
- **Example:** "Which agents were used? (comma-separated)\nOptions: Explore, Plan, general-purpose, code-reviewer, other"

#### NFR-2.2: Sensible Defaults
- **Requirement:** All interactive prompts MUST have sensible defaults (typically "no" or "skip")

#### NFR-2.3: Error Handling
- **Requirement:** System MUST handle malformed input gracefully
- **Behavior:** Show helpful error message, allow retry

### NFR-3: Maintainability

#### NFR-3.1: Extensibility
- **Requirement:** Implementation MUST support adding new agent types without code changes
- **Method:** Use flexible string matching, not hardcoded enums

#### NFR-3.2: Documentation
- **Requirement:** All code changes MUST be documented with comments
- **Requirement:** CHANGELOG.md MUST be updated

### NFR-4: Compatibility

#### NFR-4.1: Template Backward Compatibility
- **Requirement:** Updated templates MUST be usable with older CLI versions
- **Behavior:** Older versions ignore new section, still generate valid docs

#### NFR-4.2: Script Compatibility
- **Requirement:** Changes to document-ai-session.sh MUST be backward compatible
- **Behavior:** Script works on systems with bash 4.0+

---

## User Stories

### US-1: Developer Using Claude Code (Automatic Mode)

**As a** developer using Claude Code for AI-assisted development
**I want** my agent usage to be automatically tracked and documented
**So that** I don't have to manually record which specialized AI capabilities I used

**Acceptance Criteria:**
- Agent usage is detected without any user input
- Documentation includes all agents used, with context
- No additional time or effort required from user

### US-2: Developer Using Interactive Mode

**As a** developer documenting a session manually via shell
**I want** to optionally document which Claude agents I used
**So that** I can maintain consistent documentation across all sessions

**Acceptance Criteria:**
- Script prompts me for agent usage information
- I can skip this section if no agents were used
- Prompts are clear and provide examples

### US-3: Team Lead Reviewing Documentation

**As a** team lead reviewing AI session documentation
**I want** to see which specialized agents were used and their impact
**So that** I can understand the sophistication of the AI assistance and ROI

**Acceptance Criteria:**
- Documentation clearly shows which agents were used
- Impact and value of each agent is documented
- Summary section highlights most valuable agents

### US-4: Developer Replicating a Workflow

**As a** developer trying to replicate a successful AI-assisted workflow
**I want** to know which agents were used and for what purpose
**So that** I can leverage the same specialized capabilities

**Acceptance Criteria:**
- Agent types and their purposes are clearly documented
- Context is provided for when each agent was invoked
- Outcomes show what each agent accomplished

---

## Acceptance Criteria

### AC-1: Template Updates

- [ ] TEMPLATE.md includes new "Claude Agents Used" section
- [ ] TEMPLATE-RESEARCH.md includes new "Claude Agents Used" section
- [ ] Section structure matches specification
- [ ] Section is properly positioned in template hierarchy
- [ ] Templates are valid markdown

### AC-2: Automatic Detection

- [ ] System detects all Task tool invocations in conversation history
- [ ] Agent types are correctly extracted
- [ ] Invocation counts are accurate
- [ ] Purpose/context is extracted from prompts
- [ ] Outcomes are reasonably inferred from conversation
- [ ] Summary section is generated correctly
- [ ] Detection works with multiple agent types in one session
- [ ] Detection handles zero agent usage gracefully

### AC-3: Interactive Mode

- [ ] Prompt for agent usage appears after AI tool selection
- [ ] Default is "no" (pressing Enter skips section)
- [ ] Multi-agent input is accepted (comma-separated)
- [ ] Per-agent details are collected for each agent
- [ ] User input is validated (basic checks)
- [ ] Invalid input prompts retry with helpful message
- [ ] Skip option works correctly

### AC-4: Documentation Generation

- [ ] Automatic mode populates section with detected data
- [ ] Interactive mode populates section with user data
- [ ] Generated documentation matches template structure
- [ ] No placeholders or TODOs in generated section
- [ ] Section is omitted when no agents used (or shows "None")
- [ ] Existing documentation workflows remain unchanged

### AC-5: End-to-End Testing

- [ ] Full automatic workflow tested with agent usage
- [ ] Full interactive workflow tested with agent usage
- [ ] Both workflows tested without agent usage
- [ ] Generated documentation is valid and complete
- [ ] Files are correctly saved to .usecase/cases/
- [ ] Sync to hub works correctly

### AC-6: Documentation

- [ ] CHANGELOG.md updated with feature addition
- [ ] README.md mentions agent tracking capability
- [ ] CLAUDE.md updated with implementation guidance (if needed)
- [ ] Feature plan document exists and is complete
- [ ] Requirements document exists and is complete
- [ ] Implementation checklist exists and is complete

---

## Data Requirements

### DR-1: Agent Data Structure

**Agent Entry:**
```markdown
- **[Agent Type]:** X invocations
  - **Purpose:** [Brief description of why agent was used]
  - **Key Findings:** [What the agent discovered/produced]
  - **Value:** [Impact on session - time saved, insights gained]
```

**Summary:**
```markdown
**Agent Effectiveness Summary:**
- Total agent invocations: X
- Most valuable agent: [Name] - [Why]
- Time saved by agents: ~X hours (optional)
```

### DR-2: Agent Types (Known)

Initial list of agent types to recognize:
- **Explore** - Codebase exploration and searching
- **Plan** - Architecture and implementation planning
- **general-purpose** - Complex multi-step tasks
- **code-reviewer** - Code review and quality checks
- **[Custom]** - Any other agent types (future extensibility)

### DR-3: Storage Location

- **Development:** `.usecase/cases/YYYY-Www-MM-DD_TICKET-XXX_description.md`
- **Hub:** Synced to `by-project/[project]/` directory
- **Format:** Markdown section within larger documentation file

---

## Interface Requirements

### IR-1: Template Interface

**Section Header:**
```markdown
### Claude Agents Used
```

**Agent Entry Format:**
```markdown
- **[Agent Name]:** X invocation(s)
  - **Purpose:** [Text]
  - **Key Findings:** [Text or bullets]
  - **Value:** [Text]
```

**Summary Format:**
```markdown
**Agent Effectiveness Summary:**
- Total agent invocations: X
- Most valuable agent: [Name] - [Reason]
- Time saved by agents: ~X hours
```

### IR-2: Interactive Prompts Interface

```bash
Claude Agents Usage:
Were any Claude agents used during this session? (y/N): [user input]

Which agents were used? (comma-separated)
Options: Explore, Plan, general-purpose, code-reviewer, other
Agents: [user input]

Details for: [Agent Name]
  Number of invocations: [user input]
  Purpose (what was it used for?): [user input]
  Key outcome or value: [user input]
```

### IR-3: Automatic Detection Interface (Internal)

**Detection Function Signature (Conceptual):**
```python
def detect_agent_usage(conversation_history: str) -> List[AgentUsage]:
    """
    Detects Claude agent usage from conversation history.

    Returns:
        List of AgentUsage objects containing:
        - agent_type: str
        - count: int
        - purposes: List[str]
        - outcomes: List[str]
        - value: str
    """
```

---

## Constraints

### C-1: Technical Constraints

- **Bash Version:** Must work with Bash 4.0+ (for interactive mode)
- **Template Format:** Must remain valid markdown
- **Backward Compatibility:** Must not break existing workflows
- **File Size:** Agent section should not add more than 500 bytes to documentation

### C-2: Operational Constraints

- **Time:** Development should complete within 3-4 weeks
- **Resources:** Single developer implementation
- **Testing:** Must test both automatic and interactive modes thoroughly

### C-3: Design Constraints

- **Template Structure:** Must follow existing template hierarchy and formatting
- **Section Naming:** Must use consistent naming with other sections
- **Optional Fields:** All agent fields must be optional (gracefully handle missing data)

### C-4: External Constraints

- **Claude Code API:** Detection relies on conversation history structure (may change)
- **Agent Types:** New agent types may be added to Claude Code in future
- **Hub Repository:** Changes must be synced correctly to hub

---

## Dependencies

### D-1: Existing Components

- `docs/TEMPLATE.md` - Current implementation template
- `docs/TEMPLATE-RESEARCH.md` - Current research template
- `.claude/commands/use-case/document-session.md` - Automatic documentation command
- `scripts/core/document-ai-session.sh` - Interactive documentation script

### D-2: External Dependencies

- Claude Code's Task tool and conversation history format
- Bash shell (v4.0+) for interactive mode
- Git for version control

### D-3: Documentation Dependencies

- `CHANGELOG.md` - Must be updated
- `README.md` - Should reference new capability
- `docs/CLAUDE.md` - May need updates for guidance

---

## Open Questions

### OQ-1: Section Inclusion Strategy
**Question:** When no agents are used, should we:
- A) Omit the section entirely?
- B) Include section with "None" or "N/A"?
- C) Include empty section with comment?

**Decision:** TBD during implementation (lean toward A for cleaner docs)

### OQ-2: Agent Type Matching
**Question:** How strict should agent type matching be?
- A) Exact match only (e.g., "Explore" != "explore")
- B) Case-insensitive (e.g., "Explore" == "explore")
- C) Fuzzy matching (e.g., "explor" matches "Explore")

**Decision:** TBD (lean toward B for flexibility)

### OQ-3: Time Saved Calculation
**Question:** Should we attempt to estimate time saved by agents, or leave optional?
- A) Always estimate (with algorithm)
- B) Optional field (user or Claude estimates)
- C) Omit entirely

**Decision:** TBD (lean toward B)

### OQ-4: Multi-Purpose Agents
**Question:** If same agent used for multiple different purposes, how to document?
- A) Single entry with combined purposes
- B) Separate entries per purpose
- C) Single entry with numbered list of purposes

**Decision:** TBD (lean toward C)

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-12-01 | Claude | Initial requirements document |

---

**Status:** Draft - Ready for Review
**Next Steps:** Create implementation checklist, begin development
