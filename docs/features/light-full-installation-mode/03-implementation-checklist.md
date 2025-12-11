# Implementation Checklist: Light/Full Installation Mode

**Feature ID:** FEATURE-LIGHT-FULL-INSTALL
**Status:** In Progress

---

## Pre-Implementation

- [x] Create feature plan document
- [x] Define command classification (core vs advanced)
- [x] Create implementation checklist (this document)
- [ ] Create feature branch

## Phase 1: Configuration & Registry

### Step 1.1: Update config-manager.sh

**File:** `scripts/utils/config-manager.sh`

- [ ] Add `installMode` field to config schema
- [ ] Add `advancedEnabled` field to config schema
- [ ] Add `is_advanced_enabled()` helper function
- [ ] Implement backward compatibility (missing fields = full access)
- [ ] Add `set_install_mode()` function
- [ ] Add `get_install_mode()` function

### Step 1.2: Create feature-registry.sh

**File:** `scripts/utils/feature-registry.sh` (NEW)

- [ ] Create file with header comments
- [ ] Define CORE_CLI_COMMANDS array
- [ ] Define ADVANCED_CLI_COMMANDS array
- [ ] Define CORE_SLASH_COMMANDS array
- [ ] Define ADVANCED_SLASH_COMMANDS array

## Phase 2: CLI Mode Awareness

### Step 2.1: Update show_help()

**File:** `ai-use-case` (lines 49-126)

- [ ] Source feature-registry.sh
- [ ] Check advancedEnabled config value
- [ ] Reorganize help to show core commands first
- [ ] Conditionally show advanced commands section
- [ ] Add "MORE FEATURES" section with unlock hint when disabled

### Step 2.2: Add require_advanced() gate

**File:** `ai-use-case`

- [ ] Add `require_advanced()` helper function
- [ ] Show friendly unlock message when disabled
- [ ] Gate `agents)` command
- [ ] Gate `review-quality)` command
- [ ] Gate `analyze-patterns)` command
- [ ] Gate `extract)` command
- [ ] Gate `tracing)` command
- [ ] Gate `bump-version)` command

### Step 2.3: Add new commands

**File:** `ai-use-case`

- [ ] Add `enable-advanced)` handler
  - [ ] Show feature description
  - [ ] Confirm with user
  - [ ] Set advancedEnabled: true
  - [ ] Show success message with next steps
- [ ] Add `disable-advanced)` handler
  - [ ] Set advancedEnabled: false
  - [ ] Show note about existing commands
- [ ] Add `status)` handler
  - [ ] Show version
  - [ ] Show install mode
  - [ ] Show advanced enabled status
  - [ ] Show hub configuration

## Phase 3: Installation & Setup

### Step 3.1: Update install.sh

**File:** `scripts/install/install.sh`

- [ ] Add flag parsing for --full and --light
- [ ] Add mode selection prompt for fresh installs
- [ ] Write installMode to config
- [ ] Write advancedEnabled to config
- [ ] Update completion message based on mode
- [ ] Show relevant commands based on mode

### Step 3.2: Create manifest.json

**File:** `.ai-tools/commands/use-case/manifest.json` (NEW)

- [ ] Create JSON structure with commands object
- [ ] Mark core commands: document-session, setup-project, sync-usecases, search-usecases, list-projects, check-updates, update-project, publish-confluence, quick-start
- [ ] Mark advanced commands: analyze-patterns, review-quality, extract-session

### Step 3.3: Update setup-project.sh

**File:** `scripts/project/setup-project.sh`

- [ ] Add function to read install mode from config
- [ ] Add function to parse manifest.json (with jq fallback)
- [ ] Filter commands based on mode during installation
- [ ] Show info message about available advanced commands
- [ ] Preserve existing advanced commands during --update

### Step 3.4: Update link-claude.sh

**File:** `scripts/project/link-claude.sh`

- [ ] Make mode-aware when listing installed commands

## Testing

### Unit Tests

- [ ] Test is_advanced_enabled() returns true for legacy configs
- [ ] Test is_advanced_enabled() returns false for light mode
- [ ] Test is_advanced_enabled() returns true for full mode
- [ ] Test enable-advanced sets correct config
- [ ] Test disable-advanced sets correct config

### Integration Tests

- [ ] Fresh install defaults to light mode
- [ ] Fresh install with --full flag enables all features
- [ ] ai-use-case --help shows only core commands in light mode
- [ ] ai-use-case --help shows all commands after enable-advanced
- [ ] Advanced commands show unlock message in light mode
- [ ] Advanced commands work after enable-advanced
- [ ] ai-use-case status displays current configuration correctly
- [ ] ai-use-case --init installs only core slash commands in light mode
- [ ] ai-use-case --init --update after enable-advanced adds advanced slash commands
- [ ] Existing installations (no installMode) have full access

### Manual Testing

- [ ] Test curl installation flow (light mode)
- [ ] Test curl installation flow with --full
- [ ] Test project setup in light mode
- [ ] Test enable-advanced → project update flow
- [ ] Verify backward compatibility with existing projects

## Documentation

- [ ] Update README.md with installation modes info
- [ ] Update COMMANDS.md with new commands (enable-advanced, disable-advanced, status)
- [ ] Update CONFIGURATION.md with new config fields

## Final Steps

- [ ] All tests passing
- [ ] Documentation updated
- [ ] PR created
- [ ] PR reviewed and approved
- [ ] Merged to main
- [ ] Version bumped

---

**Progress:** 3/50 tasks completed
