# OpenTelemetry Setup for Claude Code Session Tracking

This guide explains how to set up OpenTelemetry (OTel) to collect detailed metrics and events from your Claude Code sessions for enterprise-grade tracking and analysis.

## Overview

OpenTelemetry provides comprehensive telemetry data collection for Claude Code, including:

- **Metrics**: Token usage, costs, code changes, timing data
- **Events**: API requests, tool executions, user prompts, errors
- **Spans**: Detailed timing breakdown of operations

This data can be exported to various backends for analysis, visualization, and cost tracking.

## Quick Start

### Option 1: Console Output (Testing/Development)

The simplest setup for viewing metrics in your terminal:

```bash
# Enable telemetry
export CLAUDE_CODE_ENABLE_TELEMETRY=1

# Export metrics to console
export OTEL_METRICS_EXPORTER=console

# Set export interval (milliseconds)
export OTEL_METRIC_EXPORT_INTERVAL=1000

# Optional: Enable event logging to console
export OTEL_LOGS_EXPORTER=console

# Run Claude Code
claude
```

**What you'll see:**
- Metrics printed to console every second
- Real-time visibility into token usage, costs, and activity
- Useful for understanding what's being tracked

### Option 2: File Export (Permanent Records)

Export metrics to files for later analysis:

```bash
# Enable telemetry
export CLAUDE_CODE_ENABLE_TELEMETRY=1

# Export metrics to file
export OTEL_METRICS_EXPORTER=file
export OTEL_METRIC_EXPORT_FILE=~/.claude/metrics/$(date +%Y-%m-%d).jsonl

# Export logs to file
export OTEL_LOGS_EXPORTER=file
export OTEL_LOGS_EXPORT_FILE=~/.claude/logs/$(date +%Y-%m-%d).jsonl

# Create directories
mkdir -p ~/.claude/metrics ~/.claude/logs

# Run Claude Code
claude
```

**Benefits:**
- Persistent records of all sessions
- Can be analyzed later with scripts or tools
- Organized by date for easy archival

### Option 3: OTLP Endpoint (Production/Enterprise)

Send data to an OpenTelemetry collector or observability platform:

```bash
# Enable telemetry
export CLAUDE_CODE_ENABLE_TELEMETRY=1

# Configure OTLP endpoint (adjust to your collector)
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318

# Optional: Add service metadata
export OTEL_SERVICE_NAME=claude-code
export OTEL_RESOURCE_ATTRIBUTES="environment=production,team=engineering"

# Run Claude Code
claude
```

**Supports:**
- Jaeger, Grafana, Honeycomb, Datadog, New Relic, etc.
- Centralized monitoring across teams
- Custom dashboards and alerts

## Available Metrics

Claude Code tracks the following metrics:

### Session Metrics
- `claude_code.session.count` - Total sessions started (counter)
- `claude_code.active_time.total` - Active time in seconds (histogram)

### Token & Cost Metrics
- `claude_code.token.usage` - Tokens used (input/output/cache) (counter)
  - Attributes: `token_type` (input/output/cache_read/cache_creation)
- `claude_code.cost.usage` - Session cost in USD (counter)
  - Attributes: `model` (e.g., claude-sonnet-4.5)

### Code Metrics
- `claude_code.lines_of_code.count` - Lines added/removed (counter)
  - Attributes: `change_type` (added/removed)
- `claude_code.pull_request.count` - PRs created (counter)
- `claude_code.commit.count` - Commits created (counter)

### Tool Metrics
- `claude_code.code_edit_tool.decision` - Code edit accept/reject (counter)
  - Attributes: `decision` (accept/reject)

## Available Events

Claude Code emits events for detailed analysis:

### User Interaction Events
- `claude_code.user_prompt` - When user submits a prompt
  - Attributes: `prompt_length`, `timestamp`

### API Events
- `claude_code.api_request` - Each API call
  - Attributes: `model`, `input_tokens`, `output_tokens`, `cost`, `duration_ms`
- `claude_code.api_error` - API failures
  - Attributes: `error_type`, `error_message`, `model`

### Tool Events
- `claude_code.tool_result` - Tool execution results
  - Attributes: `tool_name`, `success`, `duration_ms`
- `claude_code.tool_decision` - Accept/reject decisions
  - Attributes: `tool_name`, `decision`, `reason`

## Configuration File Approach

For persistent configuration, create a setup script:

**File: `.claude/otel-config.sh`**

```bash
#!/usr/bin/env bash
#
# OpenTelemetry Configuration for Claude Code
# Source this file before running Claude Code sessions
#
# Usage: source .claude/otel-config.sh && claude

# Enable telemetry
export CLAUDE_CODE_ENABLE_TELEMETRY=1

# Choose your export method (uncomment one)

# Option 1: Console output (development/testing)
# export OTEL_METRICS_EXPORTER=console
# export OTEL_LOGS_EXPORTER=console
# export OTEL_METRIC_EXPORT_INTERVAL=1000

# Option 2: File output (permanent records)
export OTEL_METRICS_EXPORTER=file
export OTEL_LOGS_EXPORTER=file

# Create timestamped files for each session
SESSION_DATE=$(date +%Y-%m-%d-%H%M%S)
export OTEL_METRIC_EXPORT_FILE="$HOME/.claude/metrics/${SESSION_DATE}.jsonl"
export OTEL_LOGS_EXPORT_FILE="$HOME/.claude/logs/${SESSION_DATE}.jsonl"

# Create directories if they don't exist
mkdir -p "$HOME/.claude/metrics" "$HOME/.claude/logs"

# Option 3: OTLP endpoint (production/enterprise)
# export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318
# export OTEL_SERVICE_NAME=claude-code
# export OTEL_RESOURCE_ATTRIBUTES="environment=production,team=engineering,user=$USER"

# Export configuration
echo "✅ OpenTelemetry configured for Claude Code"
echo "   Metrics: ${OTEL_METRIC_EXPORT_FILE:-console}"
echo "   Logs: ${OTEL_LOGS_EXPORT_FILE:-console}"
```

**Make it executable:**
```bash
chmod +x .claude/otel-config.sh
```

**Usage:**
```bash
# Source the config before running Claude Code
source .claude/otel-config.sh && claude
```

## Integration with AI Use Case CLI

The OpenTelemetry data complements the ai-use-case CLI tracking:

### Automated Workflow

1. **Session Start**: OTel begins collecting metrics
2. **Session Work**: Metrics accumulated in real-time
3. **Session End**: SessionEnd hook saves summary to `.usecase/session-stats/`
4. **Documentation**: Use `/use-case:document-session` to generate docs with OTel data

### Accessing OTel Data in Documentation

When documenting a session, you can include OTel metrics:

```bash
# View recent metrics file
cat ~/.claude/metrics/$(ls -t ~/.claude/metrics/ | head -1)

# Parse specific metrics (example using jq)
cat ~/.claude/metrics/2025-12-07-*.jsonl | \
  jq -r 'select(.metricName == "claude_code.token.usage") | .value'
```

## Data Analysis Examples

### Calculate Total Cost for a Day

```bash
# Sum all costs from today's metrics
grep -h "claude_code.cost.usage" ~/.claude/metrics/2025-12-07-*.jsonl | \
  jq -s 'map(.value) | add'
```

### Token Usage by Model

```bash
# Group token usage by model
cat ~/.claude/metrics/2025-12-07-*.jsonl | \
  jq -r 'select(.metricName == "claude_code.token.usage") |
         "\(.attributes.model): \(.value) \(.attributes.token_type)"'
```

### Session Duration Analysis

```bash
# Extract active time for all sessions
grep -h "claude_code.active_time.total" ~/.claude/metrics/*.jsonl | \
  jq -s 'map(.value) | add'
```

## Visualization Dashboards

### Grafana Dashboard Example

If using an OTLP endpoint with Grafana:

```promql
# Total cost over time
sum(rate(claude_code_cost_usage_total[5m]))

# Token usage by type
sum by (token_type) (rate(claude_code_token_usage_total[5m]))

# Code changes over time
sum by (change_type) (rate(claude_code_lines_of_code_count_total[5m]))
```

### Custom Analysis Scripts

Create analysis scripts that process OTel data:

**File: `scripts/analyze-otel-data.sh`**

```bash
#!/usr/bin/env bash
# Analyze OpenTelemetry data from Claude Code sessions

METRICS_DIR="${HOME}/.claude/metrics"

echo "=== Claude Code Session Analysis ==="
echo ""

# Total sessions
SESSIONS=$(grep -h "claude_code.session.count" "${METRICS_DIR}"/*.jsonl 2>/dev/null | wc -l)
echo "Total sessions tracked: ${SESSIONS}"

# Total cost
TOTAL_COST=$(grep -h "claude_code.cost.usage" "${METRICS_DIR}"/*.jsonl 2>/dev/null | \
  jq -s 'map(.value) | add' 2>/dev/null || echo "0")
echo "Total cost: \$${TOTAL_COST}"

# Total tokens
TOTAL_TOKENS=$(grep -h "claude_code.token.usage" "${METRICS_DIR}"/*.jsonl 2>/dev/null | \
  jq -s 'map(.value) | add' 2>/dev/null || echo "0")
echo "Total tokens: ${TOTAL_TOKENS}"

# Code changes
LINES_ADDED=$(grep -h "claude_code.lines_of_code.count" "${METRICS_DIR}"/*.jsonl 2>/dev/null | \
  jq -r 'select(.attributes.change_type == "added") | .value' | \
  awk '{s+=$1} END {print s}' || echo "0")
LINES_REMOVED=$(grep -h "claude_code.lines_of_code.count" "${METRICS_DIR}"/*.jsonl 2>/dev/null | \
  jq -r 'select(.attributes.change_type == "removed") | .value' | \
  awk '{s+=$1} END {print s}' || echo "0")

echo "Lines added: ${LINES_ADDED}"
echo "Lines removed: ${LINES_REMOVED}"
echo "Net change: $((LINES_ADDED - LINES_REMOVED))"
```

## Privacy and Security

### What Data is Collected?

OpenTelemetry collects:
- ✅ Token counts, costs, timing data
- ✅ Tool usage patterns
- ✅ Code change statistics
- ✅ Session metadata

OpenTelemetry does **NOT** collect:
- ❌ Actual code content
- ❌ User prompts or AI responses (unless explicitly configured)
- ❌ File contents or names (by default)
- ❌ Personal information

### Data Retention

**Local Files:**
- Stored in `~/.claude/metrics/` and `~/.claude/logs/`
- You control retention by managing these directories
- Recommended: Archive or delete old files regularly

**OTLP Endpoints:**
- Retention depends on your observability platform
- Check your platform's data retention policies
- Consider GDPR/compliance requirements

### Disabling Telemetry

To disable OpenTelemetry:

```bash
# Remove or unset the environment variable
unset CLAUDE_CODE_ENABLE_TELEMETRY

# Or set to 0
export CLAUDE_CODE_ENABLE_TELEMETRY=0
```

Telemetry is **opt-in** and disabled by default.

## Troubleshooting

### Metrics Not Appearing

**Check telemetry is enabled:**
```bash
echo $CLAUDE_CODE_ENABLE_TELEMETRY
# Should output: 1
```

**Check exporter configuration:**
```bash
echo $OTEL_METRICS_EXPORTER
# Should output: console, file, or otlp
```

**Verify file permissions:**
```bash
ls -la ~/.claude/metrics/
# Ensure directory is writable
```

### File Not Being Created

**Check directory exists:**
```bash
mkdir -p ~/.claude/metrics ~/.claude/logs
```

**Check file path is correct:**
```bash
echo $OTEL_METRIC_EXPORT_FILE
# Should show a valid path
```

### OTLP Endpoint Not Reachable

**Test endpoint:**
```bash
curl -v $OTEL_EXPORTER_OTLP_ENDPOINT
# Should connect without errors
```

**Check firewall/network:**
- Ensure port 4318 (HTTP) or 4317 (gRPC) is open
- Verify collector is running

## Next Steps

1. **Start Simple**: Begin with console output to see what's tracked
2. **Archive Data**: Switch to file export for permanent records
3. **Analyze**: Create custom scripts to process OTel data
4. **Integrate**: Connect OTel data with `/use-case:document-session` workflow
5. **Scale Up**: Move to OTLP endpoint for team-wide tracking

## Resources

- **Claude Code Documentation**: [Monitoring Usage](https://code.claude.com/docs/en/monitoring-usage.md)
- **OpenTelemetry Documentation**: [https://opentelemetry.io/docs/](https://opentelemetry.io/docs/)
- **AI Session Statistics Guide**: [AI_SESSION_STATISTICS_GUIDE.md](./AI_SESSION_STATISTICS_GUIDE.md)

## Support

For issues or questions:
- Claude Code: [GitHub Issues](https://github.com/anthropics/claude-code/issues)
- OpenTelemetry: [Community Slack](https://cloud-native.slack.com)

---

**Created**: 2025-12-07
**Last Updated**: 2025-12-07
**Version**: 1.0.0
