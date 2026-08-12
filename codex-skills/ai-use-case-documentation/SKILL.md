---
name: ai-use-case-documentation
description: Document and sync Codex coding sessions for repositories using AI Use Case CLI. Use when recording implementation or research work, extracting session metadata, syncing use cases, searching the hub, or publishing a documented use case.
---

# AI Use Case Documentation

Use this skill for the AI Use Case CLI workflow. A documented Codex session must be selected explicitly by the user; never silently document the current conversation or an inferred git window.

## Repository setup

Confirm the current repository is initialized before writing documentation:

```bash
git rev-parse --show-toplevel
test -d .usecase/cases || ai-use-case --init
```

The CLI source of truth is the installed repository referenced by `AI_USECASES_CLI_ROOT` (otherwise `~/.local/share/ai-use-case-cli`). Use `ai-use-case --help` when command availability is uncertain.

## Select and document a Codex session

1. List recent sessions for the current repository:

```bash
${AI_USECASES_CLI_ROOT:-$HOME/.local/share/ai-use-case-cli}/scripts/core/list-codex-sessions.sh --repo "$(git rev-parse --show-toplevel)"
```

2. Ask the user to select one listed session or provide its UUID. An optional `SESSION_UUID` argument is accepted for direct selection.
3. Resolve and validate the selected UUID with `--uuid`. If it is missing, malformed, or inaccessible, stop with an actionable error.
4. Read the selected JSONL session internally and use its user, assistant, and tool events as the source for the goal, decisions, alternatives, and outcome. Do not print the raw transcript.
5. Decide whether the session is `implementation` (code or committed changes) or `research` (analysis without code changes).
6. Use git commands only for repository evidence:

```bash
git status --short
git log --since="24 hours ago" --first-parent --oneline
git diff --stat
```

7. Generate a complete document using `docs/TEMPLATE.md` or `docs/TEMPLATE-RESEARCH.md`. Do not invent session details and do not leave TODO or placeholder text.
8. Write the result below `.usecase/cases/` using the repository naming convention, then run:

```bash
ai-use-case sync
```

Ask before committing or publishing. Never expose credentials in output.

## Deterministic commands

- `ai-use-case sync` synchronizes local use cases to the configured hub.
- `ai-use-case search <term>` searches documented use cases.
- `ai-use-case stats` reports documentation statistics.
- `ai-use-case publish-confluence` publishes only after the user confirms the target and credentials.

If an interactive prompt cannot be answered safely, stop and ask the user instead of guessing. Prefer direct CLI fallbacks over agent-specific tool names.
