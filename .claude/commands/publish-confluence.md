# Publish to Confluence - Automatic Mode

**IMPORTANT**: You are Claude Code with access to the Atlassian MCP server. You should **automatically publish** the specified markdown file to Confluence as a child page under the specified parent page URL.

## Your Task

Automatically publish an AI use case documentation file to Confluence using the Atlassian MCP tools.

## Prerequisites

Before proceeding, verify:
1. Atlassian MCP server is configured (check available MCP tools)
2. User has provided:
   - Markdown file path
   - Confluence parent page URL
3. User has valid Confluence authentication (SSE or token via MCP)

## Automatic Publishing Workflow

### Step 1: Validate Inputs

Check that the markdown file exists and is readable:
```bash
ls -la <markdown-file-path>
```

If file doesn't exist, inform the user and exit.

### Step 2: Parse Parent Page URL

Extract the page ID from the Confluence URL. Confluence URLs typically follow these patterns:
- `https://{site}.atlassian.net/wiki/spaces/{space}/pages/{pageId}/{title}`
- `https://{site}.atlassian.net/wiki/spaces/{space}/pages/edit-v2/{pageId}`
- `https://{site}.atlassian.net/l/cp/{shortId}`

Use regex to extract:
- **Domain**: `{site}.atlassian.net`
- **Space key**: `{space}` (from URL or ask user if ambiguous)
- **Page ID**: `{pageId}` (numeric ID)

### Step 3: Extract Title and Content

Read the markdown file and determine the page title:

**Title extraction from filename** (e.g., `2025-10-16_PROJ-123_implement-auth.md`):
1. Remove date prefix: `2025-10-16_`
2. Extract ticket: `PROJ-123`
3. Convert slug to title: `implement-auth` → `Implement Auth`
4. Format: `PROJ-123: Implement Auth`

**Alternative**: User can provide custom title via `--title` parameter.

Read the markdown content:
```bash
cat <markdown-file-path>
```

### Step 4: Verify Atlassian MCP Access

Check if Atlassian MCP tools are available by listing available tools.

Required MCP tools:
- `mcp_atlassian_atl_getConfluencePage` - To validate parent page
- `mcp_atlassian_atl_createConfluencePage` - To create child page (if available)
- Or alternative creation methods via MCP

If MCP tools are not available, inform the user:
```
❌ Atlassian MCP server not configured

To use this feature, you need to:
1. Install the Atlassian MCP server in Claude Code
2. Configure authentication (SSE or Personal Access Token)
3. Ensure you have permission to create pages in the target space

See: https://docs.claude.com/mcp for MCP setup instructions
```

### Step 5: Validate Parent Page Access

Use the Atlassian MCP to verify you can access the parent page:
```
mcp_atlassian_atl_getConfluencePage(pageId: <extracted-page-id>)
```

This validates:
- Page exists
- User has read access
- Space is accessible

If access fails, report the error to the user with specific details.

### Step 6: Convert Markdown to Confluence Format

Confluence uses its own storage format (similar to HTML but with specific Confluence macros).

Basic conversion approach:
1. **Headers**: `# Title` → `<h1>Title</h1>`
2. **Bold**: `**text**` → `<strong>text</strong>`
3. **Italic**: `*text*` → `<em>text</em>`
4. **Code blocks**: ` ```language\ncode\n``` ` → `<ac:structured-macro ac:name="code">...</ac:structured-macro>`
5. **Lists**: Convert markdown lists to HTML `<ul>/<ol>` structure
6. **Links**: `[text](url)` → `<a href="url">text</a>`

Alternatively, check if MCP provides a markdown conversion utility.

### Step 7: Create Child Page in Confluence

Use the Atlassian MCP to create the child page:

```
mcp_atlassian_atl_createConfluencePage({
  spaceKey: <space-key>,
  parentId: <parent-page-id>,
  title: <extracted-title>,
  body: {
    storage: {
      value: <converted-html-content>,
      representation: "storage"
    }
  }
})
```

The MCP should return the created page details including:
- New page ID
- Page URL
- Space key
- Created timestamp

### Step 8: Report Success

Display results to the user:

```
✅ Successfully published to Confluence!

Page Title: PROJ-123: Implement Auth
Page URL: https://mycompany.atlassian.net/wiki/spaces/DOCS/pages/987654321/PROJ-123+Implement+Auth

Parent Page: AI Use Cases Documentation
Space: DOCS

Actions:
- Created child page under parent
- Published <file-size>KB of content
- Added AI use case documentation
```

If publishing fails, provide detailed error information:
- Authentication issues
- Permission errors
- API rate limits
- Invalid content format

## Key Principles

1. **Be Automatic**: Don't ask for details you can extract or infer
2. **Be Validated**: Check all prerequisites before attempting publish
3. **Be Secure**: Never expose credentials, use MCP auth
4. **Be Helpful**: Provide clear error messages with solutions
5. **Be Complete**: Include full content with proper formatting

## Command Parameters

When invoked via CLI, expect these parameters:

```bash
ai-use-case publish-confluence [options] <markdown-file> <parent-page-url>

Options:
  --title <title>        Override page title (default: from filename)
  --space <space-key>    Confluence space key (default: from URL)
  --dry-run             Show what would be published without doing it
```

## Example Usage

### From CLI
```bash
ai-use-case publish-confluence \
  docs/ai-use-cases/2025-10-16_PROJ-123_implement-auth.md \
  https://mycompany.atlassian.net/wiki/spaces/DOCS/pages/123456789/AI+Use+Cases
```

### From Claude Code
```
/publish-confluence docs/ai-use-cases/2025-10-16_PROJ-123_implement-auth.md https://mycompany.atlassian.net/wiki/spaces/DOCS/pages/123456789/AI+Use+Cases
```

## Error Scenarios

### MCP Not Configured
```
❌ Atlassian MCP not available

This feature requires the Atlassian MCP server.
Please configure it in Claude Code settings.
```

### Invalid URL
```
❌ Invalid Confluence URL

Expected format: https://{site}.atlassian.net/wiki/spaces/{space}/pages/{pageId}/...
Provided: <invalid-url>
```

### Permission Denied
```
❌ Permission denied

You don't have permission to create pages in this space.
Contact your Confluence administrator to request access.
```

### File Not Found
```
❌ Markdown file not found

File: <file-path>
Please verify the path is correct.
```

## Dry Run Mode

When `--dry-run` is specified, show what would be published without actually doing it:

```
🔍 Dry Run - Publishing Preview

Source File: docs/ai-use-cases/2025-10-16_PROJ-123_implement-auth.md
File Size: 15.3 KB
Page Title: PROJ-123: Implement Auth

Target:
- Parent Page ID: 123456789
- Parent Title: AI Use Cases Documentation
- Space: DOCS
- Domain: mycompany.atlassian.net

Content Preview:
================================================================================
# PROJ-123: Implement Auth

## Metadata
- Date: 2025-10-16
- Ticket: PROJ-123
- AI Tool: Claude Code (Sonnet 4.5)
...
================================================================================

✓ Validation passed
✓ Parent page accessible
✓ Markdown converted successfully

Run without --dry-run to publish.
```

## Reference

- Atlassian MCP Documentation: https://docs.claude.com/mcp/atlassian
- Confluence API: https://developer.atlassian.com/cloud/confluence/rest/v2/
- Confluence Storage Format: https://confluence.atlassian.com/doc/confluence-storage-format-790796544.html
