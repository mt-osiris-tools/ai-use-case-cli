# Document AI Session

You are helping the user document an AI-assisted coding session they just completed.

## Your Task

Run the interactive AI session documentor script and guide the user through the process.

## Steps

1. First, check if we're in a git repository and if it's set up for AI use cases:
   ```bash
   # Check if in git repo
   git rev-parse --show-toplevel

   # Check if ai-use-cases directory exists
   ls -la docs/ai-use-cases/ 2>/dev/null || echo "Not set up"
   ```

2. If not set up, offer to run the setup:
   ```bash
   ai-use-case --init
   ```

3. Gather context about the session by running:
   ```bash
   # Get git status and recent changes
   git status --short
   git log --oneline --since="24 hours ago" | head -10
   git diff --stat HEAD~1..HEAD
   ```

4. Run the interactive documentor:
   ```bash
   ai-use-case document
   ```

5. After the script completes, offer to help the user:
   - Fill in TODO sections in the generated document
   - Add code snippets
   - Calculate token usage if they tracked it
   - Review the documentation before committing

## Additional Context

- The user just completed an AI-assisted coding session using Claude Code, GitHub Copilot, or both
- They want to document what was accomplished for future reference
- Be proactive about filling in details from the git history
- Help them quantify time saved and results achieved

## Output

After documenting, show them:
- Where the file was saved
- How to view it in the central repository
- Next steps for completing the documentation
