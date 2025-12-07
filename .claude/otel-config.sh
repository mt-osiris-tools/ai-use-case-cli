#!/usr/bin/env bash
#
# OpenTelemetry Configuration for Claude Code
# Source this file before running Claude Code sessions to enable telemetry
#
# Usage:
#   source .claude/otel-config.sh && claude
#
# Or add to your shell profile (~/.bashrc, ~/.zshrc):
#   alias claude-tracked='source /path/to/.claude/otel-config.sh && claude'

# Enable telemetry
export CLAUDE_CODE_ENABLE_TELEMETRY=1

# Choose your export method (uncomment the option you prefer)

# ==========================================
# Option 1: Console Output (Development/Testing)
# ==========================================
# Metrics and logs printed to terminal in real-time
# Good for: Testing, understanding what's tracked
#
# export OTEL_METRICS_EXPORTER=console
# export OTEL_LOGS_EXPORTER=console
# export OTEL_METRIC_EXPORT_INTERVAL=1000  # Export every 1 second

# ==========================================
# Option 2: File Output (Permanent Records) - DEFAULT
# ==========================================
# Metrics and logs saved to timestamped files
# Good for: Long-term tracking, analysis, documentation

export OTEL_METRICS_EXPORTER=file
export OTEL_LOGS_EXPORTER=file

# Create timestamped files for each session
SESSION_DATE=$(date +%Y-%m-%d-%H%M%S)
OTEL_DIR="${HOME}/.claude/otel"

export OTEL_METRIC_EXPORT_FILE="${OTEL_DIR}/metrics/${SESSION_DATE}.jsonl"
export OTEL_LOGS_EXPORT_FILE="${OTEL_DIR}/logs/${SESSION_DATE}.jsonl"

# Create directories if they don't exist
mkdir -p "${OTEL_DIR}/metrics" "${OTEL_DIR}/logs"

# ==========================================
# Option 3: OTLP Endpoint (Production/Enterprise)
# ==========================================
# Send data to OpenTelemetry collector or observability platform
# Good for: Team-wide monitoring, dashboards, alerts
#
# Uncomment and configure for your environment:
#
# export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318
# export OTEL_SERVICE_NAME=claude-code
# export OTEL_RESOURCE_ATTRIBUTES="environment=production,team=engineering,user=$USER,project=$(basename $(git rev-parse --show-toplevel 2>/dev/null || echo 'unknown'))"

# ==========================================
# Additional Configuration
# ==========================================

# Export interval (milliseconds) - how often metrics are exported
# Lower = more frequent updates, higher overhead
# Higher = less frequent updates, lower overhead
export OTEL_METRIC_EXPORT_INTERVAL=5000  # 5 seconds

# Batch size - how many events to batch before export
# export OTEL_BLRP_MAX_QUEUE_SIZE=2048

# ==========================================
# Success Message
# ==========================================

echo "✅ OpenTelemetry configured for Claude Code"
echo ""
echo "Configuration:"
echo "  📊 Metrics: ${OTEL_METRICS_EXPORTER}"
echo "  📝 Logs: ${OTEL_LOGS_EXPORTER}"

if [ "${OTEL_METRICS_EXPORTER}" = "file" ]; then
    echo ""
    echo "Files:"
    echo "  📄 Metrics file: ${OTEL_METRIC_EXPORT_FILE}"
    echo "  📄 Logs file: ${OTEL_LOGS_EXPORT_FILE}"
elif [ "${OTEL_METRICS_EXPORTER}" = "otlp" ] || [ -n "${OTEL_EXPORTER_OTLP_ENDPOINT}" ]; then
    echo ""
    echo "Endpoint:"
    echo "  🌐 OTLP: ${OTEL_EXPORTER_OTLP_ENDPOINT}"
    echo "  🏷️  Service: ${OTEL_SERVICE_NAME}"
fi

echo ""
echo "Ready to start Claude Code with telemetry enabled!"
echo ""

# Optional: Create analysis helper alias
alias claude-otel-analyze='cat ${OTEL_DIR}/metrics/*.jsonl | jq -s "group_by(.metricName) | map({metric: .[0].metricName, total: map(.value) | add})"'

# Return success
return 0 2>/dev/null || exit 0
