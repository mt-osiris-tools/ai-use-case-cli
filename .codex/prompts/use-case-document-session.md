---
description: Document an AI coding session with automatic extraction and formatting
argument-hint: [SCAN_TYPE=<conversation|git|both>] [SESSION_TYPE=<implementation|research>]
---

# Document AI Session - Codex CLI

**OpenAI Codex Integration**: Interactive selection with automatic documentation generation for AI coding sessions.

## Parameters

- **$SCAN_TYPE** (optional): What to scan for documentation
  - `conversation` - Document current AI session only (no git scanning)
  - `git` - Scan git history for recent PRs and commits
  - `both` - Show all options (conversation + git)
  - If not provided, prompt the user to choose

- **$SESSION_TYPE** (optional): Type of session to document
  - `implementation` - Code changes with commits
  - `research` - Exploratory conversation, no commits
  - If not provided, auto-detect from git history

## Documentation Workflow Overview

Here's what will happen:

**Phase 1: Session Selection**
- [ ] Get git user credentials
- [ ] Based on SCAN_TYPE, detect available sessions
- [ ] Present options and wait for selection

**Phase 2: Environment Validation**
- [ ] Check CLI version against latest from GitHub
- [ ] Verify project setup (.usecase/cases/ directory)

**Phase 3: Session Analysis**
- [ ] Determine session type (implementation vs research)
- [ ] Analyze git history and/or conversation context

**Phase 4: Information Extraction**
- [ ] Calculate date with ISO 8601 week number
- [ ] Extract or generate ticket number
- [ ] Determine complexity and time saved

**Phase 5: Documentation Generation**
- [ ] Read appropriate template
- [ ] Generate complete documentation

**Phase 6: Commit and Sync**
- [ ] Commit documentation (implementation only)
- [ ] Sync to hub

## Your Task

Help the user select which work session to document, then automatically generate comprehensive documentation by analyzing git history and conversation context.

## Workflow Steps

### Step 0: Handle SCAN_TYPE Parameter

**If $SCAN_TYPE is provided:**
- Use the provided value directly
- Skip to appropriate detection step

**If $SCAN_TYPE is NOT provided:**
Ask the user:
```
What would you like to document?

1. Current conversation - Document this AI session (no git scanning)
2. Recent PRs and commits - Scan git history for recent work (last 24 hours)
3. Both - Show me all options

Please choose (1, 2, or 3):
```

### Step 1: Get Git User Credentials

Always needed regardless of scan type:
```bash
# Get current user's git email and GitHub username
USER_EMAIL=$(git config user.email)
GH_USERNAME=$(gh api user --jq '.login' 2>/dev/null)

echo "Git user: $USER_EMAIL"
if [ -n "$GH_USERNAME" ]; then
    echo "GitHub user: $GH_USERNAME"
else
    echo "GitHub CLI not configured (PR detection will be skipped)"
fi
```

### Step 2: Check CLI Version

Verify the CLI is up-to-date:
```bash
# Check for updates using the established CLI command
ai-use-case check-updates
```

If updates are available, inform the user they can run `ai-use-case update`.

### Step 3: Verify Setup

Check project configuration:
```bash
git rev-parse --show-toplevel
ls -la .usecase/cases/ 2>/dev/null || echo "Not set up"
```

If not set up, offer to run: `ai-use-case --init`

### Step 4: Detect Available Sessions

**If SCAN_TYPE is "conversation":**
- Analyze current conversation for documentation value
- Skip git history scanning
- Proceed directly to documentation

**If SCAN_TYPE is "git" or "both":**
```bash
USER_EMAIL=$(git config user.email)
GH_USERNAME=$(gh api user --jq '.login' 2>/dev/null)

# Get recent merged PRs by current user (last 24 hours)
if [ -n "$GH_USERNAME" ]; then
    gh pr list --limit 20 --state merged --author="$GH_USERNAME" --json number,title,mergedAt,headRefName,author --jq '.[] | select(.mergedAt | fromdateiso8601 > (now - 86400)) | "PR #\(.number): \(.title) (branch: \(.headRefName))"'
fi

# Get recent commits by current user
git log --since="24 hours ago" --author="$USER_EMAIL" --pretty=format:"%h - %s (%ar)" --first-parent

# Check existing documentation
ls -1 .usecase/cases/ 2>/dev/null | grep -E '^[0-9]{4}-W[0-9]{2}-[0-9]{2}-[0-9]{2}_.*\.md$'
```

### Step 5: Present Options to User

Build prioritized list based on detection:

**If multiple options found:**
```
Which session would you like to document?

1. ⚠️ PR #59: Enhance copilot instructions (branch: docs/enhance-copilot-instructions)
2. ⚠️ PR #58: Add missing project commands (branch: docs/complete-commands)
3. 🔬 Current Research Session: [Topic from conversation]

Please select (1, 2, 3, etc.):
```

**If only one option:** Skip selection, proceed with that option.

### Step 6: Determine Session Type

Based on selection, determine if implementation or research:

**Implementation Session indicators:**
- Has git commits
- Files were modified
- Associated with PRs or feature branches

**Research Session indicators:**
- No git commits
- Exploratory conversation only
- Architecture or approach discussions

### Step 7: Analyze Session

**For Implementation Sessions:**
```bash
USER_EMAIL=$(git config user.email)

# Recent commits with details
git log --since="24 hours ago" --author="$USER_EMAIL" --pretty=format:"%h - %s (%ar)" | head -20

# Latest commit stats
LATEST_USER_COMMIT=$(git log --author="$USER_EMAIL" --format="%H" -n 1 2>/dev/null)
if [ -n "$LATEST_USER_COMMIT" ]; then
    git show --stat "$LATEST_USER_COMMIT"
fi

# Current status
git status --short
```

**For Research Sessions:**
- Extract initial user query from conversation
- Document query evolution through iterations
- List key insights discovered
- Compare approaches evaluated

### Step 8: Extract Metadata

**For Implementation Sessions:**
- **Date**: Today in YYYY-Www-MM-DD format (ISO 8601 week)
- **Ticket**: Extract from commits (HUB-001, PROJ-123) or auto-generate
- **Complexity**: Low (1-3 files), Medium (4-10), High (10+)
- **Time saved**: Low: 0.5-1h, Medium: 1-3h, High: 3-8h

**For Research Sessions:**
- **Ticket**: Use RESEARCH-XXX format
- **Initial Query**: From conversation start
- **Key Insights**: List from discussion
- **Approaches Evaluated**: Different solutions discussed

### Step 9: Read Template

Templates are located in the CLI installation directory (default: `~/.local/share/ai-use-case-cli/docs/`):

```bash
# Implementation template
cat ~/.local/share/ai-use-case-cli/docs/TEMPLATE.md

# Research template
cat ~/.local/share/ai-use-case-cli/docs/TEMPLATE-RESEARCH.md
```

**Note**: If templates aren't found at the default location, check `AI_USECASES_CLI_ROOT` environment variable for custom installation paths.

### Step 10: Generate Documentation

Create markdown file following template structure:

**Filename Format:**
- Implementation: `.usecase/cases/YYYY-Www-MM-DD_TICKET-XXX_brief-description.md`
- Research: `.usecase/cases/YYYY-Www-MM-DD_RESEARCH-XXX_brief-description.md`

**Requirements:**
- All sections filled with real data (NO "TODO" placeholders)
- Actual git statistics (files changed, lines added/removed)
- Code examples from conversation where relevant
- Professional formatting

### Step 11: Commit and Sync

**For Implementation Sessions:**
```bash
git add .usecase/cases/YYYY-Www-MM-DD_TICKET-XXX_*.md
git commit -m "docs: AI session YYYY-Www-MM-DD - TICKET-XXX - Brief description

🤖 AI-Assisted Documentation"
```

**For Research Sessions:**
- Create file only (no commit since no code changes)
- User can commit manually if desired

**Both session types - sync to hub:**
```bash
ai-use-case sync
```

## Example Invocations

### With Parameters (Quick)
```
/prompts:use-case-document-session SCAN_TYPE=git
```

### Specify Session Type
```
/prompts:use-case-document-session SCAN_TYPE=conversation SESSION_TYPE=research
```

### Interactive (Recommended)
```
/prompts:use-case-document-session
```
Then follow prompts to select what to document.

## Key Principles

1. **Hybrid Parameters**: Accept optional parameters, prompt if not provided
2. **Interactive First**: Present options before extensive git scanning
3. **Automatic After Selection**: Generate docs without further questions
4. **Be Complete**: Fill all template sections with real data
5. **Be Precise**: Use exact numbers from git
6. **Filter by User**: Only show current user's PRs and commits

## Session Type Detection Summary

| Indicator | Implementation | Research |
|-----------|----------------|----------|
| Git commits | Yes | No |
| File changes | Yes | No |
| PRs/branches | Yes | No |
| Conversation focus | Code | Exploration |
| Ticket format | PROJ-XXX | RESEARCH-XXX |
| Icon | 🎯 | 🔬 |

## Output Example

```
✅ Documentation created and synced!

File: .usecase/cases/2025-W45-11-08_HUB-056_session-data-extraction.md

Summary:
- PR #56: Add session data extraction feature
- 8 files updated
- 245 lines added, 32 deleted
- Time saved: ~2 hours

Synced to hub at:
- by-project/ai-use-case-cli/
- by-date/2025/11/
```

## Reference

- Implementation template: `docs/TEMPLATE.md`
- Research template: `docs/TEMPLATE-RESEARCH.md`
- Shell script: `scripts/core/document-ai-session.sh`
