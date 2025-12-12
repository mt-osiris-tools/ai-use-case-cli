# Implementation Checklist: Layered Architecture Restructure

**Feature ID:** FEATURE-LAR-001
**Checklist Version:** 1.0
**Created:** 2025-12-11
**Status:** In Progress

---

## Pre-Implementation Setup

### Environment Preparation

- [x] **Create feature branch**
  - [x] Branch name: `feature/layered-architecture-phase1`
  - [x] Branched from: `main` (latest)
  - [x] Command: `git checkout -b feature/layered-architecture-phase1`

- [ ] **Review related documentation**
  - [x] Read feature plan: `docs/features/layered-architecture-restructure/01-feature-plan.md`
  - [x] Read requirements: `docs/features/layered-architecture-restructure/02-requirements.md`
  - [x] Review affected files from exploration phase

- [ ] **Set up test environment**
  - [x] CLI installation directory: `<CLI_INSTALLATION_DIR>`
  - [x] Hub directory: `<HUB_DIRECTORY>`
  - [ ] Verify baseline functionality: Run `./run-tests.sh`

---

## Phase 1: Foundation (Weeks 1-2) - LOW RISK

**Status:** In Progress
**Target:** Establish lib/ layer without breaking existing code

### Task 1.1: Create lib/ Directory Structure

**Priority:** High
**Estimated Time:** 15 minutes

- [x] **Create directories**
  - [x] `mkdir -p lib/{core,config,hub,project,agents,observability,utils}`
  - [x] Verify: `ls -la lib/` shows 7 subdirectories

- [x] **Commit structure**
  - [x] Stage: `git add lib/`
  - [x] Commit: `git commit -m "feat: create lib/ directory structure for layered architecture"`

### Task 1.2: Move version.sh to lib/core/

**File:** `scripts/utils/version.sh` → `lib/core/version.sh`
**Priority:** High
**Estimated Time:** 10 minutes

- [x] **Move file**
  - [x] `git mv scripts/utils/version.sh lib/core/`
  - [x] Verify: `ls lib/core/version.sh` exists

- [x] **Create backward compat symlink**
  - [x] `ln -s ../../lib/core/version.sh scripts/utils/version.sh`
  - [x] Verify: `ls -la scripts/utils/version.sh` shows symlink

- [ ] **Test**
  - [ ] Source old path: `source scripts/utils/version.sh` works
  - [ ] Source new path: `source lib/core/version.sh` works
  - [ ] Variable accessible: `echo $CLI_VERSION` shows version

### Task 1.3: Move tracing.sh to lib/observability/

**File:** `scripts/utils/tracing.sh` → `lib/observability/tracing.sh`
**Priority:** High
**Estimated Time:** 10 minutes

- [x] **Move file**
  - [x] `git mv scripts/utils/tracing.sh lib/observability/`
  - [x] Create symlink: `ln -s ../../lib/observability/tracing.sh scripts/utils/tracing.sh`

- [ ] **Test**
  - [ ] Source works from old path
  - [ ] Functions accessible: `type trace_command_start`
  - [ ] No import errors

### Task 1.4: Move progress-tracker.sh to lib/observability/

**File:** `scripts/utils/progress-tracker.sh` → `lib/observability/progress-tracker.sh`
**Priority:** High
**Estimated Time:** 10 minutes

- [x] **Move file**
  - [x] `git mv scripts/utils/progress-tracker.sh lib/observability/`
  - [x] Create symlink: `ln -s ../../lib/observability/progress-tracker.sh scripts/utils/progress-tracker.sh`

- [ ] **Test**
  - [ ] Source works from old path
  - [ ] Functions accessible: `type progress_init`

### Task 1.5: Create lib/core/constants.sh

**File:** `lib/core/constants.sh` (NEW)
**Priority:** High
**Estimated Time:** 30 minutes

- [ ] **Extract color codes**
  - [ ] Identify color codes used in multiple scripts
  - [ ] Create constants.sh with standardized colors
  - [ ] Add: GREEN, YELLOW, BLUE, RED, CYAN, BOLD, NC

- [ ] **Add default paths**
  - [ ] DEFAULT_HUB_DIR
  - [ ] CLI_ROOT
  - [ ] CONFIG_DIR, CONFIG_FILE
  - [ ] TRACING_CONFIG_FILE, AGENTS_CONFIG_FILE

- [ ] **Add configuration keys**
  - [ ] CONFIG_KEY_HUB_MODE, CONFIG_KEY_HUB_PATH
  - [ ] CONFIG_KEY_INSTALL_MODE, CONFIG_KEY_ADVANCED_ENABLED

- [ ] **Add header documentation**
  - [ ] Module purpose
  - [ ] Usage example
  - [ ] Dependencies (none)

- [ ] **Commit**
  - [ ] `git add lib/core/constants.sh`
  - [ ] `git commit -m "feat: create constants.sh with shared color codes and defaults"`

### Task 1.6: Phase 1 Testing

**Priority:** Critical
**Estimated Time:** 30 minutes

- [ ] **Run full test suite**
  - [ ] Execute: `./run-tests.sh`
  - [ ] Verify: All tests pass
  - [ ] Time: Record execution time (target < 90s currently, < 60s future)

- [ ] **Manual smoke testing**
  - [ ] `ai-use-case --version` works
  - [ ] `ai-use-case --help` works
  - [ ] `ai-use-case config show` works
  - [ ] No errors about missing files

- [ ] **Verify symlinks**
  - [ ] `ls -la scripts/utils/version.sh` → points to lib/core/version.sh
  - [ ] `ls -la scripts/utils/tracing.sh` → points to lib/observability/tracing.sh
  - [ ] `ls -la scripts/utils/progress-tracker.sh` → points to lib/observability/progress-tracker.sh

### Task 1.7: Commit Phase 1 Completion

**Priority:** High
**Estimated Time:** 10 minutes

- [ ] **Create comprehensive commit**
  - [ ] Stage all changes: `git add -A`
  - [ ] Review: `git status`
  - [ ] Commit with detailed message
  - [ ] Message includes: files moved, symlinks created, backward compat maintained

- [ ] **Tag phase**
  - [ ] `git tag phase-1-foundation`
  - [ ] Document completion in CHANGELOG.md

---

## Phase 2: Split config-manager.sh (Weeks 3-4) - HIGH VALUE

**Status:** Not Started
**Target:** Break down 1,063-line monolith into 6 focused modules

### Task 2.1: Create lib/core/colors.sh

**File:** `lib/core/colors.sh` (NEW)
**Priority:** High
**Estimated Time:** 15 minutes

- [ ] **Extract from config-manager.sh**
  - [ ] Copy lines 10-16 (color definitions)
  - [ ] Add header documentation
  - [ ] Add usage example

- [ ] **Test independently**
  - [ ] Source: `source lib/core/colors.sh`
  - [ ] Verify: `echo -e "${GREEN}Test${NC}"` shows green text

- [ ] **Commit**
  - [ ] `git add lib/core/colors.sh`
  - [ ] `git commit -m "refactor: extract colors to lib/core/colors.sh"`

### Task 2.2: Create lib/config/config-core.sh

**File:** `lib/config/config-core.sh` (NEW)
**Priority:** High
**Estimated Time:** 2 hours

- [ ] **Extract functions from config-manager.sh**
  - [ ] `ensure_config_dir()` (~30 lines)
  - [ ] `validate_path()` (~40 lines)
  - [ ] `get_config()` (~30 lines)
  - [ ] `set_config()` (~40 lines)
  - [ ] Internal helper: `_update_config_field()`

- [ ] **Add dependencies**
  - [ ] Source: `lib/core/colors.sh`
  - [ ] Add constants: CONFIG_DIR, CONFIG_FILE

- [ ] **Add documentation**
  - [ ] Header with module purpose
  - [ ] Function documentation
  - [ ] Usage examples

- [ ] **Create unit test**
  - [ ] File: `tests/lib/config/core.bats`
  - [ ] Test: ensure_config_dir creates directory
  - [ ] Test: validate_path rejects invalid characters
  - [ ] Test: get_config retrieves values
  - [ ] Test: set_config writes values

- [ ] **Commit**
  - [ ] `git add lib/config/config-core.sh tests/lib/config/core.bats`
  - [ ] `git commit -m "refactor: extract config-core.sh with JSON I/O utilities"`

### Task 2.3: Create lib/config/config-hub.sh

**File:** `lib/config/config-hub.sh` (NEW)
**Priority:** High
**Estimated Time:** 2 hours

- [ ] **Extract hub-related functions**
  - [ ] `init_config()` - Initialize configuration
  - [ ] `get_hub_mode()` - Return hub mode
  - [ ] `get_hub_path()` - Return hub path (respects env var)
  - [ ] `get_git_url()` - Return git URL
  - [ ] `is_git_mode()` - Boolean check
  - [ ] `prompt_hub_mode()` - Interactive setup
  - [ ] `show_hub_config()` - Display configuration (rename from show_config)

- [ ] **Add dependencies**
  - [ ] Source: `lib/config/config-core.sh`
  - [ ] Source: `lib/core/colors.sh`

- [ ] **Add documentation**
  - [ ] Module purpose
  - [ ] Function documentation

- [ ] **Create unit test**
  - [ ] File: `tests/lib/config/hub.bats`
  - [ ] Test: get_hub_path respects AI_USECASES_DIR
  - [ ] Test: is_git_mode detects mode correctly
  - [ ] Test: init_config creates valid config

- [ ] **Commit**
  - [ ] `git add lib/config/config-hub.sh tests/lib/config/hub.bats`
  - [ ] `git commit -m "refactor: extract config-hub.sh with hub configuration logic"`

### Task 2.4: Create lib/config/config-features.sh

**File:** `lib/config/config-features.sh` (NEW)
**Priority:** Medium
**Estimated Time:** 1 hour

- [ ] **Extract feature flag functions**
  - [ ] `get_install_mode()` - Return install mode
  - [ ] `set_install_mode()` - Set install mode
  - [ ] `get_advanced_enabled()` - Return advanced status
  - [ ] `is_advanced_enabled()` - Boolean check
  - [ ] `set_advanced_enabled()` - Toggle advanced features

- [ ] **Add dependencies**
  - [ ] Source: `lib/config/config-core.sh`
  - [ ] Source: `lib/core/colors.sh`

- [ ] **Create unit test**
  - [ ] File: `tests/lib/config/features.bats`
  - [ ] Test: is_advanced_enabled returns correct value
  - [ ] Test: set_advanced_enabled updates config

- [ ] **Commit**
  - [ ] `git add lib/config/config-features.sh tests/lib/config/features.bats`
  - [ ] `git commit -m "refactor: extract config-features.sh with feature flag management"`

### Task 2.5: Create lib/config/config-tracing.sh

**File:** `lib/config/config-tracing.sh` (NEW)
**Priority:** Medium
**Estimated Time:** 2 hours

- [ ] **Extract tracing configuration**
  - [ ] DEFAULT_TRACING_CONFIG constant
  - [ ] `init_tracing_config()` - Initialize tracing.json
  - [ ] `get_tracing_config()` - Return tracing config
  - [ ] `set_tracing_config()` - Update tracing field
  - [ ] `validate_and_repair_tracing_config()` - Validation logic
  - [ ] `show_tracing_config()` - Display tracing config
  - [ ] `configure_tracing()` - Interactive setup

- [ ] **Add dependencies**
  - [ ] Source: `lib/config/config-core.sh`
  - [ ] Source: `lib/core/colors.sh`

- [ ] **Create unit test**
  - [ ] File: `tests/lib/config/tracing.bats`
  - [ ] Test: init_tracing_config creates valid JSON
  - [ ] Test: validate_and_repair fixes broken config

- [ ] **Commit**
  - [ ] `git add lib/config/config-tracing.sh tests/lib/config/tracing.bats`
  - [ ] `git commit -m "refactor: extract config-tracing.sh with OpenTelemetry config logic"`

### Task 2.6: Create lib/config/config-confluence.sh

**File:** `lib/config/config-confluence.sh` (NEW)
**Priority:** Low
**Estimated Time:** 1.5 hours

- [ ] **Extract Confluence functions**
  - [ ] `configure_confluence()` - Interactive setup
  - [ ] `show_confluence_config()` - Display Confluence config

- [ ] **Add dependencies**
  - [ ] Source: `lib/config/config-core.sh`
  - [ ] Source: `lib/core/colors.sh`

- [ ] **Create unit test**
  - [ ] File: `tests/lib/config/confluence.bats`
  - [ ] Test: configure_confluence creates valid config

- [ ] **Commit**
  - [ ] `git add lib/config/config-confluence.sh tests/lib/config/confluence.bats`
  - [ ] `git commit -m "refactor: extract config-confluence.sh with Confluence integration logic"`

### Task 2.7: Convert config-manager.sh to Facade

**File:** `scripts/utils/config-manager.sh` (MODIFY)
**Priority:** Critical
**Estimated Time:** 1 hour

- [ ] **Replace implementation with facade**
  - [ ] Add header: "Configuration Manager - Unified facade for backward compatibility"
  - [ ] Source all 6 modules (colors, config-core, config-hub, config-features, config-tracing, config-confluence)
  - [ ] Add backward compatibility wrapper: `show_config() { show_hub_config "$@"; }`
  - [ ] Keep CLI command handler intact (lines 913-1063)

- [ ] **Result**: config-manager.sh becomes ~150 lines
  - [ ] ~20 lines sourcing modules
  - [ ] ~20 lines wrappers
  - [ ] ~110 lines CLI handler

- [ ] **Test facade**
  - [ ] Source config-manager.sh
  - [ ] All original functions accessible
  - [ ] `get_hub_path` works
  - [ ] `is_advanced_enabled` works
  - [ ] `configure_tracing` works

- [ ] **Commit**
  - [ ] `git add scripts/utils/config-manager.sh`
  - [ ] `git commit -m "refactor: convert config-manager.sh to facade pattern"`

### Task 2.8: Phase 2 Integration Testing

**Priority:** Critical
**Estimated Time:** 1 hour

- [ ] **Test all config commands**
  - [ ] `ai-use-case config show` works
  - [ ] `ai-use-case tracing configure` works
  - [ ] `ai-use-case tracing show` works

- [ ] **Test consuming scripts**
  - [ ] `scripts/core/sync-ai-use-cases.sh` works (sources config-manager)
  - [ ] `scripts/project/setup-project.sh` works (sources config-manager)
  - [ ] `scripts/utils/hub-utils.sh` works (sources config-manager)

- [ ] **Run full test suite**
  - [ ] Execute: `./run-tests.sh`
  - [ ] Verify: All tests pass
  - [ ] Verify: New unit tests pass

- [ ] **Commit phase completion**
  - [ ] Update CHANGELOG.md with Phase 2 details
  - [ ] `git tag phase-2-config-split`

---

## Phase 3: Reorganize Commands (Weeks 5-7) - LOW RISK

**Status:** Not Started
**Target:** Separate libraries from executables with clear commands/ hierarchy

### Task 3.1: Create commands/ Directory Structure

**Priority:** High
**Estimated Time:** 10 minutes

- [ ] **Create directories**
  - [ ] `mkdir -p commands/{document,hub,search,project,agents,config,maintenance}`
  - [ ] Verify: `ls -la commands/` shows 7 subdirectories

- [ ] **Commit**
  - [ ] `git add commands/`
  - [ ] `git commit -m "feat: create commands/ directory structure"`

### Task 3.2: Move Document Commands

**Priority:** High
**Estimated Time:** 1 hour

- [ ] **Move scripts/core/ → commands/document/**
  - [ ] `git mv scripts/core/document-ai-session.sh commands/document/document-session.sh`
  - [ ] `git mv scripts/core/extract-session-data.sh commands/document/extract-data.sh`
  - [ ] `git mv scripts/core/publish-confluence.sh commands/document/publish-confluence.sh`

- [ ] **Create backward compat symlinks**
  - [ ] `ln -s ../../commands/document/document-session.sh scripts/core/document-ai-session.sh`
  - [ ] `ln -s ../../commands/document/extract-data.sh scripts/core/extract-session-data.sh`
  - [ ] `ln -s ../../commands/document/publish-confluence.sh scripts/core/publish-confluence.sh`

- [ ] **Update imports**
  - [ ] Change `../utils/` → `../../lib/` in moved files
  - [ ] Test: Source paths resolve correctly

- [ ] **Commit**
  - [ ] `git add commands/document/ scripts/core/`
  - [ ] `git commit -m "refactor: move document commands to commands/document/"`

### Task 3.3: Move Hub Commands

**Priority:** High
**Estimated Time:** 30 minutes

- [ ] **Move scripts/core/ + scripts/hub/ → commands/hub/**
  - [ ] `git mv scripts/core/sync-ai-use-cases.sh commands/hub/sync.sh`
  - [ ] `git mv scripts/hub/push-hub.sh commands/hub/push.sh`
  - [ ] `git mv scripts/hub/view-hub.sh commands/hub/view.sh`

- [ ] **Create symlinks**
  - [ ] Link from old locations

- [ ] **Update imports**
  - [ ] Fix relative paths in moved files

- [ ] **Commit**
  - [ ] `git add commands/hub/ scripts/core/ scripts/hub/`
  - [ ] `git commit -m "refactor: move hub commands to commands/hub/"`

### Task 3.4: Move Search Commands

**Priority:** High
**Estimated Time:** 30 minutes

- [ ] **Move scripts/search/ → commands/search/**
  - [ ] `git mv scripts/search/search-use-cases.sh commands/search/search.sh`
  - [ ] `git mv scripts/search/stats-use-cases.sh commands/search/stats.sh`

- [ ] **Create symlinks + update imports**
- [ ] **Commit**
  - [ ] `git commit -m "refactor: move search commands to commands/search/"`

### Task 3.5: Move Project Commands

**Priority:** High
**Estimated Time:** 1 hour

- [ ] **Move scripts/project/ → commands/project/**
  - [ ] setup-project.sh → setup.sh
  - [ ] list-projects.sh → list.sh
  - [ ] update-project.sh → update.sh
  - [ ] link-claude.sh (keep name)
  - [ ] setup-codex.sh (keep name)
  - [ ] check-updates.sh (keep name)

- [ ] **Create symlinks + update imports**
- [ ] **Commit**
  - [ ] `git commit -m "refactor: move project commands to commands/project/"`

### Task 3.6: Move Agent Commands

**Priority:** Medium
**Estimated Time:** 45 minutes

- [ ] **Move scripts/agents/ → commands/agents/**
  - [ ] agent-registry.sh → registry-manager.sh
  - [ ] quality-agent.sh → quality-reviewer.sh
  - [ ] pattern-agent.sh → pattern-analyzer.sh
  - [ ] invoke-agent.sh → (move to lib/agents/agent-invoker.sh)

- [ ] **Create symlinks + update imports**
- [ ] **Commit**
  - [ ] `git commit -m "refactor: move agent commands to commands/agents/"`

### Task 3.7: Move Maintenance Commands

**Priority:** Medium
**Estimated Time:** 1 hour

- [ ] **Move scripts/utils/ + scripts/install/ → commands/maintenance/**
  - [ ] reset.sh
  - [ ] self-update.sh
  - [ ] bump-version.sh
  - [ ] validate-versions.sh
  - [ ] install.sh (from scripts/install/)
  - [ ] uninstall.sh (from scripts/install/)

- [ ] **Create symlinks + update imports**
- [ ] **Commit**
  - [ ] `git commit -m "refactor: move maintenance commands to commands/maintenance/"`

### Task 3.8: Update CLI Dispatcher

**File:** `ai-use-case` (main CLI)
**Priority:** Critical
**Estimated Time:** 1 hour

- [ ] **Update command routing**
  - [ ] Change paths from `scripts/core/` → `commands/document/`
  - [ ] Change paths from `scripts/search/` → `commands/search/`
  - [ ] Change paths for all moved commands

- [ ] **Test all commands**
  - [ ] `ai-use-case sync` works
  - [ ] `ai-use-case search test` works
  - [ ] `ai-use-case --init` works
  - [ ] All other commands work

- [ ] **Commit**
  - [ ] `git add ai-use-case`
  - [ ] `git commit -m "refactor: update CLI dispatcher for new command locations"`

### Task 3.9: Phase 3 Testing

**Priority:** Critical
**Estimated Time:** 1 hour

- [ ] **Run full test suite**
  - [ ] All tests pass
  - [ ] No import errors

- [ ] **Manual smoke testing**
  - [ ] Test every CLI command
  - [ ] Verify output unchanged
  - [ ] Check for error messages

- [ ] **Commit phase completion**
  - [ ] Update CHANGELOG.md
  - [ ] `git tag phase-3-commands`

---

## Phase 4: Split Remaining Large Files (Weeks 8-10) - MEDIUM RISK

**Status:** Not Started
**Target:** Reduce document-ai-session.sh and split hub-utils.sh, registry-manager.sh

### Task 4.1: Split document-ai-session.sh

**Priority:** High
**Estimated Time:** 4 hours

- [ ] **Create lib/document/session-extractor.sh**
  - [ ] Extract git history functions
  - [ ] Extract conversation parsing
  - [ ] Extract metadata collection
  - [ ] Target: ~300 lines

- [ ] **Create lib/document/session-formatter.sh**
  - [ ] Extract template rendering
  - [ ] Extract markdown generation
  - [ ] Extract file writing
  - [ ] Target: ~300 lines

- [ ] **Update commands/document/document-session.sh**
  - [ ] Source new lib modules
  - [ ] Keep orchestration only
  - [ ] Target: ~200 lines

- [ ] **Create tests**
  - [ ] tests/lib/document/extractor.bats
  - [ ] tests/lib/document/formatter.bats

- [ ] **Commit**
  - [ ] `git commit -m "refactor: split document-ai-session into focused modules"`

### Task 4.2: Split hub-utils.sh

**Priority:** Medium
**Estimated Time:** 2 hours

- [ ] **Create lib/hub/hub-locator.sh**
  - [ ] `get_hub_dir()`, `ensure_hub_exists()`

- [ ] **Create lib/hub/hub-validator.sh**
  - [ ] Validation logic

- [ ] **Create lib/hub/hub-git.sh**
  - [ ] Git operations

- [ ] **Convert hub-utils.sh to facade**
  - [ ] Source 3 modules
  - [ ] Provide backward compat

- [ ] **Commit**
  - [ ] `git commit -m "refactor: split hub-utils into focused modules"`

### Task 4.3: Split registry-manager.sh

**Priority:** Medium
**Estimated Time:** 2 hours

- [ ] **Create lib/project/registry-io.sh**
  - [ ] Read/write operations

- [ ] **Create lib/project/registry-queries.sh**
  - [ ] Query functions

- [ ] **Update commands/project/registry-manager.sh**
  - [ ] Source new modules
  - [ ] Keep CLI interface

- [ ] **Commit**
  - [ ] `git commit -m "refactor: split registry-manager into I/O and queries"`

### Task 4.4: Phase 4 Testing

**Priority:** Critical
**Estimated Time:** 1 hour

- [ ] **Run full test suite**
- [ ] **Test affected commands**
  - [ ] Document session creation
  - [ ] Hub operations
  - [ ] Project registry operations

- [ ] **Commit phase completion**
  - [ ] Update CHANGELOG.md
  - [ ] `git tag phase-4-large-files`

---

## Phase 5: Simplify Main CLI (Weeks 11-12) - MEDIUM RISK

**Status:** Not Started
**Target:** Reduce main CLI from 710 lines to ~150 lines

### Task 5.1: Create cli/router.sh

**Priority:** High
**Estimated Time:** 3 hours

- [ ] **Extract routing logic**
  - [ ] Move entire case statement
  - [ ] Implement routing table
  - [ ] Target: ~200 lines

- [ ] **Create routing table**
  ```bash
  declare -A COMMAND_MAP=(
    ["sync"]="commands/hub/sync.sh"
    ["search"]="commands/search/search.sh"
    ...
  )
  ```

- [ ] **Test routing**
  - [ ] All commands route correctly
  - [ ] Unknown commands show error

- [ ] **Commit**
  - [ ] `git add cli/router.sh`
  - [ ] `git commit -m "refactor: extract routing logic to cli/router.sh"`

### Task 5.2: Create cli/help.sh

**Priority:** High
**Estimated Time:** 2 hours

- [ ] **Extract help generation**
  - [ ] Move `show_help()` function
  - [ ] Separate basic vs advanced help
  - [ ] Target: ~200 lines

- [ ] **Test help output**
  - [ ] `ai-use-case --help` works
  - [ ] Output unchanged

- [ ] **Commit**
  - [ ] `git add cli/help.sh`
  - [ ] `git commit -m "refactor: extract help generation to cli/help.sh"`

### Task 5.3: Create cli/feature-gates.sh

**Priority:** Medium
**Estimated Time:** 1 hour

- [ ] **Extract feature gating**
  - [ ] Move `check_advanced_enabled()`
  - [ ] Move `require_advanced()`
  - [ ] Target: ~100 lines

- [ ] **Test feature gating**
  - [ ] Advanced commands gated properly
  - [ ] Error messages correct

- [ ] **Commit**
  - [ ] `git add cli/feature-gates.sh`
  - [ ] `git commit -m "refactor: extract feature gating to cli/feature-gates.sh"`

### Task 5.4: Simplify Main CLI

**File:** `ai-use-case` (main)
**Priority:** Critical
**Estimated Time:** 2 hours

- [ ] **Reduce to orchestration**
  - [ ] Source lib/core/version.sh
  - [ ] Source cli/router.sh
  - [ ] Source cli/help.sh
  - [ ] Source cli/feature-gates.sh
  - [ ] Call `route_command "$@"`
  - [ ] Target: ~150 lines

- [ ] **Test all commands**
  - [ ] Every command works
  - [ ] Help works
  - [ ] Feature gates work

- [ ] **Commit**
  - [ ] `git add ai-use-case`
  - [ ] `git commit -m "refactor: simplify main CLI to orchestration layer (710→150 lines)"`

### Task 5.5: Phase 5 Testing

**Priority:** Critical
**Estimated Time:** 1 hour

- [ ] **Run full test suite**
- [ ] **Test all CLI commands**
- [ ] **Commit phase completion**
  - [ ] Update CHANGELOG.md
  - [ ] `git tag phase-5-cli-simplify`

---

## Phase 6: Extract Integrations (Weeks 13-14) - LOW RISK

**Status:** Not Started
**Target:** Isolate external tool integration code

### Task 6.1: Create integrations/ Structure

**Priority:** High
**Estimated Time:** 10 minutes

- [ ] **Create directories**
  - [ ] `mkdir -p integrations/{claude-code,codex,git-hooks}`

- [ ] **Commit**
  - [ ] `git commit -m "feat: create integrations/ directory structure"`

### Task 6.2: Extract Claude Code Integration

**Priority:** High
**Estimated Time:** 2 hours

- [ ] **Create integrations/claude-code/install-commands.sh**
  - [ ] Extract from setup-project.sh
  - [ ] Symlink logic
  - [ ] Command manifest handling

- [ ] **Test independently**
  - [ ] Can install Claude commands
  - [ ] Symlinks created correctly

- [ ] **Commit**
  - [ ] `git commit -m "refactor: extract Claude Code integration"`

### Task 6.3: Extract Codex Integration

**Priority:** Medium
**Estimated Time:** 1 hour

- [ ] **Create integrations/codex/install-prompts.sh**
  - [ ] Extract from setup-project.sh
  - [ ] Prompt setup logic

- [ ] **Test independently**
- [ ] **Commit**

### Task 6.4: Extract Git Hooks Integration

**Priority:** Medium
**Estimated Time:** 1 hour

- [ ] **Create integrations/git-hooks/install-hooks.sh**
  - [ ] Extract from setup-project.sh
  - [ ] Hook installation logic

- [ ] **Test independently**
- [ ] **Commit**

### Task 6.5: Simplify setup-project.sh

**File:** `commands/project/setup.sh`
**Priority:** High
**Estimated Time:** 1 hour

- [ ] **Refactor to orchestrator**
  - [ ] Call integration modules
  - [ ] Handle user interaction
  - [ ] Target: ~300 lines

- [ ] **Test setup flow**
  - [ ] Full project setup works
  - [ ] All integrations installed

- [ ] **Commit**
  - [ ] `git commit -m "refactor: simplify setup-project to orchestrator"`

### Task 6.6: Phase 6 Testing

**Priority:** Critical
**Estimated Time:** 1 hour

- [ ] **Test fresh project setup**
  - [ ] `ai-use-case --init` in new project
  - [ ] Claude commands installed
  - [ ] Codex prompts installed
  - [ ] Git hooks installed

- [ ] **Commit phase completion**
  - [ ] Update CHANGELOG.md
  - [ ] `git tag phase-6-integrations`

---

## Phase 7: Reorganize Documentation (Weeks 15-16) - LOW RISK

**Status:** Not Started
**Target:** Clear discovery paths for users and contributors

### Task 7.1: Create docs/ Subdirectories

**Priority:** High
**Estimated Time:** 10 minutes

- [ ] **Create structure**
  - [ ] `mkdir -p docs/{guides,reference,architecture,development}`

- [ ] **Commit**
  - [ ] `git commit -m "feat: create organized docs/ structure"`

### Task 7.2: Move User Guides

**Priority:** High
**Estimated Time:** 1 hour

- [ ] **Move to docs/guides/**
  - [ ] CONFIGURATION.md → guides/configuration.md
  - [ ] WORKFLOW.md → guides/workflow.md
  - [ ] COMMANDS.md → guides/commands.md
  - [ ] Create guides/getting-started.md (new)

- [ ] **Update links**
  - [ ] Fix internal references
  - [ ] Update README.md links

- [ ] **Commit**
  - [ ] `git commit -m "docs: move user guides to docs/guides/"`

### Task 7.3: Move Technical Reference

**Priority:** Medium
**Estimated Time:** 1 hour

- [ ] **Move to docs/reference/**
  - [ ] TEMPLATE.md → reference/template.md
  - [ ] TEMPLATE-RESEARCH.md → reference/template-research.md
  - [ ] TRACING.md → reference/tracing.md
  - [ ] CONFLUENCE-INTEGRATION.md → reference/confluence.md

- [ ] **Update links**
- [ ] **Commit**

### Task 7.4: Create Architecture Documentation

**Priority:** High
**Estimated Time:** 2 hours

- [ ] **Create docs/architecture/**
  - [ ] overview.md (new) - System overview
  - [ ] library-structure.md (new) - lib/ documentation
  - [ ] diagrams/ - Move existing diagrams

- [ ] **Write architecture docs**
  - [ ] Explain layered architecture
  - [ ] Document module boundaries
  - [ ] Include dependency graphs

- [ ] **Commit**
  - [ ] `git commit -m "docs: create architecture documentation"`

### Task 7.5: Move Developer Documentation

**Priority:** Medium
**Estimated Time:** 1 hour

- [ ] **Move to docs/development/**
  - [ ] CONTRIBUTING.md → development/contributing.md
  - [ ] VERSION-MANAGEMENT.md → development/version-management.md
  - [ ] Create development/testing.md (new)

- [ ] **Update CONTRIBUTING.md**
  - [ ] Document new structure
  - [ ] Update file paths
  - [ ] Add lib/ contribution guidelines

- [ ] **Commit**

### Task 7.6: Create Index Files

**Priority:** Medium
**Estimated Time:** 1 hour

- [ ] **Create docs/README.md**
  - [ ] Main documentation index
  - [ ] Links to all sections

- [ ] **Create docs/guides/README.md**
  - [ ] Guide listing

- [ ] **Create docs/reference/README.md**
  - [ ] Reference index

- [ ] **Commit**
  - [ ] `git commit -m "docs: create documentation index files"`

### Task 7.7: Update Main README

**File:** `README.md`
**Priority:** High
**Estimated Time:** 30 minutes

- [ ] **Update with new structure**
  - [ ] Link to docs/
  - [ ] Update quick start
  - [ ] Update architecture section

- [ ] **Commit**
  - [ ] `git commit -m "docs: update README with new documentation structure"`

### Task 7.8: Phase 7 Testing

**Priority:** Medium
**Estimated Time:** 30 minutes

- [ ] **Verify all links**
  - [ ] No broken internal links
  - [ ] All references correct

- [ ] **Commit phase completion**
  - [ ] Update CHANGELOG.md
  - [ ] `git tag phase-7-docs`

---

## Phase 8: Update Tests & Final Polish (Weeks 17-18) - MEDIUM EFFORT

**Status:** Not Started
**Target:** Align tests with new structure and complete migration

### Task 8.1: Reorganize Test Suite

**Priority:** High
**Estimated Time:** 4 hours

- [ ] **Create test structure**
  - [ ] `mkdir -p tests/{lib,commands,integration}`

- [ ] **Move test files**
  - [ ] Existing tests → tests/integration/
  - [ ] New lib tests → tests/lib/
  - [ ] Command tests → tests/commands/

- [ ] **Update test_helper.bash**
  - [ ] Add lib/ test utilities
  - [ ] Update path resolution

- [ ] **Commit**
  - [ ] `git commit -m "test: reorganize test suite for new structure"`

### Task 8.2: Add Missing Test Coverage

**Priority:** High
**Estimated Time:** 3 hours

- [ ] **Unit tests for lib/ modules**
  - [ ] Ensure all modules tested
  - [ ] Target > 80% coverage

- [ ] **Command orchestration tests**
  - [ ] Test command → lib interaction

- [ ] **Integration workflow tests**
  - [ ] Full workflows tested

- [ ] **Commit**
  - [ ] `git commit -m "test: add comprehensive test coverage"`

### Task 8.3: Performance Testing

**Priority:** Medium
**Estimated Time:** 1 hour

- [ ] **Benchmark test suite**
  - [ ] Measure: `time ./run-tests.sh`
  - [ ] Target: < 60s
  - [ ] Verify no regression

- [ ] **Benchmark CLI commands**
  - [ ] Measure common commands
  - [ ] Ensure < 10% slowdown

- [ ] **Document results**
  - [ ] Record in CHANGELOG

### Task 8.4: Final Documentation Updates

**Priority:** High
**Estimated Time:** 2 hours

- [ ] **Complete CHANGELOG.md**
  - [ ] All 8 phases documented
  - [ ] Migration notes
  - [ ] Breaking changes (none)

- [ ] **Update CONTRIBUTING.md**
  - [ ] New structure fully documented
  - [ ] Examples for each layer

- [ ] **Create migration guide**
  - [ ] docs/guides/migration-v3-to-v4.md (for future)
  - [ ] Explain new structure

- [ ] **Commit**
  - [ ] `git commit -m "docs: complete documentation for layered architecture"`

### Task 8.5: Final Testing & Validation

**Priority:** Critical
**Estimated Time:** 2 hours

- [ ] **Run full test suite**
  - [ ] All tests pass
  - [ ] Test time < 60s

- [ ] **Manual smoke testing**
  - [ ] Test every CLI command
  - [ ] Test fresh project setup
  - [ ] Test upgrade scenario

- [ ] **Cross-platform testing**
  - [ ] Test on Linux
  - [ ] Test on macOS

- [ ] **Commit phase completion**
  - [ ] Update CHANGELOG.md
  - [ ] `git tag phase-8-final-polish`
  - [ ] `git tag v3.13.0` (if releasing)

---

## Post-Implementation

### PR Creation & Review

- [ ] **Create pull request**
  - [ ] Title: "feat: implement layered architecture restructure"
  - [ ] Description: Link to feature plan, requirements, checklist
  - [ ] List all 8 phases completed
  - [ ] Highlight backward compatibility

- [ ] **Code review**
  - [ ] Address review comments
  - [ ] Update based on feedback

- [ ] **Merge to main**
  - [ ] Squash or preserve phase commits (TBD)
  - [ ] Update version in main

### Release Preparation

- [ ] **Prepare release notes**
  - [ ] Highlight major improvements
  - [ ] Note backward compatibility
  - [ ] Include migration guide

- [ ] **Tag release**
  - [ ] `git tag v3.13.0`
  - [ ] Push tags

- [ ] **Announce release**
  - [ ] GitHub release notes
  - [ ] Update documentation site

### Post-Release Monitoring

- [ ] **Monitor for issues**
  - [ ] Watch for bug reports
  - [ ] Track user feedback

- [ ] **Plan future phases**
  - [ ] Evaluate v4.0.0 timeline
  - [ ] Consider removing symlinks

---

## Notes

- **Backward Compatibility:** All phases maintain backward compatibility via symlinks
- **Testing:** Each phase includes comprehensive testing before moving forward
- **Rollback:** Can pause or rollback at any phase boundary
- **Timeline:** Conservative 3-6 months, can accelerate if needed
- **Documentation:** Incremental documentation updates throughout

---

**Last Updated:** 2025-12-11
**Next Review:** After Phase 1 completion
