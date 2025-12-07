<!--
TEMPLATE-RESEARCH.md - Research Session Documentation Template
This is the single source of truth for research session documentation structure.
Location: ai-use-case-cli/docs/TEMPLATE-RESEARCH.md
Used by: AI coding assistant slash commands (/use-case:document-session)
-->

# 🔬 AI Research: [Research Topic/Question]

**Date:** YYYY-MM-DD (Week XX of YYYY)
**Repository/Project:** project-name
**Ticket:** [RESEARCH-XXX](https://your-jira-or-github/browse/RESEARCH-XXX)
**Session Type:** Research & Exploration
**AI Tool Used:** GitHub Copilot / Claude Code / OpenAI Codex / Other
**Complexity:** Low / Medium / High
**Time Saved:** ~X hours vs manual research
**Session Duration:** X hours YY minutes
**Query Iterations:** X iterations to optimal solution

---

## 📄 TL;DR

**What:** [1-2 sentences: What research question or problem were you exploring?]

**Result:** [1-2 sentences: What insights, decisions, or recommendations emerged?]

**Time:** [X minutes (AI-assisted research) vs Y hours manual research]

**Key Success:** Iterative query refinement led to actionable insights

---

## 🤖 AI Interaction Metrics

**For detailed guidance on capturing research session metrics, see [AI_SESSION_STATISTICS_GUIDE.md](https://github.com/mt-osiris-tools/ai-use-case-cli/blob/main/docs/AI_SESSION_STATISTICS_GUIDE.md) and [CAPTURING_USER_QUERIES.md](https://github.com/mt-osiris-tools/ai-use-case-cli/blob/main/docs/CAPTURING_USER_QUERIES.md)**

### Research Engagement
- **Total Interactions:** X back-and-forth exchanges between user and AI
- **User Prompts:** X total queries/questions from user
- **AI Responses:** X total responses from AI
- **Total Queries:** X queries throughout session
- **Query Types:**
  - Exploratory questions: X
  - Clarification requests: X
  - Follow-up deep dives: X
  - Comparative analysis: X
- **Iterations to Solution:** X major refinement cycles
- **First-Attempt Understanding:** X/Y queries (Z% immediately useful)
- **Session Flow:** Exploratory / Iterative / Convergent

### Token Usage Summary
- **Total Tokens Used:** X,XXX tokens
  - **Input Tokens:** X,XXX (questions, context, follow-ups)
  - **Output Tokens:** X,XXX (AI explanations, comparisons, recommendations)
  - **Cache Hits:** X,XXX tokens (if prompt caching used)
- **Estimated Cost:** ~$X.XX (based on model pricing)
- **Model Used:** Claude Sonnet 4.5 / GPT-4 / Other
- **Average Tokens per Query:** ~XXX tokens
- **Token Efficiency:** ~XXX tokens per insight gained

### Tool Usage (if applicable)
- **Read Operations:** X (reviewing existing code/docs)
- **Search Operations:** X (finding patterns, examples)
- **Other:** [Any other tools used during research]

### Research Efficiency
- **Questions Resolved:** X total questions answered
- **Approaches Evaluated:** X distinct approaches compared
- **Decision Confidence Reached:** High / Medium / Low
- **Time per Major Insight:** ~X minutes average
- **Cost per Insight:** ~$X.XX / insight

### AI Agents Used

*(Note: Specialized agents from Claude, Copilot, or other AI tools)*

- **Explore Agent:** X invocations
  - **Purpose:** Codebase exploration, finding patterns, understanding architecture
  - **Key Findings:** [What the agent discovered or helped with]
  - **Value:** [Impact on research - saved time, provided insights, etc.]

- **Plan Agent:** X invocations
  - **Purpose:** Architecture planning, implementation strategy design
  - **Output:** [What plans or strategies were generated]
  - **Value:** [How it helped the research process]

- **General-Purpose Agent:** X invocations
  - **Purpose:** [Specific research tasks handled]
  - **Outcome:** [What was accomplished]
  - **Value:** [Contribution to research success]

**Agent Effectiveness Summary:**
- Total agent invocations: X
- Most valuable agent: [Agent name and why]
- Time saved by agents: ~X hours (optional)

---

## 📊 Session Statistics (/cost Command)

**Capture session statistics by running:** `/cost`

This provides real-time data about token usage, costs, and research session metrics from Claude Code.

```
[Paste the output of /cost command here]

Example output:
Total cost: $0.32
Total duration (API): 1m 45s
Total duration (wall): 25m 18s
Total code changes: 0 (research session - no code modified)
```

**When to capture:**
- **During session**: Run `/cost` periodically to track token usage during exploration
- **End of session**: Run `/cost` before ending the session for final statistics
- **Post-session**: If using SessionEnd hook, statistics are auto-saved to `.usecase/session-stats/`

**Note:** For research sessions, the `/cost` command helps quantify the cost of exploration and iterative query refinement. This data populates the "Token Usage Summary" and "Research Efficiency" sections above.

---

## 🔍 Research Context

**Initial Query:** [Your original question or problem statement]

**Objective:** [What were you trying to understand or decide?]

**Background:** [Why was this research needed? What triggered it?]

**Domain:** [Technical area: Architecture, API Design, Database, Testing, DevOps, etc.]

**Query Refinement:** [Number] iterations to reach optimal clarity

---

## 🔄 Query Evolution & Exploration Process

### Iteration 1: Initial Query
- **Query:** [Your first question to the AI]
- **AI Response:** [Summary of what the AI provided]
- **Gaps Identified:** [What was missing, unclear, or needed deeper exploration]
- **Time:** X minutes

### Iteration 2: Refined Query
- **Query:** [How you refined or expanded your question]
- **AI Response:** [Summary of improved response]
- **Insights Gained:** [New understanding or perspectives]
- **Time:** X minutes

### Iteration 3-N: Further Refinement
[Continue documenting each major iteration of query refinement]
- **Query:** [Evolved question]
- **AI Response:** [Summary]
- **Insights Gained:** [Cumulative understanding]
- **Time:** X minutes

### Final Query
- **Query:** [Your most refined, specific question]
- **AI Response:** [Summary of comprehensive answer]
- **Confidence Level:** High / Medium / Low
- **Time:** X minutes

---

## 🎯 Query Effectiveness Analysis

**For detailed guidance, see [CAPTURING_USER_QUERIES.md](https://github.com/mt-osiris-tools/ai-use-case-cli/blob/main/docs/CAPTURING_USER_QUERIES.md)**

### High-Quality Queries (Immediate Value)
**Pattern: Specific + Context + Clear Goal**

✅ **Query:** "[Example of effective research query]"
- **Why it worked:** [Specific, provided context, clear objective]
- **Time to insight:** X minutes
- **Value:** [What insight this unlocked]

### Queries Needing Refinement
**Pattern: Too Broad / Lacked Context**

⚠️ **Initial Query:** "[Example of vague query]"
- **Issue:** [Why it wasn't immediately useful]
- **Refined to:** "[How you improved it]"
- **Iterations needed:** X
- **Learning:** [How to ask better next time]

### Most Valuable Query
**The single question that unlocked the most insight:**
> "[Your most impactful query]"

**Why it mattered:** [Impact on decision/understanding]

---

## 💡 Key Insights Discovered

[Comma-separated list of main insights for quick reference]

**Detailed Insights:**

### 1. [Insight Category/Topic]
**Discovery:** [What you learned]

**Implications:** [Why this matters, what it means for your project]

**Supporting Evidence:** [Reasoning, examples, or references provided by AI]

### 2. [Insight Category/Topic]
**Discovery:** [What you learned]

**Implications:** [Why this matters]

**Supporting Evidence:** [Reasoning or examples]

### 3. [Insight Category/Topic]
**Discovery:** [What you learned]

**Implications:** [Why this matters]

**Supporting Evidence:** [Reasoning or examples]

[Continue for all major insights...]

---

## 🎯 Approaches Evaluated

[Comma-separated list of approaches considered]

### Approach 1: [Name/Description]

**Overview:** [Brief description of this approach]

**Pros:**
- ✅ [Advantage 1]
- ✅ [Advantage 2]
- ✅ [Advantage 3]

**Cons:**
- ❌ [Disadvantage 1]
- ❌ [Disadvantage 2]
- ❌ [Disadvantage 3]

**Best For:** [Use cases where this approach excels]

**Avoid When:** [Scenarios where this approach is problematic]

**Estimated Effort:** [Low/Medium/High]

### Approach 2: [Name/Description]

**Overview:** [Brief description]

**Pros:**
- ✅ [Advantage 1]
- ✅ [Advantage 2]
- ✅ [Advantage 3]

**Cons:**
- ❌ [Disadvantage 1]
- ❌ [Disadvantage 2]
- ❌ [Disadvantage 3]

**Best For:** [Use cases]

**Avoid When:** [Scenarios to avoid]

**Estimated Effort:** [Low/Medium/High]

[Continue for all approaches evaluated...]

---

## ✅ Final Decision & Recommendation

**Decision:** [Chosen approach or answer to your research question]

**Decision Confidence:** High / Medium / Low

**Rationale:**
1. [Primary reason for this choice]
2. [Secondary reason]
3. [Additional supporting reason]

**Trade-offs Accepted:**
- [Trade-off 1: What you're giving up for the benefits]
- [Trade-off 2]
- [Trade-off 3]

---

## 🚀 Implementation Guidance

**Recommended Next Steps:**
1. [Immediate action 1]
2. [Immediate action 2]
3. [Immediate action 3]

**Prerequisites:**
- [Requirement 1: Technology, permission, or knowledge needed]
- [Requirement 2]
- [Requirement 3]

**Estimated Implementation Time:** [X hours/days/weeks]

**Estimated Complexity:** Low / Medium / High

**Key Considerations:**
- ⚠️ [Important factor to keep in mind]
- ⚠️ [Potential pitfall to avoid]
- ⚠️ [Critical dependency or constraint]

---

## ⚠️ Risks & Mitigations

### Risk 1: [Risk Description]
**Likelihood:** High / Medium / Low
**Impact:** High / Medium / Low
**Mitigation:** [How to address or reduce this risk]

### Risk 2: [Risk Description]
**Likelihood:** High / Medium / Low
**Impact:** High / Medium / Low
**Mitigation:** [How to address or reduce this risk]

### Risk 3: [Risk Description]
**Likelihood:** High / Medium / Low
**Impact:** High / Medium / Low
**Mitigation:** [How to address or reduce this risk]

---

## 📊 Research Impact

### Knowledge Gained
- **Questions Answered:** [Number] through iterative refinement
- **Approaches Evaluated:** [Number] distinct approaches
- **Decision Confidence:** High / Medium / Low
- **Time Efficiency:** [X]x faster than manual research ([Y] hours saved)

### Business Value
- ✅ **Reduced Decision Risk:** Clear evaluation of trade-offs and implications
- ✅ **Accelerated Planning:** [X] hours saved in research phase
- ✅ **Knowledge Transfer:** Documented insights shareable across team
- ✅ **Future Reference:** Reusable decision framework for similar problems

### Qualitative Benefits
- [Benefit 1: e.g., Deeper understanding of architectural patterns]
- [Benefit 2: e.g., Discovered best practices not previously known]
- [Benefit 3: e.g., Identified potential issues before implementation]

### Future Applications
- [Where else can these insights be applied?]
- [What similar problems does this solve?]
- [What patterns emerged that are reusable?]

---

## 📚 Resources & References

**AI Tool Used:** [Specific AI tool and model]

**Related Documentation:**
- [Link to relevant internal docs]
- [Link to external references]
- [Link to related research]

**Similar Research Sessions:**
- [Link to related RESEARCH-XXX docs]
- [Link to related use cases]

**Follow-up Actions:**
- [ ] [Action item 1]
- [ ] [Action item 2]
- [ ] [Action item 3]

**People to Share With:**
- [Team member 1 who should know about this]
- [Team member 2]
- [Stakeholder]

---

## 🔄 Replicability Framework

### This research approach is directly replicable for:

- ✅ [Similar research question or problem type 1]
- ✅ [Similar research question or problem type 2]
- ✅ [Similar research question or problem type 3]
- ❌ Not suitable for [Types of problems this approach won't work for]

### Prerequisites for Replication

**Technology:**
- [AI tool/model required]
- [Access or permissions needed]
- [Other tools or resources]

**Knowledge:**
- [Domain understanding required]
- [Technical skills needed]
- [Background context necessary]

**Context:**
- [When is this approach most effective]
- [Scenarios where it provides most value]
- [Conditions that maximize success]

### Expected Timeframe & Complexity

| Scenario | Time | Iterations | Complexity |
|----------|------|------------|------------|
| Simple question | 15-30 min | 2-3 | Low |
| Medium exploration | 30-60 min | 4-6 | Medium |
| Complex decision | 1-2 hours | 7-10 | High |

### Best Practices for Similar Research Sessions

1. **Start Broad:** Begin with open-ended questions to explore the landscape
2. **Iterate Deliberately:** Refine queries based on gaps in understanding
3. **Document Continuously:** Capture insights in real-time while fresh
4. **Evaluate Alternatives:** Always consider multiple approaches
5. **Quantify Impact:** Track time saved and value added
6. **Share Knowledge:** Document for team benefit and future reference

---

**Created:** YYYY-MM-DD
**Last Updated:** YYYY-MM-DD
**Author:** [Your name]
**Review Status:** Draft / In Review / Approved

**Research Outcome:** Decision Made / Ongoing Investigation / Needs Follow-up

---

<!--
TEMPLATE USAGE NOTES:
- This template is for RESEARCH/EXPLORATORY sessions without code changes
- For implementation sessions with code changes, use TEMPLATE.md instead
- Fill in all bracketed [sections] with your specific details
- Remove sections that don't apply to your research
- Add additional sections as needed for your specific use case
-->
