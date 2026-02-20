# OpenCode Integration Notes

This repository is designed to be agent-agnostic, but some prompt content was originally authored around Claude Code terminology.
This document maps those concepts to OpenCode and lists the practical checks to ensure things work end-to-end.

## What OpenCode Needs

- `AGENTS.md` at repo root: primary instructions OpenCode agents should follow.
- Config is stored at `$XDG_CONFIG_HOME/ai-use-case-cli/config.json` (default: `~/.config/ai-use-case-cli/config.json`).
- Project setup creates:
  - `.usecase/cases/`
  - `.ai-tools/commands/use-case/` (source-of-truth slash commands)
  - Optional tool-specific wiring:
    - `.github/prompts/use-case/` (Copilot prompt symlink)
    - `~/.codex/prompts/` (Codex prompt copies)
    - `.claude/commands/use-case/` (Claude Code discovery symlink, only created if `.claude/` exists or via `ai-use-case --link-claude`)

## Concept-to-Tool Mapping

Some command prompt files reference tools by name (e.g., "AskUserQuestion", "TodoWrite", "Task tool"). Treat these as concepts:

- "AskUserQuestion" => OpenCode `question` tool
- "TodoWrite" => OpenCode `todowrite` tool
- "Task tool" / `subagent_type` => OpenCode `task` tool (subagent invocation)

If your OpenCode deployment does not support an equivalent capability, use the underlying CLI scripts instead of the agent prompt flow.

## Verification Checklist (Local)

```bash
# Smoke
./ai-use-case --help
./ai-use-case --version

# Tests
git submodule update --init --recursive
./run-tests.sh

# Lint (recommended)
shellcheck -x ai-use-case run-tests.sh
shopt -s globstar && shellcheck -x scripts/**/*.sh lib/**/*.sh
```

## Non-Interactive Setup (CI / Automation)

To validate that first-time init does not hang when stdin is not a TTY:

```bash
# In a clean project repo
ai-use-case --init < /dev/null
```

Expected outcomes:

- `.usecase/cases/` exists
- `.ai-tools/commands/use-case/` exists and contains the command markdown files
- `.github/prompts/use-case/` is a symlink when Copilot integration is selected (non-interactive defaults select all agents)
- `~/.codex/prompts/` contains `use-case-*.md` when Codex integration runs

## Notes on "Advanced" Agent Commands

Files under `.ai-tools/commands/use-case/` for:

- `review-quality`
- `analyze-patterns`
- `optimize-organization`

reference a "Task tool" and `subagent_type`. They will only work if your agent runtime (OpenCode) can execute subagents; otherwise, treat them as documentation-only guidance.
