# Search AI Use Cases

You are helping the user search through their documented AI use cases to find relevant examples and patterns.

## Your Task

Help the user search, filter, and analyze their AI use case documentation across all projects.

## Quick Search

Use the search script for simple keyword searches:
```bash
ai-use-case search <search-term>
```

## Available Search Methods

### 1. Search by Topic/Keyword
```bash
# Use the search script (recommended)
ai-use-case search authentication

# Or search manually (use ${AI_USECASES_DIR:-~/.local/share/ai-use-case-cli/hub} to substitute the hub path):
# Search filenames
find ${AI_USECASES_DIR:-~/.local/share/ai-use-case-cli/hub}/by-project -name "*keyword*" -type f

# Search content
grep -r "search term" ${AI_USECASES_DIR:-~/.local/share/ai-use-case-cli/hub}/by-project --include="*.md" -l

# Search with context
grep -r "search term" ${AI_USECASES_DIR:-~/.local/share/ai-use-case-cli/hub}/by-project --include="*.md" -B 2 -A 2
```

### 2. Search by Date Range
```bash
# Use cases from October 2025
find ${AI_USECASES_DIR:-~/.local/share/ai-use-case-cli/hub}/by-date/2025/10 -name "*.md" -type l

# Recent (last 30 days)
find ${AI_USECASES_DIR:-~/.local/share/ai-use-case-cli/hub}/by-date -name "*.md" -type f -mtime -30
```

### 3. Search by Project
```bash
# List all projects
ls ${AI_USECASES_DIR:-~/.local/share/ai-use-case-cli/hub}/by-project/

# Use cases for specific project
ls -lh ${AI_USECASES_DIR:-~/.local/share/ai-use-case-cli/hub}/by-project/PROJECT_NAME/
```

### 4. Search by Topic Tag
```bash
# All authentication-related use cases
ls ${AI_USECASES_DIR:-~/.local/share/ai-use-case-cli/hub}/by-topic/ | grep -i auth

# Use cases in a specific topic
ls -lh ${AI_USECASES_DIR:-~/.local/share/ai-use-case-cli/hub}/by-topic/TOPIC_NAME/
```

## Analysis Queries

### Count use cases per project:
```bash
for dir in ${AI_USECASES_DIR:-~/.local/share/ai-use-case-cli/hub}/by-project/*/; do
    count=$(find "$dir" -name "*.md" -type f | wc -l)
    echo "$(basename "$dir"): $count"
done | sort -t: -k2 -rn
```

### Find most common AI tools used:
```bash
grep -h "Agent Used:" ${AI_USECASES_DIR:-~/.local/share/ai-use-case-cli/hub}/by-project/*/*.md 2>/dev/null | sort | uniq -c | sort -rn
```

### Total time saved:
```bash
grep -h "Time Saved:" ${AI_USECASES_DIR:-~/.local/share/ai-use-case-cli/hub}/by-project/*/*.md 2>/dev/null | grep -oP '\d+(\.\d+)?' | awk '{sum+=$1} END {print "Total hours saved: " sum}'
```

## Interaction Flow

1. Ask the user what they're looking for:
   - Specific topic/technology?
   - Recent work?
   - Specific project?
   - Pattern/approach they used before?

2. Run appropriate search commands

3. Display results in a readable format

4. Offer to:
   - Read full content of matching files
   - Compare similar use cases
   - Extract patterns or best practices
   - Generate a summary report

## Examples

**User asks:** "Show me all authentication use cases"

- Search filenames: `find ${AI_USECASES_DIR:-~/.local/share/ai-use-case-cli/hub}/by-project -name "*auth*" -type f`
- Search content: `grep -r "authentication" ${AI_USECASES_DIR:-~/.local/share/ai-use-case-cli/hub}/by-project --include="*.md" -l`

**User asks:** "What did I work on last week?"

- `find ${AI_USECASES_DIR:-~/.local/share/ai-use-case-cli/hub}/by-date -name "*.md" -type f -mtime -7 -printf '%TY-%Tm-%Td %p\n' | sort -r`

**User asks:** "How many hours have I saved using Claude Code?"

- Extract and sum time saved metrics from all use cases
