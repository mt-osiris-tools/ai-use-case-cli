# Sync AI Use Cases

You are helping the user manually sync AI use case documentation from their current project to the central repository.

## Your Task

Run the sync script to copy use case documents from the current project to the central hub.

## Steps

1. Verify we're in a project with use cases:
   ```bash
   # Find all use case files
   find .usecase/cases -name "*.md" -type f 2>/dev/null | head -10
   ```

2. Show what will be synced:
   ```bash
   echo "Files to sync:"
   find .usecase/cases -name "*.md" -type f ! -name "README.md" 2>/dev/null
   ```

3. Run the sync:
   ```bash
   bash ~/.local/share/ai-use-case-cli/scripts/core/sync-ai-use-cases.sh .
   ```

4. Show the results:
   ```bash
   # Show synced files stats
   bash ~/.local/share/ai-use-case-cli/scripts/search/stats-use-cases.sh
   ```

5. Optionally show recent use cases:
   ```bash
   bash ~/.local/share/ai-use-case-cli/scripts/project/list-projects.sh
   ```

## When to Use This

- After creating/updating use case documents
- To verify sync is working
- If automatic sync didn't trigger
- To sync multiple old use cases at once

## Note

Auto-sync happens automatically on git commit if the post-commit hook is installed. Manual sync is usually only needed for testing or troubleshooting.
