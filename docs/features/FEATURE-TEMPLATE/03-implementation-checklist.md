# Implementation Checklist: [Feature Name]

**Feature ID:** FEATURE-XXX
**Checklist Version:** 1.0
**Created:** YYYY-MM-DD
**Status:** Not Started | In Progress | Completed

---

## Pre-Implementation Setup

### Environment Preparation

- [ ] **Create feature branch**
  - [ ] Branch name: `feature/[feature-name]`
  - [ ] Branched from: `main` (latest)
  - [ ] Command: `git checkout -b feature/[feature-name]`

- [ ] **Review related documentation**
  - [ ] Read feature plan: `docs/features/[feature-name]/[feature-name].md`
  - [ ] Read requirements: `docs/features/[feature-name]/[feature-name]-requirements.md`
  - [ ] Review affected files (list from technical architecture)

- [ ] **Set up test environment**
  - [ ] [Specific test setup step 1]
  - [ ] [Specific test setup step 2]
  - [ ] Verify baseline functionality works

---

## Phase 1: [Phase Name]

### Task 1.1: [Task Name]

**File:** `path/to/file`
**Priority:** High | Medium | Low
**Estimated Time:** X hours/minutes

- [ ] **Subtask 1**
  - [ ] Detailed step 1
  - [ ] Detailed step 2
  - [ ] Verification: [How to verify this works]

- [ ] **Subtask 2**
  - [ ] Detailed step 1
  - [ ] Detailed step 2

- [ ] **Test changes**
  - [ ] Test case 1
  - [ ] Test case 2
  - [ ] Verify no regressions

- [ ] **Commit changes**
  - [ ] Stage file: `git add [file]`
  - [ ] Commit: `git commit -m "type: description"`

### Task 1.2: [Task Name]

**File:** `path/to/file`
**Priority:** High | Medium | Low
**Estimated Time:** X hours/minutes

- [ ] **Implementation steps**
  - [ ] Step 1
  - [ ] Step 2
  - [ ] Step 3

- [ ] **Verification**
  - [ ] How to verify
  - [ ] Expected output

- [ ] **Commit changes**
  - [ ] Stage and commit

---

## Phase 2: [Phase Name]

### Task 2.1: [Task Name]

**File:** `path/to/file`
**Priority:** High | Medium | Low
**Estimated Time:** X hours/minutes

- [ ] **Planning**
  - [ ] Understand current implementation
  - [ ] Identify insertion points
  - [ ] Plan integration approach

- [ ] **Implementation**
  - [ ] Change 1
  - [ ] Change 2
  - [ ] Change 3

- [ ] **Testing**
  - [ ] Unit test
  - [ ] Integration test
  - [ ] Edge cases

- [ ] **Commit**
  - [ ] Descriptive commit message

### Task 2.2: [Task Name]

**File:** `path/to/file`
**Priority:** High | Medium | Low
**Estimated Time:** X hours/minutes

- [ ] **Steps**
  - [ ] [Step]

---

## Phase 3: [Phase Name]

### Task 3.1: [Task Name]

**Priority:** High | Medium | Low
**Estimated Time:** X hours/minutes

- [ ] **Test Scenario 1: [Description]**
  - [ ] Setup: [What to set up]
  - [ ] Execute: [What to run]
  - [ ] Verify: [Expected result]
  - [ ] Actual result: [To be filled during testing]

- [ ] **Test Scenario 2: [Description]**
  - [ ] Setup
  - [ ] Execute
  - [ ] Verify
  - [ ] Actual result

- [ ] **Document test results**
  - [ ] Create: `tests/[test-name].md`
  - [ ] Record all test outcomes
  - [ ] Note any issues or bugs

### Task 3.2: [Task Name]

**Priority:** High | Medium | Low
**Estimated Time:** X hours/minutes

- [ ] **Test Case 1**
  - [ ] Description
  - [ ] Steps
  - [ ] Expected result
  - [ ] Actual result

---

## Phase 4: Integration & Testing

### Task 4.1: End-to-End Testing

**Priority:** High
**Estimated Time:** X hours

- [ ] **Workflow 1: [Description]**
  - [ ] Step 1
  - [ ] Step 2
  - [ ] Verify complete workflow

- [ ] **Workflow 2: [Description]**
  - [ ] Step 1
  - [ ] Step 2
  - [ ] Verify results

### Task 4.2: Regression Testing

**Priority:** High
**Estimated Time:** X hours

- [ ] **Test existing functionality unchanged**
  - [ ] Feature 1 still works
  - [ ] Feature 2 still works
  - [ ] No formatting issues
  - [ ] No performance degradation

- [ ] **Test all CLI commands**
  - [ ] Command 1
  - [ ] Command 2
  - [ ] Command 3

### Task 4.3: Cross-Platform Testing

**Priority:** Medium
**Estimated Time:** X minutes

- [ ] **Test on Linux**
  - [ ] All features work
  - [ ] No platform-specific issues

- [ ] **Test on macOS** (if applicable)
  - [ ] All features work
  - [ ] No platform-specific issues

---

## Phase 5: Documentation Updates

### Task 5.1: Update CHANGELOG.md

**File:** `CHANGELOG.md`
**Priority:** High (Mandatory)
**Estimated Time:** 15 minutes

- [ ] **Add entry under [Unreleased] section**
  ```markdown
  ### Added
  - [Feature description]
  - [Sub-feature 1]
  - [Sub-feature 2]

  ### Changed (if applicable)
  - [What changed]

  ### Fixed (if applicable)
  - [What was fixed]
  ```

- [ ] **Commit changes**
  - [ ] Stage file: `git add CHANGELOG.md`
  - [ ] Commit: `git commit -m "docs: update CHANGELOG for [feature]"`

### Task 5.2: Update README.md

**File:** `README.md`
**Priority:** High (Mandatory)
**Estimated Time:** 20 minutes

- [ ] **Add feature mention**
  - [ ] Update features section
  - [ ] Add examples if needed
  - [ ] Update command reference

- [ ] **Commit changes**
  - [ ] Stage file: `git add README.md`
  - [ ] Commit: `git commit -m "docs: add [feature] to README"`

### Task 5.3: Update Related Documentation

**Priority:** Medium
**Estimated Time:** X minutes

- [ ] **Update [Doc 1]**
  - [ ] Section to update
  - [ ] What to add/change

- [ ] **Update [Doc 2]** (if needed)
  - [ ] Changes needed

- [ ] **Commit changes**
  - [ ] Stage and commit all doc updates

---

## Phase 6: Review & Finalization

### Task 6.1: Code Review

**Priority:** High
**Estimated Time:** 1 hour

- [ ] **Self-review all changes**
  - [ ] Check code quality and style
  - [ ] Verify comments and documentation
  - [ ] Look for potential bugs
  - [ ] Check error handling
  - [ ] Verify no debug code left

- [ ] **Review against requirements**
  - [ ] Go through requirements document
  - [ ] Verify each requirement is met
  - [ ] Check all acceptance criteria

- [ ] **Security review**
  - [ ] No sensitive data exposed
  - [ ] Input validation present
  - [ ] No injection vulnerabilities

### Task 6.2: Documentation Review

**Priority:** High
**Estimated Time:** 30 minutes

- [ ] **Verify all documentation updated**
  - [ ] CHANGELOG.md ✓
  - [ ] README.md ✓
  - [ ] Other docs ✓
  - [ ] Feature docs complete ✓

- [ ] **Check for consistency**
  - [ ] Terminology consistent
  - [ ] Examples match behavior
  - [ ] No conflicting information

- [ ] **Verify markdown formatting**
  - [ ] All markdown renders correctly
  - [ ] No broken links
  - [ ] Proper heading hierarchy

### Task 6.3: Pre-PR Checklist

**Priority:** High (Mandatory)
**Estimated Time:** 15 minutes

- [ ] **Verify branch is clean**
  - [ ] Run: `git status`
  - [ ] All changes committed
  - [ ] No untracked files (or properly ignored)

- [ ] **Verify commit messages**
  - [ ] All commits use conventional format
  - [ ] Messages are clear and descriptive
  - [ ] No WIP or temporary commits

- [ ] **Run final tests**
  - [ ] All features work end-to-end
  - [ ] No regressions
  - [ ] Clean test output

- [ ] **Complete PR checklist items**
  - [ ] ✅ Created feature branch (not on `main`)
  - [ ] ✅ **MANDATORY: Updated CHANGELOG.md**
  - [ ] ✅ **MANDATORY: Updated README.md**
  - [ ] ✅ Updated version (if applicable)
  - [ ] ✅ Tested changes locally
  - [ ] ✅ Updated all related documentation

### Task 6.4: Create Pull Request

**Priority:** High
**Estimated Time:** 30 minutes

- [ ] **Push feature branch**
  - [ ] Run: `git push -u origin feature/[feature-name]`

- [ ] **Prepare PR description**
  - [ ] Summary of changes
  - [ ] List of files changed
  - [ ] Test results summary
  - [ ] Screenshots/examples if applicable
  - [ ] Checklist of completed items

- [ ] **Ask user for approval**
  - [ ] Present summary to user
  - [ ] Confirm all requirements met
  - [ ] Wait for user confirmation

- [ ] **Create PR**
  - [ ] Run: `gh pr create --title "type: [description]" --body "[description]"`
  - [ ] Include proper formatting
  - [ ] Add emoji and attribution

- [ ] **Provide PR URL to user**

---

## Post-Implementation Tasks

### Task 7.1: Monitoring

**Priority:** Low
**Estimated Time:** Ongoing

- [ ] **Monitor for issues**
  - [ ] Watch for user feedback
  - [ ] Check for bug reports
  - [ ] Look for edge cases

- [ ] **Collect usage data**
  - [ ] How often is feature used?
  - [ ] Are users finding it valuable?
  - [ ] Any common pain points?

### Task 7.2: Follow-up

**Priority:** Low
**Estimated Time:** Varies

- [ ] **Address post-release feedback**
  - [ ] Fix bugs found in production
  - [ ] Address usability issues
  - [ ] Implement quick wins

- [ ] **Plan improvements**
  - [ ] Based on user feedback
  - [ ] Based on usage patterns
  - [ ] Document in feature plan

---

## Notes & Decisions

### Decision Log

Track important decisions made during implementation:

**Decision 1: [Topic]**
- **Date:** YYYY-MM-DD
- **Decision:** [What was decided]
- **Rationale:** [Why this choice was made]
- **Alternatives considered:** [Other options]
- **Impact:** [What this affects]

**Decision 2: [Topic]**
- **Date:** YYYY-MM-DD
- **Decision:** [What was decided]
- **Rationale:** [Why]

---

## Progress Tracking

**Overall Progress:** 0% (0/X tasks completed)

**Phase 1:** 0/X tasks
**Phase 2:** 0/X tasks
**Phase 3:** 0/X tasks
**Phase 4:** 0/X tasks
**Phase 5:** 0/X tasks
**Phase 6:** 0/X tasks
**Phase 7:** 0/X tasks

**Last Updated:** YYYY-MM-DD

---

## Blockers & Issues

Track blockers and issues as they arise:

**Issue 1: [Description]**
- **Date Identified:** YYYY-MM-DD
- **Impact:** [How it affects progress]
- **Status:** Open | In Progress | Resolved
- **Resolution:** [How it was resolved, if applicable]

**Issue 2: [Description]**
- **Date Identified:** YYYY-MM-DD
- **Impact:** [Impact description]
- **Status:** Open | In Progress | Resolved

---

## Time Tracking (Optional)

| Phase | Estimated | Actual | Variance |
|-------|-----------|--------|----------|
| Phase 1 | X hours | Y hours | +/- Z hours |
| Phase 2 | X hours | Y hours | +/- Z hours |
| Phase 3 | X hours | Y hours | +/- Z hours |
| Phase 4 | X hours | Y hours | +/- Z hours |
| Phase 5 | X hours | Y hours | +/- Z hours |
| Phase 6 | X hours | Y hours | +/- Z hours |
| **Total** | **X hours** | **Y hours** | **+/- Z hours** |

---

**Status:** Not Started | In Progress | Completed
**Next Action:** [What to do next]
**Assigned To:** [Developer Name]
**Target Completion:** [Date]
