# Analyze Documentation Patterns

**Command:** `/use-case:analyze-patterns`
**Purpose:** Analyze patterns in AI Use Case documentation across projects and hubs
**Agent:** Pattern Analyzer (Phase 3)

## Tooling Notes (for OpenCode and other runtimes)

Tool names referenced in this command are conceptual:

- "Task tool" / `subagent_type` => subagent invocation tool (OpenCode: `task`)

---

## Your Task

When the user invokes this command, you will analyze documentation patterns, identify trends, classify projects, and provide data-driven recommendations for improving documentation workflows.

## Workflow

### Step 1: Determine Analysis Scope

**Default (no arguments):**
Analyze the current project's `.usecase/cases/` directory.

**Project mode:**
```
/use-case:analyze-patterns --project ai-use-case-cli
```
Analyze a specific project from the hub.

**Hub mode:**
```
/use-case:analyze-patterns --hub
```
Analyze all projects in the hub with optional comparison.

**If scope is unclear:**
```
What would you like me to analyze?

1. Current project (.usecase/cases/)
2. Specific project from hub
3. Entire hub (all projects)

Enter choice (1-3):
```

### Step 2: Configure Analysis

Ask about analysis preferences if not specified:

```
Analysis Configuration:

Time period:
1. All time (default)
2. Last month
3. Last 3 months
4. Last 6 months
5. Last year
6. Custom date range

Include quality scores? (slower but more detailed): y/N
Compare projects? (hub mode only): y/N

Enter your preferences or press Enter for defaults:
```

### Step 3: Collect Documentation Data

1. Find all markdown files in the target directory
2. Parse filenames for metadata (date, ticket, session type)
3. Extract relevant content from each document
4. Filter by date range if specified

Show progress:
```
Collecting documentation data...
  Found 45 documents in project 'ai-use-case-cli'
  Period: 2025-06-01 to 2025-12-07
  Processing...
```

### Step 4: Invoke Pattern Agent

Use the Task tool to invoke the pattern analyzer agent:

```javascript
Task({
  subagent_type: "use-case-pattern-agent",
  description: "Analyze documentation patterns",
  prompt: `Analyze patterns in this AI Use Case documentation and provide insights.

Analysis type: ${analysisType}
Scope: ${scopeName}
Period: ${startDate} to ${endDate}
Document count: ${documentCount}

Documents:
${documentsJson}

Options:
- Include quality scores: ${includeQuality}
- Compare projects: ${compareProjects}
- Focus area: ${focusArea}

Please provide:
1. Summary statistics (sessions, time saved, ROI)
2. Pattern breakdown (session types, complexity, tools)
3. Trend analysis (frequency, quality)
4. Project classification
5. Insights (strengths and opportunities)
6. Prioritized recommendations

Output in JSON format as specified in the agent prompt.`
})
```

### Step 5: Parse and Present Results

The agent will return JSON with the analysis. Parse and present clearly:

```
═══════════════════════════════════════════════
Pattern Analysis Results
═══════════════════════════════════════════════

Scope: ai-use-case-cli
Documents Analyzed: 45
Period: 2025-06-01 to 2025-12-07

📊 Summary
━━━━━━━━━━
  Total Sessions: 45
  Implementation: 35 (77.8%)
  Research: 10 (22.2%)
  Time Saved: 120 hours
  Estimated ROI: $5,400

🔍 Detected Patterns
━━━━━━━━━━━━━━━━━━━
  Session Types:
    Implementation: 35 sessions (77.8%)
    Research: 10 sessions (22.2%)

  Complexity Distribution:
    Low: 10 (22.2%)
    Medium: 20 (44.4%)
    High: 12 (26.7%)
    Critical: 3 (6.7%)

  Top Tools/Technologies:
    TypeScript: 30 uses (66.7%)
    React: 18 uses (40%)
    PostgreSQL: 8 uses (17.8%)

📈 Trends
━━━━━━━━━
  Documentation Frequency: increasing (+15%)
  Quality Trend: stable (avg score: 7.8)
  Time Savings: increasing (+0.3h per session)

  Monthly Breakdown:
  ├─ Jun: █████ 5
  ├─ Jul: ██████ 6
  ├─ Aug: ████████ 8
  ├─ Sep: ███████ 7
  ├─ Oct: █████████ 9
  └─ Nov: ██████████ 10

💡 Insights
━━━━━━━━━━
  Strengths:
    ✓ Documentation frequency increased 15% over 6 months
    ✓ Technical depth scores consistently above 8/10
    ✓ 90% of sessions include file references

  Opportunities:
    ⚡ Lessons Learned section often generic
    ⚡ Research sessions underrepresented (22% vs 25% target)
    ⚡ Limited cross-references between related sessions

📋 Recommendations
━━━━━━━━━━━━━━━━━━

[HIGH] Improve Lessons Learned specificity
  Current lessons are often generic ('test thoroughly').
  → Action: Review high-scoring sessions and use their format as templates
  → Impact: 10-15% improvement in actionability scores
  → Effort: Low

[MEDIUM] Track more metrics consistently
  Time saved estimates vary widely.
  → Action: Use complexity-based estimation (Low=1h, Medium=2h, High=4h)
  → Impact: More accurate ROI calculations
  → Effort: Low

[MEDIUM] Document more research sessions
  Research provides high value (4h avg savings) but only 22%
  → Action: Document any investigation > 30 minutes
  → Impact: Capture more institutional knowledge
  → Effort: Medium

[LOW] Add more cross-references
  Sessions rarely reference related documentation
  → Action: Link to original session when documenting follow-ups
  → Impact: Improved knowledge navigation
  → Effort: Low

🏷️ Classifications
━━━━━━━━━━━━━━━━━
  Project Type: CLI Tooling
  Documentation Maturity: Established
  Primary Focus: Feature Development
  Confidence: 85%
```

### Step 6: Offer Follow-up Actions

After presenting the analysis:

```
Would you like me to:
1. Show more details on a specific pattern
2. Compare with another project
3. Generate improvement action plan
4. Export this analysis to JSON
5. Review a specific session's quality
```

## Analysis Modes

### Project Analysis
Analyzes a single project, providing:
- Documentation patterns and statistics
- Trend analysis over time
- Project classification
- Targeted recommendations

### Hub Analysis
Analyzes all projects, additionally providing:
- Cross-project comparisons
- Best practices identification
- Hub-wide trends
- Knowledge sharing opportunities

### Period Filtering
Support various time periods:
- `all` - All available documentation
- `1month` - Last month
- `3months` - Last 3 months
- `6months` - Last 6 months (default for trends)
- `1year` - Last year
- `YYYY-MM-DD:YYYY-MM-DD` - Custom date range

## Key Principles

1. **Be Data-Driven:** Every insight backed by evidence
2. **Be Actionable:** Recommendations must be specific and achievable
3. **Be Fair:** Consider project context in comparisons
4. **Be Clear:** Use visualizations and clear formatting
5. **Be Prioritized:** Focus on high-impact findings first

## Error Handling

**No documentation found:**
```
⚠ No Documentation Found

No documentation files were found in .usecase/cases/ for the specified period.

Check that:
1. The project is initialized (run 'ai-use-case --init')
2. Documentation exists in .usecase/cases/
3. The date range includes documents

If documenting for the first time, try:
  /use-case:document-session
```

**Agent not enabled:**
```
❌ Pattern Analyzer Not Enabled

The pattern analyzer agent needs to be enabled first.

Run: ai-use-case agents enable pattern-analyzer

Then try this command again.
```

**Hub not configured:**
```
❌ Hub Not Configured

The hub is not configured for this project.

Run: ai-use-case config

To set up your documentation hub.
```

**Insufficient data for trends:**
```
⚠ Limited Data for Trend Analysis

Only 3 documents found. Trend analysis works best with 10+ documents.

Current analysis is based on limited data and trends may not be statistically significant.

Continue with available data? (y/N)
```

## Advanced Features

### Focus Areas

Specify focus to get targeted analysis:

```
/use-case:analyze-patterns --focus patterns
```

Options:
- `patterns` - Documentation patterns (default)
- `trends` - Trend analysis
- `recommendations` - Prioritized recommendations only
- `all` - Complete analysis

### Project Comparison

Compare projects in hub mode:

```
/use-case:analyze-patterns --hub --compare
```

Produces comparison table:
```
Project Comparison
━━━━━━━━━━━━━━━━━━

Project          Sessions  Avg Quality  Time Saved  Strengths
─────────────────────────────────────────────────────────────
ai-use-case-cli  45        7.8/10       120h        consistency
backend-api      30        8.2/10       85h         actionability
mobile-app       15        7.1/10       40h         technical depth

Best Practice Leaders:
  - Highest Quality: backend-api
  - Most Consistent: ai-use-case-cli
  - Best ROI: ai-use-case-cli
```

### JSON Export

For programmatic use:

```
/use-case:analyze-patterns --format json
```

Returns raw JSON from agent for further processing.

## Integration with Other Commands

### With Document Session
After documenting a session:
```
✓ Session documented successfully!

This is your 46th session. Your documentation patterns show:
- Consistent weekly documentation
- Strong technical depth
- Opportunity: Add more quantitative metrics

Would you like to see full pattern analysis? (/use-case:analyze-patterns)
```

### With Quality Review
After reviewing quality:
```
Quality Score: 7.5/10

This aligns with your project's average quality of 7.8.
Recent trend shows improving quality (+0.2/month).

See full pattern analysis: /use-case:analyze-patterns
```

## Examples

### Example 1: Default Analysis

**User:** `/use-case:analyze-patterns`

**You:**
1. Analyze current project's `.usecase/cases/`
2. Use default period (all time)
3. Invoke pattern agent
4. Present formatted results
5. Offer follow-up actions

### Example 2: Hub Analysis with Comparison

**User:** `/use-case:analyze-patterns --hub --compare`

**You:**
1. Find hub path from configuration
2. Collect data from all projects
3. Invoke pattern agent with comparison option
4. Present hub-wide analysis with project comparison
5. Highlight best practices to share

### Example 3: Period-Specific Analysis

**User:** `/use-case:analyze-patterns --period 6months`

**You:**
1. Calculate date range (6 months ago to today)
2. Filter documents by date
3. Analyze trends within period
4. Compare to previous period if data available
5. Present period-specific insights

### Example 4: Specific Project from Hub

**User:** `/use-case:analyze-patterns --project backend-api`

**You:**
1. Find project in hub
2. Collect all project documentation
3. Analyze project-specific patterns
4. Present results with context
5. Suggest comparing with other projects

---

## Notes

- **Phase 3 Implementation:** Pattern Analysis Agent
- **Agent Required:** Pattern analyzer must be enabled (`ai-use-case agents enable pattern-analyzer`)
- **Claude Code Required:** This command only works in Claude Code (uses Task tool)
- **Performance:** Project analysis takes ~30-60 seconds; Hub analysis may take longer
- **Caching:** Results are cached for 1 hour by default
- **Data Quality:** Analysis accuracy improves with more documented sessions (10+ recommended)

---

**Remember:** Your goal is to help teams understand and improve their documentation patterns. Focus on actionable insights that lead to better knowledge capture!
