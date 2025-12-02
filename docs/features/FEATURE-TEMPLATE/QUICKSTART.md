# Quick Start: Creating a New Feature

This guide shows you how to quickly set up documentation for a new feature using the templates.

## 1. Create Feature Directory

```bash
# Navigate to features directory
cd docs/features

# Create your feature directory (use lowercase with hyphens)
mkdir my-new-feature

# Copy templates
cp FEATURE-TEMPLATE/*.md my-new-feature/

# Navigate into feature directory
cd my-new-feature
```

## 2. Rename Template Files

```bash
# Rename the templates to match your feature name
mv 01-feature-plan.md my-new-feature.md
mv 02-requirements.md my-new-feature-requirements.md
mv 03-implementation-checklist.md my-new-feature-checklist.md
```

## 3. Fill in Feature Plan

Open `my-new-feature.md` and fill in:

1. **Header metadata** (Feature ID, dates, status, priority)
2. **Overview** (2-3 sentence summary)
3. **Problem Statement** (what problem does this solve?)
4. **Goals** (what you want to achieve)
5. **Proposed Solution** (how you'll implement it)
6. **Technical Architecture** (components affected, data flow)
7. **Implementation Phases** (break into phases)
8. **Risks & Mitigations** (what could go wrong?)

**Tip:** Start with the problem statement and goals first. Everything else flows from those.

## 4. Fill in Requirements

Open `my-new-feature-requirements.md` and document:

1. **Functional Requirements** (what the system MUST do)
   - Group related requirements (FR-1, FR-2, etc.)
   - Each requirement should be testable

2. **Non-Functional Requirements** (performance, usability, etc.)
   - Think about: speed, user experience, maintainability, compatibility

3. **User Stories** (from user's perspective)
   - Format: "As a [user], I want [goal], so that [benefit]"

4. **Acceptance Criteria** (how to verify it works)
   - Make these specific and testable
   - These become your test cases

5. **Data Requirements** (structure, storage, format)

6. **Interface Requirements** (CLI commands, APIs, configs)

7. **Open Questions** (decisions to make)
   - Document options and rationale

**Tip:** Be specific! "Feature must be fast" is vague. "Feature must complete in < 2 seconds" is testable.

## 5. Create Implementation Checklist

Open `my-new-feature-checklist.md` and create:

1. **Pre-Implementation Setup**
   - Branch creation
   - Review documentation
   - Test environment setup

2. **Phase-by-Phase Tasks**
   - Break work into phases (typically 4-6 phases)
   - Each phase should have 3-10 tasks
   - Each task should have:
     - File being modified
     - Priority (High/Medium/Low)
     - Time estimate
     - Detailed steps
     - Testing steps
     - Commit message

3. **Testing Phase**
   - Unit tests
   - Integration tests
   - Regression tests
   - Cross-platform tests (if applicable)

4. **Documentation Phase**
   - CHANGELOG.md (mandatory)
   - README.md (mandatory)
   - Other docs

5. **Review & PR Phase**
   - Self-review checklist
   - Pre-PR verification
   - PR creation steps

**Tip:** Be granular! Tasks should be small enough to complete in 15-60 minutes each.

## 6. Review and Refine

Before starting implementation:

- [ ] Share feature plan with team/stakeholders
- [ ] Get feedback on requirements
- [ ] Refine based on feedback
- [ ] Ensure checklist is complete and realistic

## 7. Start Implementation

```bash
# Create feature branch
git checkout -b feature/my-new-feature

# Start working through checklist
# Check off tasks as you complete them
# Update decision log as you make choices
```

## Example: Real Feature

See `claude-agents-tracking/` for a complete example of:
- Feature plan with detailed design
- Requirements with 5 functional requirement groups
- Checklist with 82 tasks across 7 phases

## Tips for Success

### Do:
✅ **Be specific** - Vague requirements lead to scope creep
✅ **Include examples** - Code snippets, mockups, command examples
✅ **Think about edge cases** - What could go wrong?
✅ **Consider backwards compatibility** - Will this break existing usage?
✅ **Estimate realistically** - Better to overestimate than underdeliver
✅ **Update as you go** - Keep docs in sync with decisions made

### Don't:
❌ **Don't rush planning** - Time spent planning saves time implementing
❌ **Don't skip requirements** - You'll regret it later
❌ **Don't make checklists too vague** - "Implement feature" isn't helpful
❌ **Don't forget documentation** - CHANGELOG and README are mandatory
❌ **Don't skip testing** - Regression tests prevent surprises

## Time Investment

**Planning Phase:**
- Feature Plan: 1-2 hours
- Requirements: 2-3 hours
- Implementation Checklist: 1-2 hours
- **Total: 4-7 hours**

**ROI:**
- Reduces implementation surprises by 80%
- Catches edge cases early
- Makes code reviews faster
- Provides clear progress tracking
- Creates valuable documentation for future

**Rule of thumb:** For every hour spent planning, save 3-5 hours during implementation.

## Need Help?

- **See full guide:** `docs/features/README.md`
- **Review templates:** `docs/features/FEATURE-TEMPLATE/`
- **Example feature:** `docs/features/claude-agents-tracking/`
- **Ask questions:** Open an issue or discuss with team

---

**Next Steps:**
1. Create your feature directory
2. Copy and rename templates
3. Start filling in feature plan
4. Share with team for feedback
5. Begin implementation when plan is approved
