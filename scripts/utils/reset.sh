#!/bin/bash
# AI Use Case CLI - Reset Configuration
# Safely reset CLI configuration, registry, and cached data

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONSTANTS_SH="$SCRIPT_DIR/../../lib/core/constants.sh"
if [ -f "$CONSTANTS_SH" ]; then
    source "$CONSTANTS_SH"
else
    GREEN='' YELLOW='' BLUE='' RED='' CYAN='' BOLD='' NC=''
    CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ai-use-case-cli"
    CONFIG_FILE="$CONFIG_DIR/config.json"
    TRACING_CONFIG="$CONFIG_DIR/tracing.json"
fi

TRACING_CONFIG="${TRACING_CONFIG:-${TRACING_CONFIG_FILE:-$CONFIG_DIR/tracing.json}}"

DATA_DIR="$HOME/.local/share/ai-use-case-cli"
REGISTRY_FILE="$DATA_DIR/projects-registry.json"
TRACING_VENV="$DATA_DIR/tracing-venv"
HUB_DIR="$DATA_DIR/hub"

# Flags
RESET_ALL=false
RESET_CONFIG=false
RESET_REGISTRY=false
RESET_TRACING=false
RESET_HUB=false
DRY_RUN=false
FORCE=false

# Parse arguments
show_help() {
    echo -e "${BLUE}AI Use Case CLI - Reset Configuration${NC}"
    echo ""
    echo -e "${YELLOW}Usage:${NC}"
    echo "  $0 [options]"
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo -e "  ${GREEN}--all${NC}           Reset everything (config, registry, tracing, hub)"
    echo -e "                  ${RED}⚠ WARNING: This includes your hub data!${NC}"
    echo ""
    echo -e "  ${GREEN}--config${NC}        Reset only configuration files"
    echo "                  (config.json, tracing.json)"
    echo ""
    echo -e "  ${GREEN}--registry${NC}      Reset only projects registry"
    echo "                  (projects-registry.json)"
    echo ""
    echo -e "  ${GREEN}--tracing${NC}       Reset only tracing configuration and virtual environment"
    echo "                  (tracing.json, tracing-venv/)"
    echo ""
    echo -e "  ${GREEN}--hub${NC}           Reset hub directory"
    echo -e "                  ${RED}⚠ WARNING: This deletes all your documented use cases!${NC}"
    echo "                  Only affects local-only mode hubs"
    echo ""
    echo -e "  ${GREEN}--dry-run${NC}       Show what would be deleted without actually deleting"
    echo ""
    echo -e "  ${GREEN}--force, -y${NC}     Skip confirmation prompts"
    echo ""
    echo -e "  ${GREEN}--help, -h${NC}      Show this help message"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  $0 --config              # Reset only configuration files"
    echo "  $0 --tracing             # Reset tracing setup"
    echo "  $0 --registry --config   # Reset registry and config"
    echo "  $0 --all --dry-run       # See what --all would delete"
    echo "  $0 --config --force      # Reset config without confirmation"
    echo ""
    echo -e "${YELLOW}Safety:${NC}"
    echo "  • All operations require confirmation unless --force is used"
    echo "  • Use --dry-run to preview changes before executing"
    echo "  • Hub data is only deleted if explicitly requested with --hub or --all"
    echo "  • Git-based hubs are never deleted (only local-only mode)"
    echo ""
    echo -e "${YELLOW}What Gets Reset:${NC}"
    echo "  Config:   $CONFIG_DIR/"
    echo "  Registry: $REGISTRY_FILE"
    echo "  Tracing:  $TRACING_CONFIG + $TRACING_VENV/"
    echo "  Hub:      $HUB_DIR/ (local-only mode only)"
    echo ""
}

# Parse flags
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            RESET_ALL=true
            shift
            ;;
        --config)
            RESET_CONFIG=true
            shift
            ;;
        --registry)
            RESET_REGISTRY=true
            shift
            ;;
        --tracing)
            RESET_TRACING=true
            shift
            ;;
        --hub)
            RESET_HUB=true
            shift
            ;;
        --dry-run|-n)
            DRY_RUN=true
            shift
            ;;
        --force|-y)
            FORCE=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown option '$1'${NC}"
            echo "Run $0 --help for usage information"
            exit 1
            ;;
    esac
done

# If --all is set, enable everything
if [ "$RESET_ALL" = true ]; then
    RESET_CONFIG=true
    RESET_REGISTRY=true
    RESET_TRACING=true
    RESET_HUB=true
fi

# Check if at least one option is selected
if [ "$RESET_CONFIG" = false ] && [ "$RESET_REGISTRY" = false ] && [ "$RESET_TRACING" = false ] && [ "$RESET_HUB" = false ]; then
    echo -e "${RED}Error: No reset options specified${NC}"
    echo "Run $0 --help for usage information"
    exit 1
fi

# Collect items to reset
ITEMS_TO_RESET=()
ITEMS_DISPLAY=()

if [ "$RESET_CONFIG" = true ]; then
    if [ -f "$CONFIG_FILE" ]; then
        ITEMS_TO_RESET+=("$CONFIG_FILE")
        SIZE=$(du -sh "$CONFIG_FILE" 2>/dev/null | cut -f1 || echo "unknown")
        ITEMS_DISPLAY+=("  ${CYAN}Config:${NC}   $CONFIG_FILE ($SIZE)")
    fi
    if [ -f "$TRACING_CONFIG" ] && [ "$RESET_TRACING" = false ]; then
        ITEMS_TO_RESET+=("$TRACING_CONFIG")
        SIZE=$(du -sh "$TRACING_CONFIG" 2>/dev/null | cut -f1 || echo "unknown")
        ITEMS_DISPLAY+=("  ${CYAN}Tracing:${NC}  $TRACING_CONFIG ($SIZE)")
    fi
fi

if [ "$RESET_REGISTRY" = true ] && [ -f "$REGISTRY_FILE" ]; then
    ITEMS_TO_RESET+=("$REGISTRY_FILE")
    SIZE=$(du -sh "$REGISTRY_FILE" 2>/dev/null | cut -f1 || echo "unknown")
    ITEMS_DISPLAY+=("  ${CYAN}Registry:${NC} $REGISTRY_FILE ($SIZE)")
fi

if [ "$RESET_TRACING" = true ]; then
    if [ -f "$TRACING_CONFIG" ]; then
        ITEMS_TO_RESET+=("$TRACING_CONFIG")
        SIZE=$(du -sh "$TRACING_CONFIG" 2>/dev/null | cut -f1 || echo "unknown")
        ITEMS_DISPLAY+=("  ${CYAN}Tracing:${NC}  $TRACING_CONFIG ($SIZE)")
    fi
    if [ -d "$TRACING_VENV" ]; then
        ITEMS_TO_RESET+=("$TRACING_VENV")
        SIZE=$(du -sh "$TRACING_VENV" 2>/dev/null | cut -f1 || echo "unknown")
        ITEMS_DISPLAY+=("  ${CYAN}Venv:${NC}     $TRACING_VENV/ ($SIZE)")
    fi
fi

if [ "$RESET_HUB" = true ]; then
    if [ -d "$HUB_DIR" ]; then
        # Check if hub is git-based
        if [ -d "$HUB_DIR/.git" ]; then
            echo -e "${YELLOW}Warning: Hub appears to be a git repository${NC}"
            echo "Path: $HUB_DIR"
            echo ""
            echo -e "${RED}Git-based hubs should NOT be deleted via reset!${NC}"
            echo "Please manage your git repository manually."
            echo ""
            if [ "$FORCE" = false ]; then
                read -p "Skip hub deletion and continue? [y/N] " -n 1 -r
                echo ""
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    echo "Reset cancelled"
                    exit 1
                fi
                RESET_HUB=false
            else
                echo "Skipping hub deletion (git repository detected)"
                RESET_HUB=false
            fi
        else
            ITEMS_TO_RESET+=("$HUB_DIR")
            SIZE=$(du -sh "$HUB_DIR" 2>/dev/null | cut -f1 || echo "unknown")
            ITEMS_DISPLAY+=("  ${RED}Hub:${NC}      $HUB_DIR/ ($SIZE) ${RED}[ALL USE CASES WILL BE DELETED!]${NC}")
        fi
    fi
fi

# Check if anything to delete
if [ ${#ITEMS_TO_RESET[@]} -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Nothing to reset (specified items do not exist)"
    exit 0
fi

# Display header
echo -e "${BLUE}╭────────────────────────────────────────────────────────────╮${NC}"
echo -e "${BLUE}│${NC} ${BOLD}AI Use Case CLI - Reset${NC}                                ${BLUE}│${NC}"
echo -e "${BLUE}╰────────────────────────────────────────────────────────────╯${NC}"
echo ""

# Display items to reset
echo -e "${YELLOW}The following will be deleted:${NC}"
echo ""
for item in "${ITEMS_DISPLAY[@]}"; do
    echo -e "$item"
done
echo ""
echo -e "Total items: ${BOLD}${#ITEMS_TO_RESET[@]}${NC}"
echo ""

# Special warning for hub deletion
if [ "$RESET_HUB" = true ]; then
    echo -e "${RED}╭────────────────────────────────────────────────────────────╮${NC}"
    echo -e "${RED}│${NC} ${BOLD}⚠ WARNING: HUB DELETION${NC}                               ${RED}│${NC}"
    echo -e "${RED}│${NC}                                                            ${RED}│${NC}"
    echo -e "${RED}│${NC} This will permanently delete ALL your documented use      ${RED}│${NC}"
    echo -e "${RED}│${NC} cases from the local hub. This cannot be undone!          ${RED}│${NC}"
    echo -e "${RED}╰────────────────────────────────────────────────────────────╯${NC}"
    echo ""
fi

# Dry run mode
if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}[DRY RUN] No files will be deleted${NC}"
    exit 0
fi

# Confirm deletion
if [ "$FORCE" = false ]; then
    if [ "$RESET_HUB" = true ]; then
        echo -e "${RED}Type 'DELETE HUB' to confirm hub deletion:${NC}"
        read -r CONFIRMATION
        if [ "$CONFIRMATION" != "DELETE HUB" ]; then
            echo "Reset cancelled"
            exit 0
        fi
        echo ""
    fi

    read -p "Proceed with deletion? [y/N] " -n 1 -r
    echo ""
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Reset cancelled"
        exit 0
    fi
else
    echo -e "${YELLOW}Auto-confirming deletion (--force flag used)${NC}"
    echo ""
fi

# Perform deletion
DELETED_COUNT=0
FAILED_COUNT=0

for item in "${ITEMS_TO_RESET[@]}"; do
    ITEM_NAME=$(basename "$item")

    if [ -f "$item" ]; then
        if rm -f "$item" 2>/dev/null; then
            echo -e "${GREEN}✓${NC} Deleted file: $ITEM_NAME"
            DELETED_COUNT=$((DELETED_COUNT + 1))
        else
            echo -e "${RED}✗${NC} Failed to delete: $ITEM_NAME"
            FAILED_COUNT=$((FAILED_COUNT + 1))
        fi
    elif [ -d "$item" ]; then
        if rm -rf "$item" 2>/dev/null; then
            echo -e "${GREEN}✓${NC} Deleted directory: $ITEM_NAME/"
            DELETED_COUNT=$((DELETED_COUNT + 1))
        else
            echo -e "${RED}✗${NC} Failed to delete: $ITEM_NAME/"
            FAILED_COUNT=$((FAILED_COUNT + 1))
        fi
    fi
done

# Clean up empty directories
if [ "$RESET_CONFIG" = true ] && [ -d "$CONFIG_DIR" ]; then
    if [ -z "$(ls -A "$CONFIG_DIR" 2>/dev/null)" ]; then
        rmdir "$CONFIG_DIR" 2>/dev/null || true
    fi
fi

if [ -d "$DATA_DIR" ]; then
    if [ -z "$(ls -A "$DATA_DIR" 2>/dev/null)" ]; then
        rmdir "$DATA_DIR" 2>/dev/null || true
    fi
fi

echo ""
echo -e "${GREEN}╭────────────────────────────────────────────────────────────╮${NC}"
echo -e "${GREEN}│${NC} ${BOLD}Reset Complete${NC}                                         ${GREEN}│${NC}"
echo -e "${GREEN}╰────────────────────────────────────────────────────────────╯${NC}"
echo ""
echo -e "Successfully deleted: ${GREEN}$DELETED_COUNT${NC}"
if [ $FAILED_COUNT -gt 0 ]; then
    echo -e "Failed to delete:     ${RED}$FAILED_COUNT${NC}"
fi
echo ""

# Show next steps
echo -e "${CYAN}Next steps:${NC}"
if [ "$RESET_CONFIG" = true ]; then
    echo "  • Run ${GREEN}ai-use-case --init${NC} to setup a new project"
    echo "  • Run ${GREEN}ai-use-case config reconfigure${NC} to setup hub again"
fi
if [ "$RESET_TRACING" = true ]; then
    echo "  • Run ${GREEN}ai-use-case tracing configure${NC} to setup tracing again"
    echo "  • Run ${GREEN}ai-use-case tracing install-deps${NC} to reinstall dependencies"
fi
if [ "$RESET_HUB" = true ]; then
    echo "  • Run ${GREEN}ai-use-case config reconfigure${NC} to create a new hub"
fi
echo ""
