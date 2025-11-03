# Template Structure Reference

This document outlines the structure of both documentation templates used in the AI Use Case CLI project.

---

## TEMPLATE.md - Implementation Sessions

Use this template for sessions involving code changes, commits, and file modifications.

### Structure Overview

```
📋 Header Section
├── Title with emoji (🎯)
├── Date (with ISO 8601 week number)
├── Repository/Project
├── Ticket link
├── Agent Used
├── Complexity
├── Time Saved
└── Session Duration

📄 TL;DR
├── What (1-2 sentences)
├── Result (1-2 sentences)
├── Time comparison
├── Cost estimate
└── Key Success

🤖 AI Interaction Metrics
├── Engagement Level
│   ├── Total Interactions
│   ├── User Prompts
│   ├── AI Responses
│   ├── First-Attempt Success Rate
│   ├── Average Iterations
│   ├── Clarification Requests
│   ├── Autonomous Actions
│   └── Session Flow
├── Token Usage Summary
│   ├── Total Tokens Used
│   ├── Input Tokens (prompt, context, code)
│   ├── Output Tokens (responses, code generated)
│   ├── Cache Hits (if applicable)
│   ├── Estimated Cost
│   ├── Model Used
│   └── Average Tokens per Interaction
└── Tool Usage Breakdown
    ├── Total Tool Uses
    ├── Read operations
    ├── Write operations
    ├── Edit operations
    ├── Bash commands
    ├── Grep/Search operations
    └── Other tools

💬 Key User Queries (Optional)
├── Query #1
│   ├── User prompt
│   ├── AI Response summary
│   ├── Tools Used
│   ├── Result (✅/⚠️/❌)
│   └── Iterations
├── Query #2...
└── Prompt Effectiveness Analysis
    ├── High-Quality Prompts
    └── Prompts Needing Iteration

🏢 Business Context
├── Objective
├── Domain
├── Requestor
├── Background
└── Expected Benefits

⏱️ Time Analysis
├── Manual Estimate (breakdown by task)
├── Actual Time (with AI breakdown)
└── Results
    ├── Time Saved
    ├── Efficiency Multiplier
    └── Blockers Avoided

🔄 Workflow Steps
└── Step 1, 2, 3... (with time estimates)

🛠️ Technical Details
├── Tools & Technologies Used
├── Detailed Token Usage Analysis
│   ├── Token breakdown by phase (table)
│   ├── Model pricing reference
│   └── Interaction breakdown by phase (table)
├── Cost Efficiency Analysis
│   ├── Manual alternative cost
│   ├── AI-assisted cost
│   ├── Net savings
│   └── ROI calculation
├── Code Patterns Used
└── Key Technical Insights

📊 Results & Impact
├── Quantitative Results
│   ├── Files modified
│   ├── Lines added/removed
│   ├── Files created
│   ├── Tests written/passing
│   ├── Commits created
│   └── Regressions
├── Code Quality Metrics
│   ├── Test coverage
│   ├── Code standards compliance
│   ├── Type safety
│   ├── Security
│   └── Performance
├── Commit Distribution (optional table)
└── Business Impact

📈 Success Metrics
└── Metrics table (Target vs Actual)

💡 Key Learnings
├── What Worked Well
├── Areas for Improvement
└── Process Refinements

🎯 Best Practices Identified
└── Practice 1, 2, 3...

🔄 Replicability Framework
├── This workflow is replicable for
├── Prerequisites for Replication
│   ├── Technology
│   ├── Permissions
│   ├── Knowledge
│   ├── Documentation
│   └── Budget
├── Expected Timeframe & Cost
│   ├── Simple version
│   ├── Medium complexity
│   └── Complex version
└── Adaptation Guidelines

📝 Implementation Summary
├── Files Modified (categorized)
└── Quality Verification Results

🔗 Related Resources
├── Pull Request link
├── Issue/Ticket link
├── Repository
├── Branch
├── Documentation links
└── Related Use Cases

📸 Screenshots / Artifacts (Optional)

📋 Footer
├── Created date
├── Last Updated date
├── Author
└── Review Status
```

---

## TEMPLATE-RESEARCH.md - Research & Exploration Sessions

Use this template for exploratory sessions without code changes (architecture discussions, approach evaluation).

### Structure Overview

```
📋 Header Section
├── Title with emoji (🔬)
├── Date (with ISO 8601 week number)
├── Repository/Project
├── Ticket link (RESEARCH-XXX format)
├── Session Type: Research & Exploration
├── Agent Used
├── Complexity
├── Time Saved
├── Session Duration
└── Query Iterations count

📄 TL;DR
├── What (research question)
├── Result (insights/decisions)
├── Time comparison
└── Key Success

🤖 AI Interaction Metrics
├── Research Engagement
│   ├── Total Interactions
│   ├── User Prompts
│   ├── AI Responses
│   ├── Total Queries
│   ├── Query Types
│   │   ├── Exploratory questions
│   │   ├── Clarification requests
│   │   ├── Follow-up deep dives
│   │   └── Comparative analysis
│   ├── Iterations to Solution
│   ├── First-Attempt Understanding rate
│   └── Session Flow
├── Token Usage Summary
│   ├── Total Tokens Used
│   ├── Input Tokens (questions, context)
│   ├── Output Tokens (explanations, comparisons)
│   ├── Cache Hits (if applicable)
│   ├── Estimated Cost
│   ├── Model Used
│   ├── Average Tokens per Query
│   └── Token Efficiency (per insight)
├── Tool Usage (if applicable)
└── Research Efficiency
    ├── Questions Resolved
    ├── Approaches Evaluated
    ├── Decision Confidence
    ├── Time per Major Insight
    └── Cost per Insight

🔍 Research Context
├── Initial Query
├── Objective
├── Background
├── Domain
└── Query Refinement iterations

🔄 Query Evolution & Exploration Process
├── Iteration 1: Initial Query
│   ├── Query text
│   ├── AI Response summary
│   ├── Gaps Identified
│   └── Time
├── Iteration 2: Refined Query
│   ├── Query text
│   ├── AI Response summary
│   ├── Insights Gained
│   └── Time
├── Iteration 3-N: Further Refinement...
└── Final Query
    ├── Query text
    ├── AI Response summary
    ├── Confidence Level
    └── Time

🎯 Query Effectiveness Analysis
├── High-Quality Queries (Immediate Value)
│   ├── Pattern description
│   ├── Example query
│   ├── Why it worked
│   ├── Time to insight
│   └── Value gained
├── Queries Needing Refinement
│   ├── Pattern description
│   ├── Initial query example
│   ├── Issue identified
│   ├── Refined version
│   ├── Iterations needed
│   └── Learning
└── Most Valuable Query
    ├── The query text
    └── Why it mattered

💡 Key Insights Discovered
├── List of main insights (comma-separated)
└── Detailed Insights
    ├── Insight 1
    │   ├── Discovery
    │   ├── Implications
    │   └── Supporting Evidence
    ├── Insight 2...
    └── Insight 3...

🎯 Approaches Evaluated
├── List of approaches (comma-separated)
└── Detailed Evaluation
    ├── Approach 1
    │   ├── Overview
    │   ├── Pros
    │   ├── Cons
    │   ├── Best For
    │   ├── Avoid When
    │   └── Estimated Effort
    ├── Approach 2...
    └── Approach 3...

✅ Final Decision & Recommendation
├── Decision
├── Decision Confidence
├── Rationale
└── Trade-offs Accepted

🚀 Implementation Guidance
├── Recommended Next Steps
├── Prerequisites
├── Estimated Implementation Time
├── Estimated Complexity
└── Key Considerations

⚠️ Risks & Mitigations
├── Risk 1
│   ├── Likelihood
│   ├── Impact
│   └── Mitigation
├── Risk 2...
└── Risk 3...

📊 Research Impact
├── Knowledge Gained
│   ├── Questions Answered
│   ├── Approaches Evaluated
│   ├── Decision Confidence
│   └── Time Efficiency
├── Business Value
│   ├── Reduced Decision Risk
│   ├── Accelerated Planning
│   ├── Knowledge Transfer
│   └── Future Reference
├── Qualitative Benefits
└── Future Applications

📚 Resources & References
├── AI Tool Used
├── Related Documentation
├── Similar Research Sessions
├── Follow-up Actions (checklist)
└── People to Share With

🔄 Replicability Framework
├── This research approach is replicable for
├── Prerequisites for Replication
│   ├── Technology
│   ├── Knowledge
│   └── Context
├── Expected Timeframe & Complexity (table)
│   ├── Simple question
│   ├── Medium exploration
│   └── Complex decision
└── Best Practices for Similar Research Sessions

📋 Footer
├── Created date
├── Last Updated date
├── Author
├── Review Status
└── Research Outcome
```

---

## Key Differences

### Implementation Template (TEMPLATE.md)
- **Focus**: Code changes, technical implementation
- **Metrics**: Files modified, lines changed, tests passing
- **Workflow**: Step-by-step implementation process
- **Output**: Working code, commits, pull requests

### Research Template (TEMPLATE-RESEARCH.md)
- **Focus**: Knowledge discovery, decision-making
- **Metrics**: Queries, iterations, approaches evaluated
- **Workflow**: Query evolution and refinement
- **Output**: Insights, recommendations, decisions

---

## Usage Guidelines

### When to Use Implementation Template
- Adding new features
- Fixing bugs
- Refactoring code
- Writing tests
- Any session with git commits

### When to Use Research Template
- Architecture discussions
- Technology evaluation
- Approach comparison
- Learning new concepts
- Exploratory questions
- Any session without code changes

---

## File Naming Convention

Both templates follow the same naming pattern:

```
YYYY-Www-MM-DD_TICKET-XXX_brief-description.md
```

**Examples:**
- Implementation: `2025-W44-11-02_PROJ-123_add-token-metrics.md`
- Research: `2025-W44-11-02_RESEARCH-001_evaluate-auth-approaches.md`

**Components:**
- `YYYY` = Year (e.g., 2025)
- `Www` = ISO 8601 week number (W01-W53)
- `MM` = Month (01-12)
- `DD` = Day (01-31)
- `TICKET-XXX` = Ticket identifier (use RESEARCH-XXX for research sessions)
- `brief-description` = Lowercase with hyphens

---

## Location

Templates are stored in the hub repository:
- **Hub Repository**: https://github.com/mt-osiris-tools/ai-use-case-hub
- **Implementation Template**: `TEMPLATE.md`
- **Research Template**: `TEMPLATE-RESEARCH.md`

---

## Related Documentation

- [AI Session Statistics Guide](AI_SESSION_STATISTICS_GUIDE.md) - How to capture metrics
- [Capturing User Queries](CAPTURING_USER_QUERIES.md) - Query tracking best practices
- [Hub Sync Checklist](HUB-SYNC-CHECKLIST.md) - Syncing documentation to hub
- [Version Management](VERSION-MANAGEMENT.md) - CLI versioning guide

---

**Last Updated**: 2025-11-02
**Related**: Templates v2.4.0 (enhanced with token and interaction metrics)
