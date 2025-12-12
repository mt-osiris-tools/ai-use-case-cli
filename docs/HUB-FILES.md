# Documentation Hub Files

This repository contains **CLI tools** for documenting AI-assisted development workflows. Some documentation files are located in the **separate hub repository**, not in this CLI tools repository.

## Files in the Hub Repository

The following files are maintained in the [ai-use-case-hub](https://github.com/mt-osiris-tools/ai-use-case-hub) repository:

### TEMPLATE.md
Comprehensive template for documenting AI use cases. Includes sections for:
- TL;DR summary
- Business context and objectives
- Step-by-step workflow with time tracking
- Technical details with code snippets
- Results and impact metrics
- Key learnings and best practices
- Replicability framework

**Location**: `https://github.com/mt-osiris-tools/ai-use-case-hub/blob/main/TEMPLATE.md`

### QUICK-REFERENCE.md
Quick reference guide for common commands and workflows.

**Location**: `https://github.com/mt-osiris-tools/ai-use-case-hub/blob/main/QUICK-REFERENCE.md`

### CHANGELOG.md
Version history documenting changes to the hub infrastructure and organization system.

**Location**: `https://github.com/mt-osiris-tools/ai-use-case-hub/blob/main/CHANGELOG.md`

## Why Separate Repositories?

The system uses a two-repository architecture:

1. **ai-use-case-cli** (this repo)
   - CLI tools and scripts
   - Installation/uninstallation utilities
   - Git hook templates
   - VS Code extension
   - Documentation for tool usage

2. **ai-use-case-hub** (separate repo)
   - Central documentation storage
   - Symlink-based organization (by-project/, by-date/, by-topic/)
   - Templates and reference documentation
   - Actual use case documents

This separation allows:
- Independent versioning of tools vs. documentation
- Lightweight CLI tool distribution
- Flexible hub location (can be anywhere on disk)
- Clean separation of concerns

## Setting Up the Hub

To set up the documentation hub:

```bash
mkdir -p ~/.local/share/ai-use-case-cli
cd ~/.local/share/ai-use-case-cli
git clone https://github.com/mt-osiris-tools/ai-use-case-hub.git hub
export AI_USECASES_DIR="$HOME/.local/share/ai-use-case-cli/hub"
```

Or let the installer do it for you:

```bash
curl -fsSL https://raw.githubusercontent.com/mt-osiris-tools/ai-use-case-cli/main/install.sh | bash
# Answer 'Y' when prompted to set up the documentation hub
```

## Using Templates

When documenting a session with `ai-use-case document`, the script automatically:
1. Looks for TEMPLATE.md in the hub directory
2. Uses it to structure your documentation
3. Saves the completed document to your project's `.usecase/cases/` directory
4. Syncs it to the hub via git post-commit hook

You don't need to manually copy or reference these files - the CLI tools handle it automatically.
