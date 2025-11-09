# Check for CLI Updates

You are helping the user identify which projects need updates to the latest AI Use Case CLI version.

## Your Task

Check all registered projects and report which ones are running outdated versions of the CLI, helping the user keep their projects up to date.

## Command

Run the check-updates script:
```bash
bash ~/.local/share/ai-use-case-cli/scripts/project/check-updates.sh
```

## Available Options

### Default (Pretty Output)
Shows detailed information about outdated projects:
```bash
bash ~/.local/share/ai-use-case-cli/scripts/project/check-updates.sh
```

### JSON Output
For programmatic processing:
```bash
bash ~/.local/share/ai-use-case-cli/scripts/project/check-updates.sh --json
```

### Paths Only
Get only project paths (useful for scripting):
```bash
bash ~/.local/share/ai-use-case-cli/scripts/project/check-updates.sh --paths-only
```

## Information Displayed

For each outdated project:
- Project name
- Project path
- Current (outdated) version
- Latest available version
- Last update timestamp

Summary statistics:
- Total registered projects
- Number of outdated projects

## Next Steps

After checking for updates, offer to:

### 1. Update a Single Project
```bash
bash ~/.local/share/ai-use-case-cli/scripts/project/update-project.sh /path/to/project
```

### 2. Update All Outdated Projects
```bash
for p in $(bash ~/.local/share/ai-use-case-cli/scripts/project/check-updates.sh --paths-only); do
  bash ~/.local/share/ai-use-case-cli/scripts/project/update-project.sh "$p"
done
```

### 3. View Project Details
```bash
bash ~/.local/share/ai-use-case-cli/scripts/project/list-projects.sh --registry-only
```

## Interaction Flow

1. Run the check-updates script
2. Display the results clearly
3. Based on the output:
   - **If no updates needed**: Confirm all projects are current
   - **If updates available**:
     - List which projects need updates
     - Explain the version difference
     - Offer to update them (ask if single or all)

## Important Notes

- Projects are only checked if they're registered in the CLI registry
- Updates are non-breaking for patch and minor versions
- The update process re-runs the setup script safely
- Existing use cases and configuration are preserved
- Git hooks may be updated with new features

## Example Interactions

**When all projects are up to date:**
"All X projects are running the latest CLI version (v3.1.0). No updates needed!"

**When updates are available:**
"Found 2 projects that need updating:
- my-app: v3.0.0 → v3.1.0
- other-project: v2.5.0 → v3.1.0

Would you like me to update them? I can update all at once or one at a time."

**When no projects are registered:**
"No projects are registered yet. Projects get registered when you run the setup script.
Would you like to set up a project?"

## Safety

- Updates are safe and non-destructive
- The update command will:
  - ✓ Preserve existing use cases
  - ✓ Keep git hooks functional
  - ✓ Update Claude Code slash commands
  - ✓ Update registry metadata
  - ✗ NOT modify your project code
  - ✗ NOT change git history
