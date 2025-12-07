# Session Statistics Automation

**Status**: Implemented
**Version**: 3.4.0+
**Date**: 2025-12-07

## Overview

Comprehensive automation of session statistics capture for AI-assisted development sessions, enabling accurate tracking of costs, tokens, time, and code changes with minimal manual effort.

## Features Implemented

### 1. SessionEnd Hook

**File**: `.claude/hooks/SessionEnd`

Automatically captures session metadata when Claude Code sessions end.

**Captures:**
- Session end timestamp
- Repository and branch information
- Recent commits (last 2 hours)
- Uncommitted changes
- Instructions to run `/cost` command

**Output Location**: `.usecase/session-stats/YYYY-MM-DD-HHMMSS.txt`

**Setup**: Hook is automatically created during `ai-use-case --init`

### 2. Template Updates

**Files Updated:**
- `docs/TEMPLATE.md` - Implementation session template
- `docs/TEMPLATE-RESEARCH.md` - Research session template

**New Section Added**: "📊 Session Statistics (/cost Command)"

**Includes:**
- Instructions to run `/cost`
- Code block for pasting output
- When to capture statistics
- How to use the data in documentation

### 3. Documentation Workflow Integration

**File**: `.ai-tools/commands/use-case/document-session.md`

**New Step Added**: "Step 6.5: Capture Session Statistics"

**Features:**
- Instructions for running `/cost` command
- Option to use auto-saved statistics from SessionEnd hook
- Guidance on populating documentation with statistics
- Graceful fallback if statistics unavailable

### 4. OpenTelemetry Configuration

**Files Created:**
- `docs/OPENTELEMETRY-SETUP.md` - Comprehensive setup guide
- `.claude/otel-config.sh` - Configuration script

**Capabilities:**
- Console output for development/testing
- File export for permanent records
- OTLP endpoint for enterprise monitoring
- Detailed metrics and events tracking

**Metrics Tracked:**
- Token usage (input/output/cache)
- Costs by model
- Code changes (lines added/removed)
- Session duration
- Tool usage patterns

## Usage

### Quick Start

1. **Run `/cost` during or after your Claude Code session:**
   ```
   /cost
   ```

2. **SessionEnd hook automatically runs** when session ends:
   - Stats saved to `.usecase/session-stats/`
   - No manual action required

3. **Document your session:**
   ```
   /use-case:document-session
   ```
   - Select the session to document
   - Paste `/cost` output when prompted
   - Statistics automatically populate documentation

### Advanced: Enable OpenTelemetry

```bash
# Source the configuration
source .claude/otel-config.sh && claude

# Work as usual with automatic telemetry collection
```

**Benefits:**
- Detailed metrics exported continuously
- Historical analysis of all sessions
- Cost tracking across projects
- Team-wide monitoring (with OTLP endpoint)

## Documentation

- **User Guide**: [AI_SESSION_STATISTICS_GUIDE.md](../../AI_SESSION_STATISTICS_GUIDE.md)
- **OpenTelemetry Setup**: [OPENTELEMETRY-SETUP.md](../../OPENTELEMETRY-SETUP.md)
- **Template Example**: [TEMPLATE.md](../../TEMPLATE.md)

## Benefits

### Accuracy
- Real data from `/cost` command, not estimates
- Automatic capture eliminates manual errors
- Consistent tracking across sessions

### Efficiency
- SessionEnd hook saves data automatically
- No interruption to workflow
- Documentation generation includes statistics by default

### Insights
- Token usage trends over time
- Cost tracking per project
- Time savings quantification
- ROI calculation support

### Enterprise Ready
- OpenTelemetry for centralized monitoring
- Multiple export formats
- Dashboards and alerts
- Compliance and audit trails

## Implementation Details

### SessionEnd Hook

**Trigger**: Runs when Claude Code session ends (automatically)

**Process:**
1. Detects repository root
2. Creates `.usecase/session-stats/` if needed
3. Generates timestamp
4. Captures git activity
5. Writes formatted report
6. Returns success

**No user interaction required.**

### /cost Integration

**Command**: Built into Claude Code (no installation needed)

**Output Example:**
```
Total cost: $0.45
Total duration (API): 2m 34s
Total duration (wall): 15m 42s
Total code changes: +487 -92
```

**Integration Points:**
- Documentation templates (new section)
- Workflow prompts (Step 6.5)
- Auto-saved statistics (SessionEnd hook references it)

### OpenTelemetry

**Configuration Options:**

1. **Console** (development):
   ```bash
   export OTEL_METRICS_EXPORTER=console
   ```

2. **File** (persistent):
   ```bash
   export OTEL_METRICS_EXPORTER=file
   export OTEL_METRIC_EXPORT_FILE=~/.claude/metrics/session.jsonl
   ```

3. **OTLP** (enterprise):
   ```bash
   export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318
   ```

**Metrics Available:**
- `claude_code.token.usage`
- `claude_code.cost.usage`
- `claude_code.lines_of_code.count`
- `claude_code.session.count`
- `claude_code.active_time.total`
- And more...

## Testing

### Test SessionEnd Hook

```bash
# Run hook manually
./.claude/hooks/SessionEnd

# Check output
cat .usecase/session-stats/$(ls -t .usecase/session-stats/ | head -1)
```

**Expected Output:**
- Session metadata
- Recent commits
- Instructions for `/cost`

### Test Documentation Workflow

```bash
# In Claude Code
/use-case:document-session

# Follow prompts
# Paste /cost output when requested
```

**Expected Result:**
- Documentation generated with statistics section populated

### Test OpenTelemetry

```bash
# Enable console output
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=console

# Run Claude Code
claude

# Verify metrics printed to console
```

## Migration Guide

### From Manual Statistics

**Before:**
- Manually estimate token usage
- Guess costs based on rates
- Track time with external tools
- Copy/paste from various sources

**After:**
- Run `/cost` for accurate data
- SessionEnd hook captures automatically
- Paste into documentation
- OpenTelemetry for historical tracking

**Action Required:**
- None! New projects get hooks automatically
- Existing projects: Run `ai-use-case --init` to add hooks

### From Estimations

**Old Workflow:**
```markdown
Token Usage: ~50,000 (estimated)
Cost: ~$0.30 (estimated)
```

**New Workflow:**
```markdown
Run /cost command:
Total cost: $0.28
Total tokens: 48,234
```

**More accurate, less effort!**

## Future Enhancements

Potential additions (not yet implemented):

- [ ] Automatic `/cost` execution (if Claude Code API allows)
- [ ] Dashboard for viewing all session statistics
- [ ] Cost alerts when exceeding thresholds
- [ ] Automatic ROI calculation reports
- [ ] Integration with time tracking tools
- [ ] Team-wide cost allocation

## Support

**Questions?**
- See [AI_SESSION_STATISTICS_GUIDE.md](../../AI_SESSION_STATISTICS_GUIDE.md)
- See [OPENTELEMETRY-SETUP.md](../../OPENTELEMETRY-SETUP.md)
- Open an issue on GitHub

**Contributing:**
- Improvements welcome!
- See [CONTRIBUTING.md](../../../CONTRIBUTING.md)

---

**Feature Team**: AI Use Case CLI
**Maintainer**: Mt Osiris Tools
**License**: Same as project (ISC)
