# PlantUML Diagrams

Activity diagrams documenting the flow of AI Use Case CLI commands and processes.

## Available Diagrams

### Installation & Setup

- **[installation-flow.puml](installation-flow.puml)** - CLI installation process
  - Shows installation prerequisites check
  - PATH configuration
  - Environment variable setup
  - Completion flow

- **[init-command-flow.puml](init-command-flow.puml)** - Project initialization (`ai-use-case --init`)
  - Hub configuration (first time setup)
  - Project directory structure creation
  - AI tool command installation
  - Claude Code symlink creation (with migration)
  - Git hooks installation
  - Initial sync to hub

- **[config-command-flow.puml](config-command-flow.puml)** - Configuration management
  - `config show` - Display current configuration
  - `config reconfigure` - Change hub mode
  - Local vs private-git setup

### Core Commands

- **[sync-command-flow.puml](sync-command-flow.puml)** - Documentation sync (`ai-use-case sync`)
  - File discovery and parsing
  - Copy to hub by-project/
  - Symlink creation (by-date/, by-topic/)
  - Git commit and push (if private-git mode)

- **[document-session-flow.puml](document-session-flow.puml)** - AI session documentation (`/use-case:document-session`)
  - Session selection (PRs/commits/conversation)
  - Git analysis and metadata extraction
  - AI-powered content generation
  - Template selection (implementation vs research)
  - Auto-commit and sync

- **[search-command-flow.puml](search-command-flow.puml)** - Search and statistics
  - `search <term>` - Search use cases
  - `stats` - View statistics and analytics

### Project Management

- **[project-management-flow.puml](project-management-flow.puml)** - Project registry commands
  - `list-projects` - Show all registered projects
  - `check-updates` - Find outdated projects
  - `update-project` - Update project to latest CLI version
    - Migration handling
    - Custom command preservation
    - Registry updates

## Viewing Diagrams

### Option 1: PlantUML Preview (VS Code)

1. Install PlantUML extension in VS Code
2. Open any `.puml` file
3. Press `Alt+D` to preview

### Option 2: PlantUML Server

```bash
# Using Docker
docker run -d -p 8080:8080 plantuml/plantuml-server:jetty
# Open browser to http://localhost:8080
# Paste .puml content
```

### Option 3: Generate SVG Files

```bash
# Install PlantUML
sudo apt-get install plantuml  # Linux
brew install plantuml          # macOS

# Generate SVG
cd docs/diagrams/plantuml
for file in *.puml; do
  plantuml -tsvg "$file"
done
```

### Option 4: Online PlantUML Editor

Visit: https://www.plantuml.com/plantuml/uml/

## Diagram Conventions

### Colors

- **Green (#90EE90)**: Success states
- **Light Blue (#87CEEB)**: Action/processing states
- **Lavender (#E6E6FA)**: AI-powered operations
- **Gold (#FFD700)**: Decision points
- **Pink (#FFB6C1)**: Migration/special handling
- **Light Yellow (#FFE4B5)**: Git operations
- **Light Green (#98FB98)**: Search operations
- **Light Steel Blue (#B0C4DE)**: Confluence operations
- **Plum (#DDA0DD)**: Agent operations

### Annotations

- **<<Success>>**: Successful completion
- **<<Action>>**: Standard action
- **<<AI>>**: AI-powered processing
- **<<Git>>**: Git operation
- **<<Migration>>**: Structure migration
- **<<Update>>**: Update operation
- **<<Config>>**: Configuration change
- **<<Search>>**: Search operation
- **<<Processing>>**: Data processing operation
- **<<Confluence>>**: Confluence-specific operation
- **<<Agent>>**: Agent framework operation

### Partitions

Logical groupings of related steps:
- "Project Setup"
- "Git Analysis"
- "AI Analysis & Generation"
- "For Each Use Case File"
- etc.

## Updating Diagrams

When command behavior changes:

1. Update the corresponding `.puml` file
2. Regenerate SVG if needed
3. Update this README if new diagrams added
4. Commit changes

## Related Documentation

- **[../README.md](../README.md)** - Overview of all diagrams
- **[C4 diagrams](../)** - Architecture diagrams
- **[../../COMMANDS.md](../../COMMANDS.md)** - Command reference
- **[../../WORKFLOW.md](../../WORKFLOW.md)** - Development workflow

---

**Note**: These are activity/flow diagrams showing command execution. For system architecture, see the C4 diagrams in the parent directory.
