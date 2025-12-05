# Setup AI Use Cases for Current Project

You are helping the user set up AI use case documentation automation for their current project.

## Your Task

Configure the current project to automatically sync AI use case documentation to the central repository.

## Steps

1. Verify we're in a git repository:
   ```bash
   git rev-parse --show-toplevel
   ```

2. Check current status:
   ```bash
   # Check if already set up
   ls -la .usecase/cases/ 2>/dev/null && echo "Already set up" || echo "Not set up"
   ls -la .git/hooks/post-commit 2>/dev/null && grep -q "AI Use Cases" .git/hooks/post-commit && echo "Hook installed" || echo "Hook not installed"
   ```

3. Run the setup script:
   ```bash
   ai-use-case --init
   ```

4. Verify the setup:
   ```bash
   # Check what was created
   ls -la .usecase/cases/
   ls -la .git/hooks/post-commit

   # Show the user where files will be synced
   echo "Files will sync to the hub at: \$AI_USECASES_DIR/by-project/$(basename $(git rev-parse --show-toplevel))/"
   ```

5. Explain to the user:
   - How to create use case documents (naming convention)
   - That commits will auto-sync to the central repository
   - Where to find synced files (by-project, by-date, by-topic)

## What Gets Set Up

- `.usecase/cases/` directory in the project
- Git post-commit hook for auto-syncing
- `.gitignore` patterns for draft files
- README in the ai-use-cases directory

## Update Mode

If the project is already set up and you want to refresh the installation (update Claude Code slash commands and git hooks):

```bash
bash ~/.local/share/ai-use-case-cli/setup-project.sh --update .
```

### What Gets Updated

- Claude Code slash commands (refreshed from CLI installation)
- Git hooks (post-commit, pre-commit)

### What Stays the Same

- Existing use case documents
- Project registry entry
- .usecase/cases/ directory structure
- .gitignore configuration

### When to Use

- After upgrading the CLI to a new version
- To get latest slash command improvements
- To fix corrupted or outdated hooks
- When slash commands aren't working correctly

**Note**: For managed updates with version tracking, consider using the `/use-case:update-project` command instead, which internally calls `setup-project.sh --update` and updates the project registry.

## Next Steps

Suggest the user:
1. Use `/use-case:document-session` slash command after their next coding session
2. View the template in the hub repository (location shown during setup)
3. Use `/use-case:sync-usecases` to manually sync if needed
