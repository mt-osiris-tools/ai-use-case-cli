<!--
TEMPLATE.md - Implementation Session Documentation Template
This is the single source of truth for implementation session documentation structure.
Location: ai-use-case-cli/docs/TEMPLATE.md
Used by: Claude Code slash command (/use-case:document-session)
-->

# 🎯 Claude Code: [Brief Descriptive Title]

**Date:** YYYY-MM-DD (Week XX of YYYY)
**Repository/Project:** project-name
**Ticket:** [TICKET-XXXXX](https://your-jira-or-github/browse/TICKET-XXXXX)
**Agent Used:** Claude Code (Sonnet 4.5) / GitHub Copilot / Other
**Complexity:** Low / Medium / High
**Time Saved:** ~X hours vs manual approach
**Session Duration:** X hours YY minutes

---

## 📄 TL;DR

**What:** [1-2 sentences: What did the AI help you accomplish?]

**Result:** [1-2 sentences: What was the outcome? Files changed, features added, etc.]

**Time:** [X minutes (AI-assisted) vs Y hours manual approach]

**Cost:** ~[tokens/cost] for complete workflow

**Key Success:** [What made this particularly successful?]

---

## 🤖 AI Interaction Metrics

**For detailed guidance on capturing these metrics, see [AI_SESSION_STATISTICS_GUIDE.md](https://github.com/mt-osiris-tools/ai-use-case-cli/blob/main/docs/AI_SESSION_STATISTICS_GUIDE.md)**

### Engagement Level
- **Total Interactions:** X back-and-forth exchanges between user and AI
- **User Prompts:** X total prompts/messages from user
- **AI Responses:** X total responses from AI
- **First-Attempt Success Rate:** X/Y prompts (Z%)
- **Average Iterations:** X.X per task
- **Clarification Requests:** X times AI needed more context
- **Autonomous Actions:** X (test fixes, code standards, commits, etc.)
- **Session Flow:** Linear / Iterative / Exploratory

### Token Usage Summary
- **Total Tokens Used:** X,XXX tokens
  - **Input Tokens:** X,XXX (prompt, context, code read)
  - **Output Tokens:** X,XXX (AI responses, code generated)
  - **Cache Hits:** X,XXX tokens (if prompt caching used)
- **Estimated Cost:** ~$X.XX (based on model pricing)
- **Model Used:** Claude Sonnet 4.5 / GPT-4 / Other
- **Average Tokens per Interaction:** ~XXX tokens

### Tool Usage Breakdown
- **Total Tool Uses:** XX
  - **Read:** X (context gathering, code analysis)
  - **Write:** X (new files created)
  - **Edit:** X (files modified)
  - **Bash:** X (tests, git, build commands)
  - **Grep/Search:** X (code searches)
  - **Other:** X (specify)

### Commands Executed by AI
```bash
# Key commands run during session
command-1
command-2
command-3
```

### Claude Agents Used

- **Explore Agent:** X invocations
  - **Purpose:** Codebase exploration, finding patterns, understanding architecture
  - **Key Findings:** [What the agent discovered or helped with]
  - **Value:** [Impact on session - saved time, provided insights, etc.]

- **Plan Agent:** X invocations
  - **Purpose:** Architecture planning, implementation strategy design
  - **Output:** [What plans or strategies were generated]
  - **Value:** [How it helped the implementation]

- **General-Purpose Agent:** X invocations
  - **Purpose:** [Specific multi-step tasks handled]
  - **Outcome:** [What was accomplished]
  - **Value:** [Contribution to session success]

**Agent Effectiveness Summary:**
- Total agent invocations: X
- Most valuable agent: [Agent name and why]
- Time saved by agents: ~X hours (optional)

---

## 💬 Key User Queries (Optional)

**For detailed guidance on capturing queries, see [CAPTURING_USER_QUERIES.md](https://github.com/mt-osiris-tools/ai-use-case-cli/blob/main/docs/CAPTURING_USER_QUERIES.md)**

### Query #1: [Brief Summary] (HH:MM)
**User:** "[Your prompt or request]"

**AI Response:** [Summary of AI's understanding and actions]

**Tools Used:** [List: Read, Write, Edit, Bash, etc.]

**Result:** ✅ Success / ⚠️ Needed refinement / ❌ Failed

**Iterations:** X

---

### Query #2: [Brief Summary] (HH:MM)
**User:** "[Your prompt or request]"

**AI Response:** [Summary]

**Tools Used:** [List]

**Result:** ✅ / ⚠️ / ❌

**Iterations:** X

---

[Continue for major queries...]

### Prompt Effectiveness Analysis
**High-Quality Prompts (worked first time):**
- ✅ "[Example of effective prompt and why it worked]"

**Prompts Needing Iteration:**
- ⚠️ "[Example of prompt that needed refinement and how to improve it]"

---

## 🏢 Business Context

**Objective:** [What business problem were you solving?]

**Domain:** [Technical area: Frontend, Backend, Infrastructure, Testing, etc.]

**Requestor:** [Who requested this? Team, stakeholder, technical debt initiative]

**Background:** [Why was this work needed? What problem exists without it?]

**Expected Benefits:**
- [Benefit 1]
- [Benefit 2]
- [Benefit 3]

---

## ⏱️ Time Analysis

### Manual Estimate (without AI): X.X hours
- Understanding codebase: X.Xh
- Writing code: X.Xh
- Writing tests: X.Xh
- Debugging: X.Xh
- Documentation: X.Xh

### Actual Time (with AI): X.X hours
- AI context gathering: X.Xh
- Guided implementation: X.Xh
- AI-assisted testing: X.Xh
- AI-assisted debugging: X.Xh
- AI-generated documentation: X.Xh

### Results
- **Time Saved:** X.X hours (XX% faster)
- **Efficiency Multiplier:** X.Xx
- **Blockers Avoided:** [What issues AI helped you avoid]

---

## 🔄 Workflow Steps

### 1. **[Step Name]**
- [What you did]
- [Tools/commands used]
- **Time:** X minutes

### 2. **[Step Name]**
- [What you did]
- [Tools/commands used]
- **Time:** X minutes

### 3. **[Step Name]**
- [What you did]
- [Tools/commands used]
- **Time:** X minutes

[Continue for all major steps...]

---

## 🛠️ Technical Details

### Tools & Technologies Used
- **Primary AI Tool:** [Claude Code / Copilot / etc.]
- **Version Control:** [Git commands, branching strategy]
- **Testing:** [Test frameworks used]
- **Other Tools:** [Any other relevant tools]

### Detailed Token Usage Analysis

| Phase | Input Tokens | Output Tokens | Cache Hits | Total Tokens | Cost (USD) | Notes |
|-------|--------------|---------------|------------|--------------|------------|-------|
| Initial analysis | ~X,XXX | ~XXX | ~X,XXX | ~X,XXX | ~$X.XX | Context gathering, codebase exploration |
| Implementation | ~X,XXX | ~X,XXX | ~X,XXX | ~X,XXX | ~$X.XX | Code generation, edits, refactoring |
| Testing & Debugging | ~X,XXX | ~XXX | ~X,XXX | ~X,XXX | ~$X.XX | Test writing, error fixes |
| Documentation | ~X,XXX | ~X,XXX | ~XXX | ~X,XXX | ~$X.XX | Comments, docs generation |
| **Total** | **~X,XXX** | **~X,XXX** | **~X,XXX** | **~X,XXX** | **~$X.XX** | **Full workflow** |

**Model Pricing Reference:** (Update based on your AI tool)
- Input: $X per 1M tokens
- Output: $X per 1M tokens
- Cache hits: $X per 1M tokens (if applicable)

### Interaction Breakdown by Phase

| Phase | Interactions | User Prompts | AI Responses | Avg Tokens/Interaction |
|-------|--------------|--------------|--------------|------------------------|
| Planning | X | X | X | ~XXX |
| Implementation | X | X | X | ~XXX |
| Testing | X | X | X | ~XXX |
| Documentation | X | X | X | ~XXX |
| **Total** | **X** | **X** | **X** | **~XXX avg** |

### Cost Efficiency Analysis
- **Manual Alternative:** X hours × $Y/hour = $Z
- **AI-Assisted:** X hours × $Y/hour + $Z (token costs) = $Total
- **Net Savings:** $Amount (X% cost reduction)
- **ROI:** X:1 (for every $1 spent on AI, save $X in labor)

### Code Patterns Used

```[language]
// Example of key pattern or approach used
[code snippet]
```

### Key Technical Insights

1. **[Insight 1]:** [What you learned]

2. **[Insight 2]:** [What worked well]

3. **[Insight 3]:** [What to watch out for]

---

## 📊 Results & Impact

### Quantitative Results
- **Files Modified:** X files
- **Lines Added:** +XXX
- **Lines Removed:** -XXX
- **Net Change:** +/-XXX lines
- **Files Created:** X new files
- **Tests Written:** X unit, X functional/integration
- **Tests Passing:** Y/Y (100%)
- **Commits Created:** Z
- **Regressions:** 0

### Code Quality Metrics
- **Test Coverage:** XX% (target: XX%)
- **Code Standards:** ✅ PSR-12 / ESLint / etc. compliant
- **Type Safety:** ✅ Full type hints / TypeScript strict mode
- **Security:** ✅ No vulnerabilities introduced
- **Performance:** [Impact on performance metrics]

### Commit Distribution (if applicable)

| Ticket/Commit | Files Changed | Purpose |
|---------------|---------------|---------|
| TICKET-001 | X | [Description] |
| TICKET-002 | Y | [Description] |

### Business Impact
- ✅ **[Impact 1]:** [Description]
- ✅ **[Impact 2]:** [Description]
- ✅ **[Impact 3]:** [Description]

---

## 📈 Success Metrics

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Time to complete | <X hours | Y minutes | ✅ Met / ❌ Missed |
| Test coverage | X% | Y% | ✅ Met / ❌ Missed |
| Code quality | 0 issues | Y issues | ✅ Met / ❌ Missed |
| Documentation | Complete | Complete | ✅ Met / ❌ Missed |

---

## 💡 Key Learnings

### ✅ What Worked Well

- **[Success 1]:** [Why it worked]

- **[Success 2]:** [Why it worked]

- **[Success 3]:** [Why it worked]

### ⚠️ Areas for Improvement

- **[Area 1]:** [What could be better]

- **[Area 2]:** [What could be better]

### 🔄 Process Refinements

1. **[Refinement 1]:** [How to improve next time]

2. **[Refinement 2]:** [How to improve next time]

---

## 🎯 Best Practices Identified

1. **[Practice 1]:** [Description and rationale]

2. **[Practice 2]:** [Description and rationale]

3. **[Practice 3]:** [Description and rationale]

---

## 🔄 Replicability Framework

### This workflow is directly replicable for

- ✅ [Use case 1]
- ✅ [Use case 2]
- ✅ [Use case 3]
- ❌ Not suitable for [Use case that won't work]

### Prerequisites for Replication

- **Technology:** [Tools needed]
- **Permissions:** [Access required]
- **Knowledge:** [Skills/understanding needed]
- **Documentation:** [Docs that must exist]
- **Budget:** [Expected cost]

### Expected Timeframe & Cost

- **Simple version:** X minutes, ~Y tokens (~$Z)
- **Medium complexity:** X minutes, ~Y tokens (~$Z)
- **Complex version:** X hours, ~Y tokens (~$Z)

### Adaptation Guidelines

1. **For different [context]:** [How to adapt]

2. **For different [context]:** [How to adapt]

3. **For different [context]:** [How to adapt]

---

## 📝 Implementation Summary

### Files Modified (X total)

**[Category] (X):**
- `path/to/file1.ext`
- `path/to/file2.ext`

**[Category] (Y):**
- `path/to/file3.ext`
- `path/to/file4.ext`

### Quality Verification Results

```bash
# Tests
✅ X/X tests passing
✅ Y assertions successful

# Code quality
✅ 0 linting issues
✅ 0 type errors

# Static analysis
✅ 0 errors
```

---

## 🔗 Related Resources

- **Pull Request:** [Link to PR]
- **Issue/Ticket:** [Link to Jira/GitHub issue]
- **Repository:** [Repo name]
- **Branch:** `branch-name`
- **Documentation:** [Links to relevant docs]
- **Related Use Cases:** [Links to similar use cases]

---

## 📸 Screenshots / Artifacts (Optional)

[Include any relevant screenshots, diagrams, or output]

```
[Code snippets or command output]
```

---

**Created:** YYYY-MM-DD
**Last Updated:** YYYY-MM-DD
**Author:** [Your name]
**Review Status:** Draft / Complete / Reviewed
