# AI Session Statistics & Documentation Guide

## Overview

This guide helps you capture meaningful statistics and metrics from AI-assisted development sessions (Claude Code, GitHub Copilot, etc.) for tracking productivity, quality, and ROI.

---

## Core Statistics Categories

### 1. Session Metadata

**Essential Information:**
- **Date/Time:** When the session occurred (include week number for temporal organization)
- **Duration:** Total time spent (HH:MM format)
- **Ticket/Issue:** JIRA ticket, GitHub issue, or task identifier
- **Project:** Repository/project name
- **AI Tool(s):** Claude Code, GitHub Copilot, Copilot CLI, combination
- **Developer:** Who worked on this (for team metrics)
- **Week Number:** ISO week number (1-52/53) for better organization

**Example:**
```
Date: 2025-10-31 (Week 44 of 2025)
Duration: 2:30
Ticket: LSFB-12345
Project: lms-medtrainer
AI Tool: Claude Code (Sonnet 4.5)
Developer: james

# Calculate week number (Linux/Mac):
date -d "2025-10-31" +%V  # Returns: 44
```

---

### 2. Work Performed Metrics

**Code Changes:**
- **Files Modified:** Number of files changed
- **Lines Added:** Total lines of code added
- **Lines Removed:** Total lines removed
- **Net Change:** Lines added - lines removed
- **Files Created:** New files generated
- **Files Deleted:** Files removed

**Task Completion:**
- **Features Added:** List of new features
- **Bugs Fixed:** Number/list of bugs resolved
- **Refactorings:** Code improvements made
- **Tests Written:** Number of test files/cases added
- **Documentation:** Docs created/updated

**Example:**
```
Files Modified: 8
Lines Added: 342
Lines Removed: 127
Net Change: +215
Files Created: 3 (Service, Test, Migration)
Features: User authentication API endpoint
Bugs Fixed: 2 (LSFB-12340, LSFB-12341)
Tests Written: 4 unit tests, 2 functional tests
```

---

### 3. AI Interaction Metrics

**Engagement Level:**
- **Number of Prompts:** Total user requests to AI
- **Tool Uses:** Number of tool invocations (Read, Write, Edit, Bash, etc.)
- **Context Switches:** How many times focus changed
- **Iterations:** Attempts needed to complete task
- **Autonomous Actions:** Tasks AI completed without prompts
- **Session Flow:** Linear / Iterative / Exploratory

**Tool Usage Breakdown:**
- **Read Operations:** Files read for context
- **Write Operations:** New files created
- **Edit Operations:** Files modified
- **Search Operations:** Grep/Glob searches performed
- **Shell Commands:** Bash executions
- **Test Runs:** PHPUnit/Jest executions

**Prompt Effectiveness Tracking:**
- **First-Attempt Success Rate:** Prompts that succeeded without refinement (X/Y = Z%)
- **Average Iterations Per Task:** How many refinements needed per prompt
- **Clarification Requests:** Times AI needed more context
- **Effective Prompts (4-5 stars):** High-quality, clear prompts
- **Prompts Needing Refinement (1-3 stars):** Unclear or ambiguous prompts

**Example:**
```
Prompts: 12
  - First-attempt success: 8/12 (67%)
  - Average iterations: 1.3 per task
  - Clarification requests: 2

Tool Uses: 45
  - Read: 15
  - Edit: 8
  - Bash: 12 (tests, git, composer)
  - Search: 10

Iterations: 2 (first approach needed refactor)
Autonomous: 6 (test fixes, code standards, git commit)

Session Flow: Iterative (some back-and-forth for clarification)
```

**📖 For detailed guidance on capturing and analyzing user queries, see [CAPTURING_USER_QUERIES.md](./CAPTURING_USER_QUERIES.md)**

This companion guide covers:
- Methods to capture conversation history from Claude Code
- Query logging templates and tools
- Prompt effectiveness analysis
- Conversation flow patterns
- Privacy and security considerations
- Full session query documentation examples

---

### 4. Time Savings Analysis

**Time Estimates:**
- **Estimated Time (Manual):** How long without AI
- **Actual Time (With AI):** Time with AI assistance
- **Time Saved:** Difference
- **Efficiency Multiplier:** Manual time ÷ Actual time

**Calculation Examples:**
```
Manual Development Estimate: 6 hours
  - Understanding codebase: 1.5 hours
  - Writing code: 2.5 hours
  - Writing tests: 1.5 hours
  - Debugging: 0.5 hours

With AI: 2.5 hours
  - AI context gathering: 0.5 hours
  - Guided implementation: 1.0 hours
  - AI-assisted testing: 0.5 hours
  - AI-assisted debugging: 0.5 hours

Time Saved: 3.5 hours (58% reduction)
Efficiency: 2.4x faster
```

**Factors to Consider:**
- Was this a familiar or unfamiliar codebase?
- Complex or straightforward task?
- Did AI help avoid rabbit holes?
- How much manual debugging was saved?

---

### 5. Quality Metrics

**Code Quality:**
- **Test Coverage:** Percentage or lines covered
- **Tests Passing:** Pass/fail ratio
- **Code Standards:** PSR compliance, linting
- **Type Safety:** Type hints, strict types
- **Security:** Vulnerabilities avoided

**Review Metrics:**
- **PR Review Time:** Reduced review cycles
- **Comments Addressed:** Fewer review comments
- **First-Time Approval:** Passed review on first try
- **Rollback Rate:** Reduced production issues

**Example:**
```
Test Coverage: 85% (target met)
Tests: 18/18 passing
Code Standards: PSR-12 compliant (phpcbf auto-fixed)
Security: SQL injection prevented (parameterized queries)
Type Safety: Full type hints, strict_types=1
PR Review: Approved first time, 0 change requests
```

---

### 6. Problem-Solving Metrics

**Complexity Handled:**
- **Problem Difficulty:** Simple, Medium, Complex
- **Unknowns Resolved:** New patterns learned
- **Blockers Overcome:** Issues that would have stopped progress
- **Architecture Decisions:** Design choices made with AI

**Research Avoided:**
- **Stack Overflow Searches:** Not needed
- **Documentation Reads:** AI explained patterns
- **Colleague Interruptions:** Self-sufficient with AI

**Example:**
```
Complexity: Medium-High
  - Unfamiliar Symfony Messenger component
  - Complex async workflow design

Blockers Overcome:
  - Claude explained Messenger best practices
  - Avoided 2+ hours of doc reading
  - No need to interrupt senior developer

Research Saved: ~2 hours of Stack Overflow/docs
Knowledge Gained: Messenger patterns reusable for future tasks
```

---

### 7. Business Value Metrics

**Delivery Impact:**
- **Sprint Velocity:** Story points completed
- **Deadline Met:** On-time delivery
- **Feature Completeness:** % of acceptance criteria
- **User Impact:** Users affected, value delivered

**Technical Debt:**
- **Debt Added:** New technical debt introduced
- **Debt Reduced:** Legacy code improved
- **Maintenance Impact:** Future maintenance cost

**Example:**
```
Sprint Impact: Completed 13 story points (vs 8 typical)
Deadline: Delivered 1 day early
User Impact: 5,000 users, critical auth feature
Technical Debt: -2 (refactored legacy auth, improved test coverage)
Future Maintenance: Reduced (better documentation, cleaner code)
```

---

### 8. Learning & Knowledge Transfer

**Personal Growth:**
- **New Patterns Learned:** Design patterns, best practices
- **Skills Developed:** New frameworks, languages
- **Confidence Gained:** Areas of increased proficiency

**Team Impact:**
- **Documentation Created:** READMEs, inline comments
- **Patterns Shared:** Reusable solutions
- **Onboarding Value:** Helps new team members

**Example:**
```
Learned:
  - Symfony Messenger async patterns
  - Service __invoke() pattern
  - TDD workflow with PHPUnit

Documentation:
  - Added inline comments explaining Messenger setup
  - Updated CLAUDE.md with async patterns

Reusable: This message handler pattern can be used for 3 other features
```

---

## Quick Capture Template

Use this template during/after your AI session:

```markdown
## Session Info
- Date: YYYY-MM-DD
- Duration: H:MM
- Ticket: TICKET-XXXXX
- AI Tool: Claude Code / Copilot / Both

## Work Done
- Task: [Brief description]
- Files Changed: X files
- Lines: +XXX / -XXX
- Tests: X unit, X functional

## AI Metrics
- Prompts: XX
- Tool Uses: XX (Read: X, Edit: X, Bash: X)
- Iterations: X
- First-attempt success: X/XX (XX%)

## Key Queries (Optional - see CAPTURING_USER_QUERIES.md)
1. Initial request: "[Your first prompt]" → [Result]
2. Main iteration: "[Refinement prompt]" → [Result]
3. Final polish: "[Last adjustment]" → [Result]

## Time Saved
- Manual Estimate: X hours
- Actual Time: X hours
- Saved: X hours (XX%)
- Efficiency: X.Xx

## Quality
- Tests: XX/XX passing
- Coverage: XX%
- Standards: ✅ PSR-12
- Review: ✅ First-time approval

## Value
- Feature: [Description]
- Impact: [Users affected / business value]
- Learning: [Key takeaway]
```

---

## Advanced Analytics

### Aggregate Metrics Over Time

**Weekly/Monthly Tracking:**
```
Week of 2025-10-28:
- Sessions: 12
- Total Time Saved: 28 hours
- Average Efficiency: 2.3x
- Features Delivered: 8
- Bugs Fixed: 15
- Tests Written: 94
- Lines of Code: +2,847 / -1,203
```

**Project-Level Metrics:**
```
Project: lms-medtrainer
- AI-Assisted Sessions: 47
- Total Time Saved: 156 hours
- Productivity Increase: 2.1x average
- Test Coverage: Increased 15% → 78%
- Code Quality: PSR violations reduced 85%
```

---

## ROI Calculation

**Individual ROI:**
```
Monthly AI Tool Cost: $20 (Claude Code Pro)
Time Saved per Month: 40 hours
Hourly Rate: $75
Value Generated: 40 × $75 = $3,000
ROI: ($3,000 - $20) / $20 = 14,900%
```

**Team ROI:**
```
Team Size: 5 developers
Monthly Cost: $100 (5 × $20)
Average Time Saved: 35 hours per developer
Total Time Saved: 175 hours
Team Hourly Rate: $75
Value Generated: 175 × $75 = $13,125
ROI: ($13,125 - $100) / $100 = 13,025%
```

---

## Best Practices for Tracking

### During the Session

1. **Start a timer** when you begin
2. **Note your initial estimate** before starting
3. **Count prompts naturally** (don't obsess)
4. **Track major iterations** (significant direction changes)
5. **Note blockers overcome** (moments AI saved you)

### After the Session

1. **Run git stats** for accurate code metrics:
   ```bash
   git diff --stat main..HEAD
   git log --oneline --since="2 hours ago"
   ```

2. **Check test results**:
   ```bash
   kool run phpunit --testsuite=unit
   ```

3. **Review code quality**:
   ```bash
   kool run phpcs
   ```

4. **Document immediately** (details fade quickly)

### Weekly Review

1. **Aggregate metrics** across sessions
2. **Identify patterns** (what works best)
3. **Share insights** with team
4. **Adjust workflows** based on data

---

## Common Questions

**Q: How do I estimate "manual time" accurately?**
A: Break down the task:
- Codebase research: 1-2 hours for unfamiliar code
- Implementation: 2-3x slower without AI guidance
- Testing: 1.5-2x slower without AI-generated tests
- Debugging: 2-3x slower without AI assistance

**Q: Should I count time spent prompting?**
A: Yes, include it in "Actual Time" - it's part of the AI-assisted workflow.

**Q: What if I'm unsure about time saved?**
A: Be conservative. Use lower estimates. It's better to underreport than overreport.

**Q: How do I handle pair programming with AI?**
A: Count it as AI-assisted. Note if human pair programming also occurred.

**Q: What about failed attempts?**
A: Count everything. Failed iterations are part of the learning curve and still faster than manual.

---

## Visualization Ideas

**Charts to Generate:**
1. **Time Saved Over Time** (line chart)
2. **Efficiency Multiplier by Task Type** (bar chart)
3. **Tool Usage Breakdown** (pie chart)
4. **Test Coverage Trend** (line chart)
5. **Features Delivered per Sprint** (bar chart)
6. **ROI by Developer** (comparison chart)

**Dashboard Metrics:**
- Total sessions documented
- Total time saved
- Average efficiency
- Most productive day/time
- Most common AI tool uses
- Quality score trends

---

## Integration with AI Use Case CLI

The `ai-use-case` CLI captures most of these metrics automatically:

```bash
# Document a session (interactive prompts)
ai-use-case document

# View statistics
ai-use-case stats

# Search past sessions
ai-use-case search "authentication"
```

**CLI captures:**
- Session metadata (date, ticket, project)
- Work description
- Time estimates
- Tools used
- Results and outcomes

**You add:**
- Detailed metrics (lines of code, test counts)
- Quality assessments
- Learning insights
- Business value context

---

## Automated Session Statistics Capture

**New in Version 3.4+**: The CLI now supports automatic capture of Claude Code session statistics!

### SessionEnd Hook

Automatically saves session data when Claude Code sessions end:

```bash
# Hook location
.claude/hooks/SessionEnd

# Stats saved to
.usecase/session-stats/YYYY-MM-DD-HHMMSS.txt
```

**What it captures:**
- Session end time
- Repository and branch
- Recent commits (last 2 hours)
- Uncommitted changes
- Instructions to run `/cost`

### /cost Command Integration

Claude Code's built-in `/cost` command provides real-time statistics:

```bash
# Run in Claude Code
/cost
```

**Output includes:**
- Total cost (USD)
- Total duration (API and wall time)
- Code changes (lines added/removed)
- Token usage breakdown

**Integration with documentation:**
- Templates now include a "Session Statistics" section
- `/use-case:document-session` workflow prompts for `/cost` output
- Automatically populate token/cost data in documentation

### OpenTelemetry Support

For enterprise-grade tracking, configure OpenTelemetry:

```bash
# Enable telemetry
source .claude/otel-config.sh && claude
```

**Benefits:**
- Detailed metrics and events
- Multiple export formats (console, file, OTLP)
- Centralized monitoring across teams
- Custom dashboards and analysis

**See:** [OPENTELEMETRY-SETUP.md](./OPENTELEMETRY-SETUP.md) for complete setup guide

### Workflow Integration

**Recommended workflow:**

1. **Start session**: OTel begins collecting (optional)
2. **Work**: Code, test, document as usual
3. **Session end**: SessionEnd hook auto-saves metadata
4. **Capture stats**: Run `/cost` before closing
5. **Document**: Run `/use-case:document-session`
6. **Paste output**: Include `/cost` output in documentation

This provides complete, accurate session statistics with minimal manual effort!

---

## Example Real-World Session

```markdown
# 2025-10-31_LSFB-12345_user-authentication-api.md

## Session Info
- Date: 2025-10-31
- Duration: 2:45
- Ticket: LSFB-12345
- Project: lms-medtrainer
- AI Tool: Claude Code (Sonnet 4.5)
- Developer: james

## Task Description
Implement JWT authentication API endpoint with refresh token support,
including unit tests and database migration for token storage.

## Work Performed

### Code Changes
- Files Modified: 11
- Lines Added: 487
- Lines Removed: 92
- Net Change: +395

### Files Created
1. `symfony/src/MedTrainer/AuthBundle/Service/GenerateJwtTokenService.php`
2. `symfony/src/MedTrainer/AuthBundle/Service/RefreshTokenService.php`
3. `symfony/tests/Unit/AuthBundle/Service/GenerateJwtTokenServiceTest.php`
4. `symfony/tests/Unit/AuthBundle/Service/RefreshTokenServiceTest.php`
5. `symfony/migrations/Version20251031143022.php` (tokens table)

### Files Modified
1. `symfony/src/MedTrainer/AuthBundle/Controller/AuthController.php`
2. `symfony/config/routes.yaml`
3. `symfony/config/services.yaml`
4. `composer.json` (added firebase/php-jwt)
5. `.gitignore` (added .env.local)
6. `symfony/tests/Functional/AuthBundle/Controller/AuthControllerTest.php`

## AI Interaction Metrics

### Tool Usage
- Total Tool Uses: 67
  - Read: 18 (analyzed existing auth code, config files)
  - Write: 5 (new services and tests)
  - Edit: 12 (controller, routes, services config)
  - Bash: 24 (composer install, phpunit, migrations, phpcs)
  - Grep: 8 (searched for existing auth patterns)

### Engagement
- User Prompts: 15
- AI Iterations: 2 (first JWT library had issues, switched to firebase)
- Autonomous Actions: 12 (test fixes, phpcbf, git commit with message)

### Commands Run by AI
```bash
kool run composer require firebase/php-jwt
kool run phpunit --testsuite=unit
kool run phpunit tests/Unit/AuthBundle/Service/GenerateJwtTokenServiceTest.php
kool run phpunit tests/Functional/AuthBundle/Controller/AuthControllerTest.php
kool run migrations
kool run phpcbf
kool run phpcs
git add . && git commit -m "LSFB-12345: Add JWT authentication API endpoint"
```

## Time Analysis

### Manual Estimate (without AI): 8.0 hours
- Understanding existing auth system: 1.5h
- Research JWT best practices: 1.0h
- Design token refresh flow: 0.5h
- Implement services (TDD): 2.5h
- Write controller endpoint: 0.5h
- Database migration: 0.5h
- Integration tests: 1.0h
- Documentation: 0.5h

### Actual Time (with AI): 2.75 hours
- AI-guided codebase analysis: 0.25h
- Discuss approach with AI: 0.25h
- AI-assisted TDD implementation: 1.5h
- AI-generated migration: 0.25h
- AI-assisted integration testing: 0.25h
- AI-generated documentation: 0.25h

### Results
- **Time Saved:** 5.25 hours (66% faster)
- **Efficiency Multiplier:** 2.9x
- **Blocked Issues Avoided:** JWT library selection (saved 1h research)

## Quality Metrics

### Testing
- Unit Tests: 8/8 passing
- Functional Tests: 2/2 passing
- Coverage: 92% for new services

### Code Standards
- PSR-12: ✅ Compliant (phpcbf auto-fixed)
- Type Hints: ✅ Full coverage
- Strict Types: ✅ `declare(strict_types=1)`

### Security
- ✅ Parameterized queries (no SQL injection)
- ✅ Password hashing (bcrypt)
- ✅ Token expiration enforced
- ✅ No PII in logs
- ✅ Environment variables for secrets

### Code Review
- Status: ✅ Approved first review
- Comments: 0 change requests
- Merge Time: Same day

## Business Value

### Feature Impact
- Affects: All 5,000+ users
- Criticality: High (enables mobile app launch)
- Sprint: Delivered on time (2 days ahead of deadline)

### Technical Debt
- Debt Reduced: Removed legacy session-based auth
- Maintainability: +1 (clean service pattern, well-tested)
- Documentation: Inline comments + updated CLAUDE.md

### Dependencies Unblocked
- Mobile app team can now integrate API
- Frontend refresh token logic can proceed

## Learning & Knowledge

### New Skills Acquired
1. Firebase JWT library usage in Symfony
2. Refresh token rotation pattern
3. Secure token storage strategies

### Patterns Learned
- Service __invoke() pattern (reinforced)
- TDD with mocked dependencies
- Migration two-phase approach (IF EXISTS guards)

### Documentation Created
- Inline comments explaining JWT flow
- Updated CLAUDE.md with auth patterns
- API endpoint documentation in Swagger

### Reusable for Future
- Token refresh pattern applicable to API key refresh (LSFB-12399)
- Service pattern template for other auth features
- Test structure reusable for other endpoints

## Key Moments

### AI Value Highlights
1. **Library Selection:** AI recommended firebase/php-jwt immediately vs 1h research
2. **Security Best Practices:** AI proactively added security measures I would have missed
3. **Test Generation:** AI wrote comprehensive test cases covering edge cases
4. **Migration Safety:** AI added IF EXISTS guards automatically
5. **Code Standards:** AI auto-fixed PSR violations without being asked

### Challenges Overcome
- Initial approach used raw JWT encoding - AI suggested firebase library (better)
- Forgot to add token expiration - AI caught during review
- Tests initially failed due to mocking issues - AI debugged and fixed

## Notes

- AI's knowledge of Symfony Messenger and TDD workflow was excellent
- Following TDD saved debugging time later
- Git commit message auto-generated by AI was clear and followed conventions
- This pattern will accelerate 3 upcoming auth-related tickets

## Tags
#authentication #jwt #api #security #symfony #tdd #high-impact
```

---

## Summary

**Minimum Viable Metrics:**
- Date, duration, ticket
- Task description
- Time estimate vs actual
- Key results

**Comprehensive Metrics:**
- All of the above PLUS
- Code change stats
- AI tool usage breakdown
- Quality metrics
- Business value
- Learning outcomes

**Start simple, expand over time.** Even basic tracking provides valuable insights!

---

## Next Steps

1. **Document your next session** using this guide
2. **Track for 2 weeks** to establish baseline
3. **Review patterns** and optimize workflow
4. **Share insights** with team
5. **Iterate** on what metrics matter most to you

**Happy tracking! 🚀**
