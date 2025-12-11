# Feature Plan: Light/Full Installation Mode

**Feature ID:** FEATURE-LIGHT-FULL-INSTALL
**Created:** 2025-12-10
**Status:** In Progress
**Priority:** High
**Complexity:** Medium

---

## Overview

Add "light" (default) and "full" installation modes to simplify the user experience for new users while keeping all features accessible. Light mode shows only core documentation commands (document-session, publish-confluence); advanced features are hidden but can be unlocked via `ai-use-case enable-advanced`.

## Problem Statement

Currently, ai-use-case-cli presents 20+ commands to new users during installation and in help output. This can be overwhelming for users who only need the core workflow: document AI sessions and publish to Confluence. Additionally, all slash commands are installed to projects regardless of whether users need them, creating clutter in the `.ai-tools/` directory.

New users should have a streamlined experience focused on the essential workflow, while power users retain access to advanced features like agents, pattern analysis, and tracing.

## Goals

### Primary Goals

1. **Simplify UX** - New users see fewer commands, reducing cognitive load and focusing on core workflow
2. **Faster downloads** - Reduced installation footprint for users who only need basics
3. **Clear upgrade path** - Users can easily unlock advanced features when ready

### Non-Goals

- Project separation (moving features to separate repositories) - out of scope
- Removing any existing functionality - all features remain available
- Changing the underlying architecture - this is a visibility/UX change only

## Success Criteria

1. Fresh install defaults to light mode with only core commands visible
2. Advanced commands show friendly "unlock" message instead of errors
3. `ai-use-case enable-advanced` unlocks all features
4. Existing installations continue working without changes (backward compatible)
5. Project setup installs only relevant slash commands based on mode

## Proposed Solution

### High-Level Approach

Add `installMode` and `advancedEnabled` configuration fields to track user preferences. The main CLI's help text and command dispatcher will check these fields to show/hide commands appropriately. A new `enable-advanced` command allows users to unlock all features. The installation script will prompt for mode selection (defaulting to light), and project setup will selectively install slash commands based on the mode.

### Detailed Design

#### Component 1: Configuration Fields

**Purpose:** Track installation mode and advanced feature status

**Implementation:**
- Add `installMode: "light" | "full"` to config.json
- Add `advancedEnabled: true | false` to config.json
- Add `is_advanced_enabled()` helper function with backward compatibility
- Missing fields in existing configs default to full access (legacy support)

**Example:**
```json
{
  "version": "1.0.0",
  "hubMode": "local",
  "hubPath": "~/.local/share/ai-use-case-cli/hub",
  "installMode": "light",
  "advancedEnabled": false
}
```

#### Component 2: Feature Registry

**Purpose:** Define which commands are core vs advanced

**Implementation:**
- New file: `scripts/utils/feature-registry.sh`
- Arrays for CORE_CLI_COMMANDS, ADVANCED_CLI_COMMANDS
- Arrays for CORE_SLASH_COMMANDS, ADVANCED_SLASH_COMMANDS

#### Component 3: Mode-Aware CLI

**Purpose:** Show/hide commands based on mode

**Implementation:**
- `show_help()` dynamically includes/excludes advanced commands
- `require_advanced()` gate function for advanced command handlers
- New commands: `enable-advanced`, `disable-advanced`, `status`

#### Component 4: Selective Slash Command Installation

**Purpose:** Install only relevant commands to projects

**Implementation:**
- New file: `.ai-tools/commands/use-case/manifest.json` with command categories
- `setup-project.sh` reads manifest and installs based on mode
- Existing advanced commands preserved during updates

### User Experience

**Before this feature:**
```
$ ai-use-case --help
[Shows 20+ commands including agents, tracing, analyze-patterns, etc.]

$ ai-use-case --init
[Installs all 12 slash commands]
```

**After this feature:**
```
$ ai-use-case --help
[Shows ~12 core commands]

MORE FEATURES
  Run ai-use-case enable-advanced to unlock:
  - Agent management and AI-powered quality reviews
  - Pattern analysis across projects
  - Session data extraction and tracing

$ ai-use-case --init
[Installs 9 core slash commands]
[Shows: "3 advanced commands available with 'ai-use-case enable-advanced'"]
```

## Technical Architecture

### Components Affected

| File | Changes |
|------|---------|
| `ai-use-case` | Mode-aware help, command gates, enable/disable/status commands |
| `scripts/utils/config-manager.sh` | Add installMode, advancedEnabled fields + helpers |
| `scripts/install/install.sh` | Mode selection, flag parsing, config initialization |
| `scripts/project/setup-project.sh` | Selective slash command installation |
| `scripts/project/link-claude.sh` | Mode-aware command listing |

### New Files

| File | Purpose |
|------|---------|
| `scripts/utils/feature-registry.sh` | Command categorization arrays |
| `.ai-tools/commands/use-case/manifest.json` | Slash command metadata with categories |

### Command Classification

**Core Commands (Light Mode):**

CLI:
- `--init`, `config`, `sync`, `search`, `list`, `stats`, `view`, `push`
- `publish-confluence`, `list-projects`, `check-updates`, `update-project`
- `reset`, `update`, `uninstall`, `version`, `help`

Slash Commands (9):
- `document-session`, `setup-project`, `sync-usecases`, `search-usecases`
- `list-projects`, `check-updates`, `update-project`, `publish-confluence`, `quick-start`

**Advanced Commands (Hidden in Light Mode):**

CLI:
- `agents`, `review-quality`, `analyze-patterns`, `extract`, `tracing`, `bump-version`

Slash Commands (3):
- `analyze-patterns`, `review-quality`, `extract-session`

### Data Flow

```
Installation:
  curl install.sh → Mode Selection → Write Config → Show Completion

Command Execution:
  User → ai-use-case <cmd> → Check is_advanced_enabled() → Execute or Show Unlock Message

Project Setup:
  ai-use-case --init → Read Config → Read Manifest → Install Matching Commands
```

### Dependencies

**Internal:**
- `config-manager.sh` (configuration reading/writing)
- `setup-project.sh` (slash command installation)

**External:**
- None (pure bash implementation)

## Implementation Phases

### Phase 1: Configuration & Registry

**Goals:**
- Add config fields for mode tracking
- Create feature registry with command arrays

**Tasks:**
- Add installMode/advancedEnabled to config-manager.sh
- Add is_advanced_enabled() helper with backward compatibility
- Create feature-registry.sh

### Phase 2: CLI Mode Awareness

**Goals:**
- Make help text mode-aware
- Gate advanced commands
- Add enable/disable commands

**Tasks:**
- Update show_help() to check mode
- Add require_advanced() gate function
- Add enable-advanced, disable-advanced, status command handlers

### Phase 3: Installation & Setup

**Goals:**
- Add mode selection to installer
- Make project setup selective

**Tasks:**
- Update install.sh with --full/--light flags and interactive prompt
- Create manifest.json for slash commands
- Update setup-project.sh to read manifest and filter commands

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking existing installations | High | Low | Backward compatibility: missing fields = full access |
| Confusing users about available features | Med | Med | Clear "MORE FEATURES" section with unlock instructions |
| Manifest.json parsing without jq | Low | Med | Fallback to hardcoded list if jq unavailable |

## Future Enhancements

**Phase 2 (Future):**
- Lazy download of advanced scripts (only download when enabled)
- Per-project mode override (some projects full, others light)
- Feature telemetry to understand usage patterns

**Long-term vision:**
- Plugin architecture where advanced features are optional modules
- Community-contributed agents as installable packages

## Related Documentation

- [COMMANDS.md](../../COMMANDS.md) - Full command reference
- [CONFIGURATION.md](../../CONFIGURATION.md) - Configuration system
- [FEATURES.md](../../FEATURES.md) - Feature overview

---

**Next Steps:**
1. Create feature plan (this document)
2. Create feature branch
3. Implement configuration changes
4. Implement CLI mode awareness
5. Implement installation changes
6. Test all scenarios
7. Create PR for review
