# AI Use Case CLI - Claude Code Guide

**Quick reference for AI assistants.** For detailed guides, see:
- **[docs/WORKFLOW.md](docs/WORKFLOW.md)** - Branch workflow, version management, PR checklist
- **[docs/COMMANDS.md](docs/COMMANDS.md)** - Complete command reference
- **[docs/CLAUDE.md](docs/CLAUDE.md)** - Comprehensive guide

## Repository Purpose

CLI tools for documenting AI-assisted development workflows, designed to help developers on a daily basis.

**Main Goals:**
- **Reduce cognitive overload**: Minimize mental burden through guided templates
- **Build knowledge base**: Comprehensive repository of AI tool usage patterns
- **Enable learning**: Learn from past AI-assisted sessions
- **Streamline workflow**: Quick, template-based documentation

Supports: local-only (no git) or private git repository.

## Critical Rules

### 🚨 Mandatory Workflow

1. **Branch-based only** - Never commit directly to `main`
2. **Version bumps** - Update ALL references when bumping (see [docs/VERSION-UPDATE-CHECKLIST.md](docs/VERSION-UPDATE-CHECKLIST.md))
3. **Documentation** - MUST update CHANGELOG.md and README.md for all changes

```bash
# Standard workflow
git checkout -b feature/description
# ... make changes ...
git commit -m "feat: description"
git push -u origin feature/description
gh pr create
```

See **[docs/WORKFLOW.md](docs/WORKFLOW.md)** for complete workflow guide.

### 📋 Pre-PR Checklist

- [ ] Created feature branch (not on `main`)
- [ ] **MANDATORY: Updated CHANGELOG.md**
- [ ] **MANDATORY: Updated README.md** (if user-facing changes)
- [ ] Updated version if adding features
- [ ] Tested changes locally
- [ ] Updated all related documentation

## 🎯 Feature Development Workflow

**CRITICAL**: When the user says "let's create a new feature" or "let's add [complex feature]", **ALWAYS follow the `docs/features/` process**.

### When to Use Feature Planning Process

Use the structured feature planning workflow when:
- ✅ Feature will touch multiple files or components
- ✅ Feature requires new architecture or patterns
- ✅ Feature has multiple implementation approaches
- ✅ Feature complexity is Medium or High
- ✅ Feature will take more than 1 day to implement

Skip for:
- ❌ Simple bug fixes (1-2 files, clear solution)
- ❌ Documentation-only changes
- ❌ Minor refactoring

### Quick Start: New Feature

```bash
# 1. Create feature directory
mkdir -p docs/features/[feature-name]

# 2. Copy templates
cp docs/features/FEATURE-TEMPLATE/*.md docs/features/[feature-name]/

# 3. Rename files
cd docs/features/[feature-name]
mv 01-feature-plan.md [feature-name].md
mv 02-requirements.md [feature-name]-requirements.md
mv 03-implementation-checklist.md [feature-name]-checklist.md

# 4. Start planning
# Fill in: Feature Plan → Requirements → Implementation Checklist
```

### Three Core Documents Required

1. **Feature Plan** (`[feature-name].md`)
   - Overview, problem statement, goals
   - Proposed solution and architecture
   - Implementation phases
   - Risks and mitigations

2. **Requirements** (`[feature-name]-requirements.md`)
   - Functional and non-functional requirements
   - User stories and acceptance criteria
   - Data and interface requirements
   - Constraints and open questions

3. **Implementation Checklist** (`[feature-name]-checklist.md`)
   - Phase-by-phase task breakdown
   - Each task: priority, time estimate, steps, verification
   - Progress tracking and decision log

### Feature Planning Benefits

- ✅ **Thorough planning** before implementation
- ✅ **Clear requirements** that can be validated
- ✅ **Step-by-step guidance** via detailed checklists
- ✅ **Documentation** of design decisions
- ✅ **Knowledge transfer** for maintainers

**Full guide**: [docs/features/README.md](docs/features/README.md)

## Quick Command Reference

**Full reference:** [docs/COMMANDS.md](docs/COMMANDS.md)

### Most Common Commands

```bash
# Setup & Config
ai-use-case --init              # Setup project
ai-use-case config show         # Show hub config

# Documentation
ai-use-case sync                # Sync to hub
ai-use-case search <term>       # Search use cases

# Project Management (v3.1.0+)
ai-use-case list-projects       # List registered projects
ai-use-case check-updates       # Check for outdated projects
```

### Claude Code Slash Commands

```
/use-case:document-session   # Document AI session (v3.4.0+ interactive)
/use-case:setup-project      # Setup project
/use-case:sync-usecases      # Sync to hub
/use-case:list-projects      # List projects
/use-case:check-updates      # Check updates
```

## File Structure

```
├── ai-use-case                    # Main CLI entry point
├── scripts/
│   ├── core/                      # document-ai-session.sh, sync-ai-use-cases.sh
│   ├── project/                   # setup-project.sh, registry-manager.sh
│   ├── search/                    # search-use-cases.sh, stats-use-cases.sh
│   ├── hub/                       # view-hub.sh, push-hub.sh
│   └── utils/                     # version.sh, config-manager.sh
├── .claude/commands/use-case/     # Slash commands
└── docs/                          # Documentation
    ├── WORKFLOW.md                # Workflow guide (NEW)
    ├── COMMANDS.md                # Command reference (NEW)
    ├── CLAUDE.md                  # Comprehensive guide
    ├── VERSION-MANAGEMENT.md      # Version bumps
    └── VERSION-UPDATE-CHECKLIST.md # Version checklist
```

**System files:**
- `~/.local/share/ai-use-case-cli/projects-registry.json` - Project registry (v3.1.0+)
- `~/.config/ai-use-case-cli/config.json` - Hub configuration (v3.2.0+)

## Hub Configuration (v3.2.0+)

Two modes available:

1. **Local Only** (Default) - `~/.local/share/ai-use-case-cli/hub/` (no git)
2. **Private Git** - Your own repository with full version control

```bash
ai-use-case config show         # Show current mode
ai-use-case config reconfigure  # Change modes
export AI_USECASES_DIR="/custom/path"  # Override location
```

See **[docs/COMMANDS.md](docs/COMMANDS.md#hub-configuration-v320)** for details.

## Automatic Documentation (v3.4.0+)

`/use-case:document-session` provides **interactive session selection**:

1. Detects undocumented PRs and recent commits
2. Presents options: PRs (priority), current conversation, or commits
3. Auto-generates complete documentation (NO placeholders)
4. Saves and syncs to hub

**Key benefits:**
- Ensures ALL PRs get documented
- User controls priority
- Complete automation

See **[docs/WORKFLOW.md](docs/WORKFLOW.md#automatic-documentation-claude-code)** for complete workflow.

## File Naming Convention

```
YYYY-Www-MM-DD_TICKET-XXX_brief-description.md
```

Examples:
- `2025-W44-10-31_HUB-123_add-version-command.md`
- `2025-W44-10-31_RESEARCH-001_evaluate-auth-approaches.md`

## Never Do

- ❌ Commit directly to `main`
- ❌ Skip CHANGELOG.md updates (MANDATORY)
- ❌ Skip README.md review (MANDATORY for user-facing changes)
- ❌ Create PR without testing
- ❌ Forget version bump for new features
- ❌ Use placeholders in auto-generated docs

## Quick Reference

**Current Version**: Check `scripts/utils/version.sh` line 21
**Latest Changes**: See `CHANGELOG.md`
**Main Branch**: `main` (protected, requires PRs)
**Commit Style**: Conventional commits (feat:, fix:, docs:)

**📚 Documentation:**
- **[docs/WORKFLOW.md](docs/WORKFLOW.md)** - Branch workflow, PR checklist, patterns
- **[docs/COMMANDS.md](docs/COMMANDS.md)** - Complete command reference
- **[docs/CLAUDE.md](docs/CLAUDE.md)** - Comprehensive guide
- **[docs/VERSION-MANAGEMENT.md](docs/VERSION-MANAGEMENT.md)** - Version bumps
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines
- **[README.md](README.md)** - User-facing documentation

**🔍 When to use which doc:**
- Quick reference needed? → This file (CLAUDE.md)
- Need workflow details? → [docs/WORKFLOW.md](docs/WORKFLOW.md)
- Looking for a command? → [docs/COMMANDS.md](docs/COMMANDS.md)
- Deep dive required? → [docs/CLAUDE.md](docs/CLAUDE.md)
