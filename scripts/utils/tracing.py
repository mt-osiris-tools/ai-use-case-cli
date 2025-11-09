#!/usr/bin/env python3
"""
AI Use Case CLI - Tracing Utilities
OpenTelemetry-based tracing for monitoring CLI operations, performance, and usage patterns.

This module provides:
- OpenTelemetry tracing setup with OTLP export
- Automatic span creation for CLI commands and operations
- Performance metrics collection
- Error tracking and logging integration
- User-configurable tracing settings
"""

import os
import sys
import json
import time
import subprocess
from typing import Dict, Any, Optional, List
from contextlib import contextmanager
from pathlib import Path

try:
    from opentelemetry import trace, metrics
    from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
    from opentelemetry.exporter.otlp.proto.http.metric_exporter import OTLPMetricExporter
    from opentelemetry.sdk.trace import TracerProvider
    from opentelemetry.sdk.trace.export import BatchSpanProcessor
    from opentelemetry.sdk.metrics import MeterProvider
    from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
    from opentelemetry.sdk.resources import Resource
    from opentelemetry.instrumentation.subprocess import SubprocessInstrumentor
    from opentelemetry.trace.status import Status, StatusCode
    from opentelemetry.semconv.trace import SpanAttributes
    TELEMETRY_AVAILABLE = True
except ImportError:
    TELEMETRY_AVAILABLE = False

class TracingManager:
    """Manages OpenTelemetry tracing setup and operations for the AI Use Case CLI."""
    
    def __init__(self):
        self.tracer = None
        self.meter = None
        self.enabled = False
        self.config = self._load_config()
        self._setup_tracing()
    
    def _load_config(self) -> Dict[str, Any]:
        """Load tracing configuration from config file and environment variables."""
        default_config = {
            'enabled': os.getenv('AI_USECASE_TRACING_ENABLED', 'true').lower() in ('true', '1', 'yes'),
            'endpoint': os.getenv('AI_USECASE_TRACING_ENDPOINT', 'http://localhost:4318'),
            'service_name': 'ai-use-case-cli',
            'service_version': self._get_cli_version(),
            'sampling_ratio': float(os.getenv('AI_USECASE_TRACING_SAMPLING', '1.0')),
            'export_timeout': int(os.getenv('AI_USECASE_TRACING_TIMEOUT', '30')),
        }
        
        # Try to load from config file if it exists
        config_file = Path.home() / '.config' / 'ai-use-case-cli' / 'tracing.json'
        if config_file.exists():
            try:
                with open(config_file) as f:
                    file_config = json.load(f)
                    default_config.update(file_config)
            except (json.JSONDecodeError, OSError) as e:
                print(f"Warning: Could not load tracing config from {config_file}: {e}", file=sys.stderr)
        
        return default_config
    
    def _get_cli_version(self) -> str:
        """Get CLI version from version.sh file."""
        try:
            cli_root = Path(__file__).parent.parent.parent
            version_file = cli_root / 'scripts' / 'utils' / 'version.sh'
            if version_file.exists():
                with open(version_file) as f:
                    content = f.read()
                    for line in content.splitlines():
                        if line.startswith('export CLI_VERSION='):
                            return line.split('=')[1].strip('"')
            return 'unknown'
        except Exception:
            return 'unknown'
    
    def _setup_tracing(self):
        """Initialize OpenTelemetry tracing if available and enabled."""
        if not TELEMETRY_AVAILABLE:
            if self.config.get('enabled', False):
                print("Warning: OpenTelemetry not available. Install with: pip install opentelemetry-api opentelemetry-sdk opentelemetry-exporter-otlp opentelemetry-instrumentation-subprocess", file=sys.stderr)
            return
        
        if not self.config.get('enabled', False):
            return
        
        try:
            # Create resource with service information
            resource = Resource.create({
                "service.name": self.config['service_name'],
                "service.version": self.config['service_version'],
                "deployment.environment": os.getenv('AI_USECASE_ENV', 'development'),
                "host.name": os.uname().nodename,
                "os.name": os.uname().sysname,
                "os.version": os.uname().release,
            })
            
            # Setup tracing
            trace_provider = TracerProvider(resource=resource)
            otlp_exporter = OTLPSpanExporter(
                endpoint=f"{self.config['endpoint']}/v1/traces",
                timeout=self.config['export_timeout']
            )
            span_processor = BatchSpanProcessor(otlp_exporter)
            trace_provider.add_span_processor(span_processor)
            trace.set_tracer_provider(trace_provider)
            self.tracer = trace.get_tracer(__name__)
            
            # Setup metrics
            metric_reader = PeriodicExportingMetricReader(
                OTLPMetricExporter(
                    endpoint=f"{self.config['endpoint']}/v1/metrics",
                    timeout=self.config['export_timeout']
                )
            )
            metrics.set_meter_provider(MeterProvider(resource=resource, metric_readers=[metric_reader]))
            self.meter = metrics.get_meter(__name__)
            
            # Auto-instrument subprocess calls
            SubprocessInstrumentor().instrument()
            
            self.enabled = True
            
            # Create metric instruments
            self._setup_metrics()
            
        except Exception as e:
            print(f"Warning: Could not initialize tracing: {e}", file=sys.stderr)
            self.enabled = False
    
    def _setup_metrics(self):
        """Setup metrics instruments."""
        if not self.meter:
            return
        
        self.command_counter = self.meter.create_counter(
            "ai_usecase_commands_total",
            description="Total number of CLI commands executed",
            unit="1"
        )
        
        self.command_duration = self.meter.create_histogram(
            "ai_usecase_command_duration_seconds",
            description="Duration of CLI command execution",
            unit="s"
        )
        
        self.operation_counter = self.meter.create_counter(
            "ai_usecase_operations_total",
            description="Total number of operations executed",
            unit="1"
        )
        
        self.error_counter = self.meter.create_counter(
            "ai_usecase_errors_total",
            description="Total number of errors encountered",
            unit="1"
        )
        
        self.file_operations_counter = self.meter.create_counter(
            "ai_usecase_file_operations_total",
            description="Total number of file operations",
            unit="1"
        )
        
        self.hub_sync_counter = self.meter.create_counter(
            "ai_usecase_hub_syncs_total",
            description="Total number of hub sync operations",
            unit="1"
        )
    
    @contextmanager
    def trace_command(self, command: str, args: Optional[List[str]] = None):
        """Context manager for tracing CLI commands."""
        if not self.enabled or not self.tracer:
            yield None
            return
        
        start_time = time.time()
        span_name = f"ai-use-case.{command}"
        
        with self.tracer.start_as_current_span(span_name) as span:
            try:
                # Set span attributes
                span.set_attribute(SpanAttributes.CODE_FUNCTION, command)
                span.set_attribute("ai.usecase.command", command)
                span.set_attribute("ai.usecase.cli_version", self.config['service_version'])
                
                if args:
                    span.set_attribute("ai.usecase.args", json.dumps(args))
                    span.set_attribute("ai.usecase.args_count", len(args))
                
                # Add environment context
                if os.getenv('AI_USECASES_DIR'):
                    span.set_attribute("ai.usecase.hub_dir", os.getenv('AI_USECASES_DIR'))
                
                span.set_attribute("ai.usecase.working_dir", os.getcwd())
                
                # Record command start
                self.record_command_start(command, args)
                
                yield span
                
                # Mark as successful
                span.set_status(Status(StatusCode.OK))
                
            except Exception as e:
                # Record error
                span.set_status(Status(StatusCode.ERROR, str(e)))
                span.record_exception(e)
                self.record_error(command, str(e))
                raise
            finally:
                # Record metrics
                duration = time.time() - start_time
                self.record_command_completion(command, duration)
    
    @contextmanager
    def trace_operation(self, operation: str, **attributes):
        """Context manager for tracing internal operations."""
        if not self.enabled or not self.tracer:
            yield None
            return
        
        start_time = time.time()
        span_name = f"ai-use-case.operation.{operation}"
        
        with self.tracer.start_as_current_span(span_name) as span:
            try:
                # Set span attributes
                span.set_attribute("ai.usecase.operation", operation)
                for key, value in attributes.items():
                    if isinstance(value, (str, int, float, bool)):
                        span.set_attribute(f"ai.usecase.{key}", value)
                
                # Record operation start
                self.record_operation_start(operation)
                
                yield span
                
                # Mark as successful
                span.set_status(Status(StatusCode.OK))
                
            except Exception as e:
                # Record error
                span.set_status(Status(StatusCode.ERROR, str(e)))
                span.record_exception(e)
                self.record_error(operation, str(e))
                raise
            finally:
                # Record completion time
                duration = time.time() - start_time
                span.set_attribute("ai.usecase.duration_seconds", duration)
    
    def record_command_start(self, command: str, args: Optional[List[str]] = None):
        """Record the start of a command execution."""
        if self.meter and hasattr(self, 'command_counter'):
            self.command_counter.add(1, {"command": command, "phase": "start"})
    
    def record_command_completion(self, command: str, duration: float):
        """Record successful completion of a command."""
        if self.meter and hasattr(self, 'command_counter') and hasattr(self, 'command_duration'):
            self.command_counter.add(1, {"command": command, "phase": "complete", "status": "success"})
            self.command_duration.record(duration, {"command": command})
    
    def record_operation_start(self, operation: str):
        """Record the start of an operation."""
        if self.meter and hasattr(self, 'operation_counter'):
            self.operation_counter.add(1, {"operation": operation, "phase": "start"})
    
    def record_error(self, component: str, error_message: str):
        """Record an error occurrence."""
        if self.meter and hasattr(self, 'error_counter'):
            self.error_counter.add(1, {"component": component, "error_type": type(error_message).__name__})
    
    def record_file_operation(self, operation_type: str, file_path: str = None):
        """Record file system operations."""
        if self.meter and hasattr(self, 'file_operations_counter'):
            attributes = {"operation": operation_type}
            if file_path:
                attributes["file_type"] = Path(file_path).suffix or "unknown"
            self.file_operations_counter.add(1, attributes)
    
    def record_hub_sync(self, sync_type: str, files_count: int = 0):
        """Record hub synchronization operations."""
        if self.meter and hasattr(self, 'hub_sync_counter'):
            self.hub_sync_counter.add(1, {"sync_type": sync_type, "files_count": str(files_count)})
    
    def add_span_event(self, name: str, attributes: Optional[Dict[str, Any]] = None):
        """Add an event to the current span if tracing is enabled."""
        if not self.enabled:
            return
        
        current_span = trace.get_current_span()
        if current_span and current_span.is_recording():
            current_span.add_event(name, attributes or {})
    
    def set_span_attribute(self, key: str, value: Any):
        """Set an attribute on the current span if tracing is enabled."""
        if not self.enabled:
            return
        
        current_span = trace.get_current_span()
        if current_span and current_span.is_recording():
            current_span.set_attribute(key, value)
    
    def is_enabled(self) -> bool:
        """Check if tracing is enabled."""
        return self.enabled
    
    def get_config(self) -> Dict[str, Any]:
        """Get current tracing configuration."""
        return self.config.copy()

# Global tracing manager instance
_tracing_manager = None

def get_tracing_manager() -> TracingManager:
    """Get the global tracing manager instance."""
    global _tracing_manager
    if _tracing_manager is None:
        _tracing_manager = TracingManager()
    return _tracing_manager

# Convenience functions for common operations
def trace_command(command: str, args: Optional[List[str]] = None):
    """Decorator or context manager for tracing CLI commands."""
    return get_tracing_manager().trace_command(command, args)

def trace_operation(operation: str, **attributes):
    """Context manager for tracing internal operations."""
    return get_tracing_manager().trace_operation(operation, **attributes)

def record_file_operation(operation_type: str, file_path: str = None):
    """Record a file operation."""
    get_tracing_manager().record_file_operation(operation_type, file_path)

def record_hub_sync(sync_type: str, files_count: int = 0):
    """Record a hub sync operation."""
    get_tracing_manager().record_hub_sync(sync_type, files_count)

def add_span_event(name: str, attributes: Optional[Dict[str, Any]] = None):
    """Add an event to the current span."""
    get_tracing_manager().add_span_event(name, attributes)

def set_span_attribute(key: str, value: Any):
    """Set an attribute on the current span."""
    get_tracing_manager().set_span_attribute(key, value)

def is_tracing_enabled() -> bool:
    """Check if tracing is enabled."""
    return get_tracing_manager().is_enabled()

if __name__ == "__main__":
    # CLI interface for tracing management
    import argparse
    
    parser = argparse.ArgumentParser(description="AI Use Case CLI Tracing Manager")
    parser.add_argument("action", choices=["status", "enable", "disable", "config"], 
                       help="Action to perform")
    parser.add_argument("--endpoint", help="OTLP endpoint URL")
    parser.add_argument("--sampling", type=float, help="Sampling ratio (0.0-1.0)")
    
    args = parser.parse_args()
    
    manager = get_tracing_manager()
    
    if args.action == "status":
        print(f"Tracing enabled: {manager.is_enabled()}")
        if manager.is_enabled():
            config = manager.get_config()
            print(f"Endpoint: {config['endpoint']}")
            print(f"Service: {config['service_name']} v{config['service_version']}")
            print(f"Sampling ratio: {config['sampling_ratio']}")
    
    elif args.action == "config":
        config = manager.get_config()
        print(json.dumps(config, indent=2))
    
    else:
        print(f"Use environment variables or config file to {args.action} tracing.")
        print("Environment variables:")
        print("  AI_USECASE_TRACING_ENABLED=true|false")
        print("  AI_USECASE_TRACING_ENDPOINT=http://localhost:4318")
        print("  AI_USECASE_TRACING_SAMPLING=1.0")