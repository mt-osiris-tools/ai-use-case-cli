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

**Calculate cost** (Sonnet 4.5 pricing as of 2025):
- Input: $3 per 1M tokens
- Output: $15 per 1M tokens
- Formula: `cost = (input * 3 / 1000000) + (output * 15 / 1000000)`
- **Use 4 decimal precision** for accuracy (e.g., 0.1068 not 0.11)

**CRITICAL**: Pre-generate filenames to avoid command substitution failures:
```bash
# Generate timestamp-based filename BEFORE calling script
SESSION_DATE=$(date +%Y-%m-%d)
OUTPUT_FILE="/tmp/session-data-${SESSION_DATE}.json"
```

Execute the extraction script with robust error handling:
```bash
# Run extraction and capture exit code
bash ~/.local/share/ai-use-case-cli/scripts/core/extract-session-data.sh . <hours> json \
  --token-input <INPUT_TOKENS> \
  --token-output <OUTPUT_TOKENS> \
  --context-total <CONTEXT_SIZE> \
  --cost <ESTIMATED_COST> \
  -o "$OUTPUT_FILE"

EXIT_CODE=$?

# Handle exit codes
if [ $EXIT_CODE -eq 0 ] || [ $EXIT_CODE -eq 141 ]; then
  echo "✓ Extraction completed successfully"
  # Display the results
  cat "$OUTPUT_FILE"
elif [ $EXIT_CODE -eq 2 ]; then
  echo "✗ Syntax error - check command formatting"
  exit $EXIT_CODE
elif [ $EXIT_CODE -eq 127 ]; then
  echo "✗ Script not found - check installation"
  exit $EXIT_CODE
else
  echo "✗ Extraction failed with exit code $EXIT_CODE"
  exit $EXIT_CODE
fi
```

**Important Notes**:
- Exit code 141 (SIGPIPE) is **SUCCESS** - occurs when output pipe closes early
- Exit code 0 is standard success
- Always use the `|| EXIT_CODE=$?` pattern to capture the code before handling
- Pre-generate ALL dynamic filenames to avoid bash substitution issues

### Step 5: Present Results

**MANDATORY**: After successful extraction, ALWAYS present the data in a clear, actionable format. Parse the JSON output and create a human-readable summary.

#### Session Summary Template

```text
📊 Session Extract - <Project Name>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Git Activity:
  • Commits: X
  • Files Changed: Y
  • Lines: +A / -B
  • Branch: <branch-name>

Token Usage:
  • Input: X,XXX tokens
  • Output: Y,YYY tokens
  • Total: Z,ZZZ tokens
  • Cost: $X.XXXX USD

Session Details:
  • Duration: X hours
  • Estimated Interactions: ~Y
  • Time Window: Last X hours
  • Extracted: YYYY-MM-DD HH:MM

📁 Data saved to: /tmp/session-data-YYYY-MM-DD.json
```

**Implementation Requirements**:
- Parse the JSON output to extract actual values
- Format numbers with commas for readability (e.g., 30,000 not 30000)
- Always show 4 decimal places for cost (e.g., $0.1068)
- Include the output file path
- Present this BEFORE Step 6

### Step 6: Offer Next Actions

**MANDATORY**: ALWAYS present these options after showing the session summary.

```text
What would you like to do next?

1. 📝 Generate AI use case documentation from this session
2. 📄 Export as markdown report
3. 📊 View detailed commit breakdown
4. 🔍 Analyze patterns and insights
5. ✅ Done - session data saved
```

**Interactive Flow**:
- Wait for user to select an option
- Implement the selected action
- For option 1: Use `/use-case:document-session`
- For option 2: Generate markdown using the extracted data
- For option 3: Show detailed git commit history
- For option 4: Analyze metrics and provide insights
- For option 5: Confirm completion

**Implementation Notes**:
- Use pre-generated filenames for all file operations
- Never skip Step 5 or Step 6
- If extraction succeeded but no output visible, read the file and present it
- The user should always see both summary AND next actions

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

### Complete Extraction with Error Handling

**Recommended Pattern** (used by `/use-case:extract-session`):

```bash
# Step 1: Pre-generate filename
SESSION_DATE=$(date +%Y-%m-%d)
OUTPUT_FILE="/tmp/session-data-${SESSION_DATE}.json"

# Step 2: Run extraction
bash ~/.local/share/ai-use-case-cli/scripts/core/extract-session-data.sh . 8 json \
  --token-input 95000 \
  --token-output 9687 \
  --context-total 1000000 \
  --cost 0.4303 \
  -o "$OUTPUT_FILE"

# Step 3: Capture and handle exit code
EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ] || [ $EXIT_CODE -eq 141 ]; then
  echo "✓ Extraction completed successfully"
  cat "$OUTPUT_FILE"
else
  echo "✗ Extraction failed with exit code $EXIT_CODE"
  exit $EXIT_CODE
fi
```

### Simple Extraction (stdout)

```bash
# Direct output to stdout (no file)
bash ~/.local/share/ai-use-case-cli/scripts/core/extract-session-data.sh . 8 json \
  --token-input 95000 \
  --token-output 9687 \
  --context-total 1000000 \
  --cost 0.4303
```

### Markdown Report

```bash
# Pre-generate filename
SESSION_DATE=$(date +%Y-%m-%d)
OUTPUT_FILE="/tmp/session-report-${SESSION_DATE}.md"

# Generate markdown
bash ~/.local/share/ai-use-case-cli/scripts/core/extract-session-data.sh . 8 markdown \
  --token-input 95000 \
  --token-output 9687 \
  --context-total 1000000 \
  --cost 0.4303 \
  -o "$OUTPUT_FILE"

EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ] || [ $EXIT_CODE -eq 141 ]; then
  cat "$OUTPUT_FILE"
fi
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

```text
Input: 95,000 tokens = 95,000 * $3 / 1,000,000 = $0.2850
Output: 9,687 tokens = 9,687 * $15 / 1,000,000 = $0.1453
Total: $0.4303
```

**Precision matters**: Always use 4 decimal places to accurately track costs across multiple sessions.

## Error Handling

If extraction fails:
1. **No git repo**: Offer to initialize or use different directory
2. **No commits**: Suggest manual documentation or wait for commits
3. **Token data unavailable**: Use manual input or estimates
4. **Script errors**: Check permissions and dependencies

### Common Exit Codes

- **Exit 0**: Successful extraction
- **Exit 141 (SIGPIPE)**: Normal termination when output is piped and pipe closes early
  - This is **NOT an error** - extraction completed successfully
  - Occurs when piping to `head`, `less`, or similar commands
  - The script finished writing all data, but the receiving end closed the pipe
- **Exit 2**: Syntax error in command (check command substitution and quoting)
- **Exit 127**: Command not found (check script path)

### Command Substitution Best Practices

**ALWAYS** pre-generate dynamic values before passing to scripts:

```bash
# ✓ CORRECT - Pre-generate all dynamic values
SESSION_DATE=$(date +%Y-%m-%d)
SESSION_TIME=$(date +%H-%M-%S)
OUTPUT_FILE="/tmp/session-${SESSION_DATE}-${SESSION_TIME}.json"
bash script.sh -o "$OUTPUT_FILE"

# ✗ WRONG - Inline substitution may fail in certain execution contexts
bash script.sh -o "/tmp/session-$(date +%Y-%m-%d).json"
```

**Why this matters:**
- Inline command substitution can fail in eval contexts or restricted shells
- Pre-generation makes debugging easier (you can see the actual values)
- Consistent pattern across all script invocations
- Better error messages when paths are invalid

**Apply this pattern to:**
- Date/time stamps
- Git commit hashes
- Branch names
- Any dynamic value used in paths or parameters
