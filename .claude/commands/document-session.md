# Document AI Session - Automatic Mode

**IMPORTANT**: You are Claude Code, and you should **automatically generate documentation** based on git history and conversation context. Do NOT run the interactive `document-ai-session.sh` script or ask the user to fill in details.

## Your Task

Automatically document the AI-assisted session that just occurred by analyzing the conversation context and, if applicable, git history.

## Session Type Detection

First, determine the session type:

**Implementation Session:**
- Involves actual code changes and commits
- Files were modified
- Git history shows commits

**Research Session:**
- No code changes or commits
- Exploratory conversation only
- Back-and-forth query refinement
- Architecture or approach discussions

## Automatic Documentation Workflow

### Step 1: Verify Setup

Check if we're in a git repository with AI use cases configured:
```bash
git rev-parse --show-toplevel
ls -la docs/ai-use-cases/ 2>/dev/null || echo "Not set up"
```

If not set up, offer to run: `bash ~/.local/share/ai-use-case-cli/setup-project.sh`

### Step 2: Determine Session Type

Check for commits and file changes:
```bash
# Check for recent commits
git log --since="1 hour ago" --oneline | wc -l

# Check for uncommitted changes
git status --porcelain | wc -l

# Check for any file modifications
git diff --name-only HEAD~1..HEAD 2>/dev/null || echo "No commits"
```

**If commits exist:** Implementation Session → Continue to Step 3a
**If no commits:** Research Session → Continue to Step 3b

### Step 3a: Analyze Git History (Implementation Session)

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

### Step 3b: Analyze Conversation (Research Session)

Extract research context from conversation:
- Initial user query or question
- How the query evolved through iterations
- Different approaches discussed
- Key insights discovered
- Final recommendation or decision reached

Skip git commands if no commits exist.

### Step 4: Extract Session Information

**For Implementation Sessions:**

- **Date**: Use today's date in YYYY-MM-DD format
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

### Step 5: Generate Complete Documentation

Create a comprehensive markdown file:

**Filename Format:**
- Implementation: `docs/ai-use-cases/YYYY-MM-DD_TICKET-XXX_brief-description-slug.md`
- Research: `docs/ai-use-cases/YYYY-MM-DD_RESEARCH-XXX_brief-description-slug.md`

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

**Use the Write tool** to create the file with full content.

### Step 6: Commit and Sync

**For Implementation Sessions:**
Commit the documentation along with code changes and sync to hub:
```bash
git add docs/ai-use-cases/YYYY-MM-DD_TICKET-XXX_brief-description-slug.md
git commit -m "docs: AI session YYYY-MM-DD - TICKET-XXX - Brief description

[Additional details about what was documented...]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

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
bash ~/.local/share/ai-use-case-cli/sync-ai-use-cases.sh .
```

## Key Principles

1. **Be Automatic**: Don't ask the user to fill anything in - you have all the context
2. **Be Complete**: Generate comprehensive documentation with all sections filled
3. **Be Precise**: Use exact numbers from git (files changed, lines modified, commits)
4. **Be Contextual**: Use conversation history to add qualitative insights
5. **Be Professional**: Follow template structure, use proper formatting

## Example Output

After completion, inform the user:

```
✅ Documentation created and synced!

File: docs/ai-use-cases/2025-10-14_HUB-002_update-github-organization-references.md

Summary:
- 5 files updated
- 22 replacements made
- Time saved: ~1 hour

Available in hub at:
- by-project/[project-name]/
- by-date/2025/10/
- by-topic/[topic-slug]/
```

## When NOT to Use Automatic Mode

Only use manual/interactive mode if:
- User explicitly runs `ai-use-case document` in shell (not through you)
- User specifically requests to manually input details

Otherwise, ALWAYS use automatic mode when `/document-session` is invoked.

**Note**: Automatic mode works for BOTH implementation and research sessions. Git history is NOT required - research sessions rely purely on conversation context.

## Reference Examples

**Implementation Sessions:**
- `docs/ai-use-cases/2025-10-14_HUB-001_fix-color-encoding-in-cli-tools.md`
- `docs/ai-use-cases/2025-10-14_HUB-002_update-github-organization-references.md`

**Research Sessions (Example Format):**
- `docs/ai-use-cases/2025-10-20_RESEARCH-001_evaluate-database-migration-strategies.md`
- Focus on query evolution, insights, and decision-making
- No code changes required

All demonstrate complete, professional documentation generated automatically by Claude Code.
