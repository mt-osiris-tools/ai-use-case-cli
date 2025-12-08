# Time Calculations Reference

This document explains how all time-related metrics are calculated and captured in the AI Use Case CLI.

---

## Overview of Time Metrics

The CLI tracks several time-related metrics for each AI-assisted session:

| Metric | Type | Source |
|--------|------|--------|
| Session Duration | Automatic | Git commit timestamps |
| Time Window | Configurable | CLI parameter |
| Manual Estimate | Manual | User input |
| Actual Time | Manual | User input |
| Time Saved | Calculated | Manual Estimate - Actual Time |
| Efficiency Multiplier | Calculated | Manual Estimate / Actual Time |
| API Duration | Automatic | Claude Code `/cost` command |
| Wall Duration | Automatic | Claude Code `/cost` command |

---

## Session Duration (Automatic)

### How It's Calculated

Session duration is computed automatically from git commit timestamps within the specified time window.

**Source:** `scripts/core/extract-session-data.sh:248-264`

```bash
# Get first commit timestamp (oldest in time window)
FIRST_COMMIT_TIME=$(git log --since="${SINCE_DATE}" --reverse --pretty=format:'%at')

# Get last commit timestamp (most recent)
LAST_COMMIT_TIME=$(git log --since="${SINCE_DATE}" --pretty=format:'%at')

# Calculate duration in seconds
DURATION_SECONDS=$((LAST_COMMIT_TIME - FIRST_COMMIT_TIME))

# Convert to human-readable format
DURATION_HOURS=$((DURATION_SECONDS / 3600))
DURATION_MINUTES=$(((DURATION_SECONDS % 3600) / 60))
DURATION_HUMAN="${DURATION_HOURS}h ${DURATION_MINUTES}m"
```

### Formula

```
Session Duration = Last Commit Timestamp - First Commit Timestamp
```

### Important Notes

- **Requires commits:** If there are 0 or 1 commits, duration is `N/A`
- **Time window dependent:** Only considers commits within the specified time window
- **Unix timestamps:** Uses `%at` format (seconds since epoch) for precision
- **Excludes gaps:** Measures span, not active coding time

### Example

```
Time window: Last 8 hours
First commit: 10:30 AM (timestamp: 1699527000)
Last commit: 2:45 PM (timestamp: 1699542300)

Duration = 1699542300 - 1699527000 = 15300 seconds
         = 4 hours 15 minutes
```

---

## Time Window (Configurable)

### How It Works

The time window specifies how far back to look for git commits and file changes.

**Default:** 24 hours

**Source:** `scripts/core/extract-session-data.sh:29`

```bash
TIME_WINDOW="24" # Default: last 24 hours
```

### Usage

```bash
# Extract data from last 24 hours (default)
ai-use-case extract-session

# Extract data from last 8 hours
ai-use-case extract-session . 8

# Extract data from last 4 hours
ai-use-case extract-session . 4 json
```

### Calculation of Since Date

```bash
SINCE_DATE=$(date -d "${TIME_WINDOW} hours ago" '+%Y-%m-%d %H:%M:%S')
```

---

## Manual Estimate (User Input)

### Definition

The estimated time the task would have taken **without AI assistance**.

### How to Estimate

Break down the task into phases:

| Phase | Typical Manual Time |
|-------|---------------------|
| Understanding codebase | 1-2 hours (unfamiliar code) |
| Research & planning | 0.5-1 hour |
| Writing code | 2-3x longer than with AI |
| Writing tests | 1.5-2x longer than with AI |
| Debugging | 2-3x longer than with AI |
| Documentation | 0.5-1 hour |

### Example Breakdown

```markdown
### Manual Estimate (without AI): 6.0 hours
- Understanding codebase: 1.5h
- Writing code: 2.5h
- Writing tests: 1.5h
- Debugging: 0.5h
```

### Best Practices

1. **Be conservative** - underestimate rather than overestimate
2. **Consider your experience** - familiar vs. unfamiliar code
3. **Include research time** - Stack Overflow, docs, asking colleagues
4. **Account for context switching** - interruptions, meetings

---

## Actual Time (User Input)

### Definition

The real time spent completing the task **with AI assistance**.

### What to Include

- Time spent prompting the AI
- Time reviewing AI-generated code
- Time testing and debugging
- Time for documentation
- Waiting time for AI responses (minimal but included)

### Example Breakdown

```markdown
### Actual Time (with AI): 2.5 hours
- AI context gathering: 0.5h
- Guided implementation: 1.0h
- AI-assisted testing: 0.5h
- AI-assisted debugging: 0.5h
```

### Measurement Methods

1. **Timer:** Start a timer when you begin the session
2. **Git commits:** Use commit timestamps as reference points
3. **Claude `/cost` command:** Provides wall duration

---

## Time Saved (Calculated)

### Formula

```
Time Saved = Manual Estimate - Actual Time
Time Saved Percentage = (Time Saved / Manual Estimate) × 100
```

### Example

```
Manual Estimate: 6.0 hours
Actual Time: 2.5 hours

Time Saved = 6.0 - 2.5 = 3.5 hours
Percentage = (3.5 / 6.0) × 100 = 58%
```

### Template Output

```markdown
### Results
- **Time Saved:** 3.5 hours (58% faster)
```

---

## Efficiency Multiplier (Calculated)

### Formula

```
Efficiency Multiplier = Manual Estimate / Actual Time
```

### Interpretation

| Multiplier | Meaning |
|------------|---------|
| 1.0x | No improvement |
| 1.5x | 50% faster |
| 2.0x | Twice as fast |
| 2.5x | 2.5 times faster |
| 3.0x+ | Exceptional efficiency |

### Example

```
Manual Estimate: 6.0 hours
Actual Time: 2.5 hours

Efficiency = 6.0 / 2.5 = 2.4x
```

### Typical Ranges by Task Type

| Task Type | Typical Multiplier |
|-----------|-------------------|
| Bug fixes (familiar code) | 1.5-2.0x |
| Bug fixes (unfamiliar code) | 2.0-3.0x |
| New features | 2.0-2.5x |
| Refactoring | 1.5-2.0x |
| Test writing | 2.0-3.0x |
| Documentation | 3.0-5.0x |

---

## API Duration vs Wall Duration

### Definitions

| Metric | Description |
|--------|-------------|
| **API Duration** | Time spent waiting for AI model responses |
| **Wall Duration** | Total real-world time elapsed |

### Source

These come from Claude Code's `/cost` command:

```
Total duration (API): 2m 34s
Total duration (wall): 15m 42s
```

### Interpretation

- **API Duration:** Pure AI processing time
- **Wall Duration:** Includes your thinking, typing, reviewing code
- **Gap:** The difference represents your active work time

### Example Analysis

```
API Duration: 2m 34s
Wall Duration: 15m 42s
Your Active Time: 15:42 - 2:34 = 13m 8s

AI was processing: 16% of session
You were working: 84% of session
```

---

## Commit Frequency (Calculated)

### Formula

```
Commit Frequency = Total Commits / Time Window (hours)
```

**Source:** `scripts/core/extract-session-data.sh:349`

```bash
"commitFrequency": "$(echo "scale=2; $TOTAL_COMMITS / ($TIME_WINDOW + 0.01)" | bc) commits/hour"
```

### Example

```
Total Commits: 12
Time Window: 8 hours

Frequency = 12 / 8 = 1.5 commits/hour
```

### Interpretation

| Frequency | Meaning |
|-----------|---------|
| <0.5/hour | Long-form development |
| 0.5-1.0/hour | Normal pace |
| 1.0-2.0/hour | Rapid iteration |
| >2.0/hour | Very granular commits |

---

## Estimated Interactions (Calculated)

### Formula

**Source:** `scripts/core/extract-session-data.sh:279-284`

```bash
# Heuristic calculation
ESTIMATED_INTERACTIONS=$((TOTAL_COMMITS + (TOTAL_FILES / 3) + 5))
```

### Breakdown

| Component | Rationale |
|-----------|-----------|
| `TOTAL_COMMITS` | Each commit = at least one interaction |
| `TOTAL_FILES / 3` | Multi-file changes approximated as distinct interactions |
| `+5` | Fixed overhead for setup, init, non-commit interactions |

### Example

```
Total Commits: 8
Total Files Changed: 15

Estimated Interactions = 8 + (15 / 3) + 5
                       = 8 + 5 + 5
                       = 18 interactions
```

---

## ROI Time Calculation

### Formula

```
Time Value = Time Saved × Hourly Rate
ROI = (Time Value - AI Tool Cost) / AI Tool Cost × 100
```

### Example

```
Time Saved: 40 hours/month
Hourly Rate: $75
AI Tool Cost: $20/month

Time Value = 40 × $75 = $3,000
ROI = ($3,000 - $20) / $20 × 100 = 14,900%
```

---

## Summary Table

| Metric | Type | Formula/Source |
|--------|------|----------------|
| Session Duration | Auto | `Last Commit - First Commit` |
| Time Window | Config | CLI parameter (default: 24h) |
| Manual Estimate | Manual | User breakdown by phase |
| Actual Time | Manual | Timer or wall duration |
| Time Saved | Calc | `Manual - Actual` |
| Efficiency | Calc | `Manual / Actual` |
| API Duration | Auto | `/cost` command |
| Wall Duration | Auto | `/cost` command |
| Commit Frequency | Calc | `Commits / Hours` |
| Est. Interactions | Calc | `Commits + Files/3 + 5` |

---

## Quick Reference Commands

```bash
# Extract session data with time metrics
ai-use-case extract-session . 8 json

# Get session statistics in Claude Code
/cost

# View git activity over time
git log --since="8 hours ago" --oneline

# Calculate session span from git
git log --since="8 hours ago" --reverse --format='%ai' | head -1
git log --since="8 hours ago" --format='%ai' | head -1
```

---

## See Also

- [AI_SESSION_STATISTICS_GUIDE.md](./AI_SESSION_STATISTICS_GUIDE.md) - Complete statistics guide
- [TEMPLATE.md](./TEMPLATE.md) - Documentation template with time fields
- [EXTRACT-SESSION-REFERENCE.md](./EXTRACT-SESSION-REFERENCE.md) - Session extraction details
