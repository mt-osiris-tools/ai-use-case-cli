# Document AI Session - Interactive Selection with Automatic Generation

**IMPORTANT**: You are Claude Code, and you should **first ask the user which session to document**, then automatically generate documentation for the selected session. Do NOT run the interactive `document-ai-session.sh` script or ask the user to fill in details after selection.

## Your Task

Help the user select which work session to document, then automatically generate comprehensive documentation by analyzing git history and conversation context.

## Session Type Detection

Session types:

**Implementation Session:**
- Involves actual code changes and commits
- Files were modified
- Git history shows commits
- Usually associated with PRs or feature branches

**Research Session:**
- No code changes or commits
- Exploratory conversation only
- Back-and-forth query refinement
- Architecture or approach discussions

## Interactive Documentation Workflow

### Step 0: Detect and Present Documentation Options

**CRITICAL**: Start by identifying what work can be documented, prioritizing actual implementation work over research sessions.

#### 0.1: Detect Recent Undocumented Work

Check for recent PRs and commits that haven't been documented yet:

```bash
# Get recent merged PRs (last 24 hours)
gh pr list --limit 20 --state merged --json number,title,mergedAt,headRefName,author --jq '.[] | select(.mergedAt | fromdateiso8601 > (now - 86400)) | "PR #\(.number): \(.title) (branch: \(.headRefName))"'

# Get recent commits on current branch
git log --since="24 hours ago" --pretty=format:"%h - %s (%ar)" --first-parent

# Check existing documentation
ls -1 .usecase/cases/ 2>/dev/null | grep -E '^[0-9]{4}-W[0-9]{2}-[0-9]{2}-[0-9]{2}_.*\.md$'
```

#### 0.2: Build Options List

Create a prioritized list of documentation options:

1. **Recent PRs/Implementation Work** (Priority 1):
   - List each PR merged in the last 24 hours
   - Include PR number, title, and branch name
   - Check if already documented (match PR number or branch name in existing files)
   - Mark undocumented PRs prominently

2. **Current Conversation/Research Session** (Priority 2):
   - What happened in the current Claude Code conversation
   - Only if it's substantial enough to warrant documentation

3. **Recent Commits Not in PRs** (Priority 3):
   - Direct commits to main/current branch
   - Check if already documented

#### 0.3: Present Options to User

Use the `AskUserQuestion` tool to present options:

```markdown
**Question**: "Which work session would you like to document?"

**Options** (ordered by priority):

1. **PR #XX: [PR Title]** (branch: feature/xxx)
   - Description: "Document the implementation work from this PR"
   - Status: ⚠️ Not yet documented / ✅ Already documented

2. **PR #YY: [PR Title]** (branch: docs/yyy)
   - Description: "Document the implementation work from this PR"
   - Status: ⚠️ Not yet documented

3. **Current Research Session**
   - Description: "Document the current exploratory conversation"
   - Status: Current session

4. **Recent Commits** (X commits in last 24h)
   - Description: "Document recent direct commits"
   - Status: ⚠️ Not yet documented
```

**IMPORTANT**: Use the `AskUserQuestion` tool with:
- `multiSelect: false` (user picks ONE session)
- Clear labels like "PR #59: Enhance copilot instructions"
- Descriptions that explain what will be documented
- Visual indicators (⚠️/✅) for documentation status

#### 0.4: Process User Selection

Based on the user's selection:

**If user selected a PR**:
1. Get PR details: `gh pr view <pr-number> --json number,title,body,headRefName,commits,files`
2. Checkout the PR's merge commit to analyze the full changes
3. Extract PR metadata (title, description, files changed)
4. Proceed to Implementation Session workflow (Step 2+)

**If user selected Current Session**:
1. Analyze the current conversation history
2. Determine if it's research or implementation based on git activity
3. Proceed to appropriate workflow (Step 2+)

**If user selected Recent Commits**:
1. Analyze the specified commits
2. Proceed to Implementation Session workflow (Step 2+)

### Step 1: Check CLI Version

Before starting documentation, verify the CLI is up-to-date:
```bash
# Check current version (portable, works on macOS and Linux)
bash ~/.local/share/ai-use-case-cli/ai-use-case --version 2>&1 | grep -o 'version [0-9.]*' | cut -d' ' -f2

# Get latest version from GitHub (single source of truth)
curl -s https://raw.githubusercontent.com/mt-osiris-tools/ai-use-case-cli/main/scripts/utils/version.sh | grep '^export CLI_VERSION=' | head -1 | cut -d'"' -f2
```

**If versions differ:**
- Warn the user that an update is available
- Recommend updating: `cd ~/.local/share/ai-use-case-cli && git pull`
- Ask if they want to continue with current version or update first
- If they choose to update, instruct them to re-run the command after updating

**If update check fails (network issues):**
- Continue with current version
- Note in output that version couldn't be verified

### Step 2: Verify Setup

Check if we're in a git repository with AI use cases configured:
```bash
git rev-parse --show-toplevel
ls -la .usecase/cases/ 2>/dev/null || echo "Not set up"
```

If not set up, offer to run: `bash ~/.local/share/ai-use-case-cli/setup-project.sh`

### Step 3: Determine Session Type

Check for commits and file changes:
```bash
# Check for recent commits
git log --since="24 hours ago" --oneline | wc -l

# Check for uncommitted changes
git status --porcelain | wc -l

# Check for any file modifications
git diff --name-only HEAD~1..HEAD 2>/dev/null || echo "No commits"
```

**If commits exist:** Implementation Session → Continue to Step 4a
**If no commits:** Research Session → Continue to Step 4b

### Step 4a: Analyze Git History (Implementation Session)

Gather comprehensive git data (Run in parallel):
```bash
# Recent commits with relative time
git log --since="24 hours ago" --pretty=format:"%h - %s (%ar)" | head -20

# Latest commit details and stats
git show --stat HEAD

# Full diff of latest changes
git diff HEAD~1..HEAD

# Current status
git status --short
```

### Step 4b: Analyze Conversation (Research Session)

Extract research context from conversation:
- Initial user query or question
- How the query evolved through iterations
- Different approaches discussed
- Key insights discovered
- Final recommendation or decision reached

Skip git commands if no commits exist.

### Step 5: Extract Session Information

**For Implementation Sessions:**

- **Date**: Use today's date in YYYY-Www-MM-DD format (calculate ISO 8601 week number)
- **Ticket/Issue**: Extract from commit messages (e.g., HUB-001, PROJ-1234) or infer logical next number
- **Brief description**: Summarize main work from commit messages and conversation
- **AI Tool Used**: "Claude Code (Sonnet 4.5)"
- **Complexity**: Assess from scope (Low: 1-3 files, Medium: 4-10 files, High: 10+ files or architectural)
- **Time saved**: Estimate based on complexity (Low: 0.5-1h, Medium: 1-3h, High: 3-8h)
- **TL;DR - What**: Summarize from conversation context what was accomplished
- **TL;DR - Result**: Describe outcome and impact
- **Time spent**: Estimate from conversation (typically 15-60 minutes for AI-assisted)
- **Objective**: Extract from conversation - what problem was being solved
- **Background**: Extract from conversation - why this work was needed

**For Research Sessions (Additional Fields):**

- **Ticket/Issue**: Use format `RESEARCH-XXX` (auto-increment from existing research docs)
- **Initial Query**: User's original question from conversation start
- **Query Iterations**: Count refinement cycles in conversation
- **Key Insights**: List important learnings discovered (extract from conversation)
- **Approaches Evaluated**: Different solutions discussed (extract from conversation)
- **Final Decision**: Recommended approach and rationale
- **Complexity**: Assess from conversation depth (Low: simple Q&A, Medium: multiple approaches, High: architectural decisions)

### Step 6: Read the Template

**IMPORTANT**: Before generating documentation, read the appropriate template from the CLI installation directory.

The CLI installation includes the complete repository structure, including the docs/ directory with templates. During installation, the repository is cloned to a user-scoped directory (by default `~/.local/share/ai-use-case-cli/`).

**Path Reference Pattern:**
- **Slash commands** (this file): Use absolute path `~/.local/share/ai-use-case-cli/docs/TEMPLATE.md` since Claude Code runs in the user's project directory
- **Bash scripts**: Use `$SCRIPT_DIR/docs/TEMPLATE.md` variable for flexibility across installation methods

**For Implementation Sessions:**
```bash
cat ~/.local/share/ai-use-case-cli/docs/TEMPLATE.md
```

**For Research Sessions:**
```bash
cat ~/.local/share/ai-use-case-cli/docs/TEMPLATE-RESEARCH.md
```

**Note**: Use the Read tool with the full path shown above. The hardcoded path is necessary because this slash command runs in the user's project directory, not the CLI installation directory. The `$SCRIPT_DIR` variable pattern is only available in bash scripts.

Use the Read tool to read the template file from this path. This is your source of truth for:
- All sections that must be included
- Exact formatting and structure
- Order of sections
- What information goes in each section

### Step 7: Generate Complete Documentation

Create a comprehensive markdown file **following the template structure exactly**:

**Filename Format:**
- Implementation: `.usecase/cases/YYYY-Www-MM-DD_TICKET-XXX_brief-description-slug.md`
- Research: `.usecase/cases/YYYY-Www-MM-DD_RESEARCH-XXX_brief-description-slug.md`

Where `Www` is the ISO 8601 week number (calculate using: `date +%V` to get week number (e.g., 42), then format as W42)

**Content Requirements for Implementation Sessions:**
- ✅ All sections filled with real data (NO "TODO" or placeholders)
- ✅ Actual git statistics (files changed, lines added/removed)
- ✅ Code examples from conversation where relevant
- ✅ Quantitative metrics (files, commits, tests, etc.)
- ✅ Qualitative insights from conversation context
- ✅ Professional formatting and completeness
- ✅ Use 🎯 icon in title

**Content Requirements for Research Sessions:**
- ✅ All sections filled with conversation insights (NO "TODO" or placeholders)
- ✅ Document query evolution through iterations
- ✅ List all key insights discovered
- ✅ Compare approaches evaluated with pros/cons
- ✅ Provide clear recommendation with rationale
- ✅ Include conversation excerpts showing refinement
- ✅ Professional formatting and completeness
- ✅ Use 🔬 icon in title (not 🎯)

**Use the Write tool** to create the file with full content based on the template.

### Step 8: Commit and Sync

**For Implementation Sessions:**
Commit the documentation along with code changes and sync to hub:
```bash
git add .usecase/cases/YYYY-Www-MM-DD_TICKET-XXX_brief-description-slug.md
git commit -m "docs: AI session YYYY-Www-MM-DD - TICKET-XXX - Brief description

[Additional details about what was documented...]

🤖 Generated with [Claude Code](https://claude.com/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

**For Research Sessions:**
Create documentation file but DO NOT commit (since there are no code changes):
```bash
# Just create the file using Write tool
# User can commit manually later if desired
```

**Then sync to central hub (both session types):**
```bash
bash ~/.local/share/ai-use-case-cli/scripts/core/sync-ai-use-cases.sh .
```

## Key Principles

1. **Be Interactive First**: Always present options for what to document, prioritizing undocumented PRs and implementation work
2. **Be Automatic After Selection**: Once user selects a session, generate documentation automatically without further questions
3. **Be Complete**: Generate comprehensive documentation with all sections filled
4. **Be Precise**: Use exact numbers from git (files changed, lines modified, commits)
5. **Be Contextual**: Use conversation history to add qualitative insights
6. **Be Professional**: Follow template structure, use proper formatting
7. **Prioritize Implementation Over Research**: Real code changes and PRs should always be documented before research sessions

## Example Workflow

### Initial Presentation

```
I found 5 undocumented work sessions from today:

⚠️ PR #59: Enhance copilot instructions (docs/enhance-copilot-instructions)
⚠️ PR #58: Add missing project registry commands (docs/complete-help-banner-commands)
⚠️ PR #57: Establish mandatory documentation rule (docs/mandatory-documentation-rule)
⚠️ PR #56: Add session data extraction (feature/session-data-extraction)
⚠️ PR #55: Update version references to 3.3.0 (docs/update-version-references-to-3.3.0)

Which session would you like to document?
```

### After User Selection

```
✅ Documentation created and synced!

File: .usecase/cases/2025-W45-11-08_HUB-056_session-data-extraction-with-token-tracking.md

Summary:
- PR #56: Add session data extraction feature
- 8 files updated
- 245 lines added, 32 deleted
- Time saved: ~2 hours

Available in hub at:
- by-project/ai-use-case-cli/
- by-date/2025/11/
- by-topic/feature-development/
```

## Workflow Benefits

**Why Interactive Selection Matters:**
1. **Prevents Documentation Gaps**: Ensures all PRs and implementation work get documented, not just research sessions
2. **User Control**: Developer chooses what's most important to document right now
3. **Batch Documentation**: Can invoke multiple times to document several sessions sequentially
4. **Context Awareness**: AI has full context of the selected session for better documentation quality
5. **Audit Trail**: Clear mapping between PRs and their documentation

## When NOT to Use Manual Input

After selection, documentation generation is ALWAYS automatic. Do NOT:
- Ask user to fill in sections manually
- Run the interactive bash script `document-ai-session.sh`
- Prompt for ticket numbers, descriptions, or other details

**Exception**: If user explicitly runs `ai-use-case document` in shell (not through Claude Code), they want the manual bash script workflow.

## Reference Examples

**Implementation Sessions:**
- `.usecase/cases/2025-W42-10-14_HUB-001_fix-color-encoding-in-cli-tools.md`
- `.usecase/cases/2025-10-14_HUB-002_update-github-organization-references.md`

**Research Sessions (Example Format):**
- `.usecase/cases/2025-W43-10-20_RESEARCH-001_evaluate-database-migration-strategies.md`
- Focus on query evolution, insights, and decision-making
- No code changes required

All demonstrate complete, professional documentation generated automatically by Claude Code.
