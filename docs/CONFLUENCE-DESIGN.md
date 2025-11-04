# Confluence Publishing Feature Design

## Overview
Add ability to publish individual AI use case documentation files to Atlassian Confluence as child pages under a specified parent page.

## Requirements
1. **Command**: `ai-use-case publish-confluence <markdown-file> <parent-page-url>`
2. **MCP Integration**: Use Atlassian MCP server (prerequisite)
3. **Authentication**: Support both Atlassian SSE and token-based auth (via MCP)
4. **Scope**: Publish individual pages (not batch)
5. **Parent Page**: Specified via Confluence page URL

## Architecture

### Command Structure
```bash
ai-use-case publish-confluence [options] <markdown-file> <parent-page-url>

Options:
  --title <title>        Override page title (default: extracted from filename)
  --space <space-key>    Confluence space key (extracted from URL if not provided)
  --dry-run             Show what would be published without actually doing it
  --help                Show help message
```

### Workflow

1. **Validate Inputs**
   - Check markdown file exists and is readable
   - Validate Confluence URL format
   - Extract page ID from URL

2. **MCP Prerequisites Check**
   - Verify Atlassian MCP server is configured in Claude Code
   - Check MCP server is accessible
   - Validate authentication (SSE or token)

3. **Parse Markdown File**
   - Extract title from filename (`YYYY-Www-MM-DD_TICKET-XXX_description.md` → title)
   - Read markdown content
   - Optionally convert markdown to Confluence storage format

4. **Confluence API Operations** (via MCP)
   - Get parent page details to validate access
   - Create new child page under parent
   - Set page title and content
   - Return URL of created page

5. **Report Results**
   - Display success message with page URL
   - Handle errors gracefully with helpful messages

### URL Parsing

Confluence URLs typically follow these patterns:
```
https://{site}.atlassian.net/wiki/spaces/{space}/pages/{pageId}/{title}
https://{site}.atlassian.net/wiki/spaces/{space}/pages/edit-v2/{pageId}
https://{site}.atlassian.net/l/cp/{shortId}
```

Extract page ID using regex patterns.

### Title Extraction

From filename `YYYY-Www-MM-DD_TICKET-XXX_description.md`:
1. Remove date prefix: `YYYY-Www-MM-DD_`
2. Keep ticket: `TICKET-XXX`
3. Convert slug to title: `description` → `Description`
4. Final title: `TICKET-XXX: Description`

Or allow user override with `--title` flag.

### MCP Integration

Use these Atlassian MCP tools:
- `mcp_atlassian_atl_getConfluencePage` - Validate parent page access
- `mcp_atlassian_atl_createConfluencePage` - Create child page (if available)
- Or use appropriate MCP tools for page creation

### Authentication

The MCP server handles authentication. Users must have Atlassian MCP configured with either:
1. **SSE (Server-Sent Events)** - For Atlassian Cloud with OAuth
2. **Token-based** - For PAT (Personal Access Token)

Configuration is in Claude Code's MCP settings, not in this CLI tool.

### Error Handling

Graceful error messages for:
- Missing markdown file
- Invalid Confluence URL
- MCP server not configured
- Authentication failures
- Permission errors
- Network issues

## Implementation Plan

### Phase 1: Core Script
1. Create `publish-confluence.sh`
2. Implement input validation
3. Add URL parsing logic
4. Add title extraction

### Phase 2: MCP Integration
1. Add MCP prerequisite checks
2. Implement Confluence API calls via MCP
3. Handle authentication flows

### Phase 3: CLI Integration
1. Add `publish-confluence` command to main CLI
2. Update help text
3. Add to documentation

### Phase 4: Testing
1. Test with various URL formats
2. Test with different auth methods
3. Test error scenarios
4. Document usage examples

## File Structure

```
ai-use-case-cli/
├── ai-use-case                    # Main CLI (update)
├── publish-confluence.sh          # New script
├── CONFLUENCE-DESIGN.md          # This file
└── README.md                      # Update with new command
```

## Usage Examples

### Basic Usage
```bash
cd ~/my-project
ai-use-case publish-confluence \
  docs/ai-use-cases/2025-10-16_PROJ-123_implement-auth.md \
  https://mycompany.atlassian.net/wiki/spaces/DOCS/pages/123456789/AI+Use+Cases
```

### With Custom Title
```bash
ai-use-case publish-confluence \
  --title "PROJ-123: Complete Authentication Implementation" \
  docs/ai-use-cases/2025-10-16_PROJ-123_implement-auth.md \
  https://mycompany.atlassian.net/wiki/spaces/DOCS/pages/123456789/AI+Use+Cases
```

### Dry Run
```bash
ai-use-case publish-confluence --dry-run \
  docs/ai-use-cases/2025-10-16_PROJ-123_implement-auth.md \
  https://mycompany.atlassian.net/wiki/spaces/DOCS/pages/123456789/AI+Use+Cases
```

## Security Considerations

1. **No credential storage** - All auth handled by MCP server
2. **Read-only access to markdown files** - No modifications to source files
3. **Validation of URLs** - Prevent injection attacks
4. **Permission checks** - Validate user can create child pages

## Future Enhancements

1. **Batch publishing** - Publish multiple files at once
2. **Update existing pages** - Detect and update instead of always creating new
3. **Confluence templates** - Use custom page templates
4. **Labels/tags** - Add labels to published pages
5. **Space selection** - Interactive space picker
6. **Preview** - Show preview before publishing
7. **Attachments** - Upload referenced images/files

## Success Criteria

- ✅ Can publish markdown file to Confluence as child page
- ✅ Supports both SSE and token auth via MCP
- ✅ Graceful error handling with helpful messages
- ✅ Extracts title from filename intelligently
- ✅ Returns published page URL
- ✅ Validates all inputs before making API calls
- ✅ Works with various Confluence URL formats
