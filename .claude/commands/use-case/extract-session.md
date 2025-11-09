# Extract AI Session Data

Extract comprehensive AI interaction session data from git history, file system, and conversation context to support automated use case documentation and reporting.

## Your Task

Extract session data from the current project and present it in a structured format with all available metrics, including token usage and context from this conversation.

## Extraction Workflow

### Step 1: Verify Project Setup

Check if we're in a git repository:
```bash
git rev-parse --show-toplevel
```

If not a git repo, inform the user and offer alternatives.

### Step 2: Determine Time Window

Ask the user or use intelligent default:
- **Auto-detect**: Use time since first commit today
- **Default**: Last 8 hours (typical work session)
- **User choice**: Let user specify hours

### Step 3: Extract Token Usage from Current Session

**IMPORTANT**: As Claude Code, you have access to the current conversation's token usage. Extract this data to include in the session report.

From the most recent system reminder or conversation metadata, capture:
- Input tokens (user messages + context)
- Output tokens (assistant responses)
- Cached tokens (if available)
- Total context size
- Cache hits

Example values from current session:
```
Token usage: 104687/1000000
Input: ~95000 tokens
Output: ~9687 tokens
Context: 1000000 tokens
```

### Step 4: Run Extraction with Token Data

Execute the extraction script with captured token data:
```bash
bash ~/.local/share/ai-use-case-cli/scripts/core/extract-session-data.sh . <hours> json \
  --token-input <INPUT_TOKENS> \
  --token-output <OUTPUT_TOKENS> \
  --context-total <CONTEXT_SIZE> \
  --cost <ESTIMATED_COST>
```

**Calculate cost** (Sonnet 4.5 pricing as of 2025):
- Input: $3 per 1M tokens
- Output: $15 per 1M tokens
- Formula: `cost = (input * 3 / 1000000) + (output * 15 / 1000000)`

### Step 5: Present Results

After extraction, present the data in a clear, actionable format:

####  Session Summary
```
📊 Session Extract - <Project Name>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Git Activity:
  • Commits: X
  • Files Changed: Y
  • Lines: +A / -B

Token Usage:
  • Input: X tokens
  • Output: Y tokens
  • Total: Z tokens
  • Cost: $X.XX USD

Duration: X hours
Estimated Interactions: ~Y
```

### Step 6: Offer Next Actions

Provide helpful options:
```
What would you like to do with this data?

1. 📁 Save to file (session-data-2025-11-08.json)
2. 📝 Generate AI use case documentation
3. 📊 View detailed breakdown
4. 📄 Export as markdown report
5. 🔍 Analyze patterns and insights
```

## Output Formats

### JSON Format
Structured data including:
- Session metadata (project, branch, duration, AI tool)
- Git history (commits with full details)
- File changes (committed and uncommitted)
- **Token usage** (input, output, cached, context, cost)
- Calculated metrics (interactions, averages, frequency)
- Placeholder for additional conversation notes

### Markdown Format
Human-readable report with:
- Session overview
- Git commit history
- **Token usage and cost breakdown**
- Metrics summary
- File changes
- Space for manual conversation notes

## Token Data Capture Strategy

**Automatic capture** (when available):
1. Parse system reminders for token counts
2. Extract from conversation metadata
3. Calculate costs based on current pricing
4. Include context window information

**Manual input** (fallback):
- If token data not accessible, use `--token-*` flags
- Prompt user for approximate values
- Use estimates based on conversation length

## Usage Examples

**Auto-extract with current session tokens:**
```bash
# Claude Code will automatically populate token data
bash ~/.local/share/ai-use-case-cli/scripts/core/extract-session-data.sh . 8 json \
  --token-input 95000 \
  --token-output 9687 \
  --context-total 1000000 \
  --cost 0.43
```

**Save to file:**
```bash
bash ~/.local/share/ai-use-case-cli/scripts/core/extract-session-data.sh . 8 json \
  --token-input 95000 \
  --token-output 9687 \
  --cost 0.43 \
  -o session-data-$(date +%Y-%m-%d).json
```

**Generate markdown report:**
```bash
bash ~/.local/share/ai-use-case-cli/scripts/core/extract-session-data.sh . 8 markdown \
  --token-input 95000 \
  --token-output 9687 \
  --cost 0.43 \
  -o session-report-$(date +%Y-%m-%d).md
```

## Integration with Documentation

This extracted data directly supports:
1. **Auto-populate use case templates** with accurate git and token metrics
2. **Generate ROI reports** with real cost data
3. **Track productivity** with quantifiable outcomes
4. **Build knowledge base** with historical session data
5. **Analyze efficiency** by comparing token usage across sessions

## Expected Output Structure

```json
{
  "sessionMetadata": {
    "extractedAt": "2025-11-08T19:00:00Z",
    "projectName": "ai-use-case-cli",
    "branch": "docs/update-version-references-to-3.3.0",
    "timeWindow": "8h",
    "sessionDuration": "4.5h",
    "aiTool": "Claude Code (Sonnet 4.5)",
    "cliVersion": "3.3.0"
  },
  "gitHistory": {
    "commits": [...],
    "summary": {
      "totalCommits": 5,
      "totalFilesChanged": 12,
      "totalInsertions": 342,
      "totalDeletions": 127,
      "netLines": 215
    }
  },
  "tokenUsage": {
    "inputTokens": 95000,
    "outputTokens": 9687,
    "cachedTokens": 5000,
    "totalTokens": 104687,
    "contextTokens": 1000000,
    "cacheHits": 8,
    "estimatedCostUSD": "0.43"
  },
  "calculatedMetrics": {
    "estimatedInteractions": 35,
    "avgFilesPerCommit": 2.4,
    "avgLinesPerCommit": 93.8,
    "commitFrequency": "1.11 commits/hour"
  }
}
```

## Important Notes

- **Git history required**: Must be in a git repository
- **Token data automatic**: Captured from current conversation when possible
- **Cost estimates**: Based on Sonnet 4.5 pricing (may need updates)
- **Real-time extraction**: Best run at end of session while context is fresh
- **Privacy**: All data stays local unless explicitly saved to hub

## Cost Calculation Reference

**Sonnet 4.5 Pricing** (as of 2025):
- Input: $3 per 1M tokens
- Output: $15 per 1M tokens
- Prompt caching: Reduced cost for cached content

**Example calculation:**
```
Input: 95,000 tokens = 95,000 * $3 / 1,000,000 = $0.29
Output: 9,687 tokens = 9,687 * $15 / 1,000,000 = $0.15
Total: $0.44
```

## Error Handling

If extraction fails:
1. **No git repo**: Offer to initialize or use different directory
2. **No commits**: Suggest manual documentation or wait for commits
3. **Token data unavailable**: Use manual input or estimates
4. **Script errors**: Check permissions and dependencies
