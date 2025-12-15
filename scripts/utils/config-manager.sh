#!/bin/bash
# Configuration Manager for AI Use Case CLI - Unified Facade
#
# This file provides a unified facade for backward compatibility with the old
# config-manager.sh interface. All implementation has been split into focused
# modules in lib/config/ as part of the layered architecture refactor.
#
# NEW CODE SHOULD SOURCE THE SPECIFIC MODULES DIRECTLY:
#   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   source "$SCRIPT_DIR/../../lib/core/constants.sh"
#   source "$SCRIPT_DIR/../../lib/config/config-core.sh"
#   source "$SCRIPT_DIR/../../lib/config/config-hub.sh"
#   source "$SCRIPT_DIR/../../lib/config/config-features.sh"
#   source "$SCRIPT_DIR/../../lib/config/config-tracing.sh"
#   source "$SCRIPT_DIR/../../lib/config/config-confluence.sh"
#
# This facade exists only for backward compatibility with existing scripts.
#
# Architecture:
#   lib/core/constants.sh        - Shared constants and color codes
#   lib/config/config-core.sh    - Core config I/O (ensure_config_dir, get_config, set_config)
#   lib/config/config-hub.sh     - Hub configuration (mode, path, git URL)
#   lib/config/config-features.sh - Feature flags (install mode, advanced features)
#   lib/config/config-tracing.sh - OpenTelemetry tracing configuration
#   lib/config/config-confluence.sh - Confluence integration configuration

# ============================================================================
# Module Loading
# ============================================================================

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all configuration modules
source "$SCRIPT_DIR/../../lib/core/constants.sh"
source "$SCRIPT_DIR/../../lib/config/config-core.sh"
source "$SCRIPT_DIR/../../lib/config/config-hub.sh"
source "$SCRIPT_DIR/../../lib/config/config-features.sh"
source "$SCRIPT_DIR/../../lib/config/config-tracing.sh"
source "$SCRIPT_DIR/../../lib/config/config-confluence.sh"

# ============================================================================
# Backward Compatibility Wrappers
# ============================================================================

# Wrapper for show_config -> show_hub_config
# The old show_config function displayed hub configuration.
# It has been renamed to show_hub_config in the refactored modules.
show_config() {
    show_hub_config "$@"
}

# ============================================================================
# Main CLI Interface
# ============================================================================
# This section handles direct execution of config-manager.sh as a command
# All functions are now provided by the sourced modules above

if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    case "${1:-}" in
        init)
            shift
            prompt_hub_mode
            ;;
        get)
            get_config "${2:-}"
            ;;
        set)
            set_config "${2:-}" "${3:-}"
            ;;
        confluence)
            case "$2" in
                show)
                    show_confluence_config
                    ;;
                configure|setup)
                    configure_confluence
                    ;;
                *)
                    if [ -z "$2" ]; then
                        # Default action: configure
                        configure_confluence
                    else
                        echo "Error: Unknown confluence command '${2:-}'"
                        echo "Available: show, configure"
                        exit 1
                    fi
                    ;;
            esac
            ;;
        tracing)
            case "$2" in
                init)
                    echo -e "${BLUE}Initializing tracing configuration...${NC}"
                    if ! init_tracing_config; then
                        exit 1
                    fi
                    echo ""
                    echo -e "${CYAN}Checking dependencies...${NC}"
                    # Get script directory
                    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

                    # Check if tracing dependencies are available (more robust than parsing output)
                    # Source the tracing script to access TRACING_AVAILABLE variable
                    if source "$SCRIPT_DIR/tracing.sh" && [ "$TRACING_AVAILABLE" = true ]; then
                        echo -e "${GREEN}✓${NC} Tracing dependencies already installed"
                    else
                        echo -e "${YELLOW}Installing tracing dependencies...${NC}"
                        bash "$SCRIPT_DIR/tracing.sh" install-deps
                    fi
                    echo ""
                    echo -e "${GREEN}╭────────────────────────────────────────────────────────────╮${NC}"
                    echo -e "${GREEN}│${NC} ${BOLD}Tracing Initialization Complete${NC}                       ${GREEN}│${NC}"
                    echo -e "${GREEN}╰────────────────────────────────────────────────────────────╯${NC}"
                    echo ""
                    echo -e "${CYAN}Next steps:${NC}"
                    echo "  • Run: ${GREEN}ai-use-case tracing enable${NC}       (Enable tracing)"
                    echo "  • Run: ${GREEN}ai-use-case tracing configure${NC}    (Custom settings)"
                    echo "  • Run: ${GREEN}ai-use-case tracing test${NC}         (Test functionality)"
                    echo ""
                    ;;
                show)
                    show_tracing_config
                    ;;
                configure)
                    configure_tracing
                    ;;
                enable)
                    set_tracing_config "enabled" "true"
                    ;;
                disable)
                    set_tracing_config "enabled" "false"
                    ;;
                set)
                    if [ -z "$3" ] || [ -z "$4" ]; then
                        echo "Error: Usage: tracing set <key> <value>"
                        exit 1
                    fi
                    set_tracing_config "$3" "$4"
                    ;;
                *)
                    echo "Error: Unknown tracing command '${2:-}'"
                    echo "Available: init, show, configure, enable, disable, set"
                    exit 1
                    ;;
            esac
            ;;
        show)
            show_config
            ;;
        mode)
            get_hub_mode
            ;;
        path)
            get_hub_path
            ;;
        url)
            get_git_url
            ;;
        is-git)
            if is_git_mode; then
                echo "yes"
                exit 0
            else
                echo "no"
                exit 1
            fi
            ;;
        --help|-h)
            cat <<EOF
Configuration Manager for AI Use Case CLI

Usage:
  $(basename "$0") <command> [args]

Commands:
  init                    Interactive hub mode selection
  show                    Show current configuration
  mode                    Get hub mode
  path                    Get hub path
  url                     Get git URL
  is-git                  Check if git mode is enabled
  get <key>               Get configuration value
  set <key> <val>         Set configuration value
  confluence <subcommand> Manage Confluence integration
    show                  Show Confluence configuration
    configure             Interactive Confluence setup
  tracing <subcommand>    Manage tracing configuration
    show                  Show tracing configuration
    configure             Interactive tracing setup
    enable                Enable tracing
    disable               Disable tracing
    set <key> <value>     Set tracing configuration value

Examples:
  $(basename "$0") init
  $(basename "$0") show
  $(basename "$0") mode
  $(basename "$0") confluence configure
  $(basename "$0") confluence show
EOF
            ;;
        *)
            echo "Error: Unknown command '${1:-}'"
            echo "Run '$(basename "$0") --help' for usage"
            exit 1
            ;;
    esac
fi
