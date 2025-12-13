# Feature Plan: Layered Architecture Restructure

**Feature ID:** FEATURE-LAR-001
**Created:** 2025-12-11
**Status:** In Progress
**Priority:** High
**Complexity:** High

---

## Overview

Restructure the ai-use-case-cli repository to establish a clear layered architecture that separates concerns between sourced libraries (lib/), executable commands (commands/), user interface (cli/), and external integrations (integrations/). This addresses critical organizational issues including monolithic scripts, unclear module boundaries, and mixed concerns.

## Problem Statement

The current codebase has grown organically and faces several organizational challenges:

1. **Monolithic Scripts**: config-manager.sh (1,063 lines) handles 4 distinct domains (hub config, features, tracing, confluence). document-ai-session.sh (985 lines) mixes concerns.

2. **Unclear Boundaries**: No clear distinction between sourced libraries and executable scripts. The scripts/utils/ directory mixes both types, leading to confusion about dependencies and responsibilities.

3. **Mixed Concerns**: The main CLI (710 lines) handles command routing, help text generation, and feature gating all in one file.

4. **Fragile Dependencies**: Relative sourcing patterns (`../../utils/config-manager.sh`) make the codebase brittle. No standardized library pattern.

5. **Poor Discoverability**: New contributors struggle to understand where code belongs and how modules relate to each other.

Without addressing these issues, the codebase will become increasingly difficult to maintain, test, and extend.

## Goals

### Primary Goals

1. **Establish Clear Layers** - Create distinct layers for libraries, commands, CLI interface, and integrations
2. **Split Monolithic Scripts** - Break down config-manager.sh and document-ai-session.sh into focused modules (< 400 lines each)
3. **Improve Maintainability** - Make it easy to find, understand, and modify code
4. **Maintain Backward Compatibility** - Ensure existing installations and scripts continue working

### Non-Goals

- Complete rewrite of functionality (preserve existing behavior)
- Breaking changes to CLI interface or configuration format
- Performance optimization (not the primary focus)
- Adding new features (pure refactoring)

## Success Criteria

1. ✅ All files < 400 lines (currently max: 1,063)
2. ✅ Clear directory structure with lib/, commands/, cli/, integrations/
3. ✅ 100% backward compatibility maintained (all tests pass)
4. ✅ Zero breaking changes to public APIs
5. ✅ Test suite runs in < 60s (currently ~90s)
6. ✅ New contributor onboarding < 30 min (currently ~2+ hours)
7. ✅ Documentation clearly explains new structure

## Proposed Solution

### High-Level Approach

Implement a phased migration over 3-6 months, establishing a four-layer architecture:

1. **lib/** - Pure libraries that are sourced by other scripts (never executed directly)
2. **commands/** - Executable business logic organized by domain
3. **cli/** - User interface layer (routing, help, feature gates)
4. **integrations/** - External tool integrations (Claude Code, Codex, git hooks)

The migration will use symlinks to maintain backward compatibility, allowing us to reorganize without breaking existing code. Each phase will be independently testable and deployable.

### Detailed Design

#### Layer 1: lib/ - Pure Libraries

**Purpose:** Centralize reusable code that other scripts source

**Structure:**
```
lib/
├── core/          # Fundamental utilities (version, constants, errors)
├── config/        # Configuration modules (hub, features, tracing, confluence)
├── hub/           # Hub operations (locator, validator, git)
├── project/       # Project registry (I/O, queries)
├── agents/        # Agent framework (registry, invoker)
├── observability/ # Tracing, progress tracking
└── utils/         # Shared utilities
```

**Implementation:**
- Move existing utilities from scripts/utils/ to appropriate lib/ subdirectories
- Create symlinks in old locations for backward compatibility
- Split monolithic scripts into focused modules (one responsibility per file)

**Example:**
```bash
# New sourcing pattern
source "$SCRIPT_DIR/../lib/core/constants.sh"
source "$SCRIPT_DIR/../lib/config/config-hub.sh"

# Old pattern still works via symlinks
source "$SCRIPT_DIR/../utils/config-manager.sh"  # → lib/config/* (facade)
```

#### Layer 2: commands/ - Executable Commands

**Purpose:** Business logic organized by domain

**Structure:**
```
commands/
├── document/      # Document session, extract, publish
├── hub/           # Sync, push, view
├── search/        # Search, stats
├── project/       # Setup, link, list, update
├── agents/        # Registry, quality, pattern
├── config/        # Show, reconfigure, init
└── maintenance/   # Reset, update, install, uninstall
```

**Implementation:**
- Move scripts from scripts/{core,project,search,agents,hub,install,utils} to commands/
- Rename for clarity (e.g., sync-ai-use-cases.sh → commands/hub/sync.sh)
- Update imports to use lib/ modules
- Create symlinks in old locations

#### Layer 3: cli/ - User Interface

**Purpose:** Routing, help generation, feature gating

**Components:**
- `cli/router.sh` - Command dispatch using routing table
- `cli/help.sh` - Help text generation
- `cli/feature-gates.sh` - Advanced feature gating

**Implementation:**
- Extract from main CLI (710 lines → 150 lines)
- Use declarative routing table instead of large case statement
- Auto-generate help from command metadata

#### Layer 4: integrations/ - External Tools

**Purpose:** Self-contained integration modules

**Structure:**
```
integrations/
├── claude-code/   # Claude Code symlink setup
├── codex/         # Codex prompt installation
└── git-hooks/     # Git hooks installation
```

**Implementation:**
- Extract from setup-project.sh
- Each integration self-contained and testable
- Easy to add new AI tools

### User Experience

**Before this feature:**
```bash
# Developer trying to find where hub configuration is managed
$ grep -r "get_hub_path" .
# Returns 20+ results across multiple files
# Unclear which is the source vs which uses it
# Must read 1000+ line files to understand

# Time to understand: 30+ minutes
```

**After this feature:**
```bash
# Clear structure immediately visible
$ ls lib/config/
config-core.sh config-hub.sh config-features.sh ...

# Find implementation instantly
$ grep -r "get_hub_path" lib/config/
lib/config/config-hub.sh:get_hub_path() { ... }

# Small, focused files
$ wc -l lib/config/config-hub.sh
200 lib/config/config-hub.sh

# Time to understand: 2-5 minutes
```

## Technical Architecture

### Components Affected

1. **scripts/utils/config-manager.sh** → Split into 6 modules in lib/config/
2. **scripts/core/document-ai-session.sh** → Split into 3 modules in lib/document/ + commands/document/
3. **scripts/utils/{version,tracing,progress-tracker}.sh** → Move to lib/{core,observability}/
4. **ai-use-case (main CLI)** → Extract routing to cli/router.sh, help to cli/help.sh
5. **scripts/project/setup-project.sh** → Extract integrations to integrations/
6. **30+ command scripts** → Reorganize into commands/ hierarchy
7. **docs/** → Reorganize into guides/, reference/, architecture/, development/
8. **tests/** → Align with new structure (lib/, commands/, integration/)

### Data Flow

```
User Input
    ↓
ai-use-case (main CLI)
    ↓
cli/router.sh (dispatch)
    ↓
commands/{domain}/{command}.sh (business logic)
    ↓
lib/{category}/{module}.sh (shared utilities)
    ↓
System/External APIs
```

### Dependencies

**Internal:**
- All command scripts depend on lib/ modules
- CLI layer depends on lib/core/ for version, constants
- Integration tests depend on commands/ being stable

**External:**
- jq (JSON processing)
- BATS (testing framework)
- git (version control, hub operations)
- Python 3.8+ (tracing functionality)

## Integration Branch Workflow

To safely integrate this large multi-phase refactor, we use a dedicated integration branch before merging to main.

### Branch Strategy

```
Feature branches → integration/layered-architecture → main
```

**Integration Branch:** `integration/layered-architecture`
- Created from: `main` (latest stable)
- Purpose: Integrate all 8 phases before final merge to main
- Benefits: Allows incremental development with integration testing

### Workflow for Each Phase

**1. Branch Creation**
```bash
# Start from integration branch (not main)
git checkout integration/layered-architecture
git pull
git checkout -b feature/layered-architecture-phase<N>
```

**2. Development**
- Implement phase according to plan
- Follow backward compatibility requirements
- Write/update tests
- Update documentation

**3. Pull Request**
- Target: `integration/layered-architecture` (not `main`)
- Title: `feat: Phase N - <Description>`
- Include: Testing results, migration notes, rollback plan

**4. Review & Merge**
- Code review
- Integration testing on the integration branch
- Merge to `integration/layered-architecture`

**5. Final Integration (After All Phases)**
- Create PR: `integration/layered-architecture` → `main`
- Comprehensive testing of all integrated phases
- Final review and merge to main

### Benefits

✅ **Incremental Development** - Each phase developed and reviewed independently
✅ **Integration Testing** - All phases tested together before main
✅ **Main Stability** - Main branch remains stable during refactor
✅ **Easy Rollback** - Can revert individual phases in integration branch
✅ **Clear Progress** - Track phase completion in single integration branch

### Phase Status Tracking

| Phase | Status | PR | Merged to Integration |
|-------|--------|----|-----------------------|
| Phase 1: Foundation | In Review | #165 | ⏳ Pending |
| Phase 2: Split config-manager.sh | Not Started | - | - |
| Phase 3: Reorganize Commands | Not Started | - | - |
| Phase 4: Split Large Files | Not Started | - | - |
| Phase 5: Standardize Interfaces | Not Started | - | - |
| Phase 6: CLI Refactor | Not Started | - | - |
| Phase 7: Documentation | Not Started | - | - |
| Phase 8: Cleanup | Not Started | - | - |

---

## Implementation Phases

### Phase 1: Foundation (Weeks 1-2) - LOW RISK

**Goals:**
- Establish lib/ directory structure
- Move foundational utilities
- Create constants module
- Verify backward compatibility

**Tasks:**
- Create lib/{core,config,hub,project,agents,observability,utils}
- Move version.sh, tracing.sh, progress-tracker.sh with symlinks
- Create lib/core/constants.sh
- Run test suite to verify

### Phase 2: Split config-manager.sh (Weeks 3-4) - HIGH VALUE

**Goals:**
- Break down 1,063-line monolith
- Create focused config modules
- Maintain API compatibility

**Tasks:**
- Create 6 modules in lib/config/
- Convert config-manager.sh to facade
- Write unit tests for each module
- Integration test entire config system

### Phase 3: Reorganize Commands (Weeks 5-7) - LOW RISK

**Goals:**
- Separate libraries from executables
- Establish clear commands/ hierarchy
- Update imports to use lib/

**Tasks:**
- Create commands/ subdirectories
- Move 30+ scripts with symlinks
- Update import paths
- Verify CLI dispatcher works

### Phase 4: Split Large Files (Weeks 8-10) - MEDIUM RISK

**Goals:**
- Modularize document-ai-session.sh
- Split hub-utils.sh and registry-manager.sh
- Improve testability

**Tasks:**
- Create document extraction/formatter modules
- Split hub utilities into 3 modules
- Split registry into I/O and queries
- Write tests for new modules

### Phase 5: Simplify Main CLI (Weeks 11-12) - MEDIUM RISK

**Goals:**
- Reduce main CLI to ~150 lines
- Extract routing, help, feature gates
- Improve extensibility

**Tasks:**
- Create cli/ layer modules
- Implement routing table
- Extract help generation
- Update main CLI to orchestrate

### Phase 6: Extract Integrations (Weeks 13-14) - LOW RISK

**Goals:**
- Isolate integration code
- Simplify setup-project.sh
- Enable easy addition of new tools

**Tasks:**
- Create integrations/ modules
- Extract from setup-project.sh
- Write integration tests

### Phase 7: Reorganize Documentation (Weeks 15-16) - LOW RISK

**Goals:**
- Clear discovery paths
- Organized by audience
- Complete migration guide

**Tasks:**
- Create docs/{guides,reference,architecture,development}
- Move existing docs to appropriate locations
- Create index files
- Update all internal links

### Phase 8: Final Polish (Weeks 17-18) - MEDIUM EFFORT

**Goals:**
- Align tests with structure
- Complete documentation
- Prepare for release

**Tasks:**
- Reorganize test suite
- Add missing test coverage
- Update CONTRIBUTING.md
- Create migration guide

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking existing installations | High | Low | Symlinks maintain backward compat; comprehensive testing |
| Test suite doesn't catch all issues | High | Medium | Manual smoke testing; phased rollout; user feedback |
| Team velocity slows during migration | Medium | High | Clear phases; can pause between phases; incremental releases |
| New structure confusing to existing contributors | Medium | Medium | Comprehensive documentation; onboarding guide; clear examples |
| Config-manager split introduces bugs | High | Low | Extensive unit tests; facade maintains API; integration tests |
| Timeline extends beyond 6 months | Low | Medium | Conservative estimates; can defer non-critical phases |

## Future Enhancements

**Phase 2 (Future):**
- Plugin system for extensible commands
- Auto-discovery of commands in commands/
- Command metadata for dynamic help generation
- Module dependency graph visualization

**Long-term vision:**
- Clean enough architecture to consider TypeScript/Python port
- CLI becomes thin orchestrator over well-tested modules
- Community contributions easier with clear structure
- Foundation for v4.0.0 with potential breaking changes

## Related Documentation

- [CONTRIBUTING.md](../../CONTRIBUTING.md) - Contribution guidelines
- [docs/features/FEATURE-TEMPLATE/](../FEATURE-TEMPLATE/) - Feature planning template
- [Architecture Diagrams](../../diagrams/) - System architecture

## References

- [Clean Architecture Principles](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Bash Style Guide](https://google.github.io/styleguide/shellguide.html)
- [Modular Shell Scripts](https://mywiki.wooledge.org/BashFAQ/050)

---

**Next Steps:**
1. ✅ Create feature plan (this document)
2. ⏳ Generate detailed requirements (02-requirements.md)
3. ⏳ Create implementation checklist (03-implementation-checklist.md)
4. ⏳ Begin Phase 1 implementation
