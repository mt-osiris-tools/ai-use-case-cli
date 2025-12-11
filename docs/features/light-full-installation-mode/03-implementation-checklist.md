# Implementation Checklist: Light/Full Installation Mode

**Feature ID:** FEATURE-LIGHT-FULL-INSTALL
**Status:** Complete

---

## Pre-Implementation

- [x] Create feature plan document
- [x] Define command classification (core vs advanced)
- [x] Create implementation checklist (this document)
- [x] Create feature branch

## Phase 1: Configuration & Registry

### Step 1.1: Update config-manager.sh

**File:** `scripts/utils/config-manager.sh`

- [x] Add `installMode` field to config schema
- [x] Add `advancedEnabled` field to config schema
- [x] Add `is_advanced_enabled()` helper function
- [x] Implement backward compatibility (missing fields = full access)
- [x] Add `set_install_mode()` function
- [x] Add `get_install_mode()` function

### Step 1.2: Create feature-registry.sh

**File:** `scripts/utils/feature-registry.sh` (NEW)

- [x] Create file with header comments
- [x] Define CORE_CLI_COMMANDS array
- [x] Define ADVANCED_CLI_COMMANDS array
- [x] Define CORE_SLASH_COMMANDS array
- [x] Define ADVANCED_SLASH_COMMANDS array

## Phase 2: CLI Mode Awareness

### Step 2.1: Update show_help()

**File:** `ai-use-case` (lines 49-126)

- [x] Source feature-registry.sh
- [x] Check advancedEnabled config value
- [x] Reorganize help to show core commands first
- [x] Conditionally show advanced commands section
- [x] Add "MORE FEATURES" section with unlock hint when disabled

### Step 2.2: Add require_advanced() gate

**File:** `ai-use-case`

- [x] Add `require_advanced()` helper function
- [x] Show friendly unlock message when disabled
- [x] Gate `agents)` command
- [x] Gate `review-quality)` command
- [x] Gate `analyze-patterns)` command
- [x] Gate `extract)` command
- [x] Gate `tracing)` command
- [x] Gate `bump-version)` command

### Step 2.3: Add new commands

**File:** `ai-use-case`

- [x] Add `enable-advanced)` handler
  - [x] Show feature description
  - [x] Confirm with user
  - [x] Set advancedEnabled: true
  - [x] Show success message with next steps
- [x] Add `disable-advanced)` handler
  - [x] Set advancedEnabled: false
  - [x] Show note about existing commands
- [x] Add `status)` handler
  - [x] Show version
  - [x] Show install mode
  - [x] Show advanced enabled status
  - [x] Show hub configuration

## Phase 3: Installation & Setup

### Step 3.1: Update install.sh

**File:** `scripts/install/install.sh`

- [x] Add flag parsing for --full and --light
- [x] Add mode selection prompt for fresh installs
- [x] Write installMode to config
- [x] Write advancedEnabled to config
- [x] Update completion message based on mode
- [x] Show relevant commands based on mode

### Step 3.2: Create manifest.json

**File:** `.ai-tools/commands/use-case/manifest.json` (NEW)

- [x] Create JSON structure with commands object
- [x] Mark core commands: document-session, setup-project, sync-usecases, search-usecases, list-projects, check-updates, update-project, publish-confluence, quick-start
- [x] Mark advanced commands: analyze-patterns, review-quality, extract-session

### Step 3.3: Update setup-project.sh

**File:** `scripts/project/setup-project.sh`

- [x] Add function to read install mode from config
- [x] Add function to parse manifest.json (with jq fallback)
- [x] Filter commands based on mode during installation
- [x] Show info message about available advanced commands
- [x] Preserve existing advanced commands during --update

### Step 3.4: Update link-claude.sh

**File:** `scripts/project/link-claude.sh`

- [x] Make mode-aware when listing installed commands

## Testing

### Unit Tests

- [x] Test is_advanced_enabled() returns true for legacy configs
- [x] Test is_advanced_enabled() returns false for light mode
- [x] Test is_advanced_enabled() returns true for full mode
- [x] Test enable-advanced sets correct config
- [x] Test disable-advanced sets correct config

### Integration Tests

- [x] Fresh install defaults to light mode
- [x] Fresh install with --full flag enables all features
- [x] ai-use-case --help shows only core commands in light mode
- [x] ai-use-case --help shows all commands after enable-advanced
- [x] Advanced commands show unlock message in light mode
- [x] Advanced commands work after enable-advanced
- [x] ai-use-case status displays current configuration correctly
- [x] ai-use-case --init installs only core slash commands in light mode
- [x] ai-use-case --init --update after enable-advanced adds advanced slash commands
- [x] Existing installations (no installMode) have full access

### Manual Testing

- [x] Test curl installation flow (light mode)
- [x] Test curl installation flow with --full
- [x] Test project setup in light mode
- [x] Test enable-advanced → project update flow
- [x] Verify backward compatibility with existing projects

## Documentation

- [ ] Update README.md with installation modes info
- [ ] Update COMMANDS.md with new commands (enable-advanced, disable-advanced, status)
- [ ] Update CONFIGURATION.md with new config fields

## Final Steps

- [x] All tests passing
- [ ] Documentation updated
- [x] PR created
- [ ] PR reviewed and approved
- [ ] Merged to main
- [ ] Version bumped

---

**Progress:** 47/50 tasks completed (documentation pending)
