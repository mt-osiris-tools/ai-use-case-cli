# Confluence HTML Templates

This directory contains HTML templates for publishing AI use case documentation to Confluence.

## Available Templates

### 1. `use-case-template.html` (Rich Template)
A visually rich template with modern styling, gradients, and interactive elements. Best for standalone Confluence pages where custom styling is supported.

**Features:**
- Gradient header with emoji support
- Metadata grid layout
- Color-coded status indicators
- Interactive timeline
- Styled code blocks
- Metrics dashboard
- Tag system

### 2. `use-case-template-simple.html` (Confluence Native Template)
A simplified template using Confluence's native macros and storage format. More compatible with strict Confluence instances.

**Features:**
- Native Confluence macros (info, panel, status, toc)
- Structured macro support
- Expandable sections
- Built-in table of contents
- Attachment support
- Label/tag integration

## Template Placeholders

All templates support the following placeholders that will be replaced with actual content.

> **Note:** While most placeholders are common to both templates, some are template-specific:
> - **Rich Template Only:** Uses `{{STATUS_CLASS}}` for CSS styling and `{{AI_TOOLS_BADGES}}` for visual badges
> - **Simple Template Only:** Uses `{{STATUS_COLOR}}` for Confluence macros, `{{PROJECT_NAME}}`, `{{AUTHOR}}`, `{{AI_TOOLS_LIST}}`, `{{SUCCESS_RATE}}`, and `{{ATTACHMENTS}}`
> - Both templates handle missing placeholders gracefully with default values

### Page Metadata
- `{{PAGE_TITLE}}` - Full page title including week number (e.g., "Week 45 | LSFB-123: Feature Implementation")
- `{{PAGE_EMOJI}}` - Emoji indicator (default: 🎯)
- `{{PAGE_DESCRIPTION}}` - Brief description of the use case
- `{{WEEK_NUMBER}}` - Week number (e.g., "Week 45")
- `{{DATE}}` - Full date (e.g., "2025-11-09")
- `{{TICKET_ID}}` - Ticket identifier (e.g., "LSFB-123")
- `{{TICKET_URL}}` - Link to ticket in issue tracker
- `{{STATUS}}` - Current status (e.g., "Completed", "In Progress")
- `{{STATUS_COLOR}}` - Status color for Confluence macro (Green, Yellow, Red)
- `{{STATUS_CLASS}}` - CSS class for status (completed, in-progress)
- `{{PROJECT_NAME}}` - Name of the project
- `{{AUTHOR}}` - Document author

### Content Sections
- `{{EXECUTIVE_SUMMARY}}` - Brief summary of the use case
- `{{CONTEXT_CONTENT}}` - Context and objectives (supports HTML)
- `{{IMPLEMENTATION_CONTENT}}` - Implementation details (supports HTML)
- `{{CODE_EXAMPLES}}` - Code snippets (plain text or formatted)
- `{{CODE_LANGUAGE}}` - Programming language for syntax highlighting
- `{{CHALLENGES_TABLE_ROWS}}` - HTML table rows for challenges
- `{{KEY_LEARNINGS_LIST}}` - HTML list items for learnings
- `{{PROMPTS_CONTENT}}` - Effective prompts and techniques (supports HTML)

### AI Tools
- `{{AI_TOOLS_BADGES}}` - HTML div elements for tool badges
- `{{AI_TOOLS_LIST}}` - HTML list items for tools used

### Metrics
- `{{TIME_SAVED}}` - Time saved estimate
- `{{LINES_OF_CODE}}` - Lines of code generated
- `{{ITERATIONS}}` - Number of AI iterations
- `{{SUCCESS_RATE}}` - Success rate percentage

### Timeline (Optional)
- `{{TIMELINE_ITEMS}}` - HTML div elements for timeline events
- Use `{{#if TIMELINE_ITEMS}}...{{/if}}` to conditionally show section

### Resources & Links
- `{{RELATED_RESOURCES}}` - HTML list items for related links
- `{{TAGS_LIST}}` - HTML span elements for tags
- `{{CONFLUENCE_LABELS}}` - Comma-separated Confluence labels

### System Information
- `{{CLI_VERSION}}` - AI Use Case CLI version
- `{{LAST_UPDATED}}` - Last update timestamp
- `{{ORIGINAL_MARKDOWN}}` - Original markdown content

### Optional Sections
- `{{ATTACHMENTS}}` - Use with `{{#if ATTACHMENTS}}...{{/if}}`

## Usage Examples

### Week Number in Title
When processing a file named `2025-W45-11-08_DEMO-123_implement-feature.md`:
1. The processor extracts week "W45" from the filename
2. Converts it to "Week 45" for display
3. Generates PAGE_TITLE as "Week 45 | DEMO-123: Implement Feature"
4. Both templates display this in `<title>` tag and main `<h1>` heading

**Result in HTML:**
```html
<title>Week 45 | DEMO-123: Implement Feature</title>
<h1>🎯 Week 45 | DEMO-123: Implement Feature</h1>
```

### Basic Replacement
```javascript
const template = fs.readFileSync('use-case-template.html', 'utf8');
const html = template
  .replace('{{PAGE_TITLE}}', 'Week 45 | LSFB-123: Feature Implementation')
  .replace('{{WEEK_NUMBER}}', 'Week 45')
  .replace('{{DATE}}', '2025-11-09')
  .replace('{{TICKET_ID}}', 'LSFB-123');
```

### Conditional Sections
Templates support conditional rendering using Handlebars-style syntax:
```html
{{#if CODE_EXAMPLES}}
<h2>Code Examples</h2>
<pre>{{CODE_EXAMPLES}}</pre>
{{/if}}
```

### Table Rows Example
For `{{CHALLENGES_TABLE_ROWS}}`:
```html
<tr>
    <td>Complex regex pattern needed</td>
    <td>Used AI to generate and validate pattern</td>
    <td>Claude provided working regex with explanation</td>
</tr>
<tr>
    <td>Performance optimization required</td>
    <td>AI suggested caching strategy</td>
    <td>GPT-4 analyzed bottlenecks and provided solutions</td>
</tr>
```

### Tool Badges Example
For `{{AI_TOOLS_BADGES}}`:
```html
<div class="tool-badge">Claude 3.5 Sonnet</div>
<div class="tool-badge">GitHub Copilot</div>
<div class="tool-badge">GPT-4</div>
```

## Integration with publish-confluence.sh

The templates can be integrated into the publishing workflow by:

1. **Reading the markdown file** and extracting metadata
2. **Parsing the content** into appropriate sections
3. **Loading the template** and replacing placeholders
4. **Converting to Confluence storage format** if needed
5. **Publishing via Atlassian MCP**

### Template Selection Logic
```bash
# Default to simple template for better compatibility
TEMPLATE="use-case-template-simple.html"

# Allow override via environment variable
if [ -n "$CONFLUENCE_TEMPLATE" ]; then
    TEMPLATE="$CONFLUENCE_TEMPLATE"
fi

# Or via command-line flag
if [ "$1" == "--rich-template" ]; then
    TEMPLATE="use-case-template.html"
fi
```

## Customization

### Adding New Placeholders
1. Add placeholder to template: `{{NEW_PLACEHOLDER}}`
2. Document in this README
3. Update replacement logic in publish script

### Creating Custom Templates
1. Copy an existing template as base
2. Modify HTML structure and styling
3. Maintain same placeholder naming convention
4. Test with Confluence API

## Confluence Compatibility Notes

### Rich Template (`use-case-template.html`)
- Uses inline CSS styling
- May require Confluence HTML macro
- Best for Cloud instances with custom HTML support
- Visual elements may not render in all Confluence versions

### Simple Template (`use-case-template-simple.html`)
- Uses Confluence native macros
- Compatible with Server and Data Center
- Follows Confluence storage format
- Guaranteed compatibility

## Testing Templates

### Local Preview
```bash
# Generate test HTML
sed 's/{{PAGE_TITLE}}/Test Page/g' use-case-template.html > test.html
# Open in browser
open test.html
```

### Confluence Preview
Use the Confluence API to create a draft page and preview before publishing.

## Future Enhancements

- [ ] Template validation script
- [ ] Automatic placeholder extraction from markdown
- [ ] Template preview command
- [ ] Custom CSS theme support
- [ ] Mobile-responsive templates
- [ ] PDF export optimization
- [ ] Template versioning system

## Contributing

When adding new templates:
1. Follow existing placeholder naming convention
2. Include both rich and simple versions
3. Update this README with new placeholders
4. Test with actual Confluence instance
5. Consider backwards compatibility