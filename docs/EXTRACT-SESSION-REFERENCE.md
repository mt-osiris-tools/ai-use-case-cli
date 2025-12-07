# Extract Session Data - Reference Documentation

Detailed reference for the `extract-session-data.sh` script and `/use-case:extract-session` slash command.

## Table of Contents

- [Exit Codes](#exit-codes)
- [Cost Calculation](#cost-calculation)
- [JSON Output Structure](#json-output-structure)
- [Markdown Output Format](#markdown-output-format)
- [Command Substitution Best Practices](#command-substitution-best-practices)
- [Error Handling](#error-handling)

---

## Exit Codes

Understanding exit codes helps diagnose issues with the extraction script.

### Standard Exit Codes

- **Exit 0**: Successful extraction completed
- **Exit 141 (SIGPIPE)**: Normal termination when output pipe closes early
  - This is **NOT an error** - extraction completed successfully
  - Occurs when piping to `head`, `less`, or similar commands
  - The script finished writing all data, but the receiving end closed the pipe
- **Exit 2**: Syntax error in command (check command substitution and quoting)
- **Exit 127**: Command not found (check script path or installation)

### Handling Exit Codes in Scripts

```bash
# Capture exit code immediately after command
bash ~/.local/share/ai-use-case-cli/scripts/core/extract-session-data.sh . 8 json \
  --token-input 95000 \
  --token-output 9687 \
  --context-total 1000000 \
  --cost 0.4303 \
  -o "$OUTPUT_FILE"

EXIT_CODE=$?

# Handle exit codes
if [ $EXIT_CODE -eq 0 ] || [ $EXIT_CODE -eq 141 ]; then
  echo "✓ Extraction completed successfully"
  if [ -f "$OUTPUT_FILE" ]; then
    cat "$OUTPUT_FILE"
  else
    echo "✗ Output file '$OUTPUT_FILE' not found. Extraction may have failed or produced no output."
    exit 1
  fi
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

---

## Cost Calculation

### Claude Sonnet 4.5 Pricing (as of 2025)

- **Input tokens**: $3 per 1M tokens
- **Output tokens**: $15 per 1M tokens
- **Prompt caching**: Reduced cost for cached content

### Calculation Formula

```text
cost = (input_tokens * 3 / 1,000,000) + (output_tokens * 15 / 1,000,000)
```

### Examples

**Example 1: Typical session**
```text
Input: 95,000 tokens = 95,000 * $3 / 1,000,000 = $0.2850
Output: 9,687 tokens = 9,687 * $15 / 1,000,000 = $0.1453
Total: $0.4303
```

**Example 2: Large session**
```text
Input: 150,000 tokens = 150,000 * $3 / 1,000,000 = $0.4500
Output: 25,000 tokens = 25,000 * $15 / 1,000,000 = $0.3750
Total: $0.8250
```

### Precision

**Always use 4 decimal places** for accuracy (e.g., `0.1068` not `0.11`). This precision is important for:
- Accurate tracking across multiple sessions
- Cost reporting and ROI analysis
- Budget monitoring

---

## JSON Output Structure

The extraction script generates a comprehensive JSON structure with session metadata, git history, token usage, and calculated metrics.

### Complete Structure

```json
{
  "sessionMetadata": {
    "extractedAt": "2025-11-08T19:00:00Z",
    "projectName": "ai-use-case-cli",
    "branch": "feature/new-feature",
    "timeWindow": "8h",
    "sessionDuration": "4.5h",
    "aiTool": "Claude Code (Sonnet 4.5)",
    "cliVersion": "3.10.0"
  },
  "gitHistory": {
    "commits": [
      {
        "hash": "abc1234",
        "author": "John Doe",
        "email": "john@example.com",
        "date": "2025-11-08T18:30:00Z",
        "message": "feat: Add new feature",
        "filesChanged": 3,
        "insertions": 45,
        "deletions": 12
      }
    ],
    "summary": {
      "totalCommits": 5,
      "totalFilesChanged": 12,
      "totalInsertions": 342,
      "totalDeletions": 127,
      "netLines": 215
    }
  },
  "fileChanges": {
    "committed": [
      {
        "path": "src/main.js",
        "status": "modified",
        "additions": 25,
        "deletions": 5
      }
    ],
    "uncommitted": [
      {
        "path": "README.md",
        "status": "modified"
      }
    ]
  },
  "tokenUsage": {
    "inputTokens": 95000,
    "outputTokens": 9687,
    "cachedTokens": 5000,
    "totalTokens": 104687,
    "contextTokens": 1000000,
    "cacheHits": 8,
    "estimatedCostUSD": "0.4303"
  },
  "calculatedMetrics": {
    "estimatedInteractions": 35,
    "avgFilesPerCommit": 2.4,
    "avgLinesPerCommit": 93.8,
    "commitFrequency": "1.11 commits/hour"
  },
  "conversationData": {
    "notes": "Add conversation highlights here",
    "decisions": [],
    "blockers": [],
    "learnings": []
  }
}
```

### Field Descriptions

#### sessionMetadata
- `extractedAt`: ISO 8601 timestamp of extraction
- `projectName`: Name of the project/repository
- `branch`: Current git branch
- `timeWindow`: Time window analyzed (e.g., "8h", "24h")
- `sessionDuration`: Actual working time
- `aiTool`: AI assistant used (e.g., "Claude Code (Sonnet 4.5)")
- `cliVersion`: Version of AI Use Case CLI

#### gitHistory
- `commits`: Array of commit objects with full details
- `summary`: Aggregated statistics across all commits

#### tokenUsage
- `inputTokens`: Tokens consumed from user messages and context
- `outputTokens`: Tokens generated in responses
- `cachedTokens`: Tokens served from cache
- `totalTokens`: Sum of input and output tokens
- `contextTokens`: Total context window size
- `cacheHits`: Number of times cache was used
- `estimatedCostUSD`: Calculated cost (4 decimal places)

#### calculatedMetrics
- `estimatedInteractions`: Approximate number of AI interactions
- `avgFilesPerCommit`: Average files changed per commit
- `avgLinesPerCommit`: Average lines changed per commit
- `commitFrequency`: Commits per hour

---

## Markdown Output Format

When generating markdown reports, the script produces a human-readable document with all session details.

### Structure

```markdown
# AI Session Report - PROJECT-NAME

**Generated:** 2025-11-08 19:00:00 UTC
**Branch:** feature/new-feature
**Time Window:** Last 8 hours
**Session Duration:** 4.5 hours

## Session Overview

- **AI Tool:** Claude Code (Sonnet 4.5)
- **CLI Version:** 3.10.0
- **Estimated Interactions:** ~35

## Token Usage

| Metric | Value |
|--------|-------|
| Input Tokens | 95,000 |
| Output Tokens | 9,687 |
| Cached Tokens | 5,000 |
| Total Tokens | 104,687 |
| Context Size | 1,000,000 |
| Cache Hits | 8 |
| **Estimated Cost** | **$0.4303 USD** |

## Git Activity

### Summary
- **Total Commits:** 5
- **Files Changed:** 12
- **Lines Added:** +342
- **Lines Removed:** -127
- **Net Change:** +215 lines

### Commits

#### [abc1234] feat: Add new feature
- **Author:** John Doe (john@example.com)
- **Date:** 2025-11-08 18:30:00 UTC
- **Files Changed:** 3 (+45, -12)

[Additional commits...]

## File Changes

### Committed
- `src/main.js` (modified): +25, -5
- [Additional files...]

### Uncommitted
- `README.md` (modified)

## Calculated Metrics

- **Average Files per Commit:** 2.4
- **Average Lines per Commit:** 93.8
- **Commit Frequency:** 1.11 commits/hour

## Conversation Notes

_Add manual notes about key decisions, blockers, and learnings here._

---

*This report was generated by AI Use Case CLI v3.10.0*
```

---

## Command Substitution Best Practices

When using the extraction script, proper handling of dynamic values prevents errors and improves reliability.

### The Problem

Inline command substitution can fail in certain execution contexts:

```bash
# ✗ WRONG - May fail in eval contexts or restricted shells
bash script.sh -o "/tmp/session-$(date +%Y-%m-%d).json"
```

### The Solution

**Always pre-generate dynamic values** before passing to scripts:

```bash
# ✓ CORRECT - Pre-generate all dynamic values
SESSION_DATE=$(date +%Y-%m-%d)
SESSION_TIME=$(date +%H-%M-%S)
OUTPUT_FILE="/tmp/session-${SESSION_DATE}-${SESSION_TIME}.json"
bash script.sh -o "$OUTPUT_FILE"
```

### Why This Matters

1. **Reliability**: Inline substitution can fail in eval contexts or restricted shells
2. **Debugging**: Pre-generation makes debugging easier (you can see the actual values)
3. **Consistency**: Establishes a consistent pattern across all script invocations
4. **Error Messages**: Better error messages when paths are invalid

### Apply This Pattern To

- Date/time stamps
- Git commit hashes
- Branch names
- Any dynamic value used in paths or parameters

### Complete Example

```bash
# Pre-generate all dynamic values
SESSION_DATE=$(date +%Y-%m-%d)
SESSION_TIME=$(date +%H-%M-%S)
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
OUTPUT_FILE="/tmp/session-${SESSION_DATE}-${SESSION_TIME}.json"

# Run extraction with pre-generated values
bash ~/.local/share/ai-use-case-cli/scripts/core/extract-session-data.sh . 8 json \
  --token-input 95000 \
  --token-output 9687 \
  --context-total 1000000 \
  --cost 0.4303 \
  -o "$OUTPUT_FILE"

EXIT_CODE=$?

# Handle result
if [ $EXIT_CODE -eq 0 ] || [ $EXIT_CODE -eq 141 ]; then
  echo "✓ Extraction completed successfully"
  echo "📁 Data saved to: $OUTPUT_FILE"
  if [ -f "$OUTPUT_FILE" ]; then
    cat "$OUTPUT_FILE"
  fi
else
  echo "✗ Extraction failed with exit code $EXIT_CODE"
  exit $EXIT_CODE
fi
```

---

## Error Handling

Common issues and how to resolve them.

### No Git Repository

**Symptom**: Error message about not being in a git repository

**Solution**:
```bash
# Check if you're in a git repository
git rev-parse --show-toplevel

# If not, initialize one or change to a git repository directory
git init  # To initialize new repo
# OR
cd /path/to/your/project  # To change to existing repo
```

### No Commits in Time Window

**Symptom**: Empty output or message about no commits found

**Solution**:
- Increase the time window (e.g., from 8 to 24 hours)
- Check if commits exist: `git log --since="8 hours ago"`
- Consider manual documentation if no commits yet

### Token Data Unavailable

**Symptom**: Missing or zero token values in output

**Solution**:
- Use manual input with `--token-*` flags
- Prompt user for approximate values
- Use estimates based on conversation length

### Script Not Found

**Symptom**: Exit code 127, "command not found"

**Solution**:
```bash
# Verify installation
ls -la ~/.local/share/ai-use-case-cli/scripts/core/extract-session-data.sh

# If missing, reinstall the CLI
curl -fsSL https://raw.githubusercontent.com/mt-osiris-tools/ai-use-case-cli/main/scripts/install/install.sh | bash
```

### Permission Denied

**Symptom**: Cannot execute script or write output file

**Solution**:
```bash
# Make script executable
chmod +x ~/.local/share/ai-use-case-cli/scripts/core/extract-session-data.sh

# Check output directory permissions
ls -la /tmp
# Or use a directory you have write access to
```

### Output File Not Created

**Symptom**: Script succeeds but output file doesn't exist

**Solution**:
1. Check if the directory exists: `ls -la /tmp`
2. Try outputting to stdout instead (omit `-o` flag)
3. Check disk space: `df -h`
4. Verify permissions on output directory

---

## See Also

- [Command Reference](./COMMANDS.md) - Full CLI command reference
- [Claude Code Integration](./CLAUDE.md) - Slash commands documentation
- Main repository: https://github.com/mt-osiris-tools/ai-use-case-cli
