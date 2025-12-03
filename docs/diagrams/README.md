# Architecture Diagrams

This directory contains architectural diagrams for the AI Use Case CLI project.

## C4 Architecture Diagram

**File:** `c4-architecture.puml`

This diagram uses the [C4 model](https://c4model.com/) to visualize the system architecture at multiple levels:

### Diagrams Included

1. **System Context Diagram (C4 Level 1)**
   - Shows the AI Use Case CLI system and its interactions with users and external systems
   - Highlights: Developer workflows, Claude Code integration, Git, GitHub, Confluence, OpenTelemetry

2. **Container Diagram (C4 Level 2)**
   - Shows the internal containers/components of the AI Use Case CLI system
   - Key containers: CLI Dispatcher, Core Scripts, Project Management, Search & Analytics, Configuration & Utilities, Claude Code Integration, Git Hooks
   - Storage: Configuration files, Documentation Hub, Project Use Cases

3. **Component Diagram (C4 Level 3 - Core Scripts)**
   - Deep dive into the Core Scripts container
   - Components: document-ai-session.sh, sync-ai-use-cases.sh, publish-confluence.sh, extract-session-data.sh

4. **Deployment Diagram**
   - Shows physical deployment of the system on a developer's workstation
   - File system layout: ~/.local/bin, ~/.config, ~/.local/share, project directories
   - External cloud services: GitHub, Atlassian Cloud, Observability backends

## Viewing the Diagrams

### Option 1: Online PlantUML Viewer

1. Copy the contents of `c4-architecture.puml`
2. Visit [PlantUML Online Server](https://www.plantuml.com/plantuml/uml/)
3. Paste the content and view the rendered diagram

### Option 2: VS Code Extension

1. Install the [PlantUML extension](https://marketplace.visualstudio.com/items?itemName=jebbs.plantuml) for VS Code
2. Open `c4-architecture.puml`
3. Press `Alt+D` to preview the diagram

### Option 3: Command Line (if PlantUML is installed)

```bash
# Install PlantUML (requires Java)
# On Ubuntu/Debian:
sudo apt-get install plantuml

# On macOS:
brew install plantuml

# Generate PNG images
plantuml docs/diagrams/c4-architecture.puml

# Generate SVG images
plantuml -tsvg docs/diagrams/c4-architecture.puml
```

This will generate:
- `c4-architecture-1.png` - System Context Diagram
- `c4-architecture-2.png` - Container Diagram
- `c4-architecture-3.png` - Component Diagram
- `c4-architecture-4.png` - Deployment Diagram

### Option 4: Docker (no local Java installation needed)

```bash
# Generate PNG images using Docker
docker run --rm -v $(pwd):/data plantuml/plantuml:latest docs/diagrams/c4-architecture.puml

# Generate SVG images
docker run --rm -v $(pwd):/data plantuml/plantuml:latest -tsvg docs/diagrams/c4-architecture.puml
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
