# Document AI Session - Automatic Mode

**IMPORTANT**: You are Claude Code, and you should **automatically generate documentation** based on git history and conversation context. Do NOT run the interactive `document-ai-session.sh` script or ask the user to fill in details.

## Your Task

Automatically document the AI-assisted coding session that just occurred by analyzing git history and the conversation you had with the user.

## Automatic Documentation Workflow

### Step 1: Verify Setup

Check if we're in a git repository with AI use cases configured:
```bash
git rev-parse --show-toplevel
ls -la docs/ai-use-cases/ 2>/dev/null || echo "Not set up"
```

If not set up, offer to run: `bash ~/.local/share/ai-use-case-cli/setup-project.sh`

### Step 2: Analyze Git History (Run in Parallel)

Gather comprehensive git data:
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

### Step 3: Extract Session Information

From the data gathered, automatically determine:

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

### Step 4: Generate Complete Documentation

Create a comprehensive markdown file following TEMPLATE.md structure:

**Filename**: `docs/ai-use-cases/YYYY-MM-DD_TICKET-XXX_brief-description-slug.md`

**Content Requirements**:
- ✅ All sections filled with real data (NO "TODO" or placeholders)
- ✅ Actual git statistics (files changed, lines added/removed)
- ✅ Code examples from conversation where relevant
- ✅ Quantitative metrics (files, commits, tests, etc.)
- ✅ Qualitative insights from conversation context
- ✅ Professional formatting and completeness

**Use the Write tool** to create the file with full content.

### Step 5: Commit and Sync

Commit the documentation and sync to hub:
```bash
git add docs/ai-use-cases/YYYY-MM-DD_TICKET-XXX_brief-description-slug.md
git commit -m "docs: AI session YYYY-MM-DD - TICKET-XXX - Brief description

[Additional details about what was documented...]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

Then sync to central hub:
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
- No git history is available
- User specifically requests to manually input details

Otherwise, ALWAYS use automatic mode when `/document-session` is invoked.

## Reference Examples

See these auto-generated examples:
- `docs/ai-use-cases/2025-10-14_HUB-001_fix-color-encoding-in-cli-tools.md`
- `docs/ai-use-cases/2025-10-14_HUB-002_update-github-organization-references.md`

Both demonstrate complete, professional documentation generated automatically by Claude Code.
