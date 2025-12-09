---
description: Publish AI use case documentation to Confluence as a child page
argument-hint: [FILE=<markdown-file>] [PARENT_URL=<confluence-url>] [DRY_RUN=true]
---

# Publish to Confluence - Codex CLI

**OpenAI Codex Integration**: This command publishes AI use case documentation to Confluence using the REST API via shell scripts.

## Parameters

- **$FILE** (optional): Path to the markdown file to publish
  - If not provided, prompt the user to select from `.usecase/cases/`
- **$PARENT_URL** (optional): Confluence parent page URL
  - If not provided, prompt the user for the URL
- **$DRY_RUN** (optional): Set to "true" for preview mode without publishing

## Your Task

Publish an AI use case documentation file to Confluence as a child page under the specified parent page URL.

## Prerequisites

Before proceeding, verify:
1. User has provided or will provide:
   - Markdown file path ($FILE or interactive selection)
   - Confluence parent page URL ($PARENT_URL or interactive input)
2. REST API credentials are configured (via config file or environment variables)

## Automatic Publishing Workflow

### Step 0: Handle Parameters (Hybrid Approach)

**If $FILE is provided:**
- Use it directly: `$FILE`
- Validate the file exists

**If $FILE is NOT provided:**
- List available documentation files:
  ```bash
  ls -1 .usecase/cases/*.md 2>/dev/null | head -20
  ```
- Ask the user to select which file to publish

**If $PARENT_URL is provided:**
- Use it directly: `$PARENT_URL`

**If $PARENT_URL is NOT provided:**
- Ask the user for the Confluence parent page URL
- Expected format: `https://{site}.atlassian.net/wiki/spaces/{space}/pages/{pageId}/{title}`

### Step 1: Validate Inputs

Check that the markdown file exists and is readable:
```bash
ls -la <markdown-file-path>
```

If file doesn't exist, inform the user and exit.

### Step 2: Check REST API Configuration

Verify Confluence API credentials are available:
```bash
# Check for configuration file
if [ -f ~/.config/ai-use-case-cli/config.json ]; then
    echo "Config file found"
    cat ~/.config/ai-use-case-cli/config.json | grep -q "confluence" && echo "Confluence configured"
fi

# Check for environment variables
[ -n "$CONFLUENCE_API_TOKEN" ] && echo "API token set"
[ -n "$CONFLUENCE_BASE_URL" ] && echo "Base URL set"
[ -n "$CONFLUENCE_EMAIL" ] && echo "Email set"
```

**If credentials not configured**, inform the user:
```
No Confluence credentials configured.

Please configure using one of these methods:

Option 1: Environment variables
  export CONFLUENCE_API_TOKEN="your-api-token"
  export CONFLUENCE_BASE_URL="https://yoursite.atlassian.net"
  export CONFLUENCE_EMAIL="your-email@example.com"

Option 2: Configuration file
  Run: ai-use-case config confluence

Generate API token at:
  https://{site}.atlassian.net/wiki/people/{userId}/preferences/personal-access-tokens
```

### Step 3: Parse Parent Page URL

Extract components from the Confluence URL. Supported patterns:
- `https://{site}.atlassian.net/wiki/spaces/{space}/pages/{pageId}/{title}`
- `https://{site}.atlassian.net/wiki/spaces/{space}/pages/edit-v2/{pageId}`

Extract:
- **Domain**: `{site}.atlassian.net`
- **Space key**: `{space}`
- **Page ID**: `{pageId}` (numeric ID)

### Step 4: Extract Title from Filename

Read the markdown file and determine the page title from filename.

**Title extraction** (e.g., `2025-W42-10-16_PROJ-123_implement-auth.md`):
1. Extract year and week: `2025` and `W42`
2. Extract ticket: `PROJ-123`
3. Convert slug to title: `implement-auth` → `Implement Auth`
4. Format: `🎯 2025 W42 | PROJ-123: Implement Auth`

```bash
# Example title extraction
FILENAME=$(basename "<markdown-file>")
# Parse components and format title
```

### Step 5: Preview or Publish

**If $DRY_RUN is "true":**
Show preview without publishing:
```bash
scripts/core/publish-confluence.sh \
  --markdown "<markdown-file>" \
  --parent-url "<parent-url>" \
  --dry-run
```

**If publishing (no dry-run):**
```bash
scripts/core/publish-confluence.sh \
  --markdown "<markdown-file>" \
  --parent-url "<parent-url>"
```

The shell script will:
1. Read API credentials from configuration or environment
2. Convert markdown to Confluence storage format
3. Use REST API to create the page
4. Return the created page URL

### Step 6: Report Results

**On Success:**
```
✅ Successfully published to Confluence!

Page Title: 🎯 2025 W42 | PROJ-123: Implement Auth
Page URL: https://mycompany.atlassian.net/wiki/spaces/DOCS/pages/987654321/...

Parent Page: AI Use Cases Documentation
Space: DOCS
```

**On Failure:**
Provide detailed error information with solutions:
- Authentication issues → Check API token
- Permission errors → Contact Confluence admin
- Invalid URL format → Show expected format

## Example Invocations

### With All Parameters (Quick)
```
/prompts:use-case-publish-confluence FILE=.usecase/cases/2025-W42-10-16_PROJ-123_implement-auth.md PARENT_URL="https://mycompany.atlassian.net/wiki/spaces/DOCS/pages/123456789/AI+Use+Cases"
```

### With Dry Run
```
/prompts:use-case-publish-confluence FILE=.usecase/cases/my-doc.md PARENT_URL="https://..." DRY_RUN=true
```

### Interactive (No Parameters)
```
/prompts:use-case-publish-confluence
```
Then follow prompts to select file and provide URL.

## Key Principles

1. **Hybrid Parameters**: Accept optional parameters, prompt if not provided
2. **REST API Only**: Use shell script with REST API (no MCP dependency)
3. **Be Validated**: Check all prerequisites before attempting publish
4. **Be Secure**: Never expose credentials in output
5. **Be Helpful**: Provide clear error messages with solutions

## Error Scenarios

### Missing Credentials
```
❌ No Confluence credentials configured

Please configure via:
  ai-use-case config confluence

Or set environment variables:
  CONFLUENCE_API_TOKEN, CONFLUENCE_BASE_URL, CONFLUENCE_EMAIL
```

### Invalid URL
```
❌ Invalid Confluence URL

Expected: https://{site}.atlassian.net/wiki/spaces/{space}/pages/{pageId}/...
Provided: <invalid-url>
```

### Permission Denied
```
❌ Permission denied

You don't have permission to create pages in this space.
Contact your Confluence administrator to request access.
```

## Reference

- Shell script: `scripts/core/publish-confluence.sh`
- Confluence REST API v2: https://developer.atlassian.com/cloud/confluence/rest/v2/
- Confluence Storage Format: https://confluence.atlassian.com/doc/confluence-storage-format-790796544.html
