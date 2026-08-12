---
description: Select a Codex session by UUID and document it with the AI Use Case CLI
argument-hint: [SESSION_UUID=<uuid>]
---

# Document a Codex Session

Document exactly one explicitly selected Codex session.

## 1. Discover sessions

Resolve the installed CLI root from `AI_USECASES_CLI_ROOT`, defaulting to `~/.local/share/ai-use-case-cli`. Confirm the current repository with `git rev-parse --show-toplevel`, then run:

```bash
"${cli_root}/scripts/core/list-codex-sessions.sh" --repo "${repo_root}"
```

The output is tab-separated: UUID, timestamp, repository, originator, CLI version, and source path. Show the user a concise numbered list containing the UUID, date/time, and repository. If no current-repository sessions are listed, explain that the user can provide a UUID directly.

## 2. Require selection

If `SESSION_UUID` was supplied, use it as the selected session. Otherwise ask the user to either choose a listed session or enter a Codex session UUID. Do not default to the current conversation, the newest session, recent git work, or an inferred UUID.

Resolve the selection:

```bash
"${cli_root}/scripts/core/list-codex-sessions.sh" --uuid "${session_uuid}" --json
```

If resolution fails, report the error and ask for another selection. Do not document any other session.

## 3. Read the selected session

Use the resolved JSON `path` to read the selected JSONL session internally. Extract the session metadata and relevant user, assistant, and tool events. Do not print the raw transcript or expose credentials, tokens, or unrelated personal data. The selected session record is the source for the documented goal, decisions, alternatives, actions, and outcome.

## 4. Generate and save documentation

- Classify the selected session as `implementation` or `research`.
- Use `docs/TEMPLATE.md` for implementation sessions and `docs/TEMPLATE-RESEARCH.md` for research sessions.
- Fill every required section with evidence from the selected session and repository git state. Never add TODOs or invented details.
- Write the result under `.usecase/cases/` using the established naming convention.
- Run `ai-use-case sync` after the document is created.
- Ask before committing or publishing; do not commit or publish automatically.

If the repository is not initialized for use-case documentation, stop and offer `ai-use-case --init` before writing.
