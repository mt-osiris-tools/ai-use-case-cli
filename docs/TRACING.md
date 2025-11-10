# AI Use Case CLI - Tracing Guide

## Overview

The AI Use Case CLI includes comprehensive tracing capabilities powered by OpenTelemetry to monitor command execution, performance, and usage patterns. This helps users understand how the CLI is performing and diagnose issues.

## Features

- **Distributed Tracing**: Full request/operation tracing with spans and parent-child relationships
- **Metrics Collection**: Command execution times, success/failure rates, and resource usage
- **Error Tracking**: Automatic error capture with stack traces and context
- **Configuration Management**: Flexible configuration via files and environment variables
- **AI Toolkit Integration**: Direct integration with VS Code AI Toolkit's tracing viewer
- **Zero Dependencies**: Graceful degradation when OpenTelemetry is not available

## Quick Start

### 1. Install Dependencies

```bash
# Install OpenTelemetry dependencies
ai-use-case tracing install-deps
```

### 2. Configure Tracing

```bash
# Interactive configuration
ai-use-case tracing configure

# Or enable with defaults
ai-use-case tracing enable
```

### 3. View Traces

Open the AI Toolkit tracing viewer in VS Code:

- Run any AI Use Case CLI command
- Open VS Code with AI Toolkit extension
- Go to AI Toolkit > Tracing to view traces

### 4. Check Status

```bash
# Show tracing status and configuration
ai-use-case tracing status

# Test tracing functionality
ai-use-case tracing test
```

## Configuration

### Configuration File

Location: `~/.config/ai-use-case-cli/tracing.json`

```json
{
  "enabled": true,
  "endpoint": "http://localhost:4318",
  "sampling_ratio": 1.0,
  "export_timeout": 30
}
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `AI_USECASE_TRACING_ENABLED` | `false` | Enable/disable tracing (opt-in) |
| `AI_USECASE_TRACING_ENDPOINT` | `http://localhost:4318` | OTLP HTTP endpoint |
| `AI_USECASE_TRACING_SAMPLING` | `1.0` | Sampling ratio (0.0-1.0) |
| `AI_USECASE_TRACING_TIMEOUT` | `30` | Export timeout in seconds |

Environment variables take precedence over configuration file settings.

### Configuration Commands

```bash
# Show current configuration
ai-use-case tracing show

# Interactive setup
ai-use-case tracing configure

# Enable/disable tracing
ai-use-case tracing enable
ai-use-case tracing disable

# Set individual values
ai-use-case tracing set sampling_ratio 0.5
ai-use-case tracing set endpoint http://custom:4318
```

## Collected Metrics

### Command Metrics

- **Command Execution Count**: Total commands executed by type
- **Command Duration**: Time taken for each command execution
- **Command Success/Failure Rates**: Success and error rates by command
- **Command Arguments**: Arguments passed to commands (for analysis)

### Operation Metrics

- **File Operations**: Create, update, delete operations on use case files
- **Hub Sync Operations**: Sync statistics (files synced, new, updated)
- **Search Operations**: Search queries and result counts
- **Symlink Operations**: Symlink creation and management

### Error Metrics

- **Error Counts**: Total errors by component and type
- **Error Types**: Classification of errors (script not found, permission, etc.)
- **Recovery Actions**: Successful error recovery operations

### Performance Metrics

- **Execution Time Distribution**: Percentiles and histograms of command execution times
- **Resource Usage**: Memory and disk usage patterns
- **Concurrency**: Concurrent operation tracking

## Trace Structure

### Span Hierarchy

```text
ai-use-case.sync
├── ensure_hub_exists
├── process_use_case_directories
├── create_project_directory
└── sync_complete
    ├── file_sync (new/update operations)
    ├── symlink_create (by-date and by-topic)
    └── hub_sync_complete
```

### Span Attributes

Standard attributes added to all spans:

- `ai.usecase.command`: Command being executed
- `ai.usecase.cli_version`: CLI version
- `ai.usecase.working_dir`: Working directory
- `ai.usecase.hub_dir`: Hub directory path
- `ai.usecase.args`: Command arguments

Operation-specific attributes:

- `ai.usecase.operation`: Operation type
- `ai.usecase.project`: Project name
- `ai.usecase.file`: File being processed
- `ai.usecase.error_type`: Error classification

## Integration with AI Toolkit

### Prerequisites

1. Install VS Code AI Toolkit extension
2. Ensure AI Toolkit is running with tracing enabled
3. Default endpoint `http://localhost:4318` should be accessible

### Viewing Traces

1. Execute CLI commands with tracing enabled
2. Open VS Code
3. Open AI Toolkit panel
4. Navigate to Tracing section
5. View real-time traces and metrics

### Custom Dashboards

AI Toolkit provides built-in dashboards for:

- Command execution overview
- Performance trends
- Error analysis
- Usage patterns

## Troubleshooting

### Tracing Not Working

1. Check if dependencies are installed:

   ```bash
   ai-use-case tracing status
   ```

2. Verify AI Toolkit is running:

   ```bash
   curl -s http://localhost:4318/v1/traces
   ```

3. Install dependencies if missing:

   ```bash
   ai-use-case tracing install-deps
   ```

4. Check configuration:

   ```bash
   ai-use-case tracing show
   ```

### Performance Impact

- Tracing adds minimal overhead (< 5ms per operation)
- Sampling can be reduced for high-volume usage
- Tracing can be disabled for production environments
- Graceful degradation when dependencies are missing

### Common Issues

**Import Error**: OpenTelemetry not installed

```bash
ai-use-case tracing install-deps
```

**Connection Refused**: AI Toolkit not running

- Start VS Code with AI Toolkit extension
- Check endpoint configuration

**No Traces Visible**: Sampling set to 0 or tracing disabled

```bash
ai-use-case tracing enable
ai-use-case tracing set sampling_ratio 1.0
```

## Advanced Configuration

### Custom Endpoints

For remote or custom OTLP endpoints:

```bash
# Set custom endpoint
ai-use-case tracing set endpoint https://my-otel-collector:4318

# Set custom timeout
ai-use-case tracing set export_timeout 60
```

### Sampling Strategies

- `1.0`: Trace all operations (default)
- `0.1`: Trace 10% of operations
- `0.0`: Disable tracing

```bash
# Set sampling for high-volume environments
ai-use-case tracing set sampling_ratio 0.1
```

### Environment-Specific Configuration

Development:

```bash
export AI_USECASE_TRACING_ENABLED=true
export AI_USECASE_TRACING_SAMPLING=1.0
```

Production:

```bash
export AI_USECASE_TRACING_ENABLED=true
export AI_USECASE_TRACING_SAMPLING=0.01
export AI_USECASE_TRACING_ENDPOINT=https://production-otlp:4318
```

## API Reference

### Shell Functions

When sourcing `scripts/utils/tracing.sh`:

```bash
# Check if tracing is enabled
if is_tracing_enabled; then
    echo "Tracing is active"
fi

# Start/end command tracing
trace_command_start "my_command" "arg1 arg2"
# ... do work ...
trace_command_end $?

# Record operations
trace_operation "database_query" "table=users" "action=select"

# Record events
trace_event "cache_hit" "key=user_123" "ttl=3600"

# Set attributes
trace_attribute "user.id" "12345"

# Record file operations
trace_file_operation "create" "/path/to/file.md"

# Record hub sync
trace_hub_sync "incremental" 5
```

### Python API

When using `scripts/utils/tracing.py`:

```python
from tracing import trace_command, trace_operation, add_span_event

# Trace commands
with trace_command("my_command", ["arg1", "arg2"]):
    do_work()

# Trace operations
with trace_operation("data_processing", file_count=10):
    process_files()

# Add events
add_span_event("milestone_reached", {"progress": "50%"})
```

## Best Practices

### When to Use Tracing

- **Development**: Always enable for debugging and optimization
- **Testing**: Enable to verify performance requirements
- **Production**: Use sampling for monitoring without overhead
- **CI/CD**: Enable for build and deployment pipeline monitoring

### Span Organization

- Use descriptive span names with clear hierarchy
- Include relevant context in span attributes
- Keep span durations reasonable (avoid long-running spans)
- Use events for significant milestones within spans

### Performance Considerations

- Use appropriate sampling rates for your environment
- Monitor the overhead in performance-critical paths
- Consider disabling for batch operations if needed
- Use background export to minimize blocking

### Security

- Avoid including sensitive data in span attributes
- Use appropriate network security for remote endpoints
- Consider data retention policies for trace data
- Audit access to tracing dashboards

## Migration and Compatibility

### Version Compatibility

- Tracing requires CLI version 3.5.0+
- Compatible with OpenTelemetry 1.20.0+
- Works with AI Toolkit 1.0.0+

### Upgrading

When upgrading the CLI:

1. Dependencies are automatically maintained
2. Configuration files are preserved
3. New metrics may be added automatically
4. Check release notes for breaking changes

### Backward Compatibility

- Scripts work without tracing dependencies (graceful degradation)
- Existing configurations are preserved
- Environment variables maintain precedence
- No changes required to existing workflows

## Support and Feedback

### Getting Help

- Check troubleshooting section above
- Use `ai-use-case tracing status` for diagnostic information
- Review logs in `~/.config/ai-use-case-cli/`

### Feature Requests

Tracing capabilities can be extended. Common requests:

- Custom metrics collection
- Integration with other monitoring systems
- Advanced sampling strategies
- Real-time alerting

### Contributing

To contribute to tracing features:

1. Follow OpenTelemetry best practices
2. Maintain backward compatibility
3. Add appropriate documentation
4. Include tests for new functionality
