# Review Documentation Quality

**Command:** `/use-case:review-quality`
**Purpose:** Analyze AI Use Case documentation quality and provide improvement suggestions
**Agent:** Quality Reviewer (Phase 2)

## Tooling Notes (for OpenCode and other runtimes)

Tool names referenced in this command are conceptual:

- "Task tool" / `subagent_type` => subagent invocation tool (OpenCode: `task`)

---

## Your Task

When the user invokes this command, you will analyze the quality of their AI Use Case documentation file and provide comprehensive feedback with actionable improvement suggestions.

## Workflow

### Step 1: Identify Target File

**If file path provided:**
```
/use-case:review-quality .usecase/cases/2025-W49-12-02_HUB-001_example.md
```
Use the specified file.

**If no file specified:**
- Look in `.usecase/cases/` for recent documentation files
- List the 5 most recent files
- Ask user which file to review
- Example:
  ```
  Which file would you like me to review?

  Recent documentation:
  1. 2025-W49-12-02_HUB-001_example.md (2 days ago)
  2. 2025-W48-11-28_FEATURE-002_agents.md (5 days ago)
  3. 2025-W48-11-25_BUG-123_fix-colors.md (1 week ago)

  Enter number or file path:
  ```

### Step 2: Validate File

- Check file exists
- Verify it's a markdown file
- Confirm it's in `.usecase/cases/` directory
- If issues, show helpful error and exit

### Step 3: Invoke Quality Agent

Use the Task tool to invoke the quality agent:

```javascript
Task({
  subagent_type: "use-case-quality-agent",
  description: "Review documentation quality",
  prompt: `Analyze the quality of this AI Use Case documentation file and provide detailed feedback with improvement suggestions.

File path: ${filePath}

File contents:
${fileContents}

Please provide:
1. Overall quality score (0-10)
2. Category breakdown (completeness, technical depth, clarity, actionability, quantification)
3. List of strengths
4. Specific, actionable improvement suggestions with examples
5. Summary and grade

Output in JSON format as specified in the agent prompt.`
})
```

### Step 4: Parse and Present Results

The agent will return JSON with the analysis. Parse it and present to the user in a clear, structured format:

```
═══════════════════════════════════════════════
Documentation Quality Analysis
═══════════════════════════════════════════════

File: .usecase/cases/2025-W49-12-02_HUB-001_example.md
Overall Score: 7.5/10
Grade: B

Category Scores:
  Completeness: 9.0/10 (weight: 30%)
  Technical Depth: 7.0/10 (weight: 25%)
  Clarity: 8.0/10 (weight: 20%)
  Actionability: 6.0/10 (weight: 15%)
  Quantification: 7.5/10 (weight: 10%)

✓ Strengths:
  • All required sections are present and non-empty
  • Clear technical details with specific file references
  • Good use of code examples to illustrate points
  • Well-structured and easy to follow

⚠ Improvement Suggestions:

1. ACTIONABILITY - Lessons Learned:
   Issue: Lessons are somewhat generic and could be more specific

   Recommendation: Add concrete examples of how these lessons apply to future work

   Example: Instead of 'Test thoroughly', say 'Run integration tests after each
   feature addition to catch breaking changes early'

2. QUANTIFICATION - Results & Outcomes:
   Issue: Missing some quantitative metrics

   Recommendation: Add specific numbers: lines of code changed, test coverage
   increase, performance improvements

   Example: Added 150 lines, increased test coverage from 75% to 85%, reduced
   load time by 200ms

3. TECHNICAL_DEPTH - Technical Implementation Details:
   Issue: Could benefit from more architecture context

   Recommendation: Add a brief explanation of why this architectural approach
   was chosen over alternatives

   Example: Chose microservices pattern for scalability, rejected monolith
   due to deployment constraints

Summary:
Strong documentation with good technical detail and clear structure. Main areas
for improvement: more specific lessons learned and additional quantitative metrics.
Overall quality is above average.
```

### Step 5: Offer Actions

After presenting the analysis, ask the user:

```
Would you like me to:
1. Apply these improvements to the file
2. Review another file
3. Generate a batch report for all documentation
4. Save this analysis for future reference
```

## Key Principles

1. **Be Constructive:** Frame all feedback positively and helpfully
2. **Be Specific:** Every suggestion must be actionable with examples
3. **Be Clear:** Present complex information in an easy-to-understand format
4. **Be Helpful:** Offer to help implement improvements

## Error Handling

**File not found:**
```
❌ Error: File not found

The file '.usecase/cases/example.md' doesn't exist.

Recent files in .usecase/cases/:
- 2025-W49-12-02_HUB-001_example.md
- 2025-W48-11-28_FEATURE-002_agents.md

Please specify a valid file path.
```

**Agent not enabled:**
```
❌ Quality Agent Not Enabled

The quality reviewer agent needs to be enabled first.

Run: ai-use-case agents enable quality-reviewer

Then try this command again.
```

**Agent invocation failed:**
```
❌ Analysis Failed

The quality agent encountered an error during analysis.

Error: [specific error message]

Please try again or check that Claude Code is available.
```

## Advanced Features

### Batch Mode

If user requests reviewing multiple files:

```
/use-case:review-quality --batch
```

1. Find all files in `.usecase/cases/`
2. Analyze each file
3. Generate summary report:
   ```
   Batch Quality Report

   Total files analyzed: 15
   Average score: 7.8/10

   Top performing:
   1. file1.md - 9.2/10 (A)
   2. file2.md - 8.9/10 (A-)
   3. file3.md - 8.7/10 (B+)

   Needs improvement:
   1. file13.md - 5.5/10 (D+)
   2. file14.md - 6.0/10 (C)
   3. file15.md - 6.3/10 (C+)

   Common improvement areas:
   - More quantitative metrics (mentioned in 8 files)
   - Deeper technical details (mentioned in 6 files)
   - More specific lessons learned (mentioned in 5 files)
   ```

### Project-Wide Analysis

If user requests project analysis:

```
/use-case:review-quality --project ai-use-case-cli
```

Analyze all documentation in that project from the hub.

## Integration with Document Session

When user is documenting a session, you can proactively suggest:

```
✓ Documentation created successfully!

Would you like me to review the quality of this documentation?

This will analyze:
- Completeness of all sections
- Technical depth and clarity
- Actionability of lessons learned
- Overall documentation quality

Review now? (y/N)
```

## Examples

### Example 1: Single File Review

**User:** `/use-case:review-quality .usecase/cases/2025-W49-12-02_HUB-001_example.md`

**You:**
1. Read the file
2. Invoke quality agent
3. Parse JSON response
4. Present formatted results
5. Offer to apply improvements

### Example 2: No File Specified

**User:** `/use-case:review-quality`

**You:**
```
Which file would you like me to review?

Recent documentation in .usecase/cases/:
1. 2025-W49-12-02_HUB-001_example.md (modified 2 days ago)
2. 2025-W48-11-28_FEATURE-002_agents.md (modified 5 days ago)
3. 2025-W48-11-25_BUG-123_fix.md (modified 1 week ago)

Enter a number (1-3) or provide a file path:
```

### Example 3: Batch Review

**User:** `/use-case:review-quality --batch`

**You:**
1. Find all files in `.usecase/cases/`
2. Show progress: "Analyzing file 5/15..."
3. Generate comprehensive batch report
4. Highlight files needing attention

---

## Notes

- **Phase 2 Implementation:** This is the first functional agent
- **Agent Required:** Quality agent must be enabled (`ai-use-case agents enable quality-reviewer`)
- **Claude Code Required:** This command only works in Claude Code (uses Task tool)
- **Performance:** Single file analysis takes ~15-30 seconds
- **Caching:** Results are cached for 1 hour by default

---

**Remember:** Your goal is to help users improve their documentation quality. Be constructive, specific, and helpful in all feedback!
