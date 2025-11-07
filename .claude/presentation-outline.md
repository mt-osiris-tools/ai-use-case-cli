# AI Use Case CLI - Presentation Outline

**Target Presentation:** https://docs.google.com/presentation/d/1WK1XT14PKvdC23POE4_zMGL-31ExIdRoCSI5XT5mhbg/edit?slide=id.p#slide=id.p

---

## Slide 1: Title Slide
**Title:** AI Use Case CLI
**Subtitle:** Document AI-assisted development workflows with ease
**Version:** v3.2.0
**Tagline:** The Documenter

---

## Slide 2: The Problem
**Title:** Why This Tool?

**Content:**
- **Reduce cognitive overload** - Pre-built templates eliminate the "what should I document?" paralysis
- **Build a knowledge base** - Create a searchable repository of successful AI interactions
- **Learn and improve** - Reference past sessions to understand what works
- **Stay organized** - Automatic syncing and categorization keeps your AI work accessible

**Bottom text:** Documentation shouldn't be a burden—it should be a valuable asset

---

## Slide 3: Key Features
**Title:** What Can It Do?

- 🎯 **Hybrid interface** - CLI commands or Claude Code slash commands
- 🚀 **AI-assisted documentation** - Automatic context capture
- 🔬 **Research & implementation** - Document code changes and exploratory work
- 🔄 **Automatic syncing** - Git hooks sync docs automatically
- 🔧 **Flexible storage** - Local-only or private git repository
- 🗂️ **Project registry** - Track and update all projects
- 🔍 **Search & stats** - Find and analyze documented use cases
- 📤 **Confluence publishing** - Publish to Confluence as child pages

---

## Slide 4: Architecture
**Title:** How It Works

**Two Components:**
1. **CLI Tools** (this repo)
   - Scripts for documenting and managing use cases

2. **Documentation Hub** (your choice)
   - **Local Only**: `~/.local/share/ai-use-case-cli/hub/` (no git)
   - **Private Git**: Your own repository (full version control)

**Organization:** By project, date, and topic using symlinks

---

## Slide 5: Quick Start
**Title:** Get Started in 3 Steps

**1. Install:**
```bash
curl -fsSL https://raw.githubusercontent.com/mt-osiris-tools/
ai-use-case-cli/main/scripts/install/install.sh | bash
```

**2. Setup your project:**
```bash
ai-use-case --init
```

**3. Document your session (in Claude Code):**
```
/use-case:document-session
```

---

## Slide 6: Workflow
**Title:** The Documentation Workflow

**Setup** → **Document** → **Sync** → **Organize**

1. **Setup**: Creates `docs/ai-use-cases/` + installs git hooks
2. **Document**: `/use-case:document-session` captures session details automatically
3. **Sync**: Git hooks sync to hub automatically
4. **Organize**: Hub organizes by project, date, and topic

---

## Slide 7: Session Types
**Title:** Two Types of Sessions

**🎯 Implementation Sessions**
- For code changes
- Captures git statistics (files, lines changed)
- Includes code snippets
- Uses project tickets (e.g., `PROJ-1234`)

**🔬 Research Sessions**
- For exploration without code changes
- Documents query refinement
- Auto-generates `RESEARCH-XXX` tickets
- Examples: Evaluating architectures, comparing solutions

---

## Slide 8: Core Commands
**Title:** Hybrid Interface Options

**Use either CLI or Claude Code slash commands:**

| Task | CLI | Claude Code |
|------|-----|-------------|
| Setup | `ai-use-case --init` | `/use-case:setup-project` |
| Document | N/A | `/use-case:document-session` |
| Search | `ai-use-case search <term>` | `/use-case:search-usecases` |
| Sync | `ai-use-case sync` | `/use-case:sync-usecases` |
| Stats | `ai-use-case stats` | - |
| List projects | `ai-use-case list` | `/use-case:list-projects` |

---

## Slide 9: Hub Configuration (v3.2.0+)
**Title:** Flexible Storage Options

**Mode 1: Local Only** (Default)
- Files in: `~/.local/share/ai-use-case-cli/hub/`
- No git, no version control
- Complete privacy - stays on your machine
- Best for: Personal use

**Mode 2: Private Git**
- Your own private repository
- Full version control
- You control access
- Best for: Team documentation

**Reconfigure anytime:** `ai-use-case config reconfigure`

---

## Slide 10: Project Registry (v3.1.0+)
**Title:** Track All Your Projects

**Features:**
- Automatic registration during setup
- Version tracking per project
- Easy update management

**Commands:**
```bash
ai-use-case list-projects      # List all registered projects
ai-use-case check-updates      # Find projects needing updates
ai-use-case update-project     # Update specific project
```

**Registry location:** `~/.local/share/ai-use-case-cli/projects-registry.json`

---

## Slide 11: File Naming Convention
**Title:** Organized Documentation

**Format:**
```
YYYY-Www-MM-DD_TICKET-XXXXX_brief-description.md
```

**Where:**
- `YYYY` = Year (2025)
- `Www` = ISO 8601 week (W01-W53)
- `MM-DD` = Month and day
- `TICKET-XXXXX` = Ticket identifier
- `brief-description` = Lowercase with hyphens

**Examples:**
- `2025-W44-11-03_PROJ-1234_implement-user-authentication.md`
- `2025-W44-11-03_RESEARCH-001_evaluate-database-strategies.md`

---

## Slide 12: Search & Analytics
**Title:** Find What You Need

**Search use cases:**
```bash
ai-use-case search "authentication"
```

**View statistics:**
```bash
ai-use-case stats
```

**View hub:**
```bash
ai-use-case view
```

**Publish to Confluence:**
```bash
ai-use-case publish-confluence
# or /use-case:publish-confluence in Claude Code
```

---

## Slide 13: Requirements
**Title:** What You Need

**System:**
- **OS**: Linux, macOS, WSL on Windows
- **Shell**: Bash 4.0+
- **Git**: For version control and hooks
- **Dependencies**: Standard Unix tools (realpath, find, grep)

**Optional:**
- **Claude Code**: For AI-assisted documentation
- **Confluence**: For publishing features

---

## Slide 14: Benefits Summary
**Title:** Why Use AI Use Case CLI?

**For Developers:**
- ✅ No more "what should I document?" paralysis
- ✅ Automatic capture of context and changes
- ✅ Searchable knowledge base of solutions
- ✅ Learn from past successful AI interactions

**For Teams:**
- ✅ Shared understanding of AI tool usage
- ✅ Consistent documentation format
- ✅ Version-controlled or private documentation
- ✅ Track improvements over time

---

## Slide 15: Get Started Today
**Title:** Ready to Document?

**Install now:**
```bash
curl -fsSL https://raw.githubusercontent.com/mt-osiris-tools/
ai-use-case-cli/main/scripts/install/install.sh | bash
```

**Resources:**
- **GitHub**: github.com/mt-osiris-tools/ai-use-case-cli
- **Documentation**: Full docs in repo
- **Support**: GitHub Issues & Discussions
- **License**: MIT License

**Version 3.2.0 - Last Updated: 2025-11-06**
