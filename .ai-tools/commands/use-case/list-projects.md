# List AI Use Case Projects

You are helping the user view all projects registered with the AI Use Case CLI.

## Your Task

Display all projects that are using the AI Use Case CLI, showing both hub information and registry data including version information and update status.

## Command

Run the list-projects script:
```bash
ai-use-case list-projects
```

## Available Options

### Show All Information (Default)
Shows both hub projects and registry information:
```bash
ai-use-case list-projects
```

### Registry Only
Show only registered projects with version details:
```bash
ai-use-case list-projects --registry-only
```

### Hub Only
Show only projects in the hub with use case counts:
```bash
ai-use-case list-projects --hub-only
```

## Information Displayed

### Hub Information
- Project names from the hub
- Number of documented use cases per project

### Registry Information (v3.1.0+)
- Project name and path
- CLI version installed
- Update status (up-to-date or outdated)
- Installation and last update timestamps
- Statistics (total projects, outdated count)

## Next Steps

After viewing the projects, you can offer to:

1. **Check for updates** if outdated projects are shown:
   ```bash
   ai-use-case check-updates
   ```

2. **View use cases** for a specific project:
   ```bash
   ls ${AI_USECASES_DIR:-~/.local/share/ai-use-case-cli/hub}/by-project/PROJECT_NAME/
   ```

3. **Update a project** to the latest version:
   ```bash
   ai-use-case update-project /path/to/project
   ```

4. **Search use cases** across all projects:
   ```bash
   ai-use-case search <term>
   ```

## Interaction Flow

1. Run the list-projects script
2. Display the formatted output
3. Highlight any outdated projects
4. Suggest next steps based on the output:
   - If outdated projects exist → suggest checking updates
   - If many projects → suggest searching for specific use cases
   - If few use cases → suggest documenting more sessions

## Example Output Interpretation

**Green checkmarks (✓)** = Project is up to date
**Yellow warnings (⚠)** = Project needs update

When you see outdated projects, proactively suggest:
"I see X project(s) need updating. Would you like me to check what needs to be updated?"
