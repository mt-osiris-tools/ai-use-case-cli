# Confluence Integration Guide

This guide explains how to configure and use the Confluence publishing feature to share AI use case documentation with your team.

## Overview

The AI Use Case CLI supports multiple ways to publish documentation to Confluence:

1. **REST API with API Token** (Universal) - Works with any AI tool or manual invocation
2. **Atlassian MCP Server** (AI Assistants) - For Claude Code and other MCP-enabled tools
3. **OAuth** (Enterprise) - For organization-wide integrations

## Quick Start

### Option 1: REST API (Recommended for Most Users)

**Step 1: Generate API Token**

1. Visit: `https://id.atlassian.com/manage-profile/security/api-tokens`
   - Or: `https://{your-site}.atlassian.net/wiki/people/me/preferences/personal-access-tokens`
2. Click "Create API token"
3. Give it a descriptive name (e.g., "AI Use Case CLI")
4. Copy the token (you won't be able to see it again)

**Step 2: Configure CLI**

```bash
ai-use-case config confluence
```

You'll be prompted for:
- **Confluence base URL**: `https://your-company.atlassian.net`
- **Your email**: The email associated with your Confluence account
- **API token**: Paste the token from Step 1

**Step 3: Test Publishing**

```bash
# Dry run to preview
ai-use-case publish-confluence --dry-run \
  .usecase/cases/2025-W45-11-16_FEATURE-001_my-feature.md \
  https://your-company.atlassian.net/wiki/spaces/DOCS/pages/123456/Parent

# Actual publish
ai-use-case publish-confluence \
  .usecase/cases/2025-W45-11-16_FEATURE-001_my-feature.md \
  https://your-company.atlassian.net/wiki/spaces/DOCS/pages/123456/Parent
```

### Option 2: MCP Server (AI Assistants)

If you're using Claude Code or another MCP-enabled AI assistant:

**Step 1: Configure MCP**

Follow your AI tool's documentation to add the Atlassian MCP server.

For Claude Code:
```bash
claude mcp add --transport sse atlassian https://mcp.atlassian.com/v1/sse
```

**Step 2: Authenticate**

Follow the OAuth flow to grant access to your Confluence site.

**Step 3: Use Slash Command**

In your AI assistant:
```
/publish-confluence .usecase/cases/2025-W45-11-16_FEATURE-001_my-feature.md https://your-company.atlassian.net/wiki/spaces/DOCS/pages/123456/Parent
```

The AI assistant will automatically handle the publishing using MCP tools.

## Configuration Methods

### Method 1: Configuration File (Persistent)

Store credentials in `~/.config/ai-use-case-cli/config.json`:

```bash
ai-use-case config confluence
```

**Advantages:**
- Persistent across sessions
- Automatically used by CLI
- Secure file permissions (600)

**Security Note:** The config file contains your API token. Never commit it to version control.

### Method 2: Environment Variables (Temporary)

Set environment variables in your shell:

```bash
export CONFLUENCE_BASE_URL="https://your-company.atlassian.net"
export CONFLUENCE_EMAIL="you@company.com"
export CONFLUENCE_API_TOKEN="your-token-here"
```

Add to `~/.bashrc` or `~/.zshrc` for persistence.

**Advantages:**
- No config file needed
- Easy to use in CI/CD
- Can override config file

### Method 3: Command-Line Options (One-Time)

Pass credentials directly:

```bash
scripts/core/publish-confluence.sh \
  --base-url "https://your-company.atlassian.net" \
  --email "you@company.com" \
  --api-token "your-token-here" \
  .usecase/cases/my-case.md \
  https://your-company.atlassian.net/wiki/spaces/DOCS/pages/123456/Parent
```

**Advantages:**
- One-time usage
- Useful for testing
- Highest precedence

## Usage Examples

### Basic Publishing

```bash
# Publish with auto-generated title from filename
ai-use-case publish-confluence \
  .usecase/cases/2025-W45-11-16_FEATURE-001_implement-auth.md \
  https://company.atlassian.net/wiki/spaces/DOCS/pages/123456/AI-Use-Cases
```

### Custom Title

```bash
# Override the auto-generated title
ai-use-case publish-confluence \
  --title "FEATURE-001: Complete Authentication Implementation" \
  .usecase/cases/2025-W45-11-16_FEATURE-001_implement-auth.md \
  https://company.atlassian.net/wiki/spaces/DOCS/pages/123456/AI-Use-Cases
```

### Dry Run

```bash
# Preview what would be published without actually publishing
ai-use-case publish-confluence --dry-run \
  .usecase/cases/2025-W45-11-16_FEATURE-001_implement-auth.md \
  https://company.atlassian.net/wiki/spaces/DOCS/pages/123456/AI-Use-Cases
```

### Different Space

```bash
# Publish to a different space (override URL space)
ai-use-case publish-confluence \
  --space "ENGINEERING" \
  .usecase/cases/2025-W45-11-16_FEATURE-001_implement-auth.md \
  https://company.atlassian.net/wiki/spaces/DOCS/pages/123456/AI-Use-Cases
```

## Supported Confluence URL Formats

The CLI automatically parses various Confluence URL formats:

```
# Standard page view URL
https://{site}.atlassian.net/wiki/spaces/{space}/pages/{pageId}/{title}

# Edit page URL
https://{site}.atlassian.net/wiki/spaces/{space}/pages/edit-v2/{pageId}

# Short link (extracts page ID)
https://{site}.atlassian.net/l/cp/{shortId}
```

The CLI extracts:
- **Domain**: `{site}.atlassian.net`
- **Space Key**: `{space}`
- **Page ID**: `{pageId}` (used as parent page)

## Title Generation

The CLI automatically generates page titles from filenames:

**Filename Pattern:** `YYYY-Www-MM-DD_TICKET-XXX_description-slug.md`

**Example:**
- **Input:** `2025-W45-11-16_FEATURE-001_implement-auth.md`
- **Generated Title:** `🎯 2025 W45 | FEATURE-001: Implement Auth`

**Components:**
- `🎯` - Visual indicator
- `2025 W45` - Year and week number
- `FEATURE-001` - Ticket/issue ID
- `Implement Auth` - Humanized description

You can override this with `--title`:

```bash
ai-use-case publish-confluence \
  --title "My Custom Title" \
  .usecase/cases/2025-W45-11-16_FEATURE-001_implement-auth.md \
  ...
```

## Markdown to Confluence Conversion

The CLI converts markdown to Confluence storage format:

| Markdown | Confluence Storage |
|----------|-------------------|
| `# Heading 1` | `<h1>Heading 1</h1>` |
| `## Heading 2` | `<h2>Heading 2</h2>` |
| `**bold**` | `<strong>bold</strong>` |
| `*italic*` | `<em>italic</em>` |
| `[link](url)` | `<a href="url">link</a>` |
| Code blocks | `<ac:structured-macro ac:name="code">...` |

**Note:** The current implementation provides basic conversion. For complex markdown (tables, images, etc.), you may need to format manually in Confluence after publishing.

## AI Tool Integration

### Works With Any AI Coding Assistant

The publish-confluence command is AI-tool-agnostic:

✅ **Claude Code** - Via MCP or REST API
✅ **GitHub Copilot** - Via REST API
✅ **Cursor** - Via REST API
✅ **Cody** - Via REST API
✅ **Any AI Tool** - Via REST API
✅ **Manual/Scripts** - Via REST API

### Integration Detection

The system automatically detects available methods:

1. **Check for MCP tools** - If AI assistant has Atlassian MCP configured
2. **Check for REST API credentials** - Config file, env vars, or CLI options
3. **Prompt user** - If neither available

### For AI Assistants

When an AI assistant invokes the publish-confluence command:

1. It checks if it has MCP tools available
2. If yes, uses MCP for seamless publishing
3. If no, falls back to REST API using user's configured credentials
4. If neither, provides setup instructions

## Security Best Practices

### API Token Security

✅ **DO:**
- Store tokens in config file with restrictive permissions (600)
- Use environment variables in CI/CD
- Rotate tokens periodically
- Use descriptive token names
- Revoke unused tokens

❌ **DON'T:**
- Commit tokens to version control
- Share tokens via email/chat
- Use the same token across multiple services
- Store tokens in plain text scripts

### Config File Permissions

The CLI automatically sets secure permissions:

```bash
# Config file permissions (owner read/write only)
chmod 600 ~/.config/ai-use-case-cli/config.json
```

**Check permissions:**
```bash
ls -la ~/.config/ai-use-case-cli/config.json
# Should show: -rw------- (600)
```

### Token Rotation

To update your API token:

```bash
# Reconfigure (prompts for new token)
ai-use-case config confluence

# Or manually edit config
vim ~/.config/ai-use-case-cli/config.json
```

### Revoking Access

To revoke a token:

1. Visit: `https://id.atlassian.com/manage-profile/security/api-tokens`
2. Find the token by name
3. Click "Revoke"

After revoking, reconfigure the CLI with a new token.

## Troubleshooting

### Error: "No REST API credentials configured"

**Solution:** Configure credentials using one of the methods above:
```bash
ai-use-case config confluence
```

### Error: "Invalid Confluence URL"

**Cause:** URL doesn't match expected format

**Solution:** Use one of these formats:
- `https://{site}.atlassian.net/wiki/spaces/{space}/pages/{pageId}/...`
- `https://{site}.atlassian.net/wiki/spaces/{space}/pages/edit-v2/{pageId}`

### Error: "Permission denied"

**Cause:** Your account doesn't have permission to create pages in the space

**Solution:**
1. Contact your Confluence administrator
2. Request "Can add" permission in the target space
3. Or use a different parent page in a space where you have permission

### Error: "Authentication failed"

**Causes:**
- Invalid API token
- Incorrect email
- Token revoked or expired

**Solutions:**
1. Verify credentials: `ai-use-case config confluence show`
2. Generate new token and reconfigure
3. Check email matches your Confluence account

### Error: "Markdown file not found"

**Cause:** File path is incorrect or file doesn't exist

**Solution:**
```bash
# Check file exists
ls -la .usecase/cases/your-file.md

# Use absolute path if needed
ai-use-case publish-confluence \
  /full/path/to/file.md \
  https://...
```

### Config File Issues

**Reset configuration:**
```bash
rm ~/.config/ai-use-case-cli/config.json
ai-use-case config confluence
```

**View current config:**
```bash
ai-use-case config show
ai-use-case config confluence show
```

## Advanced Usage

### CI/CD Integration

Use environment variables in CI/CD pipelines:

```yaml
# GitHub Actions example
- name: Publish to Confluence
  env:
    CONFLUENCE_BASE_URL: ${{ secrets.CONFLUENCE_BASE_URL }}
    CONFLUENCE_EMAIL: ${{ secrets.CONFLUENCE_EMAIL }}
    CONFLUENCE_API_TOKEN: ${{ secrets.CONFLUENCE_API_TOKEN }}
  run: |
    ai-use-case publish-confluence \
      .usecase/cases/latest-release.md \
      ${{ vars.CONFLUENCE_PARENT_URL }}
```

### Batch Publishing

Publish multiple files:

```bash
#!/bin/bash
PARENT_URL="https://company.atlassian.net/wiki/spaces/DOCS/pages/123456/AI-Cases"

for file in .usecase/cases/*.md; do
  echo "Publishing: $file"
  ai-use-case publish-confluence "$file" "$PARENT_URL"
  sleep 2  # Rate limiting
done
```

### Custom Processing

Pre-process markdown before publishing:

```bash
#!/bin/bash
# Add custom header
cat header.md original.md > processed.md

# Publish processed version
ai-use-case publish-confluence processed.md $PARENT_URL

# Cleanup
rm processed.md
```

## FAQ

**Q: Can I publish to Confluence Server (on-premise)?**
A: The current implementation targets Confluence Cloud. For Server, you may need to adjust the API endpoints in the script.

**Q: Does this work with Confluence Data Center?**
A: Similar to Server, you may need to adapt API endpoints. The REST API v2 should be compatible with modern Data Center versions.

**Q: Can I update existing pages instead of creating new ones?**
A: Currently, the CLI always creates new child pages. Update functionality is planned for a future release.

**Q: What about images and attachments?**
A: Basic markdown conversion is supported. Images and attachments should be uploaded separately or linked externally.

**Q: Can I customize the page template?**
A: Custom templates are not yet supported. Pages use the default Confluence template for the space.

**Q: How do I delete pages created by mistake?**
A: Navigate to the page in Confluence and use the "..." menu → "Delete". Or use Confluence's bulk operations.

**Q: Can multiple users share the same API token?**
A: No. Each user should have their own API token for auditing and access control.

**Q: Does this support Confluence permissions?**
A: The CLI respects existing Confluence permissions. Published pages inherit the parent page's permissions.

## Related Documentation

- [Commands Reference](COMMANDS.md) - All CLI commands
- [Confluence Design](CONFLUENCE-DESIGN.md) - Technical design details
- [Claude Code Integration](CLAUDE.md) - AI assistant integration

## Support

For issues, questions, or feature requests:
- GitHub Issues: https://github.com/mt-osiris-tools/ai-use-case-cli/issues
- Documentation: https://github.com/mt-osiris-tools/ai-use-case-cli/tree/main/docs

## Version History

- **v3.7.0** - AI-tool-agnostic refactor, REST API support added
- **v3.6.0** - Initial MCP-based publishing (Claude Code only)
