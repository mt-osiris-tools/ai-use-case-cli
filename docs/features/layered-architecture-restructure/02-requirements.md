# Requirements: Layered Architecture Restructure

**Feature ID:** FEATURE-LAR-001
**Requirements Version:** 1.0
**Created:** 2025-12-11
**Last Updated:** 2025-12-11

---

## Table of Contents

1. [Functional Requirements](#functional-requirements)
2. [Non-Functional Requirements](#non-functional-requirements)
3. [User Stories](#user-stories)
4. [Acceptance Criteria](#acceptance-criteria)
5. [Data Requirements](#data-requirements)
6. [Interface Requirements](#interface-requirements)
7. [Constraints](#constraints)

---

## Functional Requirements

### FR-1: Directory Structure

**Priority:** High
**Status:** Required

#### FR-1.1: Create lib/ Layer

- **Requirement:** System MUST create a lib/ directory containing pure library modules organized by domain (core, config, hub, project, agents, observability, utils)
- **Rationale:** Separates sourced libraries from executable scripts, improving code organization and reusability
- **Source:** Architectural requirement, maintainability improvement

#### FR-1.2: Create commands/ Layer

- **Requirement:** System MUST create a commands/ directory containing all executable business logic organized by domain (document, hub, search, project, agents, config, maintenance)
- **Rationale:** Clear separation between libraries and commands improves discoverability
- **Validation:** All command scripts exist in commands/ hierarchy

#### FR-1.3: Create cli/ Layer

- **Requirement:** System MUST create a cli/ directory containing user interface components (router.sh, help.sh, feature-gates.sh)
- **Rationale:** Separates UI concerns from business logic
- **Dependencies:** Requires commands/ layer to exist

#### FR-1.4: Create integrations/ Layer

- **Requirement:** System MUST create an integrations/ directory containing external tool integration modules (claude-code, codex, git-hooks)
- **Rationale:** Isolates integration code for easy addition of new tools
- **Validation:** Each integration is self-contained and independently testable

### FR-2: Module Splitting

**Priority:** High
**Status:** Required

#### FR-2.1: Split config-manager.sh

- **Requirement:** config-manager.sh (1,063 lines) MUST be split into 6 focused modules: colors.sh, config-core.sh, config-hub.sh, config-features.sh, config-tracing.sh, config-confluence.sh
- **Rationale:** Reduces complexity, improves maintainability, enables unit testing
- **Validation:** Each module < 250 lines, single responsibility, all functions accessible

#### FR-2.2: Split document-ai-session.sh

- **Requirement:** document-ai-session.sh (985 lines) MUST be split into session-extractor.sh, session-formatter.sh, and orchestration script
- **Rationale:** Separates concerns (extraction, formatting, orchestration)
- **Validation:** Orchestration script < 250 lines, lib modules testable independently

#### FR-2.3: Modularize hub-utils.sh

- **Requirement:** hub-utils.sh MUST be split into hub-locator.sh, hub-validator.sh, hub-git.sh
- **Rationale:** Separates hub location, validation, and git operations
- **Validation:** Each module has clear responsibility

### FR-3: Backward Compatibility

**Priority:** Critical
**Status:** Required

#### FR-3.1: Maintain Symlinks

- **Requirement:** System MUST create symlinks from old file locations to new locations for all moved files
- **Rationale:** Ensures existing installations continue working without modification
- **Validation:** All old import paths resolve correctly via symlinks

#### FR-3.2: Preserve Function Signatures

- **Requirement:** All public function signatures MUST remain unchanged
- **Rationale:** Scripts that source modules will continue working
- **Validation:** Test suite passes without modification to consuming scripts

#### FR-3.3: Maintain CLI Interface

- **Requirement:** All CLI commands MUST work identically after restructure
- **Rationale:** User-facing interface must not break
- **Validation:** Manual smoke testing of all commands

### FR-4: Code Organization

**Priority:** High
**Status:** Required

#### FR-4.1: File Size Limits

- **Requirement:** All files MUST be < 400 lines (excluding comments and blank lines)
- **Rationale:** Keeps files manageable and understandable
- **Measurement:** Line count validation in tests
- **Target:** Max 400 lines, average < 250 lines

#### FR-4.2: Single Responsibility

- **Requirement:** Each module MUST have one clear responsibility
- **Rationale:** Improves maintainability and testability
- **Validation:** Module can be described in one sentence

#### FR-4.3: Clear Dependencies

- **Requirement:** Module dependencies MUST be explicit via source statements
- **Rationale:** Makes dependency graph clear
- **Validation:** No hidden dependencies

---

## Non-Functional Requirements

### NFR-1: Performance

#### NFR-1.1: Test Suite Speed

- **Requirement:** Test suite MUST complete in < 60 seconds
- **Measurement:** `time ./run-tests.sh`
- **Target:** < 60s (currently ~90s)
- **Rationale:** Faster feedback loop for developers

#### NFR-1.2: CLI Startup Time

- **Requirement:** CLI startup (help command) MUST complete in < 500ms
- **Measurement:** `time ai-use-case --help`
- **Target:** < 500ms
- **Rationale:** Responsive user experience

#### NFR-1.3: No Performance Regression

- **Requirement:** Command execution time MUST NOT increase by > 10%
- **Measurement:** Benchmark all commands before/after
- **Rationale:** Restructuring shouldn't slow down operations

### NFR-2: Usability

#### NFR-2.1: Clear Directory Structure

- **Requirement:** Directory structure MUST be self-explanatory
- **Rationale:** New contributors should understand layout instantly
- **Standard:** Industry-standard layered architecture
- **Validation:** < 30 min onboarding for new contributors

#### NFR-2.2: Code Discoverability

- **Requirement:** Developers MUST be able to find relevant code in < 2 minutes
- **Measurement:** Timed search tasks
- **Target:** < 2 min (currently 5-10 min)
- **Rationale:** Improves development velocity

#### NFR-2.3: Error Messages

- **Requirement:** Error messages MUST include file path references when helpful
- **Examples:** "Config error in lib/config/config-hub.sh:42"
- **Rationale:** Helps debugging with new structure

### NFR-3: Maintainability

#### NFR-3.1: Code Quality

- **Requirement:** Code MUST follow Bash style guide
- **Validation:** shellcheck passes on all scripts
- **Standard:** Google Bash Style Guide

#### NFR-3.2: Documentation

- **Requirement:** All lib/ modules MUST have header documentation describing purpose, functions, dependencies
- **Standard:** Consistent header format with usage examples
- **Validation:** Documentation review checklist

#### NFR-3.3: Test Coverage

- **Requirement:** All lib/ modules MUST have unit tests
- **Target:** > 80% function coverage
- **Measurement:** Test count per module
- **Rationale:** Ensures modules work in isolation

### NFR-4: Compatibility

#### NFR-4.1: Backward Compatibility

- **Requirement:** Feature MUST work with all existing project installations (v3.x)
- **Testing:** Test with existing projects, no reconfiguration required
- **Duration:** Maintain backward compat through v3.x releases (3-6 months)

#### NFR-4.2: Platform Support

- **Requirement:** Feature MUST work on Linux and macOS
- **List:** Ubuntu 20.04+, macOS 12+, Fedora 35+
- **Validation:** CI tests on multiple platforms

#### NFR-4.3: Shell Compatibility

- **Requirement:** Scripts MUST work with Bash 4.0+
- **Rationale:** Common baseline for Linux/macOS
- **Validation:** Test with Bash 4.0, 4.4, 5.0

---

## User Stories

### US-1: New Contributor - Understanding Structure

**As a** new contributor
**I want** to quickly understand where different types of code live
**So that** I can find the right place to make changes without extensive guidance

**Acceptance Criteria:**
- Can identify lib/ vs commands/ distinction in < 5 min
- Can find relevant module for a change in < 2 min
- Directory README files explain purpose

**Priority:** High

### US-2: Maintainer - Adding New Configuration

**As a** CLI maintainer
**I want** to add new configuration options without modifying 1000+ line files
**So that** I can make changes confidently without breaking existing functionality

**Acceptance Criteria:**
- Can add config option by modifying < 200 line file
- Unit tests for new option are straightforward
- No risk of breaking unrelated config

**Priority:** High

### US-3: Developer - Fixing Bug

**As a** developer
**I want** to isolate and fix bugs in small, focused modules
**So that** I don't have to understand entire 1000-line files

**Acceptance Criteria:**
- Can understand relevant module in < 15 min
- Can write test for bug in focused module
- Fix doesn't risk breaking unrelated code

**Priority:** High

### US-4: User - Upgrading CLI

**As a** CLI user
**I want** upgrades to happen seamlessly without breaking my setup
**So that** I can benefit from improvements without disruption

**Acceptance Criteria:**
- No reconfiguration required
- All commands work identically
- No error messages about missing files

**Priority:** Critical

### US-5: Integration Developer - Adding New AI Tool

**As an** integration developer
**I want** a clear pattern for adding new AI tool integrations
**So that** I can extend the CLI without modifying core logic

**Acceptance Criteria:**
- Can add integration module in integrations/
- Integration is self-contained
- Clear examples to follow

**Priority:** Medium

---

## Acceptance Criteria

### AC-1: lib/ Layer Structure

- [ ] lib/{core,config,hub,project,agents,observability,utils} directories exist
- [ ] version.sh moved to lib/core/ with symlink
- [ ] tracing.sh moved to lib/observability/ with symlink
- [ ] progress-tracker.sh moved to lib/observability/ with symlink
- [ ] constants.sh created in lib/core/
- [ ] All lib/ modules are sourced (not executed)
- [ ] No lib/ module > 400 lines

### AC-2: config-manager.sh Split

- [ ] lib/core/colors.sh created (< 50 lines)
- [ ] lib/config/config-core.sh created (~150 lines)
- [ ] lib/config/config-hub.sh created (~200 lines)
- [ ] lib/config/config-features.sh created (~120 lines)
- [ ] lib/config/config-tracing.sh created (~230 lines)
- [ ] lib/config/config-confluence.sh created (~200 lines)
- [ ] scripts/utils/config-manager.sh becomes facade (~150 lines)
- [ ] All original functions still accessible
- [ ] Unit tests for each module
- [ ] Integration tests pass

### AC-3: commands/ Layer Structure

- [ ] commands/ directory structure created
- [ ] All scripts moved from scripts/core/ to commands/document/
- [ ] All scripts moved from scripts/search/ to commands/search/
- [ ] All scripts moved from scripts/project/ to commands/project/
- [ ] All scripts moved from scripts/agents/ to commands/agents/
- [ ] All scripts moved from scripts/hub/ to commands/hub/
- [ ] Maintenance scripts in commands/maintenance/
- [ ] Symlinks created in old locations
- [ ] CLI dispatcher updated to use new paths
- [ ] All commands work identically

### AC-4: cli/ Layer

- [ ] cli/ directory created
- [ ] cli/router.sh extracts routing logic (~200 lines)
- [ ] cli/help.sh extracts help generation (~200 lines)
- [ ] cli/feature-gates.sh extracts feature gating (~100 lines)
- [ ] Main CLI script reduced to ~150 lines
- [ ] Help command works identically
- [ ] Feature gating works identically

### AC-5: integrations/ Layer

- [ ] integrations/ directory structure created
- [ ] integrations/claude-code/install-commands.sh extracted
- [ ] integrations/codex/install-prompts.sh extracted
- [ ] integrations/git-hooks/install-hooks.sh extracted
- [ ] Each integration independently testable
- [ ] setup-project.sh simplified (~300 lines)

### AC-6: Backward Compatibility

- [ ] All symlinks resolve correctly
- [ ] Old sourcing patterns still work
- [ ] All CLI commands work identically
- [ ] Test suite passes without modifications
- [ ] Existing projects work without reconfiguration
- [ ] No breaking changes to public APIs

### AC-7: Testing

- [ ] Unit tests for all lib/ modules
- [ ] Command tests updated for new paths
- [ ] Integration tests pass
- [ ] Test suite < 60s
- [ ] No test coverage regression

### AC-8: Documentation

- [ ] CHANGELOG.md updated for each phase
- [ ] Architecture documentation created in docs/architecture/
- [ ] Migration guide created
- [ ] CONTRIBUTING.md updated with new structure
- [ ] Each lib/ module has header documentation
- [ ] README files in key directories

---

## Data Requirements

### DR-1: No Data Structure Changes

**Requirement:** No changes to existing data structures

**Configuration Files:**
- `~/.config/ai-use-case-cli/config.json` - Unchanged
- `~/.config/ai-use-case-cli/tracing.json` - Unchanged
- `~/.config/ai-use-case-cli/agents.json` - Unchanged
- `~/.local/share/ai-use-case-cli/projects-registry.json` - Unchanged

**Rationale:** Data format stability ensures backward compatibility

### DR-2: Storage Locations

- **Configuration:** `~/.config/ai-use-case-cli/` (unchanged)
- **Registry:** `~/.local/share/ai-use-case-cli/` (unchanged)
- **Hub:** Configured path (unchanged)
- **Format:** JSON (unchanged)

### DR-3: No Data Migration Required

- **Migration needed:** No
- **Rationale:** Pure code reorganization, no data format changes
- **Validation:** Existing config files work without modification

---

## Interface Requirements

### IR-1: CLI Interface (Unchanged)

**All Commands:**
```bash
ai-use-case --init                # Unchanged
ai-use-case --link-claude         # Unchanged
ai-use-case sync                  # Unchanged
ai-use-case search <term>         # Unchanged
ai-use-case config show           # Unchanged
# ... all other commands unchanged
```

**Options:** All existing options preserved
**Output:** Output format unchanged
**Exit Codes:** Exit codes unchanged

### IR-2: Module Sourcing Interface

**Old Pattern (still works):**
```bash
source "$SCRIPT_DIR/../utils/config-manager.sh"
get_hub_path
```

**New Pattern (recommended):**
```bash
source "$SCRIPT_DIR/../lib/config/config-hub.sh"
get_hub_path
```

**Requirement:** Both patterns MUST work identically

### IR-3: Configuration Interface (Unchanged)

**Configuration File:**
```json
{
  "version": "1.0.0",
  "hubMode": "private-git",
  "hubPath": "/path/to/hub",
  "gitUrl": "https://github.com/user/repo",
  "advancedEnabled": true
}
```

**Environment Variables:**
- `AI_USECASES_DIR` - Hub directory (unchanged)
- `AI_USECASES_CLI_ROOT` - CLI root (unchanged)

---

## Constraints

### C-1: Technical Constraints

- **Language:** Bash 4.0+
- **Dependencies:** jq, git, Python 3.8+ (for tracing)
- **Platform:** Linux, macOS (no Windows native support)
- **File Size:** All files < 400 lines

### C-2: Operational Constraints

- **Timeline:** 3-6 months (8 phases)
- **Team:** 1-2 developers part-time
- **Scope:** Pure refactoring, no new features
- **Testing:** All phases must pass full test suite

### C-3: Design Constraints

- **Architecture:** Must follow layered architecture (lib, commands, cli, integrations)
- **Naming:** Existing naming conventions preserved
- **Structure:** Symlinks for backward compatibility required
- **Testing:** Unit tests required for all lib/ modules

### C-4: External Constraints

- **User Impact:** Zero breaking changes allowed
- **Performance:** No regression > 10%
- **Documentation:** Must document all changes
- **Review:** Each phase requires code review

---

## Dependencies

### D-1: Existing Components

- `scripts/utils/config-manager.sh` - Split into modules
- `scripts/utils/hub-utils.sh` - Split into modules
- `ai-use-case` (main CLI) - Extract routing/help
- All command scripts - Move to commands/
- Test suite - Update for new structure

### D-2: External Dependencies

- `jq` (1.6+) - JSON processing
- `git` (2.x) - Version control, hub operations
- `BATS` (1.x) - Testing framework
- `Python` (3.8+) - Tracing functionality (optional)
- `shellcheck` - Linting (development)

### D-3: Documentation Dependencies

- CHANGELOG.md - Update for each phase
- CONTRIBUTING.md - Update with new structure
- docs/architecture/ - Create new documentation
- README.md - Update with new structure references

---

## Open Questions

### OQ-1: Symlink Removal Timeline

**Question:** When should we remove backward compatibility symlinks?

**Options:**
- A) Never remove (maintain indefinitely)
- B) Remove in v4.0.0 (6-12 months)
- C) Remove in v3.15.0 (3-6 months)

**Decision:** B) Remove in v4.0.0
**Date Decided:** 2025-12-11
**Rationale:** Gives users extended transition period, aligns with major version

### OQ-2: Deprecation Warnings

**Question:** Should we add deprecation warnings when old paths are used?

**Options:**
- A) Yes, add warnings immediately
- B) No warnings, silent compatibility
- C) Add warnings in later phases

**Decision:** B) No warnings, silent compatibility
**Date Decided:** 2025-12-11
**Rationale:** Avoids noise for users, symlinks are transparent

### OQ-3: Documentation Reorganization Timing

**Question:** Should Phase 7 (docs reorganization) happen earlier or later?

**Options:**
- A) Early (Phase 3-4) to document new structure
- B) Late (Phase 7) as planned
- C) Incremental with each phase

**Decision:** C) Incremental with each phase
**Date Decided:** 2025-12-11
**Rationale:** Documentation stays current with implementation

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-12-11 | Claude Code | Initial requirements document |

---

**Status:** Approved
**Next Steps:** Create implementation checklist (03-implementation-checklist.md)
