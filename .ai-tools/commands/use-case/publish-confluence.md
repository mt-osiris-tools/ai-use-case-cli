# Publish to Confluence - Automatic Mode

**AI-Tool-Agnostic**: This command works with any AI coding assistant (Claude Code, GitHub Copilot, etc.) or can be invoked directly via shell script. The system automatically detects the best available integration method.

## Your Task

Automatically publish an AI use case documentation file to Confluence as a child page under the specified parent page URL.

## Integration Methods

This command supports multiple Confluence integration approaches:

1. **Atlassian MCP Server** (preferred for MCP-enabled AI assistants)
   - Used by Claude Code and potentially other AI tools
   - Requires MCP tools like `mcp_atlassian_*`
   - Automatic authentication via MCP

2. **Shell Script with REST API** (universal fallback)
   - Works with any AI tool or manual invocation
   - Uses `scripts/core/publish-confluence.sh`
   - Requires Confluence API token or OAuth configuration

## Prerequisites

Before proceeding, verify:
1. User has provided:
   - Markdown file path
   - Confluence parent page URL
2. At least one integration method is available (MCP server OR API credentials)

## Automatic Publishing Workflow

### Step 0: Detect Integration Method

Check available Confluence integration methods in order of preference:

```bash
# Check for MCP tools (if you're an AI assistant with tool access)
# Look for tools like: mcp_atlassian_atl_getConfluencePage, mcp_atlassian_atl_createConfluencePage

# If MCP not available, check for shell script + API credentials
# Check if scripts/core/publish-confluence.sh exists
# Check if user has configured API credentials (via config)
```

**Decision logic**:
- If MCP tools available → Use MCP-based workflow (Steps 4-8)
- If no MCP but API configured → Use shell script workflow
- If neither available → Prompt user to configure one method

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

**Title extraction from filename** (e.g., `2025-W42-10-16_PROJ-123_implement-auth.md`):
1. Extract year and week: `2025` and `W42`
2. Extract ticket: `PROJ-123`
3. Convert slug to title: `implement-auth` → `Implement Auth`
4. Format: `🎯 2025 W42 | PROJ-123: Implement Auth`

**Alternative**: User can provide custom title via `--title` parameter.

Read the markdown content:
```bash
cat <markdown-file-path>
```

### Step 4: Choose Integration Method

**Option A: MCP-Based Integration** (if available)

Check if Atlassian MCP tools are available by listing available tools.

Required MCP tools:
- `mcp_atlassian_atl_getConfluencePage` - To validate parent page
- `mcp_atlassian_atl_createConfluencePage` - To create child page (if available)
- Or alternative creation methods via MCP

If MCP tools are available, proceed with Steps 5-8 using MCP.

**Option B: Shell Script Integration** (universal fallback)

If MCP is not available, use the shell script approach:

```bash
# Invoke the publish script directly
scripts/core/publish-confluence.sh \
  --markdown <markdown-file-path> \
  --parent-url <parent-page-url> \
  --api-token "$CONFLUENCE_API_TOKEN" \
  --base-url "$CONFLUENCE_BASE_URL"
```

The shell script will:
1. Read API credentials from configuration or environment
2. Convert markdown to Confluence storage format
3. Use REST API to create the page
4. Return the created page URL

**If neither method is available**, inform the user:
```
❌ No Confluence integration method available

Please configure one of the following:

Option 1: Atlassian MCP Server (AI assistants with MCP support)
  - Best for: Claude Code and other MCP-enabled AI tools
  - Setup: Configure Atlassian MCP in your AI tool
  - Docs: https://support.atlassian.com/atlassian-rovo-mcp-server/

Option 2: Confluence REST API (universal)
  - Best for: Any AI tool, manual invocation, CI/CD
  - Setup: Configure API token via: ai-use-case config confluence
  - Requires: Confluence API token or OAuth credentials
  - Docs: Run 'ai-use-case config confluence --help'

See docs/CONFLUENCE-INTEGRATION.md for detailed setup instructions.
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

Page Title: 🎯 2025 W42 | PROJ-123: Implement Auth
Page URL: https://mycompany.atlassian.net/wiki/spaces/DOCS/pages/987654321/2025+W42+PROJ-123+Implement+Auth

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

1. **Be AI-Tool-Agnostic**: Work with any AI assistant or manual invocation
2. **Be Automatic**: Don't ask for details you can extract or infer
3. **Be Adaptive**: Detect and use the best available integration method
4. **Be Validated**: Check all prerequisites before attempting publish
5. **Be Secure**: Never expose credentials, use secure auth methods
6. **Be Helpful**: Provide clear error messages with solutions
7. **Be Complete**: Include full content with proper formatting

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
  .usecase/cases/2025-W42-10-16_PROJ-123_implement-auth.md \
  https://mycompany.atlassian.net/wiki/spaces/DOCS/pages/123456789/AI+Use+Cases
```

### From Claude Code
```
/publish-confluence .usecase/cases/2025-W42-10-16_PROJ-123_implement-auth.md https://mycompany.atlassian.net/wiki/spaces/DOCS/pages/123456789/AI+Use+Cases
```

## Error Scenarios

### No Integration Method Available
```
❌ No Confluence integration method configured

Please choose one:

1. MCP Server (for MCP-enabled AI assistants):
   Configure Atlassian MCP in your AI tool settings

2. REST API (universal):
   Run: ai-use-case config confluence
   Provide your Confluence API token and base URL

See: docs/CONFLUENCE-INTEGRATION.md
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

Source File: .usecase/cases/2025-W42-10-16_PROJ-123_implement-auth.md
File Size: 15.3 KB
Page Title: 🎯 2025 W42 | PROJ-123: Implement Auth

Target:
- Parent Page ID: 123456789
- Parent Title: AI Use Cases Documentation
- Space: DOCS
- Domain: mycompany.atlassian.net

Content Preview:
================================================================================
# 🎯 2025 W42 | PROJ-123: Implement Auth

## Metadata
- Date: 2025-W42-10-16
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

### Integration Methods
- Local Setup Guide: `docs/CONFLUENCE-INTEGRATION.md`
- Atlassian MCP Setup: <https://support.atlassian.com/atlassian-rovo-mcp-server/>
- Confluence REST API v2: <https://developer.atlassian.com/cloud/confluence/rest/v2/>
- Confluence Storage Format: <https://confluence.atlassian.com/doc/confluence-storage-format-790796544.html>

### Authentication Options
- **MCP**: Handled by AI tool's MCP server configuration
- **API Token**: Generate at `https://{site}.atlassian.net/wiki/people/{userId}/preferences/personal-access-tokens`
- **OAuth**: For enterprise integrations (see Confluence API docs)
