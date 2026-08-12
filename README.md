<div align="center">
    <img src="./media/ai_use_case_cli_documentator_04.webp" alt="AI Use Case CLI - The Documenter" width="800"/>
    <h1>AI Use Case CLI</h1>
    <h3><em><strong>v3.14.0</strong> - Document AI-assisted development workflows with ease.</em></h3>
</div>

---

## Table of Contents

- [Why This Tool?](#why-this-tool)
- [Features](#features)
- [Quick Install](#quick-install)
- [Quick Start](#quick-start)
- [Core Commands](#core-commands)
- [Learn More](#learn-more)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

---

## Why This Tool?

Help developers on a daily basis by making AI session documentation effortless:

- **Reduce cognitive overload**: Pre-built templates eliminate the "what should I document?" paralysis
- **Build a knowledge base**: Create a searchable repository of successful AI interactions and solutions
- **Learn and improve**: Reference past sessions to understand what works and replicate success patterns
- **Stay organized**: Automatic syncing and categorization keeps your AI work documented and accessible

Documentation shouldn't be a burden—it should be a valuable asset that grows your team's AI expertise.

## Features

- 🎯 **Hybrid interface** - Use standalone CLI or AI assistant slash commands
- 🚀 **AI-assisted documentation** - Automatic context capture with any AI coding assistant
- 🔬 **Research & implementation** - Document both code changes and exploratory work
- 🤖 **Agent tracking** - Automatically track specialized agents from any AI tool
- 📊 **Session statistics** - Track costs, tokens, and time automatically
- 🔄 **Automatic syncing** - Git hooks sync docs to your hub
- 🔧 **Flexible storage** - Choose local-only or private git repository
- 🔍 **Search & analytics** - Find and analyze documented use cases

**[View All Features →](docs/FEATURES.md)**

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/mt-osiris-tools/ai-use-case-cli/main/scripts/install/install.sh | bash
```

Or clone and install manually:

```bash
git clone https://github.com/mt-osiris-tools/ai-use-case-cli.git ~/.local/share/ai-use-case-cli
cd ~/.local/share/ai-use-case-cli
./scripts/install/install.sh
```

## Quick Start

### 1. Setup Your Project

```bash
ai-use-case --init
```

This creates:
- `.usecase/cases/` directory for documentation
- Git hooks for automatic syncing
- Slash commands in `.ai-tools/commands/`
- Agent-specific integrations (Claude Code, GitHub Copilot, and/or Codex)

During initialization, you'll choose:

**Hub mode:**
- **Local Only** (default): Documentation stays on your machine
- **Private Git**: Full version control with your repository

**AI Agent(s):**
- **Claude Code** (default): Creates `.claude/commands/use-case/` symlink
- **GitHub Copilot**: Creates `.github/prompts/use-case/` symlink + `.vscode/settings.json` config
- **Codex**: Installs a reusable skill and backward-compatible prompt adapters
- **Multiple**: Configure multiple agents together
- **None**: Skip agent setup (configure later)

### 2. Work With AI

Use your preferred AI coding assistant:
- GitHub Copilot
- Claude Code
- Codex-style CLI tools
- Cursor
- Any other AI tool

### 3. Document Your Session

In your AI assistant:
```
/use-case:document-session
```

The AI assistant will:
1. List recent Codex sessions for the current repository
2. Ask you to select a session or provide its UUID
3. Document only the selected session
3. Present options (undocumented PRs, current session, recent commits)
4. Generate complete documentation automatically
5. Sync to hub via git hooks

### 4. Search and Analyze

```bash
# Search use cases
ai-use-case search "authentication"

# View statistics
ai-use-case stats

# Extract session data
ai-use-case extract
```

**[Complete Usage Guide →](docs/USAGE-GUIDE.md)**

## Core Commands

### Essential Commands

| Command | Description |
|---------|-------------|
| `ai-use-case --init` | Setup project and configure hub |
| `ai-use-case --init --update` | Update project installation |
| `ai-use-case --link-claude` | Create Claude Code symlinks (after Claude setup) |
| `ai-use-case --setup-copilot` | Setup GitHub Copilot custom prompts + VS Code settings |
| `ai-use-case --setup-codex [--global\|--local] [--dry-run] [--force]` | Setup Codex skill and prompt adapters |
| `ai-use-case update [options]` | Update the CLI installation (`--check`, `--dry-run`, `--yes`) |
| `ai-use-case sync` | Manually sync to hub |
| `ai-use-case search <term>` | Search use cases |
| `ai-use-case stats` | View statistics |
| `ai-use-case release prepare <type>` | Prepare a reviewed release PR |
| `ai-use-case release publish <version>` | Validate and publish a post-merge release tag |
| `ai-use-case --version` | Show version |
| `ai-use-case --help` | Show help |

### Slash Commands (Claude Code)

| Command | Description |
|---------|-------------|
| `/use-case:document-session` | Document current session |
| `/use-case:sync-usecases` | Sync to hub |
| `/use-case:search-usecases` | Search use cases |
| `/use-case:publish-confluence` | Publish to Confluence |

### Custom Prompts (GitHub Copilot)

Type `/` in VS Code Copilot Chat to access these prompts:

| Command | Description |
|---------|-------------|
| `/use-case:document-session` | Document current session |
| `/use-case:setup-project` | Setup another project |
| `/use-case:sync-usecases` | Sync to hub |
| `/use-case:search-usecases` | Search use cases |
| `/use-case:quick-start` | Quick start guide |

Setup: `ai-use-case --setup-copilot`

**Note**: Setup automatically configures `.vscode/settings.json` with required Copilot settings (`chat.promptFiles: true`). Reload VS Code window after setup.

### Codex Integration

| Command | Description |
|---------|-------------|
| `/prompts:use-case-document-session` | Legacy prompt adapter for documenting a session |
| `/prompts:use-case-publish-confluence` | Legacy prompt adapter for publishing documentation |

The preferred integration is the repository-local skill at
`.codex/skills/ai-use-case-documentation/SKILL.md`. Install it with:

```bash
ai-use-case --setup-codex --local
```

Use `--global` for personal Codex defaults, `--dry-run` to preview changes, and
`--force` only when replacing modified installed adapters is intentional.

The documentation prompt lists sessions from `~/.codex/sessions/` (or
`CODEX_HOME`) and accepts a direct UUID:

```text
/prompts:use-case-document-session SESSION_UUID=<codex-session-uuid>
```

### Configuration Commands

| Command | Description |
|---------|-------------|
| `ai-use-case config show` | View configuration |
| `ai-use-case config reconfigure` | Change hub mode |
| `ai-use-case reset [options]` | Reset configuration |

### Project Management

| Command | Description |
|---------|-------------|
| `ai-use-case list-projects` | List all registered projects |
| `ai-use-case check-updates` | Find projects needing updates |
| `ai-use-case update-project <path>` | Update specific project |

### Monitoring

| Command | Description |
|---------|-------------|
| `ai-use-case tracing init` | Initialize tracing |
| `ai-use-case tracing enable` | Enable tracing |
| `ai-use-case tracing status` | View tracing status |

**[Full Command Reference →](docs/USAGE-GUIDE.md#core-commands)**

## Learn More

### Documentation

- **[Usage Guide](docs/USAGE-GUIDE.md)** - Detailed usage instructions
- **[Configuration](docs/CONFIGURATION.md)** - Hub modes, environment variables, tracing
- **[Features](docs/FEATURES.md)** - Complete feature descriptions
- **[Architecture](docs/diagrams/)** - C4 model and sequence diagrams
- **[Tracing](docs/TRACING.md)** - OpenTelemetry monitoring setup
- **[Agents](docs/agents/framework/README.md)** - AI agent framework

### Development

- **[Contributing](CONTRIBUTING.md)** - Contribution guidelines
- **[Workflow](docs/WORKFLOW.md)** - Development workflow
- **[Changelog](CHANGELOG.md)** - Version history

## Examples

### Document a Bug Fix

After fixing a bug with commits:

```
/use-case:document-session
```

The AI extracts:
- Ticket from commit messages
- Git statistics (files changed, lines)
- Conversation insights
- Complete documentation

### Document Research Session

After exploring approaches without code:

```
/use-case:document-session
```

The AI creates:
- Research session with auto-generated `RESEARCH-XXX` ticket
- Analysis and findings
- Decision rationale

### Publish to Confluence

```
/use-case:publish-confluence
```

Publishes documentation as Confluence pages (requires Atlassian MCP server).

**[More Examples →](docs/USAGE-GUIDE.md#workflow-details)**

## Optional Dependencies

### Markdown Linting (markdownlint-cli)

For automatic markdown quality validation and fixing when publishing to Confluence:

```bash
# Install globally via npm
npm install -g markdownlint-cli
```

**Benefits:**
- Auto-fixes markdown formatting issues during publishing
- Ensures consistent documentation quality
- Reduces manual formatting fixes

**Usage:**
- The `publish-confluence` command automatically validates and fixes markdown files when markdownlint is installed
- Use `--no-autofix` flag to skip automatic fixes: `./scripts/core/publish-confluence.sh --no-autofix file.md parent-url`
- If not installed, the command will work normally with a warning message

## Troubleshooting

### CLI Command Not Found

```bash
# Check PATH
echo $PATH | grep ".local/bin"

# Add to shell profile
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Hooks Not Syncing

```bash
# Check permissions
ls -la /path/to/project/.git/hooks/post-commit
chmod +x /path/to/project/.git/hooks/post-commit

# Test manually
ai-use-case sync
```

### Reset Configuration

```bash
# Preview changes
ai-use-case reset --config --dry-run

# Reset configuration
ai-use-case reset --config

# Reset everything
ai-use-case reset --all
```

**[Complete Troubleshooting →](docs/CONFIGURATION.md#troubleshooting-configuration)**

## Updates

Check version:
```bash
ai-use-case --version
```

Update to latest:
```bash
# Recommended
ai-use-case update

# Check without installing
ai-use-case update --check

# Or re-run install script
curl -fsSL https://raw.githubusercontent.com/mt-osiris-tools/ai-use-case-cli/main/scripts/install/install.sh | bash
```

## Uninstall

```bash
ai-use-case uninstall
```

Removes CLI and optionally cleans up configuration.

## Contributing

We welcome contributions! This project follows a branch-based workflow.

**Quick Start:**
1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Make changes and update CHANGELOG.md
4. Run tests: `./run-tests.sh`
5. Push and open PR

**Testing:**
```bash
# Initialize test framework (first time only)
git submodule update --init --recursive

# Run all tests
./run-tests.sh

# Run specific tests
./run-tests.sh version config-manager
```

**[Full Contributing Guide →](CONTRIBUTING.md)**

## Requirements

- **OS**: Linux, macOS, WSL on Windows
- **Shell**: Bash 4.0+
- **Git**: For version control and hooks
- **Dependencies**: Standard Unix tools (`realpath`, `find`, `grep`)

## Support

- **Issues**: [GitHub Issues](https://github.com/mt-osiris-tools/ai-use-case-cli/issues)
- **Discussions**: [GitHub Discussions](https://github.com/mt-osiris-tools/ai-use-case-cli/discussions)
- **Documentation**: [docs/](./docs/)

## Related Projects

- [Claude Code](https://claude.com/code) - AI coding assistant with slash commands
- [GitHub Copilot](https://github.com/features/copilot) - AI pair programmer with custom prompts
- Codex-style CLI tools - Various coding assistants with prompt-based workflows

## License

MIT License - see [LICENSE](./LICENSE) file for details

---

**Version**: 3.14.0
**Last Updated**: 2026-08-11
