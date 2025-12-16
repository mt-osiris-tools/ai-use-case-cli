# Changelog

All notable changes to the AI Use Case CLI project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Enhanced CLAUDE.md Documentation**: Comprehensive guidance for Claude Code instances working in this repository
  - **Project Overview**: Clear explanation of CLI structure, shell scripts, git hooks, slash commands, and library modules
  - **Essential Commands**: Testing and development commands with examples
  - **Code Architecture**: Repository structure, main CLI flow, dual-repository architecture, configuration system, and script patterns
  - **Critical Development Rules**: Branch workflow, version management, documentation revision rules, shell script standards, and security guidelines
  - **Session Documentation Types**: Implementation vs research sessions with formats and templates
  - **Advanced Features**: Gating, cross-platform compatibility, and integration points
  - **Common Development Tasks**: Step-by-step guides for adding commands, modifying hub interaction, and adding feature flags
  - **Anti-Patterns**: Clear DO/DON'T examples for best practices

- **Markdown Linting Validation for Confluence Publishing**: Automatically validate and fix markdown formatting issues when publishing to Confluence
  - **Auto-fix by default**: When `markdownlint-cli` is installed, the `publish-confluence` script automatically fixes markdown linting issues using all default markdownlint rules
  - **New Flag**: `--no-autofix` option to skip automatic markdown fixes
  - **Graceful degradation**: Works seamlessly whether markdownlint is installed or not
  - **Configuration file**: Added `.markdownlint.json` with project-standard linting rules (disables line-length, inline-html, and first-line-heading checks while enabling all other standard rules)
  - **User-friendly messages**: Clear feedback when linting/fixing occurs or when markdownlint is not installed
  - **Documentation**: Updated README.md with optional dependency installation instructions

## [3.13.0] - 2025-12-15

### Added

- **Phase 4: Session Selector Agent** - Intelligent session analysis and prioritization for documentation
  - **New Agent**: Session Selector Agent (`use-case-session-selector-agent`) for analyzing and scoring documentation sessions
  - **New Flag**: `--intelligent` flag for `/use-case:document-session` command enables AI-powered session prioritization
  - **Priority Scoring**: Assigns scores (0-10) to PRs, commits, and research sessions based on documentation value
  - **Priority Levels**: Groups sessions as HIGH (8-10), MEDIUM (5-7), LOW (2-4), or SKIP (0-1) with clear recommendations
  - **Commit Grouping**: Automatically groups related commits by time proximity, file overlap, and message similarity
  - **Metadata Extraction**: Pre-populates template fields (ticket number, complexity, time saved, technologies) for faster documentation
  - **Already Documented Detection**: Identifies and filters out sessions that have already been documented
  - **Enhanced Presentation**: Shows prioritized sessions with scores, reasoning, and recommendations in document-session workflow
  - **Agent Prompt**: Comprehensive scoring criteria based on complexity, novelty, reusability, impact, and quality
  - **Agent Registry**: Session-selector agent enabled by default in agent registry template
  - **Documentation**: Updated COMMANDS.md with detailed --intelligent flag usage guide and examples
  - **Documentation**: Updated agents framework README with Phase 4 implementation details

- **GitHub Copilot Custom Prompts Integration**: Full support for GitHub Copilot custom prompts in VS Code
  - **New Command**: `ai-use-case --setup-copilot` to configure GitHub Copilot custom prompts
  - **Custom Prompts**: Workspace-specific `.github/prompts/use-case/` directory with 5 core prompts:
    - `document-session.prompt.md` - Document AI coding sessions automatically
    - `setup-project.prompt.md` - Setup project for documentation
    - `sync-usecases.prompt.md` - Sync use cases from project to hub
    - `search-usecases.prompt.md` - Search documented use cases
    - `quick-start.prompt.md` - Quick start guide for first-time users
  - **Symlink Architecture**: Project prompts symlink to CLI installation for automatic updates
  - **Agent Selection**: GitHub Copilot added to agent selection menu during `--init`
  - **Multiple Agent Support**: Enhanced agent selection to support multiple simultaneous agents (Claude + Copilot + Codex)
  - **Setup Script**: `scripts/project/setup-copilot.sh` handles prompt symlink creation
  - **Documentation**: New `docs/agents/copilot/GUIDE.md` with comprehensive setup and usage instructions
  - **YAML Frontmatter**: All prompts include description metadata for discoverability in VS Code

- **Codex CLI Integration**: Support for Codex-style CLI tools with slash commands
  - **Note**: This integration provides slash command prompts compatible with CLI tools that use
    the Codex CLI pattern (YAML frontmatter, `/prompts:` invocation). This does NOT use the
    deprecated OpenAI Codex completion API, but rather provides user-global prompt files for
    compatible CLI coding assistants.
  - **New Command**: `ai-use-case --setup-codex` to install Codex prompts into user's home directory
  - **Codex Prompts**: User-global `~/.codex/prompts/` directory with YAML frontmatter
    - `use-case-document-session.md` - Document AI sessions with hybrid parameters
    - `use-case-publish-confluence.md` - Publish to Confluence via REST API
  - **Hybrid Parameters**: Optional named parameters with interactive fallback
  - **Setup Script**: `scripts/project/setup-codex.sh` handles prompt installation and updates
  - **Documentation**: Updated README and USAGE-GUIDE with Codex CLI integration details

- **Decoupled .ai-tools Setup**: `.ai-tools` folder is now created during `--init` even without `.claude` folder
  - **New Command**: `ai-use-case --link-claude` to create Claude Code symlinks on demand
  - **Improved Flexibility**: Users can set up ai-use-case before installing Claude Code
  - **Informational Messages**: Clear guidance when `.claude` folder is missing during setup
  - **Idempotent**: Both `--init` and `--link-claude` can be safely run multiple times
  - **Tests**: Comprehensive bats tests for all new functionality

- **Automated Test Suite**: Comprehensive bats-core testing framework for CI/CD and development
  - **Test Framework**: bats-core with bats-support, bats-assert, and bats-file libraries (git submodules)
  - **Test Runner**: `./run-tests.sh` script with filtering, verbose mode, and TAP output support
  - **Test Coverage**: 10 test files covering 190 tests across all core functionality
    - `version.bats` - Version system and semver validation
    - `config-manager.bats` - Configuration management functions
    - `hub-utils.bats` - Hub utility functions
    - `cli-commands.bats` - Main CLI entry point and commands
    - `search.bats` - Search functionality
    - `stats.bats` - Statistics generation
    - `sync.bats` - Hub synchronization
    - `setup-project.bats` - Project initialization
    - `registry.bats` - Project registry management
    - `integration.bats` - End-to-end workflow tests
  - **Test Isolation**: Temporary directories and HOME override for safe testing
  - **Documentation**: Updated CONTRIBUTING.md and README.md with testing instructions

- **Pattern Analysis Agent** (Phase 3 - Intelligent Agents Integration): Full implementation of pattern analysis capabilities
  - **Agent Prompt**: Created `.ai-tools/agents/use-case-pattern-agent.md` with comprehensive analysis methodology
    - Pattern detection (session types, complexity, tools, ticket types)
    - Trend analysis (documentation frequency, quality trends, time savings)
    - Project classification (type, maturity, focus area)
    - Prioritized recommendations with expected impact
  - **CLI Wrapper**: Added `scripts/agents/pattern-agent.sh` for pattern analysis
    - Project-level and hub-wide analysis modes
    - Period filtering (1month, 3months, 6months, 1year, custom ranges)
    - Document collection with date filtering
    - Text and JSON output formats
    - Quality scores and project comparison options
  - **CLI Command**: `ai-use-case analyze-patterns [options]`
    - `--project <name>`: Analyze specific project from hub
    - `--hub`: Analyze all projects in hub
    - `--period <period>`: Filter by time period
    - `--compare`: Compare projects in hub mode
    - `--format <json|text>`: Output format
  - **Slash Command**: `/use-case:analyze-patterns` for Claude Code integration
    - Interactive scope selection
    - Configurable analysis options
    - Visual trend displays
    - Actionable recommendations
  - **Documentation**: Updated `docs/agents/framework/README.md` with Phase 3 completion status

- **Comprehensive Documentation Restructure**: Enhanced documentation organization with dedicated guides
  - **docs/USAGE-GUIDE.md** (NEW): Complete usage guide with detailed command reference, session types, file naming conventions, and workflow details
  - **docs/CONFIGURATION.md** (NEW): Comprehensive configuration guide covering hub modes, environment variables, tracing setup, project registry, and git hooks
  - **docs/FEATURES.md** (NEW): Detailed feature descriptions with version history, comparison matrix, and use cases

### Changed

- **BREAKING: Codex Prompts Now Global**: Codex-style CLI prompts are now installed in the home directory (`~/.codex/prompts/`) instead of project-local directories
  - **Migration**: Project-local `.codex/prompts/` directories are no longer used and can be safely deleted
  - **Benefit**: Prompts are now available globally across all projects
  - **Affected Files**: `scripts/project/setup-codex.sh`, tests, and documentation updated
  - **User Action Required**: Run `ai-use-case --setup-codex` again to install prompts in home directory, then delete old project-local `.codex/` folders

- **README.md Streamlined**: Reduced from 526 to 322 lines (39% reduction) for better readability
  - Removed version-specific noise (v3.x.x+ annotations throughout)
  - Condensed features list from 13 to 8 high-level points
  - Simplified table of contents from 18 to 10 items
  - Moved detailed sections to dedicated documentation files
  - Added clear "Learn More" section with organized documentation links
  - Focus on quick start flow rather than comprehensive reference
- **CONTRIBUTING.md**: Updated documentation references to include new guide structure
  - Added references to USAGE-GUIDE.md, CONFIGURATION.md, and FEATURES.md
  - Updated version consistency table with new documentation files

### Fixed

- **Symlink Creation - Absolute Paths**: Simplified symlink creation by using absolute paths instead of Python-based relative paths
  - **Issue**: Initial implementation used Python (`python3 -c "import os; print(os.path.relpath(...))"`) for cross-platform relative path calculation to avoid macOS `realpath` unavailability
  - **Decision**: Switched to absolute paths for simplicity - no external dependencies required
  - **Trade-off**: Symlinks break if CLI installation moves, but user can re-run setup command (rare scenario)
  - **Benefit**: No Python dependency, simpler code, works on all platforms without additional tools
  - **Affected files**:
    - `scripts/project/setup-copilot.sh:78-80` - Copilot prompt symlink creation
    - `scripts/core/sync-ai-use-cases.sh:275-280` - By-date symlink creation
    - `scripts/core/sync-ai-use-cases.sh:297-302` - By-topic symlink creation
  - **Impact**: Cleaner implementation with zero external dependencies beyond bash and ln

- **Documentation Accuracy**: Ensured correct slash format in quick-start.prompt.md during development (PR #178)
  - Claude Code commands use `/use-case:command` (colon) instead of `/use-case/command` (slash)
  - Following old instructions would have failed to match any command, but the file was added with the correct format from the start
  - File added in PR #178 with correct format: `.github/prompts/use-case/quick-start.prompt.md:91-95`

## [3.12.0] - 2025-12-07

### Added

- **PlantUML Activity Diagrams**: Added comprehensive activity diagrams for all major CLI commands
  - **New directory**: `docs/diagrams/plantuml/` with 9 PlantUML diagrams
  - **Diagrams created**:
    - `installation-flow.puml` - CLI installation process
    - `init-command-flow.puml` - Project initialization with migration handling
    - `sync-command-flow.puml` - Documentation sync to hub with symlink creation
    - `document-session-flow.puml` - AI-powered session documentation
    - `search-command-flow.puml` - Search and statistics commands
    - `project-management-flow.puml` - Project registry management (list/check/update)
    - `config-command-flow.puml` - Hub configuration management
    - `publish-confluence-flow.puml` - Confluence publishing workflow
    - `agent-commands-flow.puml` - Agent framework operations
  - **Documentation**: Created `plantuml/README.md` with viewing instructions and conventions
  - **Updated**: Main `docs/diagrams/README.md` to index PlantUML diagrams
  - **Benefits**: Visual documentation of command execution flows, easier onboarding, clearer understanding of complex workflows
  - **Color coding**: Success (Green #90EE90), Actions (Light Blue #87CEEB), AI operations (Lavender #E6E6FA), Git operations (Yellow #FFFF99), etc. See `docs/diagrams/plantuml/README.md` for full color conventions.

- **Agent Framework Component Diagram**: Added new C4 Component Diagram for Agent Framework
  - Shows internal components: agent-registry.sh, invoke-agent.sh, quality-agent.sh, and agent prompts
  - Visualizes agent lifecycle management, invocation flow, and integration points
  - Includes notes on key features (caching, statistics, timeout handling) and registry management
  - Located at `docs/diagrams/AI Use Case CLI - C4 Component Diagram (Agent Framework).svg`
  - Part of comprehensive architecture documentation

- **Session Statistics Automation** (v3.12.0+): Comprehensive automation of session statistics capture for AI-assisted development sessions
  - **SessionEnd Hook**: Automatically captures session metadata when Claude Code sessions end
    - Created `.claude/hooks/SessionEnd` - bash script executed automatically at session end
    - Captures timestamp, repository info, branch, recent commits, and uncommitted changes
    - Saves output to `.usecase/session-stats/YYYY-MM-DD-HHMMSS.txt`
    - Provides instructions for running `/cost` command to capture full statistics
    - Automatically installed by `ai-use-case --init` via `setup-project.sh`
  - **Template Updates**: Added "📊 Session Statistics (/cost Command)" section to both documentation templates
    - Updated `docs/TEMPLATE.md` with session statistics section and `/cost` command instructions
    - Updated `docs/TEMPLATE-RESEARCH.md` with parallel section adapted for research sessions
    - Includes instructions for capturing statistics, example output, and usage notes
  - **Documentation Workflow Integration**: Added Step 6.5 to `/use-case:document-session` workflow
    - Instructions for running `/cost` command during documentation
    - Option to use auto-saved statistics from SessionEnd hook
    - Graceful fallback if statistics unavailable
  - **OpenTelemetry Configuration**: Enterprise-grade telemetry support for detailed metrics tracking
    - Created `.claude/otel-config.sh` - configuration script with multiple export modes (console, file, OTLP)
    - Created `docs/OPENTELEMETRY-SETUP.md` - 420+ line comprehensive setup guide
    - Supports console output (development), file export (persistent), and OTLP endpoints (enterprise)
    - Tracks token usage, costs, code changes, session duration, and tool usage patterns
  - **Comprehensive Documentation**:
    - Updated `docs/AI_SESSION_STATISTICS_GUIDE.md` with "Automated Session Statistics Capture" section
    - Created `docs/features/session-statistics-automation/README.md` - complete feature documentation
    - Includes testing procedures, migration guide, usage examples, and benefits analysis
  - **Benefits**: Accurate real-time data from `/cost` command (not estimates), automatic capture eliminates manual errors, consistent tracking, enterprise monitoring with OpenTelemetry

- **Documentation Consistency Checklist**: Created comprehensive workflow for testing documentation consistency
  - New file: `docs/DOCUMENTATION-CONSISTENCY-CHECKLIST.md`
  - Complete checklist for reviewing documentation when adding/modifying features
  - Covers: Core docs (CHANGELOG, README, COMMANDS), templates, cross-references, version consistency
  - Includes validation scripts for links, file paths, and template consistency
  - Integration with PR workflow and pre-commit hooks
  - Identifies common documentation issues and solutions

### Changed

- **Update Script Preserves Custom Commands**: Fixed `update-project.sh` to work with new subdirectory symlink structure
  - **Previous behavior**: Removed entire `.claude` directory during updates (lines 194-228), deleting custom commands
  - **New behavior**: Preserves `.claude/commands/` directory and custom commands, only updates `use-case/` symlink
  - **Handles migration**: Automatically migrates projects from old full-directory symlink to new structure
  - **Custom command detection**: Reports number of custom commands found and confirms preservation
  - **User benefit**: Custom commands in `.claude/commands/` are now preserved across CLI updates

- **Claude Code Symlink Strategy - Subdirectory Level**: Changed from full-directory to subdirectory-level symlink to preserve custom commands
  - **Previous approach**: `.claude/commands/` → `../.ai-tools/commands` (replaced entire directory, lost custom commands)
  - **New approach**: `.claude/commands/use-case/` → `../../.ai-tools/commands/use-case` (preserves custom commands)
  - **Updated `setup-project.sh`**: Lines 339-381 now create `.claude/commands/` as regular directory with only `use-case/` symlinked
  - **Automatic migration**: Detects old full-directory symlink and automatically migrates to new structure (lines 346-358)
  - **Migration process**: Removes old symlink, creates directory, adds subdirectory symlink - fully automated
  - **Updated `update-project.sh`**: Lines 191-229 now preserve custom commands during project updates
    - Detects old vs new structure intelligently
    - Removes only `use-case/` symlink for refresh
    - Preserves all custom command directories
    - Shows which custom commands are preserved
  - **User benefit**: Users can now safely add custom commands to `.claude/commands/other-commands/` without conflicts
  - **Updated documentation**: README.md, CLAUDE.md, and docs/CLAUDE.md reflect new subdirectory symlink approach
  - **Updated .gitignore**: Added `.claude/commands/` to prevent tracking generated symlinks in CLI repo
  - **Fixed progress tracker bug**: Corrected task name mismatch in UPDATE_MODE ("Update Claude Code slash commands" → "Update AI tool slash commands")

- **AI Assistant Repository Guidelines**: Added `COPILOT.md` with comprehensive guidelines for AI coding assistants
  - Project structure and module organization reference
  - Build, test, and development command examples
  - Coding style and naming conventions (bash, snake_case, kebab-case)
  - Testing guidelines for local smoke tests
  - Commit and PR workflow guidelines
  - Explicit guidance to use `echo -e` for ANSI color codes
  - Helps AI assistants (GitHub Copilot, Claude Code, etc.) understand repo patterns and contribute effectively

- **Documentation Reorganization - Agent-Specific Structure**: Reorganized documentation into agent-specific directories
  - **New structure**: Created `docs/agents/` with subdirectories for `claude/`, `copilot/`, and `framework/`
  - **Moved files**:
    - `CLAUDE.md` → `docs/agents/claude/README.md` (Quick reference)
    - `docs/CLAUDE.md` → `docs/agents/claude/GUIDE.md` (Comprehensive guide)
    - `COPILOT.md` → `docs/agents/copilot/README.md`
    - `docs/AGENTS.md` → `docs/agents/framework/README.md`
  - **Created overview**: `docs/agents/README.md` provides index of all agent documentation
  - **Updated references**: All documentation now points to new locations (README.md, CONTRIBUTING.md, docs/WORKFLOW.md)
  - **Benefits**: Clearer organization, easier to add new agents (Cursor, Windsurf), separates usage from implementation
  - **Rationale**: Scalable structure for supporting multiple AI coding assistants

- **Quick Start Documentation Enhanced**: Updated all quick start sections to reflect symlink architecture and recent features
  - **README.md**: Updated step 1 to explain what `ai-use-case --init` creates (including `.claude/commands/` symlink)
  - **docs/CLAUDE.md**: Added symlink creation and slash command copying to setup-project.sh description
  - **.ai-tools/commands/use-case/quick-start.md**: Enhanced step 6 with detailed slash command discovery explanation and verification commands
  - All quick start sections now mention `.claude/commands/` symlink for Claude Code compatibility
  - Users understand how slash commands are discovered, stored, and verified after setup

- **Installation Banner Display Improved**: Enhanced installer UX with persistent banner visibility
  - Banner now clears screen and displays at installation start
  - Banner refreshes after git operations complete
  - Banner redisplays with completion message at installation end
  - Provides consistent visual feedback throughout installation process
  - Users see the branded banner at key transition points instead of it scrolling away

- **FEATURE-002 Implementation Checklist Updated**: Marked Phase 1-2 as complete in intelligent agents integration checklist
  - Updated `docs/features/intelligent-agents-integration/03-implementation-checklist.md` to reflect completion status
  - **Phase 1 (Agent Framework)**: Marked 35/35 tasks complete (100%) - merged in PR #116 on 2025-12-02, released in v3.11.0 on 2025-12-07
  - **Phase 2 (Quality Reviewer Agent)**: Marked 26/26 tasks complete (100%) - merged in PR #116 on 2025-12-02, released in v3.11.0 on 2025-12-07
  - Added progress summary section showing completion statistics (61/137 tasks, 44.5% overall)
  - Updated status from "Not Started" to "In Progress (Phase 1-2 Complete, Phase 3-5 Pending)"
  - Updated all references to include both PR number (PR #116) and release version (v3.11.0) with dates for full traceability
  - All parent tasks and sub-tasks marked as complete for Phase 1-2
  - Remaining phases (3-5) clearly identified: Pattern Analysis, Session Selection, Organization Intelligence

- **Architecture Diagrams Updated for Agent Framework and AI Tool Agnosticism**: Updated all C4 diagrams to reflect recent architectural changes
  - **C4 Context Diagram**: Generalized "Claude Code" to "AI Coding Assistants" with examples (Claude Code, GitHub Copilot, etc.)
  - **C4 Container Diagram**:
    - Added "Agent Framework" container with lifecycle management, invocation, caching, and statistics
    - Renamed "Claude Code Integration" to "AI Assistant Integration"
    - Updated Configuration database description to include agents.json
    - Added relationships showing CLI → Agent Framework and Core Scripts → Agent Framework
  - **C4 Deployment Diagram**:
    - Added agents.json to configuration files (~/.config/ai-use-case-cli/)
    - Updated project directory to show .ai-tools/ (formerly .claude/)
    - Renamed "Claude Code Extension" to "AI Assistant Extensions"
  - **Diagrams README**: Updated documentation to reflect new Agent Framework diagram and AI tool terminology
  - All SVG files regenerated with latest changes
  - Diagrams now accurately represent v3.11.0 architecture with Agent Framework (Phases 1 & 2)

### Fixed

- **ANSI Escape Codes in Piped Output**: Fixed literal escape codes appearing when CLI output is piped or redirected
  - Added TTY detection to automatically disable colors when stdout is not a terminal
  - Colors now work correctly in terminals but appear as clean text when piped (e.g., `ai-use-case --help | cat`)
  - Respects `NO_COLOR` environment variable standard (https://no-color.org/)
  - Added `FORCE_COLOR` environment variable to override TTY detection (useful for testing)
  - Updated `config-manager.sh` to only set colors if not already defined by parent script
  - Updated test suite to use `FORCE_COLOR=1` for color-related tests
  - Extracted color setup logic into reusable `setup_colors()` function to avoid duplication
  - Improves user experience when copying help text, saving output to files, or using CLI in scripts

- **Self-Update Color Rendering**: Fixed ANSI color codes displaying as literal text in `scripts/utils/self-update.sh`
  - Changed `echo` to `echo -e` at line 102 to properly interpret color escape sequences
  - Version display now correctly shows cyan-colored version number instead of `\033[0;36m3.11.0\033[0m`
  - Improves user experience when running `ai-use-case update`

## [3.11.0] - 2025-12-07

### Changed

- **Template-Based Documentation Generation**: Refactored `document-ai-session.sh` to read and populate template files instead of using inline heredoc
  - Removed ~370 lines of heredoc documentation generation
  - Now reads `docs/TEMPLATE.md` and `docs/TEMPLATE-RESEARCH.md` as single source of truth
  - Uses sed for placeholder replacement with collected user input
  - Ensures consistency with Claude Code slash command `/use-case:document-session`
  - Prevents template/script divergence and reduces maintenance burden
  - Template files remain the authoritative source for documentation structure
- **AI Tool Agnostic Refactoring**: Made codebase support multiple AI coding assistants, not just Claude Code
  - **Directory Structure**: Renamed `.claude/` to `.ai-tools/` to reflect support for multiple AI tools
  - **Templates**: Updated TEMPLATE.md and TEMPLATE-RESEARCH.md
    - Changed title from "🎯 Claude Code:" to "🎯 AI-Assisted:" (implementation) / "🔬 AI Research:" (research)
    - Renamed "Agent Used" to "AI Tool Used" with support for GitHub Copilot, Claude Code, OpenAI Codex, etc.
    - Updated "Claude Agents Used" section to "AI Agents Used" to support agents from any AI tool
  - **Scripts**: Updated document-ai-session.sh and extract-session-data.sh
    - Changed default AI tool from "Claude Code (Sonnet 4.5)" to "GitHub Copilot"
    - Added OpenAI Codex / ChatGPT as an option
    - Generalized agent tracking prompts to "AI agents" instead of "Claude agents"
  - **Slash Commands**: Updated document-session.md to be tool-agnostic
    - Generalized references to support any AI coding assistant
    - Made commit attribution optional and tool-specific
  - **Documentation**: Updated README.md, CLAUDE.md, and docs/CLAUDE.md
    - Updated references to mention multiple AI tools (GitHub Copilot, Claude Code, OpenAI Codex, etc.)
    - Changed "Claude Code slash commands" to "AI assistant slash commands"
    - Updated file structure diagrams to show `.ai-tools/` directory
  - **Migration**: update-project.sh now removes old `.claude/` directory structure automatically
- **Refactored Slash Commands to Remove Hardcoded Paths**: Replaced all hardcoded CLI installation paths with portable solutions
  - Updated 9 slash command files (46+ command references) to use `ai-use-case` wrapper commands
  - Replaced direct script calls (e.g., `bash ~/.local/share/ai-use-case-cli/scripts/...`) with wrapper equivalents
  - Introduced `AI_USECASES_CLI_ROOT` environment variable for custom installation paths
  - Template access now uses `${AI_USECASES_CLI_ROOT:-~/.local/share/ai-use-case-cli}` pattern
  - Improves portability across different installation locations and deployment methods
  - Maintains backward compatibility with default installation path
  - Updated documentation in README.md and ai-use-case help output
- **Extract Session Slash Command Simplification**: Refactored `/use-case:extract-session` command for better maintainability
  - Reduced from 393 lines to 200 lines (49% reduction)
  - Moved detailed documentation to `docs/EXTRACT-SESSION-REFERENCE.md`
  - Kept essential workflow (Steps 1-6) and core functionality
  - Extracted detailed exit code handling, cost calculations, JSON structure, and command substitution best practices to reference doc
  - Added link to reference documentation for advanced details
  - Improved consistency with other slash commands (sync-usecases: 49 lines, list-projects: 90 lines, check-updates: 115 lines)
  - Reduced token overhead for AI processing while maintaining full functionality

### Added

- **Markdown Conversion Warnings**: Added pre-publish warnings for unsupported markdown features in `publish-confluence.sh` (PR #135 review feedback)
  - Detects code blocks (```), tables (|), and images (![]()) before publishing
  - Warns users about potential formatting issues
  - Suggests manual formatting in Confluence for complex content
  - Lines added: 394-411
- **Confluence Integration Documentation**: Enhanced `docs/CONFLUENCE-INTEGRATION.md` with implementation cross-references (PR #135 review feedback)
  - Added reference to `publish-confluence.sh` lines 326-346 (conversion logic)
  - Added reference to lines 394-411 (warning system)
  - Helps users find detailed implementation notes and understand markdown limitations
- **C4 Architecture Diagrams**: Added comprehensive architecture diagrams using PlantUML and C4 model
  - **System Context Diagram**: Shows AI Use Case CLI system interactions with users and external systems
  - **Container Diagram**: Details internal containers (CLI Dispatcher, Core Scripts, Project Management, etc.)
  - **Component Diagram**: Deep dive into Core Scripts container components
  - **Deployment Diagram**: Physical deployment layout on developer workstation
  - Located in `docs/diagrams/` with detailed README for viewing options
  - Supports multiple rendering methods: Online viewer, VS Code extension, CLI, Docker
  - Visualizes system boundaries, data flows, and integration points (Git, GitHub, Confluence, OpenTelemetry)
- **Document Session Sequence Diagram**: Added PlantUML sequence diagram for `/use-case:document-session` workflow
  - Shows complete workflow from user invocation to hub sync
  - Visualizes interactions: Claude Code → CLI → Git → GitHub → File System → Hub
  - Includes version checking, session detection, git analysis, documentation generation, and sync phases
  - Highlights key features: interactive session selection, parallel git analysis, automatic commit/sync
  - Supports both implementation and research session workflows
  - Located at `docs/diagrams/document-session-sequence.puml`
- **Feature Planning: Intelligent Agents Integration (FEATURE-002)**: Created comprehensive planning documentation for adding AI agents
  - **Feature Plan** (`docs/features/intelligent-agents-integration/01-feature-plan.md`)
    - Hybrid architecture: Bash scripts for reliability, AI agents for intelligence
    - 5 specialized agents planned: Quality Reviewer, Pattern Analyzer, Session Selector, Organization Intelligence, +1 future
    - 5 implementation phases spanning 5 weeks
    - Clear goals, success criteria, and risk mitigation strategies
  - **Requirements Document** (`docs/features/intelligent-agents-integration/02-requirements.md`)
    - 5 functional requirement groups (FR-1 through FR-5)
    - 5 non-functional requirement categories (Performance, Usability, Maintainability, Compatibility, Security)
    - 5 detailed user stories with acceptance criteria
    - Complete data schemas for agent registry and outputs
    - Interface requirements for CLI and slash commands
  - **Implementation Checklist** (`docs/features/intelligent-agents-integration/03-implementation-checklist.md`)
    - 31 major tasks across 6 phases (5 implementation + 1 integration)
    - 200+ individual checklist items with validation steps
    - Estimated 60-80 hours total implementation time
    - Phase-by-phase breakdown with clear deliverables
  - **QUICKSTART Guide** (`docs/features/intelligent-agents-integration/QUICKSTART.md`)
    - 10-minute overview for developers
    - Phase-by-phase implementation guide
    - Common tasks and debugging tips
    - Best practices and pitfalls to avoid
  - This planning follows the established feature planning structure and enables intelligent, context-aware automation while maintaining CLI reliability
- **Intelligent Agents Integration - Phase 1: Agent Framework** (FEATURE-002)
  - **Agent Registry System** (`scripts/agents/agent-registry.sh`)
    - JSON-based registry at `~/.config/ai-use-case-cli/agents.json`
    - Commands: init, list, enable, disable, info, register, stats, reset
    - 4 agents registered: quality-reviewer, pattern-analyzer, session-selector, organization-optimizer
    - Color-coded output and statistics tracking
    - Full agent lifecycle management
  - **Agent Invoker** (`scripts/agents/invoke-agent.sh`)
    - Agent validation and dependency checking
    - Result caching with configurable duration
    - Statistics tracking (invocations, success rate, duration)
    - Timeout handling and error recovery
    - Multiple output formats (text/json)
  - **CLI Integration** (`ai-use-case agents`)
    - Full `agents` subcommand integrated into main CLI
    - Help text and examples added
    - Tracing support for agent operations
    - Graceful error handling
  - **Comprehensive Documentation** (`docs/AGENTS.md`)
    - Quick start guide
    - Architecture overview (hybrid model)
    - Agent management commands
    - Configuration options
    - Troubleshooting guide
    - Developer guide for future agent implementations
  - **Phase 1 Complete**: Agent framework operational, ready for Phase 2 (Quality Reviewer implementation)
  - All agent commands tested and working: init, list, enable, disable, info, stats, reset
  - Zero performance impact on existing CLI operations (< 10ms overhead)
  - Backward compatible: CLI fully functional with or without agents
- **Intelligent Agents Integration - Phase 2: Quality Reviewer Agent** (FEATURE-002)
  - **Quality Agent Prompt** (`.claude/agents/use-case-quality-agent.md`)
    - Comprehensive quality assessment methodology with 5 scoring categories
    - Completeness (30%), Technical Depth (25%), Clarity (20%), Actionability (15%), Quantification (10%)
    - Detailed scoring guidelines (A+ to F grading scale)
    - Specific improvement suggestion framework with severity levels
    - Support for both implementation and research session types
    - JSON output schema for programmatic use
  - **Quality Agent CLI Wrapper** (`scripts/agents/quality-agent.sh`)
    - Single file review with detailed analysis
    - Batch mode for multiple files (glob patterns)
    - Project-wide review mode (analyze entire project from hub)
    - Multiple output formats (text with color-coding, JSON for automation)
    - Filtering by minimum score threshold
    - Result sorting (by score, file, grade)
    - Comprehensive help and examples
  - **CLI Integration** (`ai-use-case review-quality`)
    - New `review-quality` command: `ai-use-case review-quality <file>`
    - Support for all quality agent modes (single, batch, project)
    - Help text and examples added
    - Tracing support for quality review operations
  - **Claude Code Slash Command** (`.claude/commands/use-case/review-quality.md`)
    - Interactive file selection if no file specified
    - Automatic quality agent invocation via Task tool
    - Formatted results presentation with color-coding
    - Actionable next steps (apply improvements, review another, batch review)
    - Comprehensive workflow documentation for Claude Code
  - **Phase 2 Complete**: First functional agent operational
  - Quality agent provides: overall score (0-10), category breakdown, strengths list, improvement suggestions with examples, summary and grade
  - Framework validated: agent invocation, result formatting, CLI integration, slash command integration all working
- **Feature Development Workflow in CLAUDE.md**: Added structured feature planning process guidance
  - Critical reminder: Always use `docs/features/` process when user requests new features
  - When to use: Multi-file features, new architecture, medium/high complexity, >1 day work
  - Quick start guide: Create directory, copy templates, rename files
  - Three core documents: Feature Plan, Requirements, Implementation Checklist
  - Benefits: Thorough planning, clear requirements, step-by-step guidance, knowledge transfer
  - Links to full guide at `docs/features/README.md`
  - Ensures Claude Code follows structured approach for complex features

### Fixed

- **Template-Based Documentation Generation**: Fixed multiple issues in `document-ai-session.sh` (PR #135 review feedback)
  - **sed delimiter issues**: Changed all ~40 sed commands to use pipe (|) delimiter instead of forward slash (/)
    - Now safely handles user input containing forward slashes (URLs, file paths)
    - Added comprehensive inline documentation with examples and maintenance guidance
  - **awk pattern matching**: Fixed inconsistent section header matching for AI Agents
    - Pattern was looking for bold markdown (`\*\*Time saved by agents:`) but template uses plain text
    - Updated both research and implementation template processing (lines 797, 900)
  - **Template field mismatches**: Updated sed patterns to match current template structure
    - "Agent Used" → "AI Tool Used" (matches TEMPLATE.md line 13)
    - "# 🎯 Claude Code:" → "# 🎯 AI-Assisted:" (matches updated header)
  - **Variable naming accuracy**: Renamed `most_valuable_agent` → `most_invoked_agent`
    - Variable tracks invocation count (quantity), not subjective value (quality)
    - More accurate self-documenting code (lines 678, 690, 699, 700)
- **Temp File Security**: Fixed insecure temporary file creation in `config-manager.sh` (PR #135 review feedback)
  - Changed 3 mktemp calls to use secure directory specification
  - Now uses: `mktemp "$CONFIG_DIR/config.json.XXXXXX"` instead of `mktemp`
  - Prevents security vulnerabilities from using default /tmp location
  - Lines affected: 361, 433, 652
- **Commit Message Format**: Aligned commit message format with AI tool attribution for consistency and transparency
  - Shell script (`document-ai-session.sh`) now uses multi-line commit format matching Claude Code slash command
  - Dynamic AI attribution footer based on tool selection (Claude Code, Copilot, or both)
  - Includes proper `Co-Authored-By` lines for AI tool attribution
  - Commit message now includes: session date, ticket, brief description, TL;DR summary, and attribution footer
  - Prepares for future GitHub Copilot support with tool-agnostic attribution format
- **Duplicate Session Type Prompt**: Removed duplicate session type prompt in `document-ai-session.sh`
  - Fixed confusing user experience where session type (implementation vs research) was prompted twice
  - Removed first prompt (previously at lines 314-333) that appeared before data collection
  - Kept single prompt in the interactive prompts section (lines 347-366) where it logically belongs
  - Users now select session type only once during documentation workflow
  - Fixes issue where selections could be inconsistent if user chose different options for duplicate prompts
- **Unified Sync Behavior**: Shell script now explicitly calls sync script after commit
  - Updated `document-ai-session.sh` to call `sync-ai-use-cases.sh` explicitly after commit
  - Matches behavior of Claude Code slash command for consistency
  - Ensures reliable sync even if post-commit hook is not configured
  - Provides clear success/failure feedback to users
  - Resolves inconsistency between manual and automatic documentation modes
- **check-updates Command Output Issues**: Fixed color rendering and improved command guidance
  - Fixed ANSI color codes not rendering: replaced `cat <<EOF` with `echo -e` statements in help text
  - Removed misleading numbered list format from "Next steps" section to avoid confusion with interactive menus
  - Updated all command references to use `ai-use-case` command instead of invalid relative script paths
  - Improved clarity with proper section headers and working examples
  - Users can now copy-paste commands directly without "command not found" errors
- **Confluence Title Format**: Include year in Confluence page titles
  - Updated `/publish-confluence` slash command to format titles as `🎯 2025 W## | TICKET-ID: Title`
  - Fixed `publish-confluence.sh` to capture and include year in title extraction
  - Fixed `process-template.sh` to include year in `WEEK_NUMBER` variable
  - Ensures published Confluence pages show the full year and week for better organization

## [3.10.0] - 2025-12-01

### Added

- **Claude Agent Usage Tracking**: Track and document usage of Claude specialized agents in AI session documentation
  - **New template section**: Added "Claude Agents Used" section to both `TEMPLATE.md` and `TEMPLATE-RESEARCH.md`
  - **Interactive mode support**: Added prompts in `document-ai-session.sh` for manual agent documentation
    - Prompts for agent usage (y/N), agent list (comma-separated), and details per agent
    - Collects invocation counts, purposes, and value/impact for each agent
    - Supports multiple agents: Explore, Plan, general-purpose, code-reviewer, and custom agents
  - **Automatic detection**: Added detection instructions in `/use-case:document-session` slash command
    - Guides Claude Code to detect Task tool invocations with subagent_type
    - Extracts agent types, counts, purposes, and outcomes from conversation history
    - Includes heuristics for inferring agent effectiveness and value
  - **Documentation generation**: Auto-generates agent section with effectiveness summary
    - Shows invocation counts per agent type
    - Documents purpose, key findings, and impact for each agent
    - Calculates total invocations and identifies most valuable agent
  - **Feature planning structure**: Created standardized feature planning workflow in `docs/features/`
    - New `FEATURE-TEMPLATE/` with reusable templates (plan, requirements, checklist)
    - Example implementation in `claude-agents-tracking/` folder
    - Comprehensive `README.md` and `QUICKSTART.md` guides for future features
  - Enables tracking of which AI capabilities were leveraged during sessions
  - Helps identify valuable agents and replicate successful workflows
  - Part of FEATURE-001 implementation

## [3.9.1] - 2025-11-15

### Fixed

- **Session Data Extraction JSON Generation**: Fixed critical JSON parsing errors and improved performance in `extract-session-data.sh`
  - **Fixed special character escaping**: Commit messages with special characters (curly quotes, etc.) now properly escaped using `jq --arg` instead of format strings
  - **Fixed duplicate array bug**: Removed duplicate empty arrays caused by `pipefail` triggering fallback `|| echo "[]"` commands
  - **Fixed compact JSON output**: All JSON arrays now output as compact single-line format to prevent heredoc formatting issues
  - **Improved delimiter robustness**: Changed from direct JSON format strings to null character (`\x00`) delimiter for git log parsing to handle special characters in commit messages
  - **Optimized jq processing**: Simplified double jq piping to single invocation using `jq -Rsc 'split("\n") | map(select(length > 0))'` for better performance
  - **Reduced git subprocess calls**: Now calls `git status --short` once and reuses output, reducing from 3 subprocess invocations to 1
  - **Root cause**: `set -euo pipefail` caused grep commands to fail pipeline when no matches found, triggering both jq output AND fallback echo
  - **Solution**: Use `(grep pattern || true)` to prevent pipeline failures + compact JSON output with optimized jq commands
  - Affects: `/use-case:extract-session` command and `ai-use-case extract` functionality
- **Script Permissions**: Made `scripts/utils/progress-tracker.sh` and `scripts/utils/version.sh` executable
  - Fixed missing execute permissions on utility scripts
  - Ensures scripts have correct permissions for sourcing and tooling compatibility (note: these scripts are intended to be sourced, not executed directly)
- **Installation Script**: Modernized `scripts/install/install.sh` to align with v3.2.0+ features
  - **Fixed install URL**: Corrected quick-install curl command path (was `/install.sh`, now `/scripts/install/install.sh`)
  - **Removed deprecated environment variables**: No longer sets `AI_USECASES_DIR` and `AI_USECASES_SYNC_SCRIPT` in shell profiles
  - **Uses modern config system**: Hub configuration now uses `ai-use-case config reconfigure` (v3.2.0+) instead of manual setup
  - **Default local-only mode**: Installer explains local-only hub mode is default, with optional git mode
  - **Added tracing commands**: Installation completion now lists tracing commands (v3.6.0+)
  - **Optional config runner**: Asks if user wants to configure hub during installation, runs config automatically if requested
  - **Updated command list**: Added all modern commands (config, check-updates, extract, tracing)
  - **Claude Code slash commands**: Lists recommended slash commands in completion message

## [3.9.0] - 2025-11-13

### Fixed

- **README.md Footer Version**: Fixed version mismatch (was showing v3.7.1, now correctly shows v3.9.0)
  - During development, discovered footer was out of sync with actual version
  - Fixed version mismatch between `scripts/utils/version.sh` and README.md footer
  - Updated "Last Updated" date to 2025-11-13

### Added

- **Development Git Hooks Installer**: New `scripts/install-dev-hooks.sh` script for CLI repository developers
  - Automatically installs version validation pre-commit hook
  - Validates version consistency before allowing commits
  - Prevents version.sh/README.md/CHANGELOG.md mismatches from entering git history
  - Preserves existing hooks and creates backups
  - Easy one-command installation: `./scripts/install-dev-hooks.sh`

### Changed

- **Removed Backup Process**: Eliminated all backup creation during updates to keep projects clean
  - Removed backup creation logic for slash commands from `scripts/project/update-project.sh`
  - Removed backup creation logic for git hooks from `scripts/project/setup-project.sh`
  - Deleted `scripts/utils/cleanup-backups.sh` utility script
  - Removed `.claude/backups/` from CLI `.gitignore` and project `.gitignore` patterns
  - Updated all documentation to remove backup-related references
  - Projects now maintain only the latest versions of slash commands and git hooks without backup directories

- **Document-Session Workflow Transparency**: Added real-time TodoWrite tracking to `/use-case:document-session` command
  - **Interactive Todo List**: Creates TodoWrite list at start showing 8 visible progress steps (breaking down 6 logical workflow phases)
  - **Real-time Progress**: Updates todo status (pending → in_progress → completed) as work proceeds
  - **Full Transparency**: Users see exactly what's happening at each step
  - **6 Logical Workflow Phases** (as documented in the command file):
    1. **Session Selection**: Detect recent work, present options, wait for user selection *(broken into 3 visible steps for granular tracking)*
    2. **Environment Validation**: Check CLI version and project setup
    3. **Session Analysis**: Analyze git history and/or conversation
    4. **Information Extraction**: Gather metadata, complexity, time saved
    5. **Documentation Generation**: Read template, create complete docs
    6. **Commit and Sync**: Commit if implementation, sync to hub
  - **8 Visible TodoWrite Steps** (for user progress tracking):
    - Step 1-3: Session Selection broken into (a) Detect, (b) Present, (c) Wait
    - Step 4-8: Map 1:1 to remaining phases 2-6
  - **Benefits**:
    - Eliminates confusion about what the command is doing
    - Shows estimated time (30-60 seconds total)
    - Helps track progress through long-running operations
    - More granular progress visibility during session selection
    - Makes automated workflow predictable and transparent

- **VERSION-UPDATE-CHECKLIST.md Enhancements**: Improved documentation to prevent version update mistakes
  - Added prominent warning at top about README.md footer being commonly forgotten
  - New "Mistake #1: Forgetting README.md footer" section with detailed explanation
  - Added "Automated Pre-Commit Validation" section with setup instructions

- **Cross-Platform Compatibility**: Documentation and patterns for POSIX compliance
  - New `scripts/install-dev-hooks.sh` script uses `set -euo pipefail` for robust error handling
  - Added platform detection for `sed -i` command (macOS/Linux compatibility)
  - Added fallback logic for hooks without explicit `exit 0` statement
  - New "Cross-Platform Compatibility" section in `docs/WORKFLOW.md` with guidelines
  - Updated Pre-PR checklist to verify cross-platform compatibility
  - Added reference examples from existing scripts (setup-project.sh, install-dev-hooks.sh)
  - Clarified that README.md has TWO locations requiring updates (header + footer)
  - Emphasized using `ai-use-case bump-version` script for automated updates

## [3.8.0] - 2025-11-13

### Added

- **Command-Specific Progress Tracking**: New visual progress tracking system for CLI commands
  - **New Utility**: `scripts/utils/progress-tracker.sh` provides reusable progress tracking functions
  - **Visual Indicators**:
    - `[ ]` Pending tasks (gray)
    - `[▸]` Tasks in progress (yellow)
    - `[✓]` Completed tasks (green)
    - `[~]` Skipped tasks (cyan)
  - **Real-time Updates**: Shows current task status as commands execute
  - **Duration Tracking**: Displays elapsed time for completed tasks
  - **Progress Summary**: Final summary showing completed/skipped/incomplete tasks
  - **Integrated Commands**:
    - `sync-ai-use-cases.sh`: Tracks validation, sync, symlink creation, and git operations
    - `setup-project.sh`: Tracks project setup steps (setup vs. update modes)
  - **Non-intrusive Design**: Gracefully degrades if utility not available
  - **User Benefits**:
    - Clear visibility into what's happening during command execution
    - Know what steps remain and what's been completed
    - Better UX for long-running operations
    - Easy to troubleshoot where commands might be stuck
  - **Example Output**:
    ```
    [▸] Sync use case files...
    [✓] Sync use case files (1s)
    [✓] Create by-date symlinks
    [~] Commit to hub repository (no changes)

    === Summary ===
    ✓ Completed: 5/6
    ~ Skipped: 1/6
    ```

### Fixed

- **Progress Tracker Arithmetic**: Fixed `set -e` compatibility issue with arithmetic expressions
  - Changed `((var++))` to `var=$((var + 1))` to prevent exit code 1 when var is 0
  - Prevents premature script termination in scripts using `set -e`
  - Affects `progress_summary()` and `progress_percentage()` functions
- **Extract Session Command**: Fixed SIGPIPE errors causing premature script termination (moved from Unreleased)
  - Prevented exit code 141 (SIGPIPE) by temporarily disabling pipefail around pipe operations with `head`
  - Fixed duration calculation pipes (lines 229-233)
  - Fixed markdown output generation by pre-capturing recent commits (lines 271-278, 363)
  - Script now completes successfully when using pipe operations without false failures

## [3.7.1] - 2025-11-11

### Added

- **Self-Update Command**: New `ai-use-case update` command for automated CLI updates
  - Updates CLI installation to latest version from git repository
  - Checks for updates and shows what changed before updating
  - Safely handles local changes with git stash/restore
  - Options:
    - `-y, --yes`: Skip confirmation and update automatically
    - `--update-projects`: Also update all registered projects after CLI update
    - `--dry-run`: Preview what would be updated without making changes
  - Usage: `ai-use-case update` or `ai-use-case self-update`
  - Eliminates need for manual `cd ~/.local/share/ai-use-case-cli && git pull`
  - Shows version changes and git commit history
  - Can update CLI and all projects in one command with `--update-projects` flag
- **Project Update Flag**: New `--update` flag for `setup-project.sh` and `ai-use-case --init`
  - Allows refreshing existing project installations with latest CLI components
  - Updates Claude Code slash commands with newer versions from CLI
  - Updates git hooks (pre-commit and post-commit) with latest versions
  - Creates timestamped backups of hooks before updating
  - Preserves existing `.usecase/cases/` directory and documentation
  - Usage: `ai-use-case --init --update` or `./scripts/project/setup-project.sh --update`
  - Helpful message when components already exist: suggests using `--update` to refresh

### Changed

- **Confluence Page Naming**: Updated page title format for better readability
  - New format: `🎯 Week XX | TICKET-ID: Description`
  - Example: `🎯 Week 45 | LSFB-63590: Remove Deprecated Document Handler Exchange Queue Parameter`
  - More concise than previous `YYYY-Www-MM-DD_TICKET-XXX: Description` format
  - Highlights week number prominently with emoji indicator
  - Updated `scripts/core/publish-confluence.sh` `extract_title()` function
- **Document Session Command**: Enhanced research session detection and user filtering
  - **User Filtering**: Now shows only work by the current git user
    - PR detection uses `gh pr list --author="$GH_USERNAME"` to filter PRs
    - Commit detection uses `git log --author="$USER_EMAIL"` to filter commits
    - Prevents showing work by other team members in documentation options
    - Added Key Principle #8: "Filter by Current User"
  - **Research Session Detection**: Better detection of substantial conversations for documentation
    - Added Section 0.2: "Analyze Current Conversation" with comprehensive criteria
    - Detects substantial conversations (5+ exchanges, iterative discussions, technical decisions)
    - **ALWAYS includes research session option** when conversation is substantial, even without git commits
    - Shows research sessions with 🔬 indicator and conversation summary
    - Added conversation analysis indicators (substantial vs. not substantial)
    - Added Key Principle #9: "Detect Substantial Conversations"
    - Added Key Principle #10: "Include Research Sessions"
  - **Enhanced Examples**: Added research session example showing documentation without commits
  - **Updated Workflow Benefits**: Added "Captures Research Value" benefit
  - **Improved Filtering Consistency**: Enhanced `git show` and `git diff` commands to consistently use the latest commit by the current user
    - Changed from using HEAD (any author) to LATEST_USER_COMMIT (current user only) for improved user filtering
    - Applied in Step 3 (session type determination) and Step 4a (git history analysis)
    - Ensures all git operations consistently filter by current user as an intentional behavior change
  - **Error Handling**: Added validation for GitHub CLI authentication and git user configuration
    - Validates USER_EMAIL is available, warns if not configured
    - Checks GH_USERNAME before querying PRs, skips PR detection if gh CLI not authenticated
    - Gracefully handles first commits (no parent commit) in git diff operations
  - **Design Documentation**: Added note clarifying Claude Code command vs shell script filtering behavior

### Fixed

- **Post-Commit Hook Sync Script Path**: Fixed sync script not found after repository separation
  - **Root Cause**: After separating CLI tools from hub repo (commit f9ab996), sync script moved from `~/Documents/ai-use-case-hub/sync-ai-use-cases.sh` to `~/.local/share/ai-use-case-cli/scripts/core/sync-ai-use-cases.sh`
  - **Impact**: Post-commit hooks in existing projects failed to sync use cases because they looked for script in old location
  - **Solution**:
    - `install.sh` now automatically adds `AI_USECASES_SYNC_SCRIPT` environment variable to shell profile
    - Handles both new installs and existing installations (adds missing variable if needed)
    - `setup-project.sh` validates environment is configured and warns if variable is missing
  - **Benefit**: Post-commit hooks now work correctly for all users (new and existing)
  - Files modified: `scripts/install/install.sh`, `scripts/project/setup-project.sh`
- **Check Updates Script**: Fixed bash syntax error in `check-updates.sh`
  - Removed invalid `local` keyword usage outside of function (line 134)
  - Variables declared in while loop no longer cause script to fail
  - Affects `ai-use-case check-updates` command
- **Update Project Script**: Fixed `update-project.sh` to pass `--update` flag to setup script
  - Update script now calls `setup-project.sh --update` instead of just passing project path
  - Ensures components (slash commands and hooks) are properly refreshed during updates
  - Fixes update failures where setup script would skip already-installed components
  - Resolves integration issue between update workflow and new --update flag feature (v3.7.0+)

## [3.7.0] - 2025-11-10

### Added

- **Reset Command**: New `reset` command to safely clean CLI configuration and data
  - Added `scripts/utils/reset.sh` with comprehensive safety features
  - Selective reset options: `--config`, `--registry`, `--tracing`, `--hub`, `--all`
  - Safety features: confirmation prompts, dry-run mode (`--dry-run`), force mode (`--force`)
  - Special protection for git-based hubs (prevents accidental deletion)
  - Displays file sizes and clear warnings before deletion
  - Provides next steps after reset completion
  - Usage: `ai-use-case reset --config` or `ai-use-case reset --all --dry-run`

### Fixed

- **Tracing Configuration Initialization** (CRITICAL): Fixed empty file creation bug in tracing setup
  - **Root Cause**: `set_tracing_config` used unsafe shell redirection (`get_tracing_config > file`) that created empty files on failure
  - **Impact**: Users experienced unusable tracing with 0-byte config files, requiring manual intervention
  - **Solution**: Implemented atomic file creation with validation in new `init_tracing_config()` function
  - **Added**: `validate_and_repair_tracing_config()` function for automatic detection and repair of corrupted configs
  - **Added**: Comprehensive validation before writing (file size check, JSON syntax validation, atomic operations)
  - **Added**: Proper error handling with rollback on failure and cleanup traps for temp files
  - **Improved**: `set_tracing_config()` now validates existing files and auto-repairs before modifying
  - **Added**: New `ai-use-case tracing init` command for one-step tracing setup with dependency installation
  - **Result**: Zero instances of empty config files, automatic recovery from any broken state
  - Files modified: `scripts/utils/config-manager.sh`, `ai-use-case` main CLI
- **Reset Command Color Codes**: Fixed ANSI color codes not rendering in help output
  - Changed `show_help()` function in `scripts/utils/reset.sh` from heredoc (`cat <<EOF`) to `echo -e` statements
  - Color codes now properly render in terminal for improved readability
  - Affects help output when running `ai-use-case reset` or `ai-use-case reset --help`
- **Tracing Dependency Installation**: Fixed installation failure on externally-managed Python environments
  - Changed from `pip3 install --user` to virtual environment approach (`~/.local/share/ai-use-case-cli/venv`)
  - Updated `scripts/utils/tracing.sh` to create and use isolated venv for OpenTelemetry packages
  - Updated `scripts/utils/tracing.py` to make subprocess instrumentation optional (package not available in PyPI)
  - Resolves PEP 668 externally-managed-environment errors on modern Debian/Ubuntu systems
  - Added `AI_USECASE_VENV_DIR` environment variable to customize venv location
  - Automatic fallback to system Python if venv not available

## [3.6.0] - 2025-11-09

### Added

- **Distributed Tracing System**: Comprehensive OpenTelemetry-based tracing for CLI performance monitoring
  - Added Python tracing module (`scripts/utils/tracing.py`) with OpenTelemetry integration
  - Added shell tracing wrapper (`scripts/utils/tracing.sh`) for bash script instrumentation
  - Instrumented main CLI script and core operations (sync, search, extract)
  - Added tracing configuration management with JSON config files and environment variable support
  - Integrated with VS Code AI Toolkit's tracing viewer via OTLP endpoint (localhost:4318)
  - New tracing commands: `configure`, `status`, `enable`, `disable`, `install-deps`, `test`
  - Captures command execution times, operation metrics, error tracking, and performance data
  - Graceful degradation when OpenTelemetry dependencies are unavailable
  - Comprehensive tracing documentation in `docs/TRACING.md`

### Fixed

- **Confluence Page Naming**: Updated Confluence publish to use full filename convention
  - Page titles now include date/week prefix: `YYYY-Www-MM-DD_TICKET-XXX: Description`
  - Maintains consistency with local .md file naming convention
  - Example: `2025-W45-11-09_LSFB-60265: Add Environment Parameter to EditedDocument Message`
  - Updated `scripts/core/publish-confluence.sh` `extract_title()` function

## [3.5.0] - 2025-11-09

### Added

- **Backup Cleanup Utility**: New `cleanup-backups` command to remove backup directories
  - Added `scripts/utils/cleanup-backups.sh` script with dry-run and auto-confirm modes
  - Integrated into main CLI: `ai-use-case cleanup-backups [path]`
  - Finds and removes backups from `.claude/commands/`, `.claude/backups/`, and `.git/hooks/`
  - Supports `-y` (auto-confirm), `-n` (dry-run), and `-h` (help) flags
  - Provides detailed output showing backup locations and sizes

### Fixed

- **Duplicate Slash Commands**: Fixed issue where backup directories appeared as duplicate slash commands in Claude Code
  - Changed backup location from `.claude/commands/use-case.backup.*` to `.claude/backups/use-case.backup.*`
  - Prevents Claude Code from scanning backup directories and registering them as slash commands
  - Updated `update-project.sh` to use new backup location (lines 184-197, 250-271)
  - Updated `setup-project.sh` to use new backup location for git hook backups (lines 263, 283-286, 307-310)
  - Added automatic cleanup that keeps only the 3 most recent backups during updates
  - Added `.claude/backups/` to `.gitignore` entries in setup script

### Changed

- **Backup Management**: Improved backup handling to prevent clutter and conflicts
  - Backups now stored outside `.claude/commands/` directory structure
  - Git hook backups moved from `.git/hooks/*.backup.*` to `.claude/backups/*.backup.*`
  - Project `.gitignore` now includes `.claude/backups/` pattern during setup
  - Update script automatically cleans up old backups (keeping 3 most recent)

## [3.4.3] - 2025-11-09

### Fixed

- **Project Update Mechanism**: Enhanced `update-project.sh` to force refresh slash commands from running CLI
  - Automatically backs up and removes old slash command files before running setup
  - Copies fresh slash commands from the running CLI installation
  - Ensures projects with outdated slash commands (wrong paths) get updated correctly
  - Fixes issue where `/use-case:update-project` would fail on projects with v3.3.0 or older CLI installations
  - Provides backup directory with timestamp for safety (can be removed after verification)
  - Also checks for and prepares migration from old structure (`docs/ai-use-cases` → `.usecase/cases`)

### Changed

- **Slash Command Source**: Update script now copies from `$CLI_ROOT` instead of hardcoded path
  - More flexible and works correctly whether run from dev repo or installed location
  - Always uses the same version as the running script

## [3.4.2] - 2025-11-08

### Fixed

- **Slash Command Paths**: Fixed incorrect script paths in Claude Code slash commands
  - Updated `/use-case:update-project` to use correct `scripts/project/update-project.sh` path
  - Updated `/use-case:check-updates` to use correct `scripts/project/check-updates.sh` path
  - Updated `/use-case:list-projects` to use correct `scripts/project/list-projects.sh` path
  - Updated `/use-case:sync-usecases` to use correct `scripts/core/sync-ai-use-cases.sh` and `scripts/search/stats-use-cases.sh` paths
  - Fixes "No such file or directory" errors when running these commands on outdated CLI installations

- **Installer Update Process**: Enhanced installer to handle local modifications automatically
  - Detects and gracefully handles permission-only changes (automatically discarded with `git reset --hard`)
  - Stashes actual content changes before update and re-applies them after
  - Prevents update failures when installation directory has local modifications
  - Now checks both staged and unstaged changes using `git diff HEAD --numstat`
  - Exits with clear error if stashing fails (prevents unsafe updates)
  - Uses `git stash apply` instead of `pop` for better conflict detection and recovery
  - Only checks most recent stash to avoid confusion with old stashes from failed updates
  - Provides detailed guidance for resolving merge conflicts if they occur during restoration
  - Provides clear user feedback about what actions are being taken
  - Fixes issue where `curl | bash` installer would fail with "Failed to update repository" error

## [3.4.2] - 2025-11-08

### Changed

- **Documentation Optimization**: Refactored CLAUDE.md to reduce token usage in Claude Code context
  - Split large CLAUDE.md (418 lines) into focused documentation files:
    - `CLAUDE.md` - Quick reference with links to detailed docs
    - `docs/WORKFLOW.md` - Branch workflow, PR checklist, version management, development patterns
    - `docs/COMMANDS.md` - Complete command reference, hub configuration, project registry
  - Expected token reduction: ~60% reduction in base context (from ~4.4k to ~1.5k tokens)
  - Maintains all critical information with improved organization and discoverability
  - Each file serves specific use case: quick reference, workflow details, or command lookups
  - Added cross-references between files for easy navigation
  - Updated file structure section to reflect new documentation layout

## [3.4.1] - 2025-11-08

### Fixed

- **Version inconsistency in README.md**: Updated header and footer version references from 3.3.0 to 3.4.1
  - Fixed header badge (line 4)
  - Fixed footer metadata (line 353) with updated date
  - This was missed during the v3.4.0 release

### Added

- **VERSION-UPDATE-CHECKLIST.md**: Comprehensive checklist to prevent future version inconsistencies
  - Lists ALL files requiring version updates
  - Provides verification commands
  - Documents common pitfalls and solutions
  - Integrates with existing VERSION-MANAGEMENT.md workflow
  - Updated CLAUDE.md to reference checklist in version management section
  - Updated VERSION-MANAGEMENT.md with prominent checklist reference

## [3.4.0] - 2025-11-08

### Added

- **Interactive Session Selection**: `/use-case:document-session` now presents options instead of auto-documenting current session
  - **Prioritizes undocumented work**: Detects recent merged PRs (last 24 hours) and highlights those not yet documented
  - **User choice**: Developer selects which session to document using `AskUserQuestion` tool
  - **Multiple session support**: Can invoke command multiple times to document several PRs/sessions sequentially
  - **Smart detection**: Cross-references existing documentation to identify gaps
  - **Priority ordering**: 1) Undocumented PRs, 2) Current conversation, 3) Recent direct commits
  - Prevents documentation gaps where implementation work (PRs) was being skipped in favor of research sessions
  - Provides clear audit trail between PRs and their documentation

### Changed

- **Documentation workflow**: Changed from fully automatic to interactive selection + automatic generation
  - User interaction only at the start (selecting what to document)
  - After selection, documentation generation remains fully automatic
  - Maintains all existing automatic generation features (template adherence, metrics, sync)

### Added (Previous Unreleased)

- **Enhanced Copilot Instructions**: Comprehensive updates to `.github/copilot-instructions.md`
  - **Security and Safety Guidelines**: Input sanitization, credential handling, and environment isolation
  - **Performance Considerations**: Script efficiency, hub sync optimization, and memory usage guidelines
  - **Code Quality Standards**: Consistent error handling patterns, variable naming, and logging standards
  - **Troubleshooting Guide**: Common issues and solutions for hub sync, git hooks, and cross-platform compatibility
  - **Examples and Anti-Patterns**: Concrete good/bad code patterns with explanations
  - **CI/CD and Automation**: Branch protection, release automation, and backwards compatibility guidelines
  - **Integration Points**: Hub coordination, VS Code extension APIs, and package manager considerations
  - **Enhanced Communication Style**: Added testing instructions, documentation references, and "why" explanations

- **Session Data Extraction**: New `ai-use-case extract` command and `/use-case:extract-session` slash command
  - Extracts comprehensive session data from git history and file system
  - **Token usage tracking**: Capture input/output tokens, context size, cache hits, and estimated costs
  - **Multiple output formats**: JSON (structured data) or Markdown (human-readable reports)
  - Calculates metrics: commits, files changed, lines added/removed, duration, interactions
  - Automatic capture from Claude Code conversations when available
  - Manual input via `--token-*` flags for standalone use
  - Designed to support automated use case documentation and ROI reporting
  - Script location: `scripts/core/extract-session-data.sh`
  - Examples:
    - `ai-use-case extract 8 json --token-input 95000 --token-output 9687 --cost 0.43`
    - `ai-use-case extract 24 markdown -o session-report.md`

## [3.3.0] - 2025-11-07

### Changed

- **Folder Structure Refactoring**: Consolidated use case documentation into dedicated `.usecase/` directory
  - Use cases now stored in `.usecase/cases/` instead of `docs/ai-use-cases/`
  - Cleaner separation of use case documentation from project documentation
  - Simplified path structure (reduced nesting)
  - Claude commands remain in `.claude/commands/use-case/` for consistency
  - All documentation, scripts, and slash commands updated to use new paths
  - Project registry default path updated to `.usecase/cases`

### Added

- **Automatic Migration**: Setup script automatically migrates existing `docs/ai-use-cases/` to new structure
  - Detects old structure and prompts for migration during `ai-use-case --init`
  - Preserves all existing use case files
  - Updates `.gitignore` to exclude `.usecase/cases/` instead of old path
  - Backward compatibility in sync script warns users to migrate

- **Hub Configuration Command**: New `ai-use-case config` command for managing hub settings
  - `ai-use-case config show` - Display current hub configuration
  - `ai-use-case config reconfigure` - Interactively change hub mode (local/private)
  - Provides confirmation prompt before replacing existing configuration
  - Cleaner alternative to manually deleting config file

- **Restored ASCII Art Banner**: Brought back the classic installation banner
  - Replaced compact box design with original ASCII art project logo (displays "AI USE-CASE" for visual emphasis; official name remains `ai-use-case-cli`)
  - More visually distinctive and memorable
  - Maintains professional appearance with clear version information
  - Tagline: "Reduce documentation overhead, build knowledge"

### Removed

- **Shared hub option**: Hub configuration now offers only two modes for better privacy control
  - Local only mode (default) - No git, files stored locally
  - Private git mode - Connect to your own repository
  - Removes dependency on external shared repository
  - Users maintain full control over their documentation storage

## [3.2.1] - 2025-11-06

### Fixed

- **CLI Version Detection**: Fixed bug where project management scripts couldn't detect CLI version
  - `update-project.sh`, `list-projects.sh`, and `check-updates.sh` now correctly resolve CLI_ROOT
  - Previously showed "unknown" for CLI version, now displays actual version (e.g., 3.2.1)
  - Fixed by defining CLI_ROOT as parent directory of scripts directory
  - Affects: `scripts/project/update-project.sh:19,100`, `scripts/project/list-projects.sh:19`, `scripts/project/check-updates.sh:19,61`

### Added

- **Auto-confirm flag for update-project**: New `-y/--yes` flag to skip confirmation prompt
  - Enables non-interactive updates for automation and batch operations
  - Usage: `bash update-project.sh -y /path/to/project`
  - Useful for updating multiple projects in a loop
  - Example: `for p in $(check-updates.sh --paths-only); do update-project.sh -y "$p"; done`

## [3.2.0] - 2025-11-06

### Added

- **Optional Hub Repository Configuration**: Two flexible hub modes for documentation storage
  - **Local Only Mode**: Store files locally without git (no version control)
    - Files stored in `~/.local/share/ai-use-case-cli/hub/`
    - No git operations, no remote sync
    - Best for personal use and quick local documentation
    - Default mode for better privacy
  - **Private Git Mode**: Connect to your own private repository
    - Configure custom git repository URL during setup
    - Full version control with your chosen remote
    - Best for private team documentation and company-internal use
  - Configuration stored in `~/.config/ai-use-case-cli/config.json`
  - Interactive mode selection during first setup (`ai-use-case --init`)
  - New utility scripts: `config-manager.sh` and `hub-utils.sh`
  - Environment variable override still supported (`AI_USECASES_DIR`)
  - Users maintain full control over their documentation storage

- **Automated Version Bump System**: Fully automated version management with single command
  - `ai-use-case bump-version [major|minor|patch]` - automated version bumping
  - Automatically updates version.sh and CHANGELOG.md
  - Creates git commit with conventional commit message
  - Creates git tag (vX.Y.Z) for GitHub releases
  - Pushes to remote automatically
  - Supports dry-run, no-commit, no-tag, no-push options
  - Interactive confirmation prompts (can be skipped with --yes for CI/CD)
  - Detailed help with `ai-use-case bump-version --help`
  - Updated VERSION-MANAGEMENT.md with automated workflow documentation

- **Consolidated Templates into CLI**: Moved TEMPLATE.md and TEMPLATE-RESEARCH.md from hub repository to CLI docs/ directory
  - Establishes CLI as single source of truth for documentation structure
  - Templates now version-controlled with the tool that uses them
  - Slash command explicitly reads templates before generating documentation
  - Added header comments identifying templates as authoritative source
  - Updated documentation references across codebase to point to CLI templates
  - Interactive script now dynamically selects template based on session type (implementation vs research)

- **Centralized Version Management**: Introduced `version.sh` as single source of truth for CLI version
  - All scripts now source version from `version.sh` instead of hardcoding
  - Eliminates version drift across scripts
  - Simplifies version bumps - update one file instead of multiple
  - Includes version history and bump instructions in comments

### Changed

- **Hub setup and sync operations** now support all three hub modes
  - `setup-project.sh`: Prompts for hub mode selection on first run
  - `sync-ai-use-cases.sh`: Skips git operations in local-only mode
  - `push-hub.sh`: Warns users when in local-only mode
  - All hub-dependent scripts now use `hub-utils.sh` for consistency
  - Removed duplicate `ensure_hub_exists()` functions across scripts

- **Restructured bash scripts into organized directories**: Improved project organization and maintainability
  - Created logical directory structure under `scripts/`:
    - `core/` - Core functionality (document, sync, publish)
    - `project/` - Project management (setup, registry, updates)
    - `search/` - Search and analytics (search, stats)
    - `hub/` - Hub operations (view, push)
    - `install/` - Installation scripts
    - `utils/` - Utility scripts (version, bump-version, config-manager, hub-utils)
  - Updated all script paths in main CLI, install script, and cross-references
  - Updated documentation (README.md, CLAUDE.md) to reflect new structure
  - Benefits: Better organization, easier navigation, cleaner structure, better scalability

- **Streamlined README.md**: Major improvements for better usability and clarity
  - Consolidated command documentation into single comparison table (CLI vs Claude Code)
  - Removed redundant sections (file structure, verbose migration guide, direct script access)
  - Simplified session types and configuration sections
  - Fixed version inconsistency (footer now matches v3.1.0)
  - Reduced from 588 to 307 lines while maintaining all essential information
  - More scannable and user-focused structure
  - Moved developer-specific content to appropriate documentation files

- **Updated version retrieval in all scripts**:
  - `ai-use-case`: Sources `version.sh` for VERSION variable
  - `sync-ai-use-cases.sh`: Sources `version.sh` for display banner
  - `registry-manager.sh`: `get_cli_version()` now reads from `version.sh`
  - `document-ai-session.sh`: Updated local and remote version checks to use `version.sh`
  - `install.sh`: Updated remote and installed version checks to use `version.sh`
- Remote version checks now fetch `version.sh` instead of grepping `ai-use-case`
- All version display messages now use `$CLI_VERSION` variable

### Fixed

- **Template Path Resolution**: Updated `document-ai-session.sh` to reference templates from CLI docs/ directory
  - Changed from `$CENTRAL_DIR/TEMPLATE.md` (hub) to `$SCRIPT_DIR/docs/TEMPLATE.md` (CLI)
  - Ensures interactive documentation mode uses same template source as automatic mode
  - Addresses PR feedback about template location inconsistency

- Prevents future version inconsistencies like the v2.3.0 issue in sync script
- Makes version management more maintainable and less error-prone

### Removed

- **VS Code Extension**: Removed `vscode-extension/` directory to simplify project scope
  - Extension was at v2.2.0 and not actively maintained
  - Claude Code slash commands (`/use-case:*`) provide better AI-context-aware documentation
  - Simplifies version management and reduces maintenance burden
  - Users should migrate to Claude Code slash commands for best experience

## [3.1.1] - 2025-11-03

### Fixed

- Updated version display in `sync-ai-use-cases.sh` from v2.3.0/v2.0 to v3.1.1 for consistency with main CLI version

## [3.1.0] - 2025-11-02

### 🎉 Major Update: Hybrid CLI + Claude Code Interface

**Standalone CLI commands are back!** v3.1.0 restores all standalone bash commands while maintaining Claude Code integration, giving you the flexibility to choose your preferred workflow.

### Added

- **Restored Standalone CLI Commands**: All v2.x commands work again!
  - `ai-use-case --init` - Setup current project
  - `ai-use-case sync` - Sync use cases to hub
  - `ai-use-case search <term>` - Search documented use cases
  - `ai-use-case list` - List all registered projects
  - `ai-use-case stats` - View statistics
  - `ai-use-case view` - Open hub directory
  - `ai-use-case push` - Push hub changes
  - `ai-use-case publish-confluence` - Publish to Confluence
  - `ai-use-case uninstall` - Uninstall the CLI
  - `ai-use-case list-projects` - List projects with versions
  - `ai-use-case check-updates` - Check for updates
  - `ai-use-case update-project <path>` - Update project

- **Project Registry System**: Track all projects using the CLI tool
  - `registry-manager.sh` - Core registry management functions
  - `~/.local/share/ai-use-case-cli/projects-registry.json` - Registry database
  - Automatic project registration during setup
  - Track CLI version per project
  - Track installation and update timestamps

- **New Commands for Registry Management**:
  - `list-projects.sh` - Enhanced to show both hub and registry information with version status
  - `check-updates.sh` - Identify projects with outdated CLI versions
  - `update-project.sh` - Update a specific project to the latest CLI version

- **New Claude Code Slash Commands**:
  - `/use-case:list-projects` - View all registered projects with version information
  - `/use-case:check-updates` - Check which projects need CLI updates
  - `/use-case:update-project` - Update a project to latest CLI version

### Changed

- **Complete rewrite of `ai-use-case` CLI**: Hybrid approach supporting both standalone and Claude Code workflows
  - Proper symlink resolution for global `ai-use-case` command
  - Clean, aligned UI with consistent box borders
  - Helpful notices directing users to Claude Code for documentation features
- `setup-project.sh` now automatically registers projects in the registry
- `list-projects.sh` enhanced to show registry data alongside hub information
- Project updates now tracked with timestamps for audit trail
- Updated `install.sh` to reflect hybrid approach
- Updated all documentation (README.md, CLAUDE.md) to show both CLI and slash commands

### Fixed

- Symlink resolution: Commands now work correctly from any directory
- Border alignment in help messages and notices
- Path resolution for scripts when called via symlink

### Benefits

- ✅ **Flexibility**: Choose between fast CLI commands or AI-assisted documentation
- ✅ **Backward compatibility**: All v2.x commands work again
- ✅ **Best of both worlds**: Standalone utility + Claude Code integration
- Easily identify which projects are using the CLI
- Track CLI version across multiple projects
- Simplify bulk updates when new CLI versions are released
- Maintain audit trail of project setup and updates
- Enable better project lifecycle management

## [3.0.0] - 2025-11-02

### 🚨 BREAKING CHANGES

- **Removed standalone CLI commands**: The tool now exclusively uses Claude Code slash commands
  - Removed: `ai-use-case document`, `ai-use-case sync`, `ai-use-case init`, etc.
  - Use instead: `/use-case:document-session`, `/use-case:sync-usecases`, `/use-case:setup-project`, etc.
  - The `ai-use-case` command now shows a deprecation notice and available slash commands
  - Direct script access still available for advanced users (see `ai-use-case --help`)

### Added

- **New shell scripts** for direct access to functionality:
  - `search-use-cases.sh` - Search use cases by keyword
  - `stats-use-cases.sh` - Show statistics about use cases
  - `list-projects.sh` - List all projects with use cases
  - `view-hub.sh` - Open hub directory in file explorer
  - `push-hub.sh` - Commit and push hub changes
- **Updated slash commands** to call scripts directly instead of CLI commands
- **Comprehensive deprecation notice** explaining the migration to slash commands

### Changed

- Simplified `ai-use-case` to only show help, version, and deprecation notices
- Updated all slash command documentation to reference scripts directly
- Improved integration with Claude Code workflow

### Migration Guide

**Before (v2.x):**
```bash
ai-use-case document
ai-use-case sync
ai-use-case search authentication
```

**After (v3.x) - Use in Claude Code:**
```
/use-case:document-session
/use-case:sync-usecases
/use-case:search-usecases
```

For advanced users who need direct script access:
```bash
bash ~/.local/share/ai-use-case-cli/document-ai-session.sh
bash ~/.local/share/ai-use-case-cli/sync-ai-use-cases.sh
bash ~/.local/share/ai-use-case-cli/search-use-cases.sh authentication
```

## [2.5.0] - 2025-11-02

### Added
- **Update command**: New `ai-use-case update` command for simplified CLI updates
  - Automatically checks for and installs the latest version from GitHub
  - Shows current vs. latest version comparison
  - Displays recent changes from CHANGELOG before updating
  - Supports `--check` flag to only check for updates without installing
  - Supports `--yes` flag to skip confirmation prompt (useful for automation)
  - Validates git installation and checks for local modifications
  - Clears version check cache after successful update
  - Provides clear error messages and fallback to manual update instructions
  - Replaces manual `cd ~/.local/share/ai-use-case-cli && git pull` process

## [2.4.0] - 2025-11-02

### Added
- **Enhanced documentation templates** (in hub repository):
  - Added comprehensive Token Usage Summary section with input/output tokens and cache hits
  - Added detailed token breakdown tables by phase (analysis, implementation, testing, documentation)
  - Added interaction breakdown by phase with average tokens
  - Added ROI calculations for cost efficiency analysis
  - Enhanced both TEMPLATE.md and TEMPLATE-RESEARCH.md
- **Interactive metrics collection** (in document-ai-session.sh):
  - Added prompts for total interactions count
  - Added prompts for user prompts/messages sent
  - Added prompts for token usage (input, output, total) - optional fields
  - Added prompts for estimated costs - optional field
  - Automatically integrates collected metrics into generated documentation

### Changed
- **Better metrics organization**: Moved token metrics earlier in templates for prominence

## [2.3.0] - 2025-11-01

### Added
- **Detailed version command**: New `ai-use-case version` command for comprehensive version verification
  - Shows current version, installation directory, and git information
  - Displays last update check time
  - Actively checks for updates from GitHub repository
  - Provides update instructions if newer version is available
  - Complements existing `--version`/`-v` flag for quick version check
  - Useful for troubleshooting and verifying installation status
- **Improved CLAUDE.md**: Restructured root CLAUDE.md as concise quick reference guide
  - Critical requirements upfront (branch workflow, version management)
  - Pre-PR checklist and common patterns
  - Clear guardrails and references to detailed documentation
- **ISO 8601 week numbers**: Added week numbers to file naming convention
  - New format: YYYY-Www-MM-DD_TICKET-XXX_description.md
  - Better temporal organization with ISO 8601 week format (W01-W53)
  - Maintains chronological sort order
  - Updated all scripts and documentation

### Changed
- **Compact installation banner**: Reduced banner from 13 lines to 5 lines
  - Removed large ASCII art for cleaner display
  - Shows only essential info: name, version, description
  - More professional and space-efficient

---

**Note**: The following section contains previously documented unreleased changes that remain pending future releases.

### Added
- **Enhanced documentation templates in hub repository**: Templates now include comprehensive AI interaction metrics
  - Added AI Interaction Metrics section (prompts, success rates, tool usage)
  - Added Key User Queries section for query tracking (optional but recommended)
  - Added Query Effectiveness Analysis for research sessions
  - Enhanced Time Analysis with detailed breakdowns
  - Improved Code Quality Metrics section
  - Links to AI_SESSION_STATISTICS_GUIDE.md and CAPTURING_USER_QUERIES.md for detailed guidance
  - Week number added to date fields for better temporal organization
  - Supports prompt quality analysis and learning patterns
  - Hub PR: https://github.com/mt-osiris-tools/ai-use-case-hub/pull/2
- **Version check for document command**: CLI now verifies it's up-to-date before documenting sessions
  - Checks for updates when running `ai-use-case document` or `/use-case/document-session`
  - Warns users if newer version available with update instructions
  - Prompts to continue or update first (interactive mode)
  - **Handles non-interactive contexts** (CI/CD, piped commands, automation):
    - Detects non-interactive terminal using `[ -t 0 ]` check
    - Continues automatically with warning in non-interactive mode
    - No blocking prompts that would fail automation
  - **Automation support**: `--skip-version-check` flag to skip check entirely
  - Ensures users document with latest features and bug fixes
  - Prevents issues from outdated CLI versions during documentation
  - Gracefully handles network failures (continues with current version)

### Changed
- **Claude Code command organization**: Improved command directory structure
  - Commands now organized in `.claude/commands/use-case/` subdirectory
  - Cleaner command invocation: `/use-case/document-session` instead of `/use-case:document-session`
  - Better separation and discoverability of related commands
  - Updated setup-project.sh to install commands in new location
  - Updated all documentation to reflect new command paths
- **Hub git tracking architecture**: Documentation updated to clarify version control behavior
  - `by-project/` directories are tracked in git (canonical storage)
  - `by-date/` and `by-topic/` symlinks excluded via .gitignore (view layer only)
  - Updated hub repository `.gitignore` in v2.1.0+ to explicitly track `by-project/` subdirectories
    - Previously, a broad ignore rule excluded these directories unintentionally
    - Now, all project documentation is versioned as intended
  - README.md and CLAUDE.md updated with git tracking clarifications
- **Installation banner**: Improved installation banner messaging for better professionalism
  - Removed organization-specific branding
  - Updated tagline to be clearer and more concise
  - Removed emoji for cleaner appearance
  - Better suited for open-source project
- **Installation command list**: Now shows all 10 available commands instead of 6
  - Added: push, publish-confluence, view, list
  - Users now see complete CLI capabilities immediately after installation
  - Fixed alignment using printf formatting for professional appearance

### Added
- **Auto-update check for --init command**: Ensures users always run setup with the latest version
  - Checks for updates before running `ai-use-case --init`
  - Prompts user to update if newer version available
  - Automatically restarts with updated version after successful update
  - Critical for ensuring projects are set up with latest features and fixes
- **GitHub Copilot instructions**: Added `.github/copilot-instructions.md` for GitHub Copilot guidance
  - Provides repository context and architecture constraints for Copilot
  - Documents required workflow (branch naming, conventional commits, CHANGELOG updates)
  - Includes CLI scripts, VS Code extension, and documentation generation guidance
  - Ensures Copilot contributions align with team standards and workflows
  - Complements existing CLAUDE.md for AI assistant guidance
- **Hub-CLI Synchronization Checklist**: Comprehensive guide for maintaining consistency between repositories
  - HUB-SYNC-CHECKLIST.md with complete validation process
  - When to review hub repository (templates, workflows, naming, features, tickets)
  - 5-step validation checklist (identify, review, update, version, test)
  - Practical example using research session support (v2.2.0)
  - Quick reference with bash commands for common update patterns
  - Troubleshooting section for common synchronization issues
  - Automation opportunities for future enhancements
  - Hub-CLI Synchronization section added to CLAUDE.md
- **Pre-commit hook for branch protection**: Prevents direct commits to main/master branches
  - Installed automatically by `setup-project.sh` in all projects using the CLI
  - Blocks commits to protected branches with clear error message
  - Provides guidance on creating feature branches with conventional naming
  - Shows branch naming conventions (feature/, fix/, docs/, refactor/, test/)
  - Can be bypassed with `--no-verify` flag in exceptional cases
  - Enforces branch-based workflow across all projects using the CLI
- **Branch-based development workflow**: All changes now require pull requests
  - CONTRIBUTING.md with comprehensive contribution guidelines
  - Branch naming conventions (feature/, fix/, docs/, refactor/, test/)
  - PR requirements checklist (CHANGELOG, testing, documentation)
  - Conventional commit message guidelines
- BRANCH-PROTECTION-SETUP.md with step-by-step GitHub configuration guide
- Development workflow section in CLAUDE.md for AI assistant guidance
- Automated PR workflow for Claude Code with approval prompts

### Changed
- **Documentation structure**: Reorganized project documentation following GitHub best practices
  - Moved project-specific docs to `docs/` directory
  - Kept community standards at root (README.md, CHANGELOG.md, CONTRIBUTING.md)
  - Updated all references and internal links
  - Files moved: CLAUDE.md, HUB-SYNC-CHECKLIST.md, HUB-FILES.md, BRANCH-PROTECTION-SETUP.md, CONFLUENCE-DESIGN.md
- **Slash command organization**: Reorganized commands with `use-case:` namespace prefix
  - Improved command organization with clear namespacing using colon syntax
  - Commands now use `/use-case:` prefix (e.g., `/use-case:document-session`)
  - More conventional syntax compared to slash-based paths
  - All related commands logically grouped for better discoverability
  - Updated documentation across CLAUDE.md, setup-project.sh, and command files
- `setup-project.sh` now installs both pre-commit and post-commit hooks
- Updated README.md with branch protection documentation
- Updated CLAUDE.md to document pre-commit hook functionality
- Enhanced Git Hook Templates section with pre-commit hook details
- Updated troubleshooting section to include both hooks
- README.md Contributing section updated to reference new guidelines
- Enhanced CLAUDE.md with mandatory branch/PR workflow for AI assistants
- Repository now requires PR-based workflow (no direct commits to main)

## [2.2.0] - 2025-10-20

### Added
- **Research session support**: Document exploratory AI sessions without code changes
  - New session type selection in interactive mode (Implementation vs Research)
  - Auto-generated `RESEARCH-XXX` ticket numbering for research sessions
  - Research-specific template with 🔬 icon (vs 🎯 for implementation)
  - Query evolution tracking through conversation iterations
  - Approach evaluation with pros/cons comparison
  - Decision documentation with rationale and implementation guidance
- Research session fields: initial query, iterations, insights, approaches evaluated, final decision
- Automatic session type detection in Claude Code `/use-case:document-session` command
- Research session examples in README and CLAUDE.md
- Comprehensive research session documentation workflow

### Changed
- `document-ai-session.sh` now supports both implementation and research session types
- File naming convention expanded to include `RESEARCH-XXX` format
- `/use-case:document-session` slash command updated to handle research sessions automatically
- CLAUDE.md updated with research session guidance for AI assistants
- README.md enhanced with session types section and examples

### Improved
- Better separation of concerns between code-focused and exploration-focused sessions
- More flexible documentation workflow accommodating different AI interaction patterns
- Enhanced template system with dual templates for different session types

## [2.1.1] - 2025-10-14

### Added
- Version display in install script banner showing current vs. new version
- Automatic version detection from GitHub in install script
- Smart update prompt when outdated version is detected
- Automatic `git pull` for seamless updates when running install script

### Changed
- Install script now offers to update instead of showing "Installation cancelled"
- Update prompt defaults to Yes for better user experience
- Install script provides clear messaging about version status

### Fixed
- Users no longer stuck when running install script with existing installation
- Better handling of various installation scenarios (git repo, non-git, missing versions)

## [2.1.0] - 2025-10-14

### Added
- Unified CLI interface with `ai-use-case` command
- Automatic version checking (once per 24 hours)
- Update notifications with instructions
- `push` command for manual hub synchronization
- `publish-confluence` command for publishing to Atlassian Confluence
- Confluence MCP integration for seamless wiki publishing
- Non-blocking background version checks

### Changed
- Separated CLI tools from documentation hub repository
- Sync command now automatically commits and pushes to hub remote
- Improved error messages and user feedback
- Enhanced documentation in CLAUDE.md and README.md

### Fixed
- Hub repository auto-cloning when not present
- Path resolution for symlinked installations
- Git push confirmation prompts

## [2.0.0] - 2025-10-13

### Added
- Symlink-based architecture in hub repository
- `by-date/` organization (YYYY/MM/ structure)
- `by-topic/` organization (topic slug structure)
- `by-project/` canonical storage
- Post-commit git hook for automatic sync
- VS Code extension for one-click documentation
- Interactive `document-ai-session.sh` script

### Changed
- Complete restructure of hub organization
- Moved from flat structure to multi-view symlink system
- Enhanced template with comprehensive sections

### Removed
- Flat directory structure in hub

## [1.0.0] - 2025-10-10

### Added
- Initial release of AI Use Case CLI
- Basic `sync-ai-use-cases.sh` script
- Project setup functionality
- Simple documentation workflow
- Git integration for tracking AI sessions
- Basic template for use case documentation

[Unreleased]: https://github.com/mt-osiris-tools/ai-use-case-cli/compare/v2.3.0...HEAD
[2.3.0]: https://github.com/mt-osiris-tools/ai-use-case-cli/compare/v2.2.0...v2.3.0
[2.2.0]: https://github.com/mt-osiris-tools/ai-use-case-cli/compare/v2.1.1...v2.2.0
[2.1.1]: https://github.com/mt-osiris-tools/ai-use-case-cli/compare/v2.1.0...v2.1.1
[2.1.0]: https://github.com/mt-osiris-tools/ai-use-case-cli/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/mt-osiris-tools/ai-use-case-cli/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/mt-osiris-tools/ai-use-case-cli/releases/tag/v1.0.0
