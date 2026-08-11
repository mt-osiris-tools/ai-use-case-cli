# AI Agent Documentation

Documentation for using AI Use Case CLI with various AI coding assistants.

## Supported AI Agents

### [Claude Code](claude/)
Claude Code is Anthropic's official CLI tool for AI-assisted development.

- **[Quick Reference](claude/README.md)** - Quick start guide for Claude Code integration
- **[Comprehensive Guide](claude/GUIDE.md)** - Detailed documentation for advanced usage

**Key Features:**
- Automatic command discovery via `.claude/commands/`
- Interactive session documentation with `/use-case:document-session`
- Git history analysis and context awareness
- Auto-generated complete documentation (no placeholders)

### [GitHub Copilot](copilot/)
GitHub Copilot is GitHub's AI pair programmer.

- **[Integration Guide](copilot/README.md)** - Guidelines for using AI Use Case CLI with GitHub Copilot

**Key Features:**
- Repository-wide guidelines via `COPILOT.md`
- Coding style and naming conventions
- Project structure reference
- Testing and workflow guidelines

### [OpenCode](opencode/)
OpenCode is an agentic coding environment that reads repo instructions (like `AGENTS.md`) and can run CLI workflows.

- **[Integration Notes](opencode/README.md)** - Tool mapping and non-interactive setup guidance

### Codex

Codex uses the repository's `AGENTS.md` for durable project instructions. The
AI Use Case workflow is packaged as a reusable skill at
`.codex/skills/ai-use-case-documentation/SKILL.md`; legacy prompt adapters remain
available under `.codex/prompts/` for compatibility.

### [Agent Framework](framework/)
Built-in agent system for automated tasks and quality checks.

- **[Framework Documentation](framework/README.md)** - Agent registry, invocation, and development

**Available Agents:**
- **quality-reviewer**: AI-powered documentation quality analysis
- **session-documenter**: Automatic session documentation generation
- Extensible framework for custom agents

## Quick Start

### 1. Setup Your Project

```bash
ai-use-case --init
```

This creates:
- `.usecase/cases/` directory for documentation
- `.ai-tools/commands/` with agent-agnostic slash commands
- `.claude/commands/use-case/` symlink for Claude Code discovery
- Git hooks for automatic syncing

### 2. Use with Your Preferred Agent

**Claude Code:**
```
/use-case:document-session
```

**GitHub Copilot:**
- Copilot automatically reads `COPILOT.md` for repo guidelines
- Use CLI commands: `ai-use-case sync`, `ai-use-case search`

**Built-in Agents:**
```bash
ai-use-case agents list
ai-use-case review-quality <file>
```

## Agent-Agnostic Design

The CLI is designed to work with **any** AI coding assistant:

- **Slash Commands**: Stored in `.ai-tools/commands/` (AI-tool-agnostic)
- **Discovery**: Agent-specific symlinks (`.claude/commands/use-case/` for Claude Code)
- **CLI Commands**: Direct bash access for all agents

## Adding New Agent Support

To add support for a new AI coding assistant:

1. Create directory: `docs/agents/<agent-name>/`
2. Add integration guide: `docs/agents/<agent-name>/README.md`
3. Update this file with agent information
4. (Optional) Create agent-specific command symlinks if needed

## More Information

- **[Commands Reference](../COMMANDS.md)** - Complete command documentation
- **[Workflow Guide](../WORKFLOW.md)** - Branch workflow and PR checklist
- **[Features](../features/)** - Feature planning and implementation docs

---

**Related:**
- [Main README](../../README.md) - User-facing documentation
- [Contributing Guidelines](../../CONTRIBUTING.md) - How to contribute
