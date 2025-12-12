# Copilot Instructions

Guidance for GitHub Copilot (chat, CLI agents, or inline completions) when supporting development in this repository.

## Repository Purpose

This project ships the command-line tooling and supporting scripts that help teams document AI-assisted development sessions. The repo includes:

- **Core `ai-use-case` CLI** (unified command interface) for initializing projects, documenting sessions, syncing results, and searching the documentation hub
- **Shell helper scripts**: `setup-project.sh`, `sync-ai-use-cases.sh`, `document-ai-session.sh`, `publish-confluence.sh`, `install.sh`, `uninstall.sh`
- **Git hook templates** (`pre-commit`, `post-commit`) that enforce branch hygiene and trigger documentation syncs
- **VS Code extension** (in `vscode-extension/`) for capturing sessions from the editor with TypeScript implementation
- **Documentation and templates** for both implementation and research session types

**Architecture**: This CLI tools repository works with a separate [ai-use-case-hub](https://github.com/mt-osiris-tools/ai-use-case-hub) repository that serves as the central documentation storage with symlink-based organization by project, date, and topic.

Any change Copilot proposes must preserve seamless CLI usage, hub synchronization, documentation integrity, and the dual-repository architecture.

## Required Workflow (Non-Negotiable)

When Copilot crafts changes, ensure the workflow below stays intact:

1. **Branch Naming** – Stick to prefixes like `feature/`, `fix/`, `docs/`, `refactor/`, `test/`. If the user has already named the branch, use it.
2. **Conventional Commits** – Messages must follow `type: summary` (e.g., `feat: add sync dry run`). Multi-line bodies should explain why.
3. **CHANGELOG Updates** – Every user-facing change needs an entry under `## [Unreleased]` in `CHANGELOG.md` describing the behaviour shift.
4. **Hub Impact** – If a change alters sync or hub structure, review `docs/HUB-FILES.md` and confirm whether companion updates or migration notes are required.
5. **Testing** – For scripts, suggest realistic local tests (`./ai-use-case --help`, `./sync-ai-use-cases.sh --dry-run`, etc.). For the VS Code extension, mention running `npm test` or using `vsce package` if relevant.
6. **Documentation** – Update `README.md`, `docs/CLAUDE.md`, or command-specific docs whenever behaviour, flags, or workflows change.
7. **Pull Request Etiquette** – Before proposing a PR, verify all checklist items and ask the user for approval to open it.

## Critical Architecture Constraints

- **Dual-repository design**: CLI tools (this repo) work with a separate documentation hub. Never merge these concerns
- **Hub dependency**: The `ensure_hub_exists()` function must be used consistently across all scripts that interact with the hub
- **Git hooks workflow**: Pre-commit hooks prevent direct commits to main/master; post-commit hooks trigger documentation sync
- **User-scoped installation**: Everything installs to user directories (`~/.local/bin`, `~/.local/share`) - no system-wide changes
- **POSIX compatibility**: All shell scripts must work across macOS, Linux, and WSL environments
- **Symlink preservation**: The hub's symlink-based organization (by-project, by-date, by-topic) must be maintained

## Working With CLI Scripts

- **Script execution**: All shell scripts must remain executable (`chmod +x`) and compatible with Bash 4.0+
- **Error handling**: Use `set -euo pipefail` for new shell scripts and guard against partial failures
- **Input validation**: Validate inputs defensively; prefer explicit error messages over silent failures
- **Environment variables**: Respect existing environment variables like `AI_USECASES_DIR` and default hub paths (`~/.local/share/ai-use-case-cli/hub`)
- **Git hooks**: When modifying git hooks, preserve bypass instructions (`--no-verify`) and clear user messaging
- **Cross-platform compatibility**: Ensure POSIX-compatible shell patterns; scripts must run on macOS, Linux, and WSL
- **Hub interaction**: Always use `ensure_hub_exists()` function when scripts need to interact with the documentation hub
- **Version tracking**: Update `VERSION` variable in the main `ai-use-case` script when making user-facing changes

## Documentation Generation Guidance

- **Session types**: The CLI supports **implementation** and **research** sessions with different templates and workflows
- **Template consistency**: Keep templates aligned with the hub's `TEMPLATE.md` structure (located in the separate hub repository)
- **No placeholders**: Never leave placeholders such as "TODO" in generated session files—fill every section with concrete information or omit optional sections entirely
- **Naming conventions**: Auto-generated files should follow the `YYYY-MM-DD_TICKET-description.md` format for implementation sessions and `YYYY-MM-DD_RESEARCH-description.md` for research sessions
- **Claude Code integration**: If suggesting automated flows (e.g., Copilot Chat generating docs), ensure they mirror the expectations defined in `docs/CLAUDE.md`
- **Hub synchronization**: All documented sessions are automatically synced to the hub repository via git hooks and the sync mechanism
- **Research session fields**: Include initial query, iterations, insights, approaches evaluated, and final decision documentation

## VS Code Extension Development

- **Language**: The extension under `vscode-extension/` uses TypeScript with Node.js APIs
- **Prerequisites**: Run `npm install` in the `vscode-extension/` directory before building or testing
- **Build process**: Type-check with `npm run compile` and format via existing npm scripts (consult `package.json`)
- **Commands**: Extension provides commands for documenting sessions, project setup, syncing, and searching
- **Activation events**: Commands are registered on activation and handle workspace operations
- **Terminal integration**: Most operations delegate to CLI scripts via VS Code terminal interface
- **Error handling**: Wrap command handlers in try-catch blocks with user-friendly error messages
- **Configuration**: Respect VS Code configuration settings for extension behavior
- **Documentation**: When modifying activation events or commands, update `README.md` inside `vscode-extension/` accordingly

## Version Management and Updates

- **Version synchronization**: Keep version numbers in sync across `ai-use-case` script, `vscode-extension/package.json`, and `CHANGELOG.md`
- **Update notifications**: The CLI includes automatic version checking with smart caching (24-hour intervals)
- **Cache location**: Version check cache stored at `$HOME/.cache/ai-use-case-version-check`
- **Network handling**: Version checks must gracefully handle network failures and timeouts
- **Semantic versioning**: Follow semver (MAJOR.MINOR.PATCH) for all releases
- **Breaking changes**: Major version bumps require migration guides and backwards compatibility considerations

## Testing Strategy

- **Manual testing priority**: Due to interactive nature of CLI tools, focus on realistic manual testing scenarios
- **Shell script testing**: Test scripts with various inputs, edge cases, and error conditions
- **Cross-platform validation**: Verify functionality on macOS, Linux, and WSL environments
- **Hub integration testing**: Test sync operations with both existing and new hub repositories
- **VS Code extension testing**: Use `npm test` in `vscode-extension/` directory and test commands in real VS Code environment
- **Installation testing**: Verify `install.sh` and `uninstall.sh` work correctly in clean environments
- **Git hook testing**: Ensure pre-commit and post-commit hooks behave correctly across different git scenarios

## Confluence Integration

- **Publishing workflow**: The `publish-confluence.sh` script enables publishing use cases as child pages
- **Authentication**: Supports Confluence Cloud API with token-based authentication
- **Page hierarchy**: Maintains parent-child relationships in Confluence structure
- **Content formatting**: Converts markdown to Confluence storage format
- **Error handling**: Provides clear feedback for authentication and API failures
- **Configuration**: Stores Confluence settings in user's environment or config files

## Security and Safety Guidelines

- **Sensitive data handling**: Never expose API tokens, passwords, or personal data in code examples or documentation
- **Input sanitization**: Always validate and sanitize user inputs in shell scripts to prevent injection attacks
- **File permissions**: Maintain proper file permissions (644 for files, 755 for directories and executables)
- **Git hooks security**: Ensure git hooks cannot be used to execute malicious code or bypass security measures
- **Environment isolation**: Use user-scoped installations (`~/.local/`) to avoid system-wide security implications
- **Confluence credentials**: Store API tokens securely using environment variables or secure credential stores
- **Log sanitization**: Ensure logs don't contain sensitive information like tokens or personal data

## Performance Considerations

- **Script efficiency**: Minimize external command calls in shell scripts; prefer built-in operations when possible
- **Hub sync optimization**: Large hub repositories should use incremental sync strategies to avoid long wait times
- **Version check caching**: Respect the 24-hour cache interval for version checks to avoid unnecessary network requests
- **Memory usage**: Be mindful of memory consumption when processing large documentation files or git histories
- **Terminal responsiveness**: Provide progress indicators for long-running operations (sync, search, etc.)
- **Batch operations**: When possible, batch multiple file operations instead of individual commits

## Code Quality Standards

- **Shell script patterns**: Use consistent error handling patterns across all scripts
  ```bash
  set -euo pipefail
  # Always check command success
  if ! command -v git >/dev/null 2>&1; then
      echo "Error: git is required but not installed" >&2
      exit 1
  fi
  ```
- **Function documentation**: Document complex functions with purpose, parameters, and return values
- **Variable naming**: Use descriptive names (`hub_directory` not `hd`, `session_type` not `st`)
- **Error messages**: Provide actionable error messages that guide users toward solutions
- **Exit codes**: Use appropriate exit codes (0 for success, 1 for general errors, 2 for misuse)
- **Logging levels**: Use consistent logging patterns (INFO, WARN, ERROR) across scripts

## Troubleshooting and Common Issues

- **Hub synchronization failures**: Common causes include network issues, git conflicts, or permission problems
- **Git hook execution**: Issues often stem from PATH problems or missing dependencies in hook environment
- **VS Code extension debugging**: Use VS Code's developer console and extension host logs for troubleshooting
- **Cross-platform compatibility**: Test path handling, command availability, and shell compatibility
- **Installation problems**: Verify user has write access to `~/.local/bin` and PATH configuration
- **Version conflicts**: Check for conflicting installations in different locations

## Examples and Anti-Patterns

### Good Patterns
```bash
# Robust error handling
ensure_hub_exists() {
    local hub_dir="${AI_USECASES_DIR:-$HOME/.local/share/ai-use-case-cli/hub}"
    if [[ ! -d "$hub_dir" ]]; then
        echo "Error: Hub directory not found at $hub_dir" >&2
        echo "Run 'ai-use-case setup' to initialize the hub" >&2
        return 1
    fi
}

# Clear user feedback
echo "Syncing with hub... This may take a moment."
```

### Anti-Patterns to Avoid
```bash
# Don't: Silent failures
cd "$some_directory" 2>/dev/null

# Don't: Unclear error messages
echo "Error: Something went wrong"

# Don't: Hard-coded paths
cp file.txt /home/user/my-directory/
```

## CI/CD and Automation Considerations

- **Branch protection**: Respect the pre-commit hook requirements and branch naming conventions
- **Automated testing**: Focus on integration tests that verify CLI workflows end-to-end
- **Release automation**: Version bumps must synchronize across CLI script, VS Code extension, and CHANGELOG
- **Hub integrity**: Automated processes must preserve the hub's symlink structure and git history
- **Documentation sync**: Changes to templates or workflows should trigger documentation updates
- **Backwards compatibility**: Maintain support for existing user workflows during updates

## Integration Points

- **Hub repository coordination**: Changes affecting both repositories require careful coordination
- **Git hook lifecycle**: Modifications to hooks must consider installation, updates, and removal scenarios
- **VS Code extension APIs**: Stay current with VS Code API changes and deprecation notices
- **Confluence API**: Handle API rate limits and version compatibility in publishing workflows
- **Shell environment**: Account for different shell configurations (bash, zsh) and environment variables
- **Package managers**: Consider how different installation methods (manual, homebrew, etc.) affect updates

## Communication Style

- **Provide context-aware guidance**: Reference specific files, functions, and patterns from the codebase when making suggestions
- **Enumerate concrete next steps**: Break down complex changes into specific, actionable tasks with clear testing instructions
- **Surface trade-offs explicitly**: Highlight potential impacts on CLI usage, hub synchronization, cross-platform compatibility, or user workflow
- **Ask clarifying questions**: When user requirements could affect multiple parts of the system, gather more context before proposing solutions
- **Respect existing patterns**: Follow established coding styles, error handling patterns, and user interaction flows
- **Document breaking changes**: Clearly explain any changes that affect existing user workflows or require migration steps
- **Validate before implementing**: For complex changes, outline the approach and confirm with the user before making modifications
- **Include testing instructions**: Always provide specific commands or steps to verify changes work correctly
- **Reference documentation**: Point to relevant documentation files (`docs/CLAUDE.md`, `docs/HUB-FILES.md`, etc.) when applicable
- **Explain the "why"**: Don't just provide solutions; explain the reasoning behind architectural decisions

Adhering to these instructions keeps Copilot contributions aligned with the team's tooling standards and documentation-first workflow.