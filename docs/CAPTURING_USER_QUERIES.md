# Capturing User Queries from Claude Sessions

## Overview

This guide explains how to capture, export, and document user queries/prompts from Claude Code and other AI tool sessions for analysis, statistics, and knowledge sharing.

---

## What Data is Available?

### Claude Code (VS Code Extension)

**During Active Session:**
- ✅ All user messages visible in chat panel
- ✅ All AI responses visible
- ✅ Full conversation context
- ✅ Tool uses and results
- ✅ Timestamps (relative)

**After Session:**
- ⚠️ Limited - Conversation history is NOT permanently stored by default
- ⚠️ Sessions may be cleared when VS Code restarts
- ⚠️ No built-in export feature (as of now)

**Storage Locations:**
```
~/.config/Code/User/globalStorage/state.vscdb  # VS Code state database
~/.config/Code/User/workspaceStorage/          # Per-workspace data
~/.config/Code/logs/                           # Extension logs (limited)
```

### GitHub Copilot Chat

**During Session:**
- ✅ All chat history visible in panel
- ✅ Code suggestions and completions tracked

**After Session:**
- ✅ Better persistence than Claude Code
- ✅ History persists across restarts
- ⚠️ Limited export options

**Storage:**
```
~/.config/Code/User/globalStorage/github.copilot-chat/
```

---

## Methods to Capture User Queries

### Method 1: Real-Time Manual Capture (RECOMMENDED)

**During the session, keep notes:**

Create a scratch file:
```bash
touch ~/claude-session-$(date +%Y%m%d-%H%M).md
```

**Document as you go:**
```markdown
## Session: LSFB-12345 - 2025-10-31 14:30

### Query 1 (14:32)
"Create a JWT authentication service following the __invoke pattern"

**AI Response:** Created GenerateJwtTokenService.php with...
**Tools Used:** Write, Read (3 files), Bash (composer)
**Result:** Service created successfully

### Query 2 (14:45)
"Write unit tests for this service"

**AI Response:** Generated 4 test cases covering...
**Tools Used:** Write, Bash (phpunit)
**Result:** 4/4 tests passing

### Query 3 (14:52)
"The token expiration isn't being validated correctly"

**AI Response:** Fixed validation logic in line 47...
**Tools Used:** Edit, Bash (phpunit)
**Iterations:** 2 (first fix incomplete)
**Result:** Fixed after second iteration
```

**Advantages:**
- ✅ Immediate capture (nothing lost)
- ✅ Add context AI can't provide
- ✅ Note your thought process
- ✅ Track iterations and refinements

**Disadvantages:**
- ⏱️ Requires discipline during session
- ⏱️ Takes extra time

---

### Method 2: Copy/Paste from Chat Panel

**During or immediately after session:**

1. Select all text in Claude Code chat panel
2. Copy (Ctrl+C / Cmd+C)
3. Paste into a new document

**Format the output:**
```markdown
## Raw Conversation Export
Date: 2025-10-31 14:30
Session: LSFB-12345

---

[USER - 14:32]
Create a JWT authentication service following the __invoke pattern

[CLAUDE - 14:33]
I'll create a JWT authentication service following the Symfony __invoke pattern...
[Tool: Write] symfony/src/MedTrainer/AuthBundle/Service/GenerateJwtTokenService.php
[Tool: Bash] kool run phpunit...

[USER - 14:45]
Write unit tests for this service

[CLAUDE - 14:46]
I'll create comprehensive unit tests...
```

**Advantages:**
- ✅ Complete conversation history
- ✅ Exact wording preserved
- ✅ Shows AI's full responses

**Disadvantages:**
- ⚠️ Manual formatting needed
- ⚠️ Can be very lengthy
- ⚠️ Tool results may be truncated

---

### Method 3: Screenshot Documentation

**For complex sessions or visual reference:**

```bash
# Install screenshot tool if needed
sudo apt install flameshot  # or use built-in screenshot tool
```

**Capture key moments:**
1. Initial prompt and AI's understanding
2. Mid-session pivots or major decisions
3. Final results and summary
4. Error messages and how they were resolved

**Organize screenshots:**
```
docs/ai-use-cases/2025-10-31_LSFB-12345/
├── 01-initial-prompt.png
├── 02-service-created.png
├── 03-test-results.png
└── 04-final-summary.png
```

**Advantages:**
- ✅ Visual context preserved
- ✅ Quick to capture
- ✅ Shows entire screen state

**Disadvantages:**
- ⚠️ Not searchable text
- ⚠️ Larger file sizes
- ⚠️ Harder to extract statistics

---

### Method 4: VS Code Extension - Session Export (Future)

**Note:** This is a feature request for Claude Code extension

**Ideal functionality:**
```
Command Palette → "Claude Code: Export Conversation"
Options:
- Export as Markdown
- Export as JSON (with metadata)
- Include tool uses
- Include timestamps
```

**In the meantime:** Use Methods 1-3

---

### Method 5: Browser Developer Tools (Claude Web)

**If using Claude web interface (claude.ai):**

```javascript
// Open browser console (F12)
// Find conversation data in browser storage

// Copy conversation from DOM
const messages = document.querySelectorAll('.message');
const conversation = Array.from(messages).map(msg => ({
  role: msg.querySelector('.role')?.textContent,
  content: msg.querySelector('.content')?.textContent,
  time: msg.querySelector('.time')?.textContent
}));

console.log(JSON.stringify(conversation, null, 2));
```

**Advantages:**
- ✅ Programmatic extraction
- ✅ Structured data (JSON)

**Disadvantages:**
- ⚠️ Only works for web interface
- ⚠️ DOM structure may change
- ⚠️ Requires technical knowledge

---

## Extracting Statistics from Queries

### Analyzing User Prompts

**Count query types:**
```markdown
### Query Analysis

Total Prompts: 15

**By Type:**
- Implementation requests: 7 (47%)
- Debugging requests: 4 (27%)
- Questions/clarifications: 3 (20%)
- Test requests: 1 (7%)

**Complexity:**
- Simple/direct: 8
- Complex/multi-part: 5
- Clarifications: 2

**Iterations Required:**
- First try successful: 11 (73%)
- Needed refinement: 4 (27%)
```

### Prompt Effectiveness Metrics

**Track which prompts worked best:**

```markdown
### High-Quality Prompts (Got it right first time)

✅ "Create a JWT service following __invoke pattern with unit tests"
   - Clear expectation
   - Referenced project pattern
   - Included testing requirement

✅ "Fix the token expiration validation in GenerateJwtTokenService.php line 47"
   - Specific location
   - Clear problem
   - Fast resolution

### Prompts Needing Iteration

⚠️ "Add authentication"
   - Too vague
   - Required 3 follow-up questions
   - Better: "Add JWT authentication API endpoint with refresh tokens"

⚠️ "Make it better"
   - No context
   - AI had to guess intent
   - Better: "Refactor token validation to reduce code duplication"
```

---

## Conversation Flow Patterns

### Successful Session Pattern

```
1. Clear Initial Request
   └─> AI proposes approach
       └─> User confirms
           └─> AI implements
               └─> Tests pass
                   └─> Done ✅

Prompts: 5
Time: Fast
Iterations: 1
```

### Iterative Refinement Pattern

```
1. Broad Request
   └─> AI asks clarifying questions
       └─> User provides details
           └─> AI implements v1
               └─> User: "Not quite right"
                   └─> AI refines v2
                       └─> Tests pass ✅

Prompts: 8
Time: Medium
Iterations: 2-3
```

### Troubleshooting Pattern

```
1. Implementation works
   └─> User: "Tests fail with error X"
       └─> AI analyzes error
           └─> AI: "I see the issue..."
               └─> AI fixes
                   └─> User: "Still failing"
                       └─> AI debugs further
                           └─> Resolution ✅

Prompts: 12+
Time: Longer
Iterations: 3+
```

**Use this to identify:**
- Which patterns are most efficient
- Where initial prompts could be clearer
- Common bottlenecks

---

## Query Templates for Statistics

### Template 1: Query Log Format

```markdown
## Query Log

| # | Time | Query Summary | Type | Tools | Iterations | Result |
|---|------|---------------|------|-------|------------|--------|
| 1 | 14:32 | Create JWT service | Implement | W, R, B | 1 | ✅ Success |
| 2 | 14:45 | Write unit tests | Test | W, B | 1 | ✅ Success |
| 3 | 14:52 | Fix validation bug | Debug | E, B | 2 | ✅ Fixed |
| 4 | 15:10 | Add refresh token | Feature | W, E, B | 1 | ✅ Success |

**Legend:**
- W = Write, R = Read, E = Edit, B = Bash
- Iterations = Attempts to complete task
```

### Template 2: Detailed Query Card

```markdown
### Query #3: Fix Token Validation

**Time:** 14:52
**Duration:** 8 minutes
**Category:** Debugging

**User Prompt:**
> "The token expiration isn't being validated correctly. Tokens are still
> accepted after they've expired."

**AI Understanding:**
- Identified issue in GenerateJwtTokenService.php:47
- Recognized missing timestamp comparison
- Proposed fix with test validation

**Tools Used:**
1. Read: GenerateJwtTokenService.php
2. Edit: Added expiration check
3. Bash: Ran unit tests (failed)
4. Edit: Fixed time comparison logic
5. Bash: Tests passed ✅

**Iterations:** 2 (first approach had timezone issue)

**Result:** Fixed after correcting UTC handling

**Learning:** Always use UTC for token timestamps
```

### Template 3: Prompt Effectiveness Analysis

```markdown
## Prompt Quality Analysis

### High-Performing Prompts (< 5 min resolution)

**Pattern: Specific + Context + Constraints**

1. ✅ "Create a `GenerateJwtTokenService` with `__invoke()` method that
   takes a User entity and returns a JWT token string. Follow the existing
   service pattern in AuthBundle. Include unit tests."

   **Why it worked:**
   - Named the exact class
   - Specified method signature
   - Referenced existing patterns
   - Included testing requirement

2. ✅ "In `AuthController.php` line 42, change the response status from
   200 to 201 for successful user creation per REST standards."

   **Why it worked:**
   - Exact file and line
   - Clear change request
   - Included reasoning

### Low-Performing Prompts (> 15 min resolution)

**Pattern: Vague + No Context**

1. ⚠️ "Add authentication to the API"

   **Why it struggled:**
   - Too broad (OAuth? JWT? Session?)
   - No requirements specified
   - No reference to existing code
   - Required 4 clarifying exchanges

2. ⚠️ "It's not working"

   **Why it struggled:**
   - No context (what's "it"?)
   - No error details
   - Required investigation time
   - 3 rounds of diagnosis

### Improvement Recommendations

**Before:** "Fix the bug"
**After:** "Fix the SQL error in `UserRepository::findByEmail()` - it's not
escaping single quotes in email addresses"

**Before:** "Make it faster"
**After:** "Optimize `CourseService::getEnrollments()` - currently causing
N+1 queries. Add eager loading for user relationships."

**Before:** "Update the tests"
**After:** "Update `CourseServiceTest.php` to mock the new `EmailService`
dependency we added in line 23"
```

---

## Automated Capture Tools

### Custom VS Code Extension

**Create a simple logger:**

```javascript
// ~/.vscode/extensions/claude-logger/extension.js
const vscode = require('vscode');
const fs = require('fs');

function activate(context) {
  let disposable = vscode.commands.registerCommand(
    'claude-logger.logQuery',
    function () {
      const editor = vscode.window.activeTextEditor;
      const text = editor.document.getText();

      const timestamp = new Date().toISOString();
      const logEntry = `\n## ${timestamp}\n${text}\n---\n`;

      fs.appendFileSync(
        `${process.env.HOME}/claude-queries.log`,
        logEntry
      );

      vscode.window.showInformationMessage('Query logged!');
    }
  );

  context.subscriptions.push(disposable);
}
```

**Usage:**
- Write your prompt in a file
- Run command: "Log Claude Query"
- Prompt saved to ~/claude-queries.log

### Shell Script Logger

```bash
#!/bin/bash
# ~/bin/log-claude-query

LOGFILE="$HOME/claude-queries-$(date +%Y%m%d).md"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "Enter your query (Ctrl+D when done):"
QUERY=$(cat)

cat >> "$LOGFILE" << EOF

## Query - $TIMESTAMP

$QUERY

---
EOF

echo "✅ Query logged to $LOGFILE"
```

**Usage:**
```bash
# Before sending query to Claude
log-claude-query
# [paste or type your query]
# [press Ctrl+D]
```

---

## Integration with AI Use Case CLI

### Enhanced Documentation Template

When running `ai-use-case document`, capture query data:

```markdown
# 2025-10-31_LSFB-12345_jwt-authentication.md

## Session Metadata
- Date: 2025-10-31
- Duration: 2:45
- Prompts: 15

## Key User Queries

### Initial Request (14:32)
**Query:** "Implement JWT authentication for the API with refresh token support"

**AI Understanding:**
- Create token generation service
- Create refresh token service
- Add auth controller endpoints
- Include migrations for token storage
- Write comprehensive tests

**Result:** Correctly understood scope

### Mid-Session Pivot (15:20)
**Query:** "Actually, let's use firebase/php-jwt library instead of raw encoding"

**AI Response:** Switched approach, updated composer dependencies

**Impact:** Saved 1 hour (better library choice)

### Debugging Query (15:45)
**Query:** "Tests failing with 'Token signature invalid' error"

**AI Resolution:** Identified missing secret key in test environment

**Iterations:** 2

## Query Statistics

- Total queries: 15
- Implementation: 7
- Clarifications: 3
- Debugging: 4
- Tests: 1

**Effectiveness:**
- First-try success: 11/15 (73%)
- Required refinement: 4/15 (27%)

**Average response quality:** High (8.5/10)
```

---

## Privacy & Security Considerations

### What to Capture

✅ **Safe to Document:**
- Query topics and types
- General approach discussions
- Tool usage patterns
- Error types (sanitized)
- Learning outcomes

⚠️ **Sanitize Before Documenting:**
- Remove API keys, tokens, passwords
- Redact customer names
- Anonymize PII (emails, SSNs, etc.)
- Replace real usernames with placeholders
- Remove internal URLs/endpoints

❌ **Never Document:**
- Production credentials
- Customer private data
- Security vulnerabilities (before patched)
- Confidential business logic
- Unredacted logs with sensitive info

### Sanitization Example

**Before:**
```
"Fix authentication for user john.doe@acmecorp.com using API key
sk_live_8HdJk2jdKs9dKLd9jks"
```

**After:**
```
"Fix authentication for user [REDACTED] using API key [REDACTED]"
```

Or better:
```
"Fix authentication token validation logic"
```

---

## Best Practices

### 1. Capture Immediately
- Document queries during or right after session
- Memory fades quickly
- Context is clearer when fresh

### 2. Focus on Patterns, Not Verbatim
- Capture the intent, not every word
- Summarize long conversations
- Highlight key decision points

### 3. Tag and Categorize
```markdown
**Query Type:** Implementation
**Complexity:** Medium
**Domain:** Authentication
**Pattern:** Service creation
**Success:** First try ✅
```

### 4. Track Iterations
```markdown
**Attempts:** 3
1. Initial approach (too generic)
2. Added specific constraints (better)
3. Clarified edge cases (succeeded) ✅
```

### 5. Note What Worked
```markdown
**Effective Elements:**
- Referenced existing code pattern
- Provided specific file locations
- Included acceptance criteria
- Mentioned related tests
```

---

## Example: Full Session Query Documentation

```markdown
# Session Query Log: LSFB-12345 JWT Authentication
**Date:** 2025-10-31 14:30-17:15
**Duration:** 2:45
**Developer:** james
**AI Tool:** Claude Code (Sonnet 4.5)

---

## Query Timeline

### 1. Initial Scope [14:32] ⏱️ 15 min

**User:**
> "I need to implement JWT authentication for our Symfony API. It should
> support access tokens (15 min expiry) and refresh tokens (7 days).
> Follow the existing __invoke service pattern and include full tests."

**AI Response Summary:**
- Proposed 2 services: GenerateJwtTokenService, RefreshTokenService
- Suggested firebase/php-jwt library
- Outlined migration for token storage
- Planned 4 unit tests, 2 functional tests

**Tools:** Read (5 existing auth files), WebSearch (JWT best practices)

**Outcome:** ✅ Clear plan established

---

### 2. Library Selection [14:50] ⏱️ 5 min

**User:**
> "Which JWT library should we use? What's most compatible with Symfony 6?"

**AI Response:**
- Recommended firebase/php-jwt (most popular)
- Explained lexik/jwt-authentication-bundle is overkill for our needs
- Showed example integration

**Tools:** WebSearch (Symfony JWT comparison)

**Outcome:** ✅ Decision made: firebase/php-jwt

---

### 3. Implementation [14:55] ⏱️ 45 min

**User:**
> "Let's start. Create GenerateJwtTokenService first with tests."

**AI Actions:**
- Created service with __invoke()
- Generated 4 comprehensive unit tests
- Ran phpunit, all passed
- Fixed code standards automatically

**Tools:** Write (2 files), Bash (composer, phpunit, phpcbf)

**Outcome:** ✅ Service complete, 4/4 tests passing

---

### 4. Debugging - Secret Key [15:45] ⏱️ 12 min

**User:**
> "Tests are failing with 'Token signature invalid'. Production works
> but tests don't."

**AI Analysis:**
- Read test environment config
- Identified missing JWT_SECRET in .env.test
- Added secret to .env.test
- Re-ran tests

**Tools:** Read (3 config files), Edit (1), Bash (phpunit)

**Iterations:** 1 (found issue immediately)

**Outcome:** ✅ Fixed - tests now passing

---

### 5. Enhancement Request [16:15] ⏱️ 20 min

**User:**
> "Can we add token claims for user roles and permissions?"

**AI Response:**
- Updated GenerateJwtTokenService to include custom claims
- Modified tests to verify claims
- Added validation in middleware
- Updated documentation

**Tools:** Edit (2 files), Write (docs), Bash (phpunit)

**Outcome:** ✅ Feature added

---

### 6. Final Review [16:50] ⏱️ 10 min

**User:**
> "Run all tests and make sure everything follows PSR-12"

**AI Actions:**
- Ran full test suite (18/18 passing)
- Ran phpcs (all clean)
- Generated git commit message
- Committed changes

**Tools:** Bash (phpunit, phpcs, git)

**Outcome:** ✅ Ready for PR

---

## Query Statistics

**Total Prompts:** 15
**Major Queries:** 6 (shown above)
**Minor Queries:** 9 (quick clarifications)

**By Type:**
- Implementation: 6 (40%)
- Debugging: 3 (20%)
- Questions: 4 (27%)
- Review: 2 (13%)

**Effectiveness:**
- Resolved first try: 12/15 (80%)
- Needed iteration: 3/15 (20%)

**Response Time:**
- Average AI response: < 2 minutes
- Longest: 8 minutes (complex test generation)

**Tools Triggered:**
- Read: 18
- Write: 5
- Edit: 12
- Bash: 24
- WebSearch: 2

---

## Prompt Quality Analysis

### ✅ High-Quality Prompts

**Query #1:** "Implement JWT auth... __invoke pattern... full tests"
- **Why effective:** Specific, referenced pattern, included tests
- **Time to resolution:** 15 minutes

**Query #4:** "Tests failing with 'Token signature invalid'. Production
works but tests don't."
- **Why effective:** Specific error, environment context
- **Time to resolution:** 12 minutes

### ⚠️ Prompts Needing Refinement

**Query #7:** "Make it more secure"
- **Issue:** Too vague
- **Required:** 2 follow-up questions
- **Better version:** "Add token expiration validation and signature
verification"

---

## Key Learnings

**What worked best:**
1. Starting with clear scope and constraints
2. Referencing existing patterns (__invoke)
3. Providing specific error messages
4. Including testing requirements upfront

**What needed iteration:**
5. Vague enhancement requests ("make it better")
6. Missing context (which environment?)

**Time savings:**
- Estimated manual time: 8 hours
- With AI: 2.75 hours
- Saved: 5.25 hours (66% faster)

**Most valuable AI contributions:**
1. JWT library recommendation (saved 1h research)
2. Comprehensive test generation (saved 1.5h)
3. Quick debugging (saved 1h trial-and-error)
4. Auto code standards fixing (saved 0.5h)

---

## Reusable Patterns

This session established patterns for:
- ✅ JWT service implementation
- ✅ Token refresh flow
- ✅ Custom JWT claims
- ✅ Test environment configuration

These patterns documented and reusable for:
- LSFB-12399 (API key refresh)
- LSFB-12450 (OAuth integration)
- LSFB-12501 (Two-factor auth)
```

---

## Summary

### Quick Reference

**Best Methods for Query Capture:**

1. **Real-time notes** - Most accurate
2. **Copy/paste chat** - Complete history
3. **Query log template** - Structured data
4. **Screenshots** - Visual backup

**Key Statistics from Queries:**

- Total prompts
- Query types (implement/debug/question)
- First-try success rate
- Average iterations needed
- Most effective prompt patterns
- Time per query type

**Integration with AI Use Case CLI:**

```bash
# Document with query details
ai-use-case document

# Include sections:
# - Key User Queries
# - Query Statistics
# - Prompt Quality Analysis
```

**Privacy Checklist:**

- [ ] Sanitize credentials
- [ ] Redact PII
- [ ] Remove customer names
- [ ] Anonymize sensitive data
- [ ] Clear before sharing

---

## Next Steps

1. **Choose a capture method** (start with real-time notes)
2. **Try it for one session** (this one!)
3. **Review what worked** (iterate your process)
4. **Build a habit** (capture becomes automatic)
5. **Analyze patterns** (improve your prompting)

**Remember:** The goal is learning and improvement, not perfection. Even basic query tracking provides valuable insights!

---

## Tools & Resources

**Helpful Commands:**
```bash
# Start a session log
echo "# Claude Session $(date)" > ~/session-log.md

# Quick query capture
alias log-query='cat >> ~/session-log.md'

# Review today's queries
grep -A 5 "##" ~/session-log.md
```

**VS Code Snippets:**
```json
{
  "Log Claude Query": {
    "prefix": "logquery",
    "body": [
      "### Query #$1 [$CURRENT_HOUR:$CURRENT_MINUTE]",
      "**User:** $2",
      "**AI Response:** $3",
      "**Tools:** $4",
      "**Result:** $5",
      ""
    ]
  }
}
```

Happy documenting! 📝
