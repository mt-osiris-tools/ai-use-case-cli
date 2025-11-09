# Update Project CLI Version

You are helping the user update a project to the latest AI Use Case CLI version.

## Your Task

Update a specific project's CLI installation to the latest version, ensuring all scripts, hooks, and slash commands are up to date.

## Command

Run the update-project script with the project path:
```bash
bash ~/.local/share/ai-use-case-cli/scripts/project/update-project.sh /path/to/project
```

## Usage

### Update Current Directory
```bash
bash ~/.local/share/ai-use-case-cli/scripts/project/update-project.sh .
```

### Update Specific Project
```bash
bash ~/.local/share/ai-use-case-cli/scripts/project/update-project.sh /full/path/to/project
```

### Update Multiple Projects
```bash
# Update all outdated projects
for p in $(bash ~/.local/share/ai-use-case-cli/scripts/project/check-updates.sh --paths-only); do
  bash ~/.local/share/ai-use-case-cli/scripts/project/update-project.sh "$p"
done
```

## What Gets Updated

The update process will:

1. **Verify Registration**: Check that the project is registered
2. **Check Version**: Compare current vs latest version
3. **Update Scripts**: Re-run setup to update:
   - Git hooks (post-commit, pre-commit)
   - Claude Code slash commands
   - Script references to latest version
4. **Update Registry**: Record new version and timestamp

## What's Preserved

The update process preserves:
- ✓ Existing AI use case documentation
- ✓ Project configuration
- ✓ Git history and commits
- ✓ Custom modifications (with backups)
- ✓ Hub synchronization settings

## Interaction Flow

1. **Ask for project path** if not provided:
   - Offer to update current directory
   - Offer to show list of outdated projects
   - Accept absolute or relative paths

2. **Before updating**, confirm with user:
   - Show current version
   - Show target version
   - Explain what will be updated
   - Get explicit confirmation (script will prompt)

3. **During update**:
   - Show progress from setup script
   - Report any issues encountered

4. **After update**:
   - Confirm successful update
   - Show new version
   - Suggest next steps (test, document, etc.)

## Error Handling

If the script reports an error:

- **Project not registered**: Suggest running setup instead
- **Already up to date**: Confirm no action needed
- **Update failed**: Review error messages and suggest solutions

## Example Interactions

**Updating current directory:**
```
User: "Update this project"
Assistant: "I'll update the current project to the latest CLI version."
[Runs: bash ~/.local/share/ai-use-case-cli/scripts/project/update-project.sh .]
```

**Updating specific project:**
```
User: "Update my-app to the latest version"
Assistant: "I'll update the my-app project. Let me find the registered path first."
[Runs: bash ~/.local/share/ai-use-case-cli/scripts/project/list-projects.sh --registry-only]
[Finds path: /home/user/Projects/my-app]
[Runs: bash ~/.local/share/ai-use-case-cli/scripts/project/update-project.sh /home/user/Projects/my-app]
```

**Multiple projects:**
```
User: "Update all my projects"
Assistant: "I'll check which projects need updates and update them all."
[Runs: bash ~/.local/share/ai-use-case-cli/scripts/project/check-updates.sh]
[Shows list of outdated projects]
[Asks: "Update all X projects? This will run the setup script for each."]
[If yes, runs update-project.sh for each path]
```

## Safety Checks

Before updating, the script will:
1. Verify the directory exists
2. Check if project is registered
3. Verify it's a git repository
4. Compare versions (skip if up to date)
5. Prompt for confirmation

## Post-Update Steps

After successfully updating, suggest:

1. **Verify the update**:
   ```bash
   bash ~/.local/share/ai-use-case-cli/scripts/project/list-projects.sh --registry-only
   ```

2. **Test in Claude Code**:
   - Confirm slash commands work: `/use-case:quick-start`
   - Try documenting a session: `/use-case:document-session`

3. **Review changes**:
   - Check `.git/hooks/` for updated hooks
   - Check `.claude/commands/use-case/` for new commands

## Important Notes

- Updates require user confirmation (interactive prompt)
- Safe to run multiple times (idempotent)
- Updates preserve all existing functionality
- New features in CLI will become available after update
- Registry is automatically updated on successful completion
