# Architecture Diagrams

This directory contains architectural diagrams for the AI Use Case CLI project.

## Available Diagrams

### C4 Architecture Diagram

**File:** `c4-architecture.puml`

This diagram uses the [C4 model](https://c4model.com/) to visualize the system architecture at multiple levels:

### Diagrams Included

1. **System Context Diagram (C4 Level 1)**
   - Shows the AI Use Case CLI system and its interactions with users and external systems
   - Highlights: Developer workflows, AI coding assistants (Claude Code, Copilot, etc.), Git, GitHub, Confluence, OpenTelemetry

2. **Container Diagram (C4 Level 2)**
   - Shows the internal containers/components of the AI Use Case CLI system
   - Key containers: CLI Dispatcher, Core Scripts, Project Management, Search & Analytics, Configuration & Utilities, AI Assistant Integration, Agent Framework, Git Hooks
   - Storage: Configuration files (including agents.json), Documentation Hub, Project Use Cases

3. **Component Diagram (C4 Level 3 - Core Scripts)**
   - Deep dive into the Core Scripts container
   - Components: document-ai-session.sh, sync-ai-use-cases.sh, publish-confluence.sh, extract-session-data.sh

4. **Component Diagram (C4 Level 3 - Agent Framework)**
   - Deep dive into the Agent Framework container
   - Components: agent-registry.sh, invoke-agent.sh, quality-agent.sh, agent prompts
   - Shows agent lifecycle management, invocation, and integration points

5. **Deployment Diagram**
   - Shows physical deployment of the system on a developer's workstation
   - File system layout: ~/.local/bin, ~/.config, ~/.local/share, project directories
   - External cloud services: GitHub, Atlassian Cloud, Observability backends

### Document Session Sequence Diagram

**File:** `document-session-sequence.puml`

This diagram shows the complete workflow for the `/use-case:document-session` command in Claude Code:

**Phases Visualized:**
1. **Version Check** - CLI verifies it's up-to-date with latest release
2. **Session Detection (v3.4.0+)** - Detects undocumented PRs, recent commits, or current conversation
3. **Interactive Session Selection** - User chooses which session to document (PR priority)
4. **Git History Analysis** - Parallel execution of git commands for performance
5. **Session Information Extraction** - Extracts metadata from commits, PR descriptions, and conversation context
6. **Documentation Generation** - Auto-generates complete markdown documentation with all sections filled
7. **Git Commit** - Commits the documentation with proper attribution
8. **Hub Sync** - Syncs to hub repository with symlink organization and git push

**Key Interactions:**
- Developer ↔ Claude Code ↔ CLI ↔ Git ↔ GitHub ↔ File System ↔ Hub Repository
- Highlights automatic workflows: parallel git analysis, interactive selection, auto-commit, auto-sync
- Shows both implementation and research session support

## Viewing the Diagrams

### Option 1: Online PlantUML Viewer

1. Copy the contents of any `.puml` file (e.g., `c4-architecture.puml` or `document-session-sequence.puml`)
2. Visit [PlantUML Online Server](https://www.plantuml.com/plantuml/uml/)
3. Paste the content and view the rendered diagram

### Option 2: VS Code Extension

1. Install the [PlantUML extension](https://marketplace.visualstudio.com/items?itemName=jebbs.plantuml) for VS Code
2. Open any `.puml` file
3. Press `Alt+D` to preview the diagram

### Option 3: Command Line (if PlantUML is installed)

```bash
# Install PlantUML (requires Java)
# On Ubuntu/Debian:
sudo apt-get install plantuml

# On macOS:
brew install plantuml

# Generate all diagrams as PNG
plantuml docs/diagrams/*.puml

# Generate specific diagram as SVG
plantuml -tsvg docs/diagrams/c4-architecture.puml
plantuml -tsvg docs/diagrams/document-session-sequence.puml
```

For C4 architecture, this generates:
- `AI Use Case CLI - C4 Context Diagram.svg` - System Context Diagram
- `AI Use Case CLI - C4 Container Diagram.svg` - Container Diagram
- `AI Use Case CLI - C4 Component Diagram (Core Scripts).svg` - Core Scripts Component Diagram
- `AI Use Case CLI - C4 Component Diagram (Agent Framework).svg` - Agent Framework Component Diagram
- `AI Use Case CLI - Deployment Diagram.svg` - Deployment Diagram

For sequence diagram, this generates:
- `document-session-sequence.png` - Document session workflow

### Option 4: Docker (no local Java installation needed)

```bash
# Generate all diagrams as PNG using Docker
docker run --rm -v $(pwd):/data plantuml/plantuml:latest docs/diagrams/*.puml

# Generate specific diagram as SVG
docker run --rm -v $(pwd):/data plantuml/plantuml:latest -tsvg docs/diagrams/document-session-sequence.puml
```

## Understanding the C4 Model

The C4 model provides a hierarchical set of software architecture diagrams:

- **Level 1 - System Context**: Big picture view, showing how the system fits into the world
- **Level 2 - Container**: High-level technology choices and responsibilities
- **Level 3 - Component**: Decomposition of containers into components
- **Level 4 - Code**: (Optional) Class diagrams, entity relationships

### Legend

- **Person**: Human user of the system (blue)
- **System**: The software system being described (blue)
- **External System**: Other systems that the software system depends on (gray)
- **Container**: An application or data store (light blue)
- **Component**: A grouping of related functionality (light blue)

## Resources

- [C4 Model Official Site](https://c4model.com/)
- [C4-PlantUML GitHub](https://github.com/plantuml-stdlib/C4-PlantUML)
- [PlantUML Official Site](https://plantuml.com/)
