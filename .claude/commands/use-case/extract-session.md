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

### Step 4: Run Extraction with Token Data

Calculate cost using Sonnet 4.5 pricing ($3 per 1M input tokens, $15 per 1M output tokens). Use 4 decimal precision (e.g., 0.1068).

Pre-generate filenames to avoid command substitution failures:
```bash
SESSION_DATE=$(date +%Y-%m-%d)
OUTPUT_FILE="/tmp/session-data-${SESSION_DATE}.json"
```

Execute the extraction script:
```bash
bash ~/.local/share/ai-use-case-cli/scripts/core/extract-session-data.sh . <hours> json \
  --token-input <INPUT_TOKENS> \
  --token-output <OUTPUT_TOKENS> \
  --context-total <CONTEXT_SIZE> \
  --cost <ESTIMATED_COST> \
  -o "$OUTPUT_FILE"

EXIT_CODE=$?

# Handle exit codes (0 and 141 are success)
if [ $EXIT_CODE -eq 0 ] || [ $EXIT_CODE -eq 141 ]; then
  echo "✓ Extraction completed successfully"
  if [ -f "$OUTPUT_FILE" ]; then
    cat "$OUTPUT_FILE"
  else
    echo "✗ Output file '$OUTPUT_FILE' not found"
    exit 1
  fi
else
  echo "✗ Extraction failed with exit code $EXIT_CODE"
  exit $EXIT_CODE
fi
```

**Note**: Exit code 141 (SIGPIPE) is **SUCCESS** - it occurs when output pipe closes early but extraction completed.

### Step 5: Present Results

**MANDATORY**: Parse the JSON output and create a human-readable summary.

#### Session Summary Template

```text
📊 Session Extract - PROJECT-NAME
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

Format numbers with commas for readability. Always show 4 decimal places for cost.

### Step 6: Offer Next Actions

**MANDATORY**: Present these options after showing the session summary.

```text
What would you like to do next?

1. 📝 Generate AI use case documentation from this session
2. 📄 Export as markdown report
3. 📊 View detailed commit breakdown
4. 🔍 Analyze patterns and insights
5. ✅ Done - session data saved
```

**Interactive Flow**:
- For option 1: Use `/use-case:document-session`
- For option 2: Generate markdown using the extracted data
- For option 3: Show detailed git commit history
- For option 4: Analyze metrics and provide insights
- For option 5: Confirm completion

## Output Formats

### JSON Format
Structured data including:
- Session metadata (project, branch, duration, AI tool)
- Git history (commits with full details)
- File changes (committed and uncommitted)
- Token usage (input, output, cached, context, cost)
- Calculated metrics (interactions, averages, frequency)

### Markdown Format
Human-readable report with:
- Session overview
- Git commit history
- Token usage and cost breakdown
- Metrics summary
- File changes

## Quick Examples

### Basic Extraction
```bash
SESSION_DATE=$(date +%Y-%m-%d)
OUTPUT_FILE="/tmp/session-data-${SESSION_DATE}.json"

bash ~/.local/share/ai-use-case-cli/scripts/core/extract-session-data.sh . 8 json \
  --token-input 95000 \
  --token-output 9687 \
  --context-total 1000000 \
  --cost 0.4303 \
  -o "$OUTPUT_FILE"
```

### Markdown Report
```bash
SESSION_DATE=$(date +%Y-%m-%d)
OUTPUT_FILE="/tmp/session-report-${SESSION_DATE}.md"

bash ~/.local/share/ai-use-case-cli/scripts/core/extract-session-data.sh . 8 markdown \
  --token-input 95000 \
  --token-output 9687 \
  --context-total 1000000 \
  --cost 0.4303 \
  -o "$OUTPUT_FILE"
```

## Token Data Capture

**Automatic capture** (when available):
1. Parse system reminders for token counts
2. Extract from conversation metadata
3. Calculate costs based on current pricing
4. Include context window information

**Manual input** (fallback):
- If token data not accessible, use `--token-*` flags
- Prompt user for approximate values

## Important Notes

- **Git history required**: Must be in a git repository
- **Token data automatic**: Captured from current conversation when possible
- **Cost estimates**: Based on Sonnet 4.5 pricing (may need updates)
- **Real-time extraction**: Best run at end of session while context is fresh
- **Privacy**: All data stays local unless explicitly saved to hub
- **Command substitution**: Always pre-generate dynamic values (dates, filenames) before passing to scripts

## Detailed Reference

For detailed information about exit codes, cost calculations, JSON structure, and error handling, see:
- [Extract Session Reference Documentation](../../docs/EXTRACT-SESSION-REFERENCE.md)
