#!/bin/bash
# AI Use Case CLI - Tracing Utilities for Shell Scripts
# Provides tracing capabilities for bash scripts using Python tracer

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRACING_PY="$SCRIPT_DIR/tracing.py"

# Check if Python is available and tracing module works
TRACING_AVAILABLE=false
if command -v python3 &> /dev/null && [ -f "$TRACING_PY" ]; then
    if python3 -c "import sys; sys.path.insert(0, '$SCRIPT_DIR'); from tracing import is_tracing_enabled; print('OK')" 2>/dev/null | grep -q "OK"; then
        TRACING_AVAILABLE=true
    fi
fi

# Function to check if tracing is enabled
is_tracing_enabled() {
    if [ "$TRACING_AVAILABLE" = true ]; then
        python3 -c "
import sys
sys.path.insert(0, '$SCRIPT_DIR')
from tracing import is_tracing_enabled
print('true' if is_tracing_enabled() else 'false')
" 2>/dev/null | grep -q "true"
    else
        return 1
    fi
}

# Function to start tracing a command
trace_command_start() {
    local command="$1"
    local args="${2:-}"
    
    if [ "$TRACING_AVAILABLE" = true ] && is_tracing_enabled; then
        export TRACE_COMMAND="$command"
        export TRACE_START_TIME="$(date +%s.%N)"
        export TRACE_ARGS="$args"
        
        # Create a unique trace ID for this command execution
        export TRACE_ID="$(date +%s)_$$_$(printf '%s' "$command" | sed 's/[^a-zA-Z0-9]/_/g')"
        
        python3 -c "
import sys
import os
sys.path.insert(0, '$SCRIPT_DIR')
from tracing import get_tracing_manager, add_span_event
manager = get_tracing_manager()
manager.add_span_event('command_start', {
    'command': os.getenv('TRACE_COMMAND', ''),
    'args': os.getenv('TRACE_ARGS', ''),
    'trace_id': os.getenv('TRACE_ID', ''),
    'pid': os.getpid(),
    'working_dir': os.getcwd()
})
" 2>/dev/null || true
    fi
}

# Function to end tracing a command
trace_command_end() {
    local exit_code="${1:-0}"
    
    if [ "$TRACING_AVAILABLE" = true ] && is_tracing_enabled && [ -n "${TRACE_COMMAND:-}" ]; then
        local end_time="$(date +%s.%N)"
        local duration=""
        
        if [ -n "${TRACE_START_TIME:-}" ]; then
            duration="$(echo "$end_time - $TRACE_START_TIME" | bc 2>/dev/null || echo "0")"
        fi
        
        python3 -c "
import sys
import os
sys.path.insert(0, '$SCRIPT_DIR')
from tracing import get_tracing_manager, add_span_event
manager = get_tracing_manager()
manager.add_span_event('command_end', {
    'command': os.getenv('TRACE_COMMAND', ''),
    'exit_code': $exit_code,
    'duration_seconds': float('${duration:-0}'),
    'trace_id': os.getenv('TRACE_ID', ''),
    'status': 'success' if $exit_code == 0 else 'error'
})
if $exit_code != 0:
    manager.record_error(os.getenv('TRACE_COMMAND', ''), 'exit_code_$exit_code')
" 2>/dev/null || true
        
        # Clean up environment variables
        unset TRACE_COMMAND TRACE_START_TIME TRACE_ARGS TRACE_ID
    fi
}

# Function to record an operation
trace_operation() {
    local operation="$1"
    shift
    local attributes=""
    
    # Parse key=value attributes
    while [[ $# -gt 0 ]]; do
        if [[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]*=.* ]]; then
            if [ -n "$attributes" ]; then
                attributes="${attributes},"
            fi
            local key="${1%%=*}"
            local value="${1#*=}"
            attributes="${attributes}\"$key\":\"$value\""
        fi
        shift
    done
    
    if [ "$TRACING_AVAILABLE" = true ] && is_tracing_enabled; then
        python3 -c "
import sys
import json
sys.path.insert(0, '$SCRIPT_DIR')
from tracing import get_tracing_manager, add_span_event
manager = get_tracing_manager()
attrs = {}
if '$attributes':
    try:
        attrs = json.loads('{$attributes}')
    except:
        pass
attrs['operation'] = '$operation'
manager.add_span_event('operation', attrs)
manager.record_operation_start('$operation')
" 2>/dev/null || true
    fi
}

# Function to record file operations
trace_file_operation() {
    local operation_type="$1"
    local file_path="${2:-}"
    
    if [ "$TRACING_AVAILABLE" = true ] && is_tracing_enabled; then
        python3 -c "
import sys
sys.path.insert(0, '$SCRIPT_DIR')
from tracing import record_file_operation
record_file_operation('$operation_type', '$file_path')
" 2>/dev/null || true
    fi
}

# Function to record hub sync operations
trace_hub_sync() {
    local sync_type="$1"
    local files_count="${2:-0}"
    
    if [ "$TRACING_AVAILABLE" = true ] && is_tracing_enabled; then
        python3 -c "
import sys
sys.path.insert(0, '$SCRIPT_DIR')
from tracing import record_hub_sync
record_hub_sync('$sync_type', $files_count)
" 2>/dev/null || true
    fi
}

# Function to add a span event with attributes
trace_event() {
    local event_name="$1"
    shift
    local attributes=""
    
    # Parse key=value attributes
    while [[ $# -gt 0 ]]; do
        if [[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]*=.* ]]; then
            if [ -n "$attributes" ]; then
                attributes="${attributes},"
            fi
            local key="${1%%=*}"
            local value="${1#*=}"
            attributes="${attributes}\"$key\":\"$value\""
        fi
        shift
    done
    
    if [ "$TRACING_AVAILABLE" = true ] && is_tracing_enabled; then
        python3 -c "
import sys
import json
sys.path.insert(0, '$SCRIPT_DIR')
from tracing import add_span_event
attrs = {}
if '$attributes':
    try:
        attrs = json.loads('{$attributes}')
    except:
        pass
add_span_event('$event_name', attrs)
" 2>/dev/null || true
    fi
}

# Function to set a span attribute
trace_attribute() {
    local key="$1"
    local value="$2"
    
    if [ "$TRACING_AVAILABLE" = true ] && is_tracing_enabled; then
        python3 -c "
import sys
sys.path.insert(0, '$SCRIPT_DIR')
from tracing import set_span_attribute
set_span_attribute('$key', '$value')
" 2>/dev/null || true
    fi
}

# Function to show tracing status
trace_status() {
    if [ "$TRACING_AVAILABLE" = true ]; then
        echo "Tracing module: Available"
        if is_tracing_enabled; then
            echo "Tracing status: Enabled"
            python3 "$TRACING_PY" status 2>/dev/null || true
        else
            echo "Tracing status: Disabled"
        fi
    else
        echo "Tracing module: Not available"
        if ! command -v python3 &> /dev/null; then
            echo "Reason: Python3 not found"
        elif [ ! -f "$TRACING_PY" ]; then
            echo "Reason: Tracing module not found at $TRACING_PY"
        else
            echo "Reason: Import error (missing dependencies?)"
            echo "Install with: pip install opentelemetry-api opentelemetry-sdk opentelemetry-exporter-otlp opentelemetry-instrumentation-subprocess"
        fi
    fi
}

# Wrapper function for running commands with automatic tracing
trace_run() {
    local command_name="$1"
    shift
    
    trace_command_start "$command_name" "$*"
    local exit_code=0
    
    # Execute the command, preserving exit code
    "$@" || exit_code=$?
    
    trace_command_end "$exit_code"
    return $exit_code
}

# Function to enable tracing for the current script
enable_script_tracing() {
    local script_name="${1:-$(basename "${BASH_SOURCE[1]}")}"
    
    if [ "$TRACING_AVAILABLE" = true ] && is_tracing_enabled; then
        # Setup exit trap to record script completion
        trap 'trace_command_end $?' EXIT
        
        # Start tracing the script
        trace_command_start "$script_name" "$*"
        
        # Add some context about the script
        trace_attribute "script.name" "$script_name"
        trace_attribute "script.pid" "$$"
        trace_attribute "script.pwd" "$(pwd)"
        trace_attribute "script.user" "$(whoami)"
        
        if [ -n "${BASH_VERSION:-}" ]; then
            trace_attribute "shell.version" "$BASH_VERSION"
        fi
        
        return 0
    else
        return 1
    fi
}

# Function to install tracing dependencies
install_tracing_deps() {
    echo "Installing OpenTelemetry dependencies..."
    
    if command -v pip3 &> /dev/null; then
        pip3 install --user opentelemetry-api opentelemetry-sdk opentelemetry-exporter-otlp opentelemetry-instrumentation-subprocess
    elif command -v pip &> /dev/null; then
        pip install --user opentelemetry-api opentelemetry-sdk opentelemetry-exporter-otlp opentelemetry-instrumentation-subprocess
    else
        echo "Error: pip not found. Please install pip and try again."
        return 1
    fi
    
    echo "Dependencies installed. You may need to restart your shell."
}

# Export functions for use in other scripts
export -f is_tracing_enabled trace_command_start trace_command_end trace_operation
export -f trace_file_operation trace_hub_sync trace_event trace_attribute
export -f trace_status trace_run enable_script_tracing

# If script is run directly, provide CLI interface
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-status}" in
        status)
            trace_status
            ;;
        install-deps)
            install_tracing_deps
            ;;
        test)
            echo "Testing tracing functionality..."
            trace_command_start "test" "$*"
            trace_event "test_event" "type=functional" "status=running"
            trace_operation "test_operation" "component=shell"
            trace_file_operation "test" "/tmp/test_file"
            sleep 1
            trace_command_end 0
            echo "Test completed."
            ;;
        *)
            cat << EOF
Usage: $0 [command]

Commands:
  status       Show tracing status and configuration
  install-deps Install required Python dependencies  
  test         Run a test trace to verify functionality

Environment Variables:
  AI_USECASE_TRACING_ENABLED=true|false
  AI_USECASE_TRACING_ENDPOINT=http://localhost:4318
  AI_USECASE_TRACING_SAMPLING=1.0

Source this file in your bash scripts to enable tracing:
  source $0

Available functions:
  enable_script_tracing [script_name] [args...]  - Enable tracing for current script
  trace_run command [args...]                   - Run command with automatic tracing
  trace_command_start command [args]            - Start tracing a command
  trace_command_end [exit_code]                 - End tracing a command  
  trace_operation operation [key=value...]      - Record an operation
  trace_event event_name [key=value...]         - Add span event
  trace_attribute key value                     - Set span attribute
  trace_file_operation type [file_path]         - Record file operation
  trace_hub_sync type [files_count]            - Record hub sync
  is_tracing_enabled                           - Check if tracing is enabled
EOF
            ;;
    esac
fi