---
description: Document AI coding session automatically
---

# Document AI Session - Interactive Selection with Automatic Generation

**IMPORTANT**: You are an AI coding assistant, and you should **first ask the user which session to document**, then automatically generate documentation for the selected session. Do NOT run the interactive `document-ai-session.sh` script or ask the user to fill in details after selection.

## 📋 Documentation Workflow - What Will Happen

Before we start, here's the complete workflow you'll see:

**Phase 1: Session Selection**
- [ ] Get your git user email and detect recent work
- [ ] Check for undocumented PRs merged in last 24 hours
- [ ] Analyze current conversation for documentation value
- [ ] Present prioritized options (PRs, research sessions, commits)
- [ ] Wait for you to select which session to document

**Phase 2: Environment Validation**
- [ ] Check CLI version against latest from GitHub
- [ ] Verify project setup (.usecase/cases/ directory exists)
- [ ] Confirm git repository is properly configured

**Phase 3: Session Analysis**
- [ ] Determine session type (implementation vs research)
- [ ] Analyze git history and commits (if implementation)
- [ ] Analyze conversation context and insights (if research)
- [ ] Extract all relevant metrics and statistics

**Phase 4: Information Extraction**
- [ ] Calculate date with ISO 8601 week number for filename
- [ ] Extract or generate appropriate ticket number
- [ ] Determine complexity level from scope
- [ ] Estimate time saved based on complexity
- [ ] Extract objective and background from context

**Phase 5: Documentation Generation**
- [ ] Read the appropriate template (implementation or research)
- [ ] Generate filename following naming convention
- [ ] Create complete documentation with all sections filled
- [ ] Verify no TODO placeholders remain

**Phase 6: Commit and Sync**
- [ ] Add documentation file to git (implementation sessions only)
- [ ] Create commit with proper attribution (implementation sessions only)
- [ ] Sync documentation to your hub (all session types)
- [ ] Confirm successful completion (all session types)

**Total time**: Usually 30-60 seconds after you select a session.

---

## Your Task

Help the user select which work session to document, then automatically generate comprehensive documentation by analyzing git history and conversation context.

## 🚨 CRITICAL: Create Todo List FIRST - Before ANY Bash Commands

**IMMEDIATELY when this command runs**, use the TodoWrite tool to create the complete todo list. This must happen BEFORE:
- Running any bash commands
- Executing any git operations
- Checking for PRs or commits
- Any other detection work

This provides transparency and lets the user see what will happen before any commands execute.

**Context**: The workflow consists of **6 logical phases** (as shown in "📋 Documentation Workflow" above), but the TodoWrite list breaks down Phase 1 (Session Selection) into **3 visible progress steps** for more granular tracking. This results in **8 total TodoWrite items** that map to the 6-phase workflow structure.

**Initial Todo List** (create this first with all items as "pending"):

1. **Step 1: Detect Recent Work** *(Phase 1a - Session Selection)*
   - content: "Detect recent work (PRs, commits, conversation)"
   - activeForm: "Detecting recent work (PRs, commits, conversation)"

2. **Step 2: Present Options** *(Phase 1b - Session Selection)*
   - content: "Present prioritized documentation options to user"
   - activeForm: "Presenting prioritized documentation options to user"

3. **Step 3: Wait for Selection** *(Phase 1c - Session Selection)*
   - content: "Wait for user to select which session to document"
   - activeForm: "Waiting for user to select which session to document"

4. **Step 4: Environment Validation** *(Phase 2)*
   - content: "Check CLI version and verify project setup"
   - activeForm: "Checking CLI version and verifying project setup"

5. **Step 5: Session Analysis** *(Phase 3)*
   - content: "Analyze git history and/or conversation context"
   - activeForm: "Analyzing git history and/or conversation context"

6. **Step 6: Extract Information** *(Phase 4)*
   - content: "Extract metadata (date, ticket, complexity, time saved)"
   - activeForm: "Extracting metadata (date, ticket, complexity, time saved)"

7. **Step 7: Generate Documentation** *(Phase 5)*
   - content: "Read template and generate complete documentation"
   - activeForm: "Reading template and generating complete documentation"

8. **Step 8: Commit and Sync** *(Phase 6)*
   - content: "Commit documentation (if implementation) and sync to hub"
   - activeForm: "Committing documentation (if implementation) and syncing to hub"

**IMPORTANT**:
- Mark each todo as "in_progress" when you start that step
- Mark as "completed" immediately when finished
- Update the list in real-time as you work through the steps
- This provides full visibility to the user about what's happening

Example:
```
# When starting Step 1
TodoWrite: Mark "Step 1: Detect Recent Work" as in_progress

# When Step 1 completes
TodoWrite: Mark "Step 1: Detect Recent Work" as completed
TodoWrite: Mark "Step 2: Present Options" as in_progress
```

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

### Step 0: Present Documentation Options (BEFORE Bash Commands)

**CRITICAL WORKFLOW ORDER**:
1. **FIRST**: Create TodoWrite checklist (8 steps)
2. **SECOND**: Check git user credentials (lightweight, always needed)
3. **THIRD**: Present high-level options to user
4. **FOURTH**: Based on user choice, run git detection bash commands if needed
5. **FIFTH**: Show detailed options if needed

#### 0.1: Check Git User Credentials (ALWAYS - Lightweight Check)

**Run this immediately after creating TodoWrite checklist** - it's needed regardless of user's choice:

```bash
# Get current user's git email and GitHub username
USER_EMAIL=$(git config user.email)
GH_USERNAME=$(gh api user --jq '.login' 2>/dev/null)

# Display user info
echo "Git user: $USER_EMAIL"
if [ -n "$GH_USERNAME" ]; then
    echo "GitHub user: $GH_USERNAME"
else
    echo "GitHub CLI not configured (PR detection will be skipped)"
fi
```

**Why this is always needed:**
- Required for commit attribution in documentation
- Needed to filter PRs/commits by current user (not teammates)
- Lightweight operation (no history scanning)
- User context is essential for all documentation paths

#### 0.2: Present High-Level Choice

Use the AskUserQuestion tool to present initial options WITHOUT executing any bash commands:

**Question**: "What would you like to document?"

**Options**:
1. **"Current conversation"**
   - Description: "Document this AI session (research/exploration) - No git scanning needed"
   - When to use: Current conversation is substantial and worth documenting

2. **"Recent PRs and commits"**
   - Description: "Scan git history for recent work (PRs, commits) - Will check last 24 hours"
   - When to use: Want to document implementation work from recent PRs or commits

3. **"Both - show me all options"**
   - Description: "Scan git AND include current conversation - Comprehensive view"
   - When to use: Want to see everything available to document

**IMPORTANT**: This step uses AskUserQuestion. Based on the user's selection:
- If they choose "Current conversation": Skip to Step 0.3 (analyze conversation only, no git history scan)
- If they choose "Recent PRs and commits": Proceed to Step 0.4 (run git detection bash commands)
- If they choose "Both": Proceed to Step 0.3 then Step 0.4 (conversation + git)

#### 0.3: Analyze Current Conversation (NO BASH NEEDED)

**Only run this step if user selected "Current conversation" or "Both" in Step 0.2.**

Analyze the current AI assistant conversation to determine if it's substantial enough for documentation:

**Conversation Analysis Criteria:**
- Check conversation length (number of user messages and AI responses)
- Identify if conversation involves:
  - Technical research or exploration
  - Architecture or design discussions
  - Problem-solving or debugging approaches
  - Evaluation of multiple options/approaches
  - Learning about technologies or patterns
  - Planning or discovery work
- Determine conversation depth (simple Q&A vs. multi-round discussion)

**Substantial Conversation Indicators:**
- ✅ 5+ exchanges between user and AI
- ✅ Discussion spans multiple topics or approaches
- ✅ Iterative refinement of understanding
- ✅ Evaluation of trade-offs or alternatives
- ✅ Architectural or design decisions
- ✅ Learning/discovery of new information

**Not Substantial:**
- ❌ Single question/answer exchange
- ❌ Simple command executions
- ❌ Trivial file reads or searches
- ❌ Basic clarifications

**Edge Case Handling - User Selected "Current Conversation" but Not Substantial:**

If the user explicitly chose "Current conversation" in Step 0.2, but analysis determines the conversation is not substantial:

1. **Inform the user** with a clear message:
   ```
   "The current conversation appears to be brief (X exchanges) and may not have enough
   content for comprehensive documentation. However, since you explicitly requested to
   document it, I can proceed."
   ```

2. **Ask for confirmation** using AskUserQuestion:
   - **Question**: "The conversation seems brief. How would you like to proceed?"
   - **Options**:
     - "Document it anyway" - Proceed with current conversation documentation
     - "Scan git history instead" - Switch to git detection (go to Step 0.4)
     - "Cancel" - Exit the documentation workflow

3. **Respect user's decision** - If they choose to document anyway, proceed even though it's not substantial. The user knows their needs best.

#### 0.4: Detect Recent Work (ONLY IF USER SELECTED TO SCAN GIT)

**Run these bash commands ONLY if the user selected "Recent PRs and commits" or "Both" in Step 0.2.**

Check for recent PRs and commits by the **current git user** that haven't been documented yet:

```bash
# Note: USER_EMAIL and GH_USERNAME were already obtained in Step 0.1

# Get recent merged PRs by current user (last 24 hours) - only if GitHub CLI is configured
if [ -n "$GH_USERNAME" ]; then
    gh pr list --limit 20 --state merged --author="$GH_USERNAME" --json number,title,mergedAt,headRefName,author --jq '.[] | select(.mergedAt | fromdateiso8601 > (now - 86400)) | "PR #\(.number): \(.title) (branch: \(.headRefName))"'
else
    echo "Note: Skipping PR detection (GitHub CLI not configured or authenticated)"
fi

# Get recent commits by current user on current branch
git log --since="24 hours ago" --author="$USER_EMAIL" --pretty=format:"%h - %s (%ar)" --first-parent

# Check existing documentation
ls -1 .usecase/cases/ 2>/dev/null | grep -E '^[0-9]{4}-W[0-9]{2}-[0-9]{2}-[0-9]{2}_.*\.md$'
```

**IMPORTANT**: Only show work (PRs and commits) by the current git user. Do not show work by other team members.

> **Design Note:**
> This user filtering applies specifically to AI coding assistant `/use-case:document-session` commands.
> The related shell script (`scripts/core/document-ai-session.sh`) intentionally shows all recent work (unfiltered), so shell users see the full history.
> This distinction is by design: AI assistant users get a personalized, user-scoped view, while shell script users get a team-wide view.
> If you need to see all work (not just your own), use the shell script directly.

#### 0.5: Build Options List (Based on User's Initial Choice)

Create a prioritized list of documentation options based on what was requested:

**If user chose "Current conversation only"**:
- Skip PRs and commits detection entirely
- Skip Step 0.6 (no AskUserQuestion needed since there's only one option)
- Proceed directly to Step 0.7 with: "Current Research Session: [Topic]"
- User already made their choice in Step 0.2

**If user chose "Recent PRs and commits"**:
- List PRs and commits from Step 0.4
- **DO NOT include current conversation** - user explicitly excluded it
- Only show git-based options (PRs, commits)

**If user chose "Both"**:
1. **Recent PRs/Implementation Work** (Priority 1):
   - List each PR merged in the last 24 hours
   - Include PR number, title, and branch name
   - Check if already documented (match PR number or branch name in existing files)
   - Mark undocumented PRs prominently

2. **Current Conversation/Research Session** (Priority 2):
   - **ALWAYS include if conversation is substantial** (based on analysis above)
   - Show even when there are NO git commits
   - Label with conversation summary (e.g., "Research: Evaluate authentication approaches")
   - Indicate this is a research/exploration session

3. **Recent Commits Not in PRs** (Priority 3):
   - Direct commits to main/current branch by current user
   - Check if already documented

#### 0.6: Present Detailed Options to User (Second AskUserQuestion)

**IMPORTANT - When to run this step:**
- **Run** if user chose "Recent PRs and commits" or "Both" in Step 0.2
- **Skip** if user chose "Current conversation" (they already made their selection)

**If Step 0.5 found only one option** (e.g., only one PR, or only current conversation):
- Skip this AskUserQuestion step
- Proceed directly to Step 0.7 with that single option
- No need to ask user to "choose" when there's only one choice

**If Step 0.5 found multiple options**, use the `AskUserQuestion` tool to present detailed options:

```markdown
**Question**: "Which work session would you like to document?"

**Options** (ordered by priority):

1. **PR #XX: [PR Title]** (branch: feature/xxx)
   - Description: "Document the implementation work from this PR"
   - Status: ⚠️ Not yet documented / ✅ Already documented

2. **PR #YY: [PR Title]** (branch: docs/yyy)
   - Description: "Document the implementation work from this PR"
   - Status: ⚠️ Not yet documented

3. **Current Research Session: [Topic Summary]** (if user chose "Both")
   - Description: "Document research/exploration conversation (X exchanges, no commits)"
   - Status: 🔬 Research session (substantial conversation detected)

4. **Recent Commits** (X commits in last 24h)
   - Description: "Document recent direct commits"
   - Status: ⚠️ Not yet documented
```

**IMPORTANT**: Use the `AskUserQuestion` tool with:
- `multiSelect: false` (user picks ONE session)
- Clear labels like "PR #59: Enhance copilot instructions" or "Research: Authentication Approaches"
- Descriptions that explain what will be documented
- Visual indicators (⚠️/✅ for PRs, 🔬 for research sessions)
- **Include research session option if conversation is substantial AND user chose "Both"**

#### 0.7: Process User Selection

Based on the user's selection:

**If user selected a PR**:
1. Get PR details: `gh pr view <pr-number> --json number,title,body,headRefName,commits,files`
2. Checkout the PR's merge commit to analyze the full changes
3. Extract PR metadata (title, description, files changed)
4. Proceed to Implementation Session workflow (Step 2+)

**If user selected Current Session/Research Session**:
1. Analyze the current conversation history thoroughly
2. Check for git commits by current user to determine session type:
   - If commits exist: Implementation Session (Step 2+)
   - If NO commits: Research Session (Step 2+ with Research workflow)
3. Extract conversation context (questions, iterations, insights, decisions)
4. Proceed to appropriate workflow (Step 2+)

**If user selected Recent Commits**:
1. Analyze the specified commits
2. Proceed to Implementation Session workflow (Step 2+)

### Step 1: Check CLI Version

Before starting documentation, verify the CLI is up-to-date:
```bash
# Check current version
ai-use-case --version 2>&1 | grep -o 'version [0-9.]*' | cut -d' ' -f2

# Get latest version from GitHub (single source of truth)
curl -s https://raw.githubusercontent.com/mt-osiris-tools/ai-use-case-cli/main/scripts/utils/version.sh | grep '^export CLI_VERSION=' | head -1 | cut -d'"' -f2
```

**If versions differ:**
- Warn the user that an update is available
- Recommend updating: `ai-use-case update`
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

If not set up, offer to run: `ai-use-case --init`

### Step 3: Determine Session Type

Check for commits and file changes by the current user:
```bash
# Get current user's git email
USER_EMAIL=$(git config user.email)

# Check for recent commits by current user
git log --since="24 hours ago" --author="$USER_EMAIL" --oneline | wc -l

# Check for uncommitted changes
git status --porcelain | wc -l

# Check for any file modifications in latest commit by current user
LATEST_USER_COMMIT=$(git log --author="$USER_EMAIL" --format="%H" -n 1 2>/dev/null)
if [ -n "$LATEST_USER_COMMIT" ]; then
    # Use git show which handles first commits gracefully
    git show --name-only --format="" "$LATEST_USER_COMMIT"
else
    echo "No commits by current user"
fi
```

**If commits exist:** Implementation Session → Continue to Step 4a
**If no commits:** Research Session → Continue to Step 4b

### Step 4a: Analyze Git History (Implementation Session)

Gather comprehensive git data for the current user (Run in parallel):
```bash
# Get current user's git email
USER_EMAIL=$(git config user.email)

# Recent commits by current user with relative time
git log --since="24 hours ago" --author="$USER_EMAIL" --pretty=format:"%h - %s (%ar)" | head -20

# Get latest commit by current user
LATEST_USER_COMMIT=$(git log --author="$USER_EMAIL" --format="%H" -n 1 2>/dev/null)

# Latest commit details and stats (by current user)
if [ -n "$LATEST_USER_COMMIT" ]; then
    git show --stat "$LATEST_USER_COMMIT"

    # Full diff of latest changes by current user
    # Check if commit has a parent before using ~1 notation
    if git rev-parse "${LATEST_USER_COMMIT}~1" >/dev/null 2>&1; then
        git diff "${LATEST_USER_COMMIT}~1..$LATEST_USER_COMMIT"
    else
        # First commit - show the commit itself
        git show "$LATEST_USER_COMMIT"
    fi
fi

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
- **AI Tool Used**: Detect from context (GitHub Copilot, Claude Code, OpenAI Codex, etc.)
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

**AI Agents Usage Detection (All Sessions):**

Analyze the conversation history to detect if any specialized AI agents were used (from Claude, Copilot, or other tools):

**Detection Method:**
1. Search conversation for specialized agent invocations (Task tool, subagent calls, etc.)
2. Extract the agent type and capabilities
3. Extract the purpose/context from the invocation
4. Count invocations per agent type
5. Infer outcomes from conversation following agent execution

**Common Agent Types to Detect:**
- **Explore**: Codebase exploration and search agents
- **Plan**: Architecture/implementation planning agents
- **Code-reviewer**: Code review and quality agents
- **Test-generator**: Test creation agents
- **Documentation-writer**: Documentation generation agents
- **Custom agents**: Any other specialized agents used

**Information to Extract for Each Agent:**
- Agent type and source (Claude, Copilot, custom, etc.)
- Invocation count (how many times used)
- Purpose (summarized if long)
- Key findings/output (what the agent produced or discovered)
- Value/impact (estimated from complexity and user feedback)

**Outcome Inference Heuristics:**
- Look for user acknowledgment ("great", "thanks", "that works")
- Check if agent's output led to successful task completion
- Note if subsequent conversation built on agent's findings
- Identify time-saving indicators ("saved time", "would have taken hours")
- Observe if user requested clarification or accepted results

**If No Agents Detected:**
- Omit the "AI Agents Used" section from documentation
- This is normal - many sessions don't use specialized agents

**Example: When Explore agent is detected, populate section like:**
```markdown
### AI Agents Used

- **Explore Agent (Claude):** 2 invocations
  - **Purpose:** Codebase exploration, finding authentication patterns
  - **Key Findings:** Located 8 auth-related files across 3 directories
  - **Value:** Saved ~30 minutes of manual file searching

**Agent Effectiveness Summary:**
- Total agent invocations: 2
- Most valuable agent: Explore - quickly mapped complex codebase structure
```

### Step 6: Read the Template

**IMPORTANT**: Before generating documentation, read the appropriate template from the CLI installation directory.

The CLI installation includes the complete repository structure, including the docs/ directory with templates. The path is configurable via the `AI_USECASES_CLI_ROOT` environment variable, with a fallback to the default installation location.

**Path Reference Pattern:**
- **Slash commands** (this file): Use `${AI_USECASES_CLI_ROOT:-~/.local/share/ai-use-case-cli}` to support custom installation paths
- **Bash scripts**: Use `$SCRIPT_DIR` variable which is resolved at runtime

**For Implementation Sessions:**
```bash
cat "${AI_USECASES_CLI_ROOT:-~/.local/share/ai-use-case-cli}/docs/TEMPLATE.md"
```

**For Research Sessions:**
```bash
cat "${AI_USECASES_CLI_ROOT:-~/.local/share/ai-use-case-cli}/docs/TEMPLATE-RESEARCH.md"
```

**Note**: The environment variable `AI_USECASES_CLI_ROOT` allows users to install the CLI in custom locations. If not set, it defaults to `~/.local/share/ai-use-case-cli`.

Use the Read tool to read the template file from this path. This is your source of truth for:
- All sections that must be included
- Exact formatting and structure
- Order of sections
- What information goes in each section

### Step 6.5: Capture Session Statistics (Optional but Recommended)

**Before generating documentation, capture real-time session statistics:**

**IMPORTANT: Gathering Session Statistics**

> **Note:** Session statistics gathering via `/cost` is not available in GitHub Copilot. You can skip this step.

**For Claude Code Users:**

The `/cost` command is a Claude Code built-in command that provides session statistics. You have two options to capture this data:

**Option 1: Instruct the User (Recommended)**
Since Claude cannot directly execute slash commands like `/cost` in the current context, inform the user:

```
⚠️ To include accurate session statistics in your documentation, please run:
   /cost

Then paste the output here or save it for reference when I generate the documentation.
```

**Option 2: Use Auto-Saved Statistics**
If the SessionEnd hook is configured (`.claude/hooks/SessionEnd`), session statistics are automatically saved to:
```
.usecase/session-stats/YYYY-MM-DD-HHMMSS.txt
```

Check for recent session stats files:
```bash
ls -lt .usecase/session-stats/ | head -5
```

**What /cost provides:**
- Total cost (USD)
- Total duration (API and wall time)
- Total code changes (lines added/removed)
- Token usage breakdown (if available)

**For GitHub Copilot Users:**

- Estimate session statistics (cost, duration, code changes, token usage) based on the available conversation and code diffs.
- If auto-saved session statistics from a SessionEnd hook or other tooling are available, use those.
- Clearly note in the documentation if exact statistics were not captured.

**How to use the data:**
- Populate the "Session Statistics" section in the template
- Use token counts to fill "Token Usage Summary" (if available)
- Use cost data for "Cost Efficiency Analysis" (if available)
- Include duration in "Time Analysis" (estimate if needed)

**If exact statistics are not available:**
- Continue with estimation based on conversation analysis and git diffs
- Note in documentation that statistics are estimated
- Use the auto-saved session statistics from SessionEnd hook if available

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

🤖 AI-Assisted Documentation"
```

**Optional Co-Authored-By Attribution:**
If you want to credit the specific AI tool used, you can add attribution like:
- Claude Code: `Co-Authored-By: Claude <noreply@anthropic.com>`
- GitHub Copilot: `Co-Authored-By: GitHub Copilot <noreply@github.com>`
- Other tools: Use appropriate attribution format

**For Research Sessions:**
Create documentation file but DO NOT commit (since there are no code changes):
```bash
# Just create the file using Write tool
# User can commit manually later if desired
```

**Then sync to central hub (both session types):**
```bash
ai-use-case sync
```

## Key Principles

1. **Show Checklist First**: ALWAYS create TodoWrite checklist before running any bash commands
2. **Ask Before Scanning**: Present high-level options (current conversation vs git scan) BEFORE executing any git/bash commands
3. **Be Interactive First**: Always present options for what to document, prioritizing undocumented PRs and implementation work
4. **Be Automatic After Selection**: Once user selects a session, generate documentation automatically without further questions
5. **Be Complete**: Generate comprehensive documentation with all sections filled
6. **Be Precise**: Use exact numbers from git (files changed, lines modified, commits)
7. **Be Contextual**: Use conversation history to add qualitative insights
8. **Be Professional**: Follow template structure, use proper formatting
9. **Prioritize Implementation Over Research**: Real code changes and PRs should always be documented before research sessions
10. **Filter by Current User**: Only show PRs and commits by the current git user - never show work by other team members
11. **Detect Substantial Conversations**: Always analyze current conversation for research documentation potential, even without git commits
12. **Include Research Sessions**: Show research/exploration conversations as documentation options when substantial (5+ exchanges, iterative discussions, technical decisions)

## Example Workflow

### Step 1: Initial Checklist and User Check

```
I'll help you document an AI session. Let me create a checklist first:

[TodoWrite with 8 steps created]

Checking git user credentials...
Git user: you@example.com
GitHub user: your-username

Now, what would you like to document?

1. Current conversation - Document this AI session (no git scanning)
2. Recent PRs and commits - Scan git history for recent work (last 24 hours)
3. Both - Show me everything available

[User selects option 2: "Recent PRs and commits"]
```

### Step 2: Scan Git History (After User Choice)

```
[Now running bash commands to detect PRs and commits...]

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

### Example: Research Session (No Commits)

```
I analyzed your current conversation and found documentation options:

🔬 Current Research Session: Evaluate authentication approaches
   - 8 exchanges with iterative refinement
   - Discussed OAuth 2.0, JWT, and session-based auth
   - Architecture and security trade-offs explored
   - Status: Substantial conversation detected (no git commits)

Which session would you like to document?
```

**After User Selects Research Session:**

```
✅ Research documentation created and synced!

File: .usecase/cases/2025-W46-11-11_RESEARCH-001_evaluate-authentication-approaches.md

Summary:
- Research session on authentication strategies
- Evaluated 3 different approaches
- Key decision: Recommended JWT with refresh tokens
- Time spent: ~45 minutes
- No code changes (research only)

Available in hub at:
- by-project/my-app/
- by-date/2025/11/
- by-topic/architecture/
```

## Workflow Benefits

**Why Checklist-First + Interactive Selection Matters:**
1. **Transparency**: User sees complete workflow before any bash commands run
2. **User Control**: Developer chooses what to scan (conversation only, git, or both) before permissions are requested
3. **No Unnecessary Commands**: If documenting current conversation, git scanning is skipped entirely
4. **Prevents Documentation Gaps**: Ensures all PRs, implementation work, AND research sessions get documented
5. **Batch Documentation**: Can invoke multiple times to document several sessions sequentially
6. **Context Awareness**: AI has full context of the selected session for better documentation quality
7. **Audit Trail**: Clear mapping between PRs/conversations and their documentation
8. **Captures Research Value**: Documents exploratory work and architectural decisions even without code changes

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

All demonstrate complete, professional documentation generated automatically by GitHub Copilot.
