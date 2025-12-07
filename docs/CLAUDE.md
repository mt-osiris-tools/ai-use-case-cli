# CLAUDE.md

This file provides guidance to AI coding assistants (Claude Code, GitHub Copilot, etc.) when working with code in this repository.

## Repository Purpose

This repository contains the **CLI tools** for documenting AI-assisted development workflows across multiple software projects, designed to help developers on a daily basis.

**Main Goals:**
- **Reduce cognitive overload**: Minimize the mental burden of documentation through guided, pre-built templates
- **Build knowledge base**: Create a comprehensive, searchable repository of AI tool usage patterns and successful solutions
- **Enable learning**: Help teams learn from past AI-assisted sessions and improve their AI interaction techniques
- **Streamline workflow**: Quick, template-based documentation that integrates seamlessly with daily development

**Architecture:**
- **This repo (ai-use-case-cli)**: CLI tools, scripts, VS Code extension
- **Hub repo (ai-use-case-hub)**: Central documentation storage with symlink-based organization

The CLI tools in this repository provide commands for setting up projects, documenting AI sessions, syncing documentation, and searching use cases. By reducing the friction of documentation, we make it easy for teams to build valuable knowledge bases of their AI work.

## Installation for End Users

End users should install this CLI tool using:

```bash
curl -fsSL https://raw.githubusercontent.com/mt-osiris-tools/ai-use-case-cli/main/install.sh | bash
```

Or clone and install manually:

```bash
git clone https://github.com/mt-osiris-tools/ai-use-case-cli.git ~/.local/share/ai-use-case-cli
cd ~/.local/share/ai-use-case-cli
./install.sh
```

This creates a symlink at `~/.local/bin/ai-use-case` for global CLI access.

## What This Repository Contains

### Core CLI Tool

- **`ai-use-case`**: Main CLI entry point with unified command interface
  - `ai-use-case --init` - Setup a project
  - `ai-use-case document` - Document an AI session
  - `ai-use-case sync` - Sync to hub (auto-commits and pushes)
  - `ai-use-case push` - Manually commit and push hub changes
  - `ai-use-case publish-confluence` - Publish to Confluence
  - `ai-use-case search` - Search use cases
  - `ai-use-case stats` - Show statistics
  - `ai-use-case tracing` - Manage tracing configuration (v3.6.0+)
  - `ai-use-case list` - List projects
  - `ai-use-case view` - Open hub in file explorer
  - `ai-use-case update` - Update CLI to latest version
  - `ai-use-case version` - Show detailed version info

### Shell Scripts

1. **`setup-project.sh`**: One-time setup for a project repository
   - Creates `.usecase/cases/` directory in target project
   - Installs git pre-commit hook for branch protection
   - Installs git post-commit hook for auto-sync
   - Copies slash commands to `.ai-tools/commands/use-case/`
   - Creates `.claude/commands/use-case/` symlink (preserves custom commands)
   - Adds `.gitignore` patterns for draft files
   - Performs initial sync to hub

2. **`sync-ai-use-cases.sh`**: Syncs documents from project to hub
   - Copies files from project's `.usecase/cases/` to hub's `by-project/[project-name]/`
   - Creates symlinks in hub's `by-date/` based on YYYY-MM-DD prefix
   - Creates symlinks in hub's `by-topic/` based on topic slug
   - **Automatically commits changes to hub's git repository**
   - **Automatically pushes to remote repository** (if configured)
   - Idempotent - safe to run multiple times
   - Note: Only `by-project/` files are tracked in git; symlink directories are excluded via .gitignore

3. **`document-ai-session.sh`**: Interactive AI session documentor
   - Guides you through documenting an AI-assisted coding session
   - Captures git changes, file modifications, timestamps
   - Auto-populates template with session data
   - Can be triggered from shell or VS Code extension
   - Integrates with existing sync workflow

4. **`install.sh`**: Installs the CLI tool globally
   - Creates symlink to `~/.local/bin/ai-use-case`
   - Optionally adds environment variables to shell profile
   - No system-wide changes - everything is user-scoped

5. **`uninstall.sh`**: Removes the CLI tool
   - Removes symlink from `~/.local/bin/`
   - Optionally removes the CLI directory
   - Optionally cleans shell profile entries

### Git Hook Templates

- **`git-hooks/pre-commit`**: Branch protection hook
  - Prevents direct commits to main/master branches
  - Enforces branch-based workflow (feature/, fix/, docs/, etc.)
  - Provides clear guidance on creating feature branches
  - Can be bypassed with `--no-verify` if needed

- **`git-hooks/post-commit`**: Auto-sync hook
  - Detects when markdown files in `.usecase/cases/` directories are committed
  - Automatically triggers sync script to push docs to hub
  - Non-blocking - sync failures don't prevent commits

### VS Code Extension

- **`vscode-extension/`**: VS Code extension for one-click documentation
  - Triggered via Command Palette or keyboard shortcut (Ctrl+Alt+D)
  - Can be invoked from GitHub Copilot chat: `@workspace document my AI session`
  - Wraps the document-ai-session.sh script

### AI Assistant Integration

- **`.ai-tools/commands/use-case/`**: Slash commands for AI coding assistants
  - `/use-case:quick-start` - Get started guide
  - `/use-case:setup-project` - Setup a project
  - `/use-case:document-session` - Document an AI session (AUTOMATIC MODE)
  - `/use-case:sync-usecases` - Sync to hub
  - `/use-case:search-usecases` - Search use cases
  - `/use-case:publish-confluence` - Publish to Confluence

## For AI Assistants: Automatic Documentation

**IMPORTANT**: When the `/use-case:document-session` slash command is invoked in an AI coding assistant, documentation should be **automatically generated** based on git history and conversation context. Do NOT run the interactive `document-ai-session.sh` script.

### Automatic vs Interactive Mode

The documentation system supports two modes:

**Automatic Mode (AI Assistants):**
- Triggered by `/use-case/document-session` command in AI coding assistants
- AI analyzes git history + conversation context
- Zero user prompts required
- Generates complete documentation with all sections filled
- Best for AI-assisted sessions where the assistant has full context
- Supports both implementation and research sessions

**Interactive Mode (Manual Shell):**
- Triggered by `ai-use-case document` command in terminal
- User runs script directly without AI assistance
- Prompts user for all details interactively
- Best for manual documentation or when no AI context exists
- Supports both implementation and research sessions

### Session Types

The system now supports two types of AI sessions:

**1. Implementation Sessions (Code Changes):**
- Involves actual code changes, commits, file modifications
- Requires git history with commits
- Focuses on: technical implementation, files changed, code patterns
- Uses ticket format: `PROJ-XXX`, `HUB-XXX`, etc.
- Metrics: files changed, lines added/removed, tests passing

**2. Research Sessions (Exploratory):**
- No code changes or commits required
- Focuses on: query refinement, approach evaluation, decision-making
- Back-and-forth conversations to explore solutions
- Uses ticket format: `RESEARCH-XXX` (auto-generated if not provided)
- Metrics: iterations, insights gained, approaches evaluated, decisions made

**When to use Research Session documentation:**
- Exploring architectural approaches
- Evaluating multiple technical solutions
- Refining complex queries to find optimal solutions
- Making technology or design decisions
- Understanding existing codebases without modifications
- Investigating bugs or issues before implementing fixes

### Automatic Documentation Workflow

When `/use-case:document-session` is invoked in an AI coding assistant:

1. **Check CLI Version**: Verify the CLI is up-to-date before starting
   - Compare current version with latest from GitHub
   - If outdated, warn user and recommend updating
   - Ask if they want to continue or update first
   - If network check fails, continue with current version

2. **Analyze Git History** (run commands in parallel):
   ```bash
   git log --since="24 hours ago" --pretty=format:"%h - %s (%ar)" | head -20
   git show --stat HEAD
   git diff HEAD~1..HEAD
   git status --short
   ```

3. **Extract Session Information** from:
   - Recent commit messages and descriptions
   - Conversation context with the user
   - Files changed and their purpose
   - Technical decisions and rationale discussed

4. **Auto-populate Documentation Fields**:
   - **Date**: Use today's date (YYYY-MM-DD format)
   - **Ticket**: Extract from commit messages or infer next number (e.g., HUB-XXX, PROJ-XXX)
   - **Brief description**: Summarize main work from commits and conversation
   - **AI Tool**: "Claude Code (Sonnet 4.5)"
   - **Complexity**: Assess from scope (Low: 1-3 files, Medium: 4-10, High: 10+)
   - **Time saved**: Estimate based on complexity (Low: 0.5-1h, Medium: 1-3h, High: 3-8h)
   - **TL;DR**: Summarize from conversation and commits
   - **Objective & Background**: Extract from conversation context
   - **Technical details**: Include git stats, file lists, code patterns
   - **Results**: Quantify files changed, commits made, outcomes achieved

5. **Generate Complete Documentation File**:
   - Create file in `.usecase/cases/` with proper naming convention
   - Follow TEMPLATE.md or TEMPLATE-RESEARCH.md structure from CLI docs/ directory
   - Include all sections with real data (NO "TODO" or placeholders)
   - Use conversation context for qualitative insights
   - Use git data for quantitative metrics

6. **Commit and Sync**:
   ```bash
   git add .usecase/cases/YYYY-MM-DD_TICKET-XXX_description.md
   git commit -m "docs: AI session YYYY-MM-DD - TICKET-XXX - Brief description

   [Details about what was documented...]

   🤖 Generated with [Claude Code](https://claude.com/code)

   Co-Authored-By: Claude <noreply@anthropic.com>"

   # Sync to hub
   ai-use-case sync
   ```

### Key Principles for Claude Code

1. **Be Automatic**: Don't ask the user to fill anything - you have all the context
2. **Be Complete**: Generate comprehensive documentation with all sections filled
3. **Be Precise**: Use exact numbers from git (files, lines, commits) for implementation sessions
4. **Be Contextual**: Use conversation history for qualitative insights
5. **Be Professional**: Follow template structure, use proper formatting

### Automatic Research Session Documentation

When the session involves NO code changes (research/exploration only):

1. **Detect Research Session**: Check if conversation was purely exploratory
   - No commits made
   - No files modified
   - Focus on questions, decisions, or architecture discussion

2. **Generate Research Ticket**: Use format `YYYY-MM-DD_RESEARCH-XXX_description.md`
   - Auto-increment RESEARCH number based on existing research docs
   - Example: `2025-10-20_RESEARCH-001_evaluate-database-migration-strategies.md`

3. **Extract Research Context** from conversation:
   - **Initial Query**: User's original question or problem
   - **Query Iterations**: Count how many times the query was refined
   - **Key Insights**: List all important learnings discovered
   - **Approaches Evaluated**: Different solutions considered
   - **Final Decision**: Recommended approach and rationale

4. **Generate Research Documentation**:
   - Use research template (with 🔬 icon, not 🎯)
   - Focus on query evolution, insights, and decisions
   - Include conversation excerpts showing refinement process
   - Document trade-offs of each approach evaluated
   - Provide clear recommendation with implementation guidance

5. **Save WITHOUT Committing** (since no code changes):
   ```bash
   # Create documentation file
   # (Use Write tool to create the file)

   # For research sessions, document may be committed separately OR
   # left as draft for manual commit by user
   ```

### Research Session Example Structure

```markdown
# 🔬 Claude Code: Evaluate API Authentication Approaches

**Session Type:** Research & Exploration
**Query Iterations:** 5 iterations to reach optimal solution
**Approaches Evaluated:** 3 distinct approaches
**Decision Confidence:** High

## 🔍 Research Context
Initial Query: "What's the best way to handle API authentication?"
[Evolved through 5 iterations to specific OAuth2 vs JWT comparison]

## 💡 Key Insights Discovered
- JWT better for stateless microservices
- OAuth2 better for third-party integrations
- Session-based auth simplest for internal tools

## ✅ Final Decision & Recommendation
**Decision:** Use JWT with refresh tokens
**Rationale:** [Detailed reasoning based on requirements]
```

### Example Automatic Documentation

**Implementation Sessions:**
- `2025-10-14_HUB-001_fix-color-encoding-in-cli-tools.md`
- `2025-10-14_HUB-002_update-github-organization-references.md`
- `2025-10-14_HUB-003_enable-automatic-ai-session-documentation.md`

**Research Sessions:**
- `2025-10-20_RESEARCH-001_evaluate-database-migration-strategies.md` (example)
- `2025-10-20_RESEARCH-002_compare-state-management-libraries.md` (example)

All auto-generated by Claude Code with complete sections and no placeholders.

## For Claude Code: Development Workflow

**CRITICAL**: All changes to this repository MUST follow a branch-based workflow with pull requests. Direct commits to `main` are NOT allowed.

### Branch and PR Requirements

When working on features or fixes in this repository:

1. **Always create a feature branch**:
   ```bash
   git checkout -b feature/description-of-change
   ```
   - Use format: `feature/description` (e.g., `feature/add-version-check`)
   - Other types: `fix/`, `docs/`, `refactor/`, `test/`

2. **Make changes with conventional commits**:
   ```bash
   git commit -m "feat: add version checking to CLI" \
     -m "Implements automatic version checking that runs once per day in the background. Notifies users when updates are available."
   ```
   - Use prefixes: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`

3. **Before creating PR, complete checklist**:
   - ✅ Update **CHANGELOG.md** under `## [Unreleased]` section
   - ✅ Check **HUB-SYNC-CHECKLIST.md** if changes affect hub repository
   - ✅ Test changes locally (run scripts, CLI commands)
   - ✅ Update **README.md** or **CLAUDE.md** if behavior changes

4. **Ask user before creating PR**:
   - Show summary of changes made
   - Confirm all checklist items completed
   - Wait for user approval before creating PR

5. **Create PR with detailed description**:

   **Note**: The example below shows the structure. In practice, use the Bash tool to construct the PR description properly.

   ```bash
   # Example structure (illustrative - see actual implementation in git workflow)
   gh pr create --title "feat: add version checking" --body "[markdown description]"
   ```

   **PR Description should include**:
   ```markdown
   ## Summary
   - Implements automatic version checking
   - Runs once per day with caching
   - Non-blocking background execution

   ## Changes Made
   - Added check_for_updates() function
   - Updated CHANGELOG.md
   - Tested with multiple scenarios

   ## Checklist
   - [x] CHANGELOG.md updated
   - [x] HUB-SYNC-CHECKLIST.md reviewed
   - [x] Changes tested locally
   - [x] Documentation updated

   🤖 Generated with [Claude Code](https://claude.com/code)
   ```

   **Practical implementation**: Use the Bash tool with heredoc as shown in the git workflow section (line ~260)

### Example Claude Code Session

**User Request:** "Add a --dry-run flag to the sync command"

**Claude's Workflow:**
1. Create feature branch: `feature/add-dry-run-flag`
2. Implement the feature with proper commits
3. Update CHANGELOG.md with new feature
4. Check HUB-SYNC-CHECKLIST.md (no hub changes needed)
5. Test locally: `./ai-use-case sync --dry-run`
6. Update README.md with new flag documentation
7. **Ask user**: "I've implemented the --dry-run flag and completed all checklist items. Would you like me to create a pull request?"
8. Wait for user approval
9. Create PR with detailed description
10. Provide PR URL to user

### Workflow Checklist (For Every Change)

Before asking to create PR, verify:

- [ ] Created feature branch (not on `main`)
- [ ] Made atomic commits with conventional commit messages
- [ ] **MANDATORY: Updated CHANGELOG.md under `## [Unreleased]`** (non-negotiable)
- [ ] **MANDATORY: Reviewed and updated README.md** (non-negotiable if user-facing)
- [ ] Reviewed HUB-SYNC-CHECKLIST.md (if applicable)
- [ ] Tested changes locally (all scripts/commands work)
- [ ] Updated all related documentation (docs/*, CLAUDE.md, CONTRIBUTING.md)
- [ ] All commits include proper descriptions
- [ ] Ready to ask user for PR approval

**⚠️ DOCUMENTATION REVISION RULE:**
Every code change MUST trigger a documentation review. This is non-negotiable:
- **CHANGELOG.md**: MUST be updated for ALL changes (describe what changed and why)
- **README.md**: MUST be reviewed and updated if any user-facing functionality changed
- **Related docs**: MUST be updated if behavior, architecture, or workflows changed
- No PR should be created without documentation updates

### Never Do These

- ❌ Never commit directly to `main` branch
- ❌ **Never skip CHANGELOG.md updates** (MANDATORY for all changes)
- ❌ **Never skip README.md review** (MANDATORY for user-facing changes)
- ❌ Never create PR without updating documentation
- ❌ Never create PR without asking user first
- ❌ Never skip testing changes locally
- ❌ Never forget to check HUB-SYNC-CHECKLIST.md for hub-related changes

### Reference

For complete details, see **CONTRIBUTING.md** in this repository.

## Documentation Hub Repository

The CLI tools sync documentation to a **separate hub repository** that provides:

- **`by-project/`**: Canonical storage - all actual markdown files (tracked in git)
- **`by-date/`**: View layer - symlinks organized by YYYY/MM/ (not tracked in git)
- **`by-topic/`**: View layer - symlinks organized by topic slug (not tracked in git)
- **`QUICK-REFERENCE.md`**: Command reference guide
- **`CHANGELOG.md`**: Version history

**Note**: Templates (TEMPLATE.md and TEMPLATE-RESEARCH.md) are now in the CLI repository (docs/ directory), not in the hub.

The hub repository should be cloned separately:

```bash
cd ~/Documents
git clone https://github.com/mt-osiris-tools/ai-use-case-hub.git ai-use-case-hub
```

## File Naming Convention

All use case documents created by these tools MUST follow this pattern:
```
YYYY-Www-MM-DD_TICKET-XXXXX_brief-description.md
```

Where:
- `YYYY` = Year (e.g., 2025)
- `Www` = ISO 8601 week number (W01-W53)
- `MM` = Month (01-12)
- `DD` = Day (01-31)
- `TICKET-XXXXX` = Ticket identifier
- `brief-description` = Lowercase with hyphens

**Examples (Implementation Sessions):**
- `2025-W42-10-13_LSFB-63055_add-environment-parameter-message-flow.md`
- `2025-W42-10-14_PROJ-1234_implement-user-authentication.md`

**Examples (Research Sessions):**
- `2025-W43-10-20_RESEARCH-001_evaluate-database-migration-strategies.md`
- `2025-W43-10-20_RESEARCH-002_compare-authentication-approaches.md`

**Ticket Format Guidelines:**
- Implementation sessions: Use project ticket (e.g., `PROJ-1234`, `HUB-001`)
- Research sessions: Use `RESEARCH-XXX` (auto-generated or manual)
- Format requirements:
  - Pattern: `[A-Z]+-[0-9]+`
  - One or more uppercase letters: `[A-Z]+`
  - Exactly one dash: `-` (literal character, not quantified)
  - One or more digits: `[0-9]+`
  - Valid examples: `PROJ-1234`, `RESEARCH-001`, `HUB-42`
  - Invalid examples: `proj-123` (lowercase), `PROJ--123` (multiple dashes), `PROJ_123` (underscore)

**Parsing logic:**
- Date extraction: `^([0-9]{4})-W([0-9]{2})-([0-9]{2})-([0-9]{2})`
- Ticket and topic: `_([A-Z]+-[0-9]+)_(.+)\.md$`
- Full filename validation: `^[0-9]{4}-W[0-9]{2}-[0-9]{2}-[0-9]{2}_[A-Z]+-[0-9]+_.+\.md$`

The sync script uses regex to parse filenames and organize symlinks in the hub.

## Environment Variables

The scripts support these optional environment variables:

```bash
# Location of the documentation hub (not this CLI repo)
export AI_USECASES_DIR="$HOME/Documents/ai-use-case-hub"

# Path to the sync script (auto-detected if AI_USECASES_DIR is set)
export AI_USECASES_SYNC_SCRIPT="$AI_USECASES_DIR/sync-ai-use-cases.sh"
```

**Note**: If `AI_USECASES_DIR` is not set, scripts default to:
1. Directory where the script is located (for development)
2. `$HOME/Documents/ai-use-case-hub` (for installed hub)

## Common Commands (End User Perspective)

### Setting Up a New Project

```bash
cd /path/to/your/project
ai-use-case --init
```

This runs `setup-project.sh` which:
- Creates `.usecase/cases/` in the project
- Installs post-commit hook
- Adds `.gitignore` patterns
- Runs initial sync to hub

### Documenting an AI Session

```bash
cd /path/to/your/project
ai-use-case document
```

This runs `document-ai-session.sh` which:
- Collects git changes and session statistics
- Guides you through interactive prompts
- Generates documentation using the CLI's TEMPLATE.md or TEMPLATE-RESEARCH.md
- Saves to `.usecase/cases/` with proper naming
- Optionally commits and syncs automatically

### Manual Sync

```bash
cd /path/to/your/project
ai-use-case sync
```

This will:
1. Copy documentation files to the hub
2. Create appropriate symlinks
3. Commit changes to the hub's git repository
4. Push to the remote repository (if configured)

### Manual Push (Hub Only)

If you need to commit and push hub changes without syncing:

```bash
ai-use-case push
```

This interactively commits any uncommitted changes in the hub and pushes to the remote.

### Searching Use Cases

```bash
ai-use-case search authentication
```

### Viewing Statistics

```bash
ai-use-case stats
```

## Development Workflow

**IMPORTANT**: This repository requires branch-based development with pull requests. See the **"For Claude Code: Development Workflow"** section above for detailed requirements, or refer to **CONTRIBUTING.md** for complete guidelines.

When developing or modifying this CLI tool repository:

### Script Development

All scripts are self-contained bash scripts with embedded documentation. They:
- Use `set -e` for fail-fast behavior
- Include color-coded output for user feedback
- Support both environment variables and auto-detection for paths
- Are idempotent where applicable

### Path Resolution Strategy

Scripts resolve paths in this priority order:
1. `AI_USECASES_DIR` environment variable (points to hub)
2. Script's own directory (for development and installed scenarios)
3. Default: `$HOME/Documents/ai-use-case-hub`

### Testing Changes

```bash
# Test CLI wrapper
./ai-use-case --help

# Test setup script
./setup-project.sh /tmp/test-project

# Test sync script
./sync-ai-use-cases.sh /tmp/test-project

# Test documentation script
./document-ai-session.sh /tmp/test-project
```

### VS Code Extension Development

```bash
cd vscode-extension
npm install
npm run compile
# Press F5 in VS Code to launch Extension Development Host
```

## Important Constraints

1. **This repo contains tools only** - no `by-project/`, `by-date/`, or `by-topic/` directories. Those are in the hub repository.

2. **Respect the naming convention** - the sync script regex depends on it:
   - Must start with YYYY-MM-DD
   - Must include TICKET-XXXXX format
   - Must have descriptive slug after ticket

3. **CLI tools are version controlled here** - Scripts, documentation, and extension code are tracked in this repository.

4. **Hub infrastructure is separate** - The documentation hub with its symlink architecture is a separate repository.

5. **Scripts must work in multiple contexts**:
   - Installed globally via symlink
   - Run directly from git clone
   - Called from VS Code extension
   - Invoked via Claude Code slash commands

## Workflow for Creating New Use Cases (User Perspective)

**Option 1: Automated (Recommended)**
1. Complete your AI-assisted coding session
2. Run `ai-use-case document` (or use VS Code command)
3. Follow interactive prompts
4. Script generates documentation, commits, and syncs automatically

**Option 2: Manual**
1. Navigate to your project
2. Create markdown file in `.usecase/cases/` with proper naming
3. Document your AI-assisted work using the template
4. Commit the file with git
5. Post-commit hook automatically syncs to hub

**Result (both options):**
File appears in the hub at:
- `by-project/[project-name]/[filename].md` (actual file)
- `by-date/[year]/[month]/[project]_[filename].md` (symlink)
- `by-topic/[topic-slug]/[project]_[filename].md` (symlink)

## Key Files in This Repository

- **ai-use-case**: Main CLI entry point
- **setup-project.sh**: Project configuration script
- **sync-ai-use-cases.sh**: Synchronization script
- **document-ai-session.sh**: Interactive AI session documentor
- **install.sh**: Installation script
- **uninstall.sh**: Uninstallation script
- **git-hooks/pre-commit**: Hook template for branch protection
- **git-hooks/post-commit**: Hook template for auto-sync
- **vscode-extension/**: VS Code extension for one-click documentation
- **README.md**: User-facing documentation
- **CLAUDE.md**: This file - guidance for Claude Code

## Troubleshooting

### CLI command not found

```bash
# Check if ~/.local/bin is in PATH
echo $PATH | grep ".local/bin"

# Add to shell profile if missing
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Hook not executing

```bash
# Check if hooks are executable
ls -la /path/to/project/.git/hooks/pre-commit
ls -la /path/to/project/.git/hooks/post-commit

# Make executable if needed
chmod +x /path/to/project/.git/hooks/pre-commit
chmod +x /path/to/project/.git/hooks/post-commit
```

### Sync failing

```bash
# Debug mode
bash -x ~/.local/bin/ai-use-case sync

# Check hub exists
ls ~/Documents/ai-use-case-hub
```

### Hub repository not found

```bash
# Clone the hub repository
cd ~/Documents
git clone https://github.com/mt-osiris-tools/ai-use-case-hub.git ai-use-case-hub
```

## Version Checking

The CLI includes automatic version checking to keep users informed of updates:

- **Automatic checks**: Runs once every 24 hours (cached in `~/.cache/ai-use-case-version-check`)
- **Non-blocking**: Executes in background, doesn't delay command execution
- **GitHub integration**: Fetches latest version from main branch via curl/wget
- **Smart caching**: Only checks GitHub once per day to reduce network traffic
- **Silent failures**: If GitHub is unreachable, continues without errors

When an update is detected, users see:
```
╭────────────────────────────────────────────────────╮
│ Update available: v2.2.0 (current: v2.1.0)        │
│ Run: cd ~/.local/share/ai-use-case-cli && git pull│
╰────────────────────────────────────────────────────╯
```

Implementation is in `ai-use-case:80-115` with the `check_for_updates()` function.

## Tracing and Monitoring (v3.6.0+)

The CLI includes comprehensive OpenTelemetry-based tracing for performance monitoring and observability:

- **OpenTelemetry integration**: Full OTLP export via HTTP to localhost:4318
- **AI Toolkit integration**: Direct connection to VS Code AI Toolkit's tracing viewer
- **Graceful degradation**: CLI works normally when dependencies unavailable
- **Zero overhead when disabled**: No performance impact if tracing is off
- **Configurable**: JSON config files + environment variables

**Key capabilities:**
- Command execution tracking (duration, success/failure rates)
- File operation monitoring (create, update, symlink)
- Error tracking with full context and stack traces
- Hub sync metrics (files synced, new, updated)
- Search operation analytics

**Configuration:**
```bash
# Setup tracing
ai-use-case tracing configure
ai-use-case tracing install-deps

# Enable/disable
ai-use-case tracing enable
ai-use-case tracing disable

# Check status
ai-use-case tracing status
```

**Files:**
- `scripts/utils/tracing.py`: OpenTelemetry Python integration (395 lines)
- `scripts/utils/tracing.sh`: Shell wrapper for bash instrumentation (351 lines)
- `docs/TRACING.md`: Comprehensive documentation (409 lines)

See [docs/TRACING.md](TRACING.md) for complete setup and usage guide.

## Version History

- **v3.9.0**: Real-time TodoWrite tracking for `/use-case:document-session`, development git hooks installer, removed backup process
- **v3.8.0**: Command-specific progress tracking with visual indicators
- **v3.7.1**: Self-update command, project update flag
- **v3.7.0**: Reset command, tracing configuration fixes
- **v3.6.0**: Distributed tracing system with OpenTelemetry, AI Toolkit integration, performance monitoring
- **v3.5.0**: Fixed duplicate slash commands issue
- **v3.4.3**: Force refresh slash commands during project updates
- **v3.4.2**: Optimize CLAUDE.md token usage, split into WORKFLOW.md and COMMANDS.md
- **v3.4.1**: Fix version references, add version update checklist
- **v3.4.0**: Interactive session selection for documentation
- **v3.3.0**: Refactored folder structure to `.usecase/cases/`, added hub configuration commands, restored ASCII art banner
- **v3.2.0**: Optional hub repository (local-only or private git), automated version bump system, centralized version management
- **v3.1.0**: Hybrid CLI + Claude Code interface, project registry system for version tracking
- **v3.0.0**: Claude Code integration with slash commands (breaking changes from v2.x)
- **v2.1.0**: Separated CLI tools from documentation hub, unified CLI interface, added automatic git push, version checking
- **v2.0.0**: Introduced symlink architecture (in hub repository)
- **v1.0.0**: Initial release with basic sync functionality

## Hub-CLI Synchronization

This repository is tightly coupled with the **ai-use-case-hub** repository. When making changes to this CLI repository, always review **HUB-SYNC-CHECKLIST.md** to ensure corresponding updates are made to the hub.

### Key Synchronization Points

- **Templates**: CLI provides templates (docs/TEMPLATE*.md) and generates documentation
- **Session Types**: CLI implements workflows, Hub documents them
- **File Naming**: CLI enforces patterns, Hub organizes by them
- **Features**: CLI adds commands, Hub provides user documentation

See **HUB-SYNC-CHECKLIST.md** for the complete validation process.

## Related Repositories

- **[ai-use-case-hub](https://github.com/mt-osiris-tools/ai-use-case-hub)** - Documentation hub with symlink-based organization
- **[claude-code](https://claude.com/code)** - AI coding assistant
- **[github-copilot](https://github.com/features/copilot)** - AI pair programmer
