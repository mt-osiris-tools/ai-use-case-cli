# New Project Setup - Quick Prompt

Use this prompt with Claude Code or another AI assistant to set up a new repository with standardized git workflow, commit standards, and documentation requirements.

---

## Setup Prompt (Copy-Paste Ready)

```
Please set up this repository with the following standards and git workflow:

## Required Setup

1. **Git Hooks**

Create `.git/hooks/pre-commit` to block direct commits to main/master:
- Display clear error message with branch naming conventions
- Suggest creating feature branch instead
- Show bypass option (--no-verify) but mark as not recommended

Create `.git/hooks/commit-msg` to enforce conventional commit format:
- Pattern: type(optional-scope): description
- Valid types: feat, fix, docs, style, refactor, perf, test, chore, build, ci, revert
- Display clear error message with examples if validation fails

Make both hooks executable.

2. **CLAUDE.md** (Root of repository)

Create with these sections:
- Repository Purpose (brief description)
- Critical Rules:
  - Branch-based only (never commit to main)
  - Documentation MUST be updated (CHANGELOG.md and README.md)
  - Testing required before PR
- Standard workflow example (checkout feature branch → commit → push → create PR)
- Pre-PR Checklist (branch created, CHANGELOG updated, README reviewed, tested, docs updated)
- Branch naming conventions (feature/, fix/, docs/, refactor/, test/)
- Commit message format (conventional commits with examples)
- Never Do list (commit to main, skip CHANGELOG, skip README review, skip testing)
- Quick reference (main branch, commit style)

3. **CONTRIBUTING.md**

Include:
- Development workflow overview
- Branch naming conventions with examples
- Pull request workflow (5 steps: create branch → make changes → commit → push → create PR)
- PR requirements checklist (MANDATORY CHANGELOG.md and README.md updates)
- Documentation revision rules (non-negotiable)
- CHANGELOG.md format (Unreleased section with Added/Changed/Fixed)
- Claude Code guidelines
- Branch protection rules for GitHub
- Code review guidelines
- Testing requirements

4. **CHANGELOG.md**

Initialize with:
- Header explaining format (Keep a Changelog + Semantic Versioning)
- [Unreleased] section
- [1.0.0] section with initial release

5. **Update README.md**

Add badges section at top if not present:
- Version badge
- License badge
- Build status (if applicable)

Add at bottom:
- Development section referencing CONTRIBUTING.md
- Links to CHANGELOG.md and CONTRIBUTING.md

## Workflow Standards

- **Branch Protection**: No direct commits to main/master
- **Branch Naming**: feature/*, fix/*, docs/*, refactor/*, test/*
- **Commit Format**: Conventional commits (type: description)
- **Documentation**: CHANGELOG.md and README.md MUST be updated for all changes
- **Testing**: All changes must be tested locally before PR
- **Pull Requests**: Required for all changes, include clear description

## Git Hook Specifications

Pre-commit hook requirements:
- Check current branch name
- Block if main or master
- Display error box with visual borders
- Show helpful guidance with color coding:
  - Red for errors
  - Yellow for warnings/recommendations
  - Green for examples
- List branch naming conventions
- Show bypass option

Commit-msg hook requirements:
- Validate against conventional commit pattern
- Display error box if invalid
- Show valid types and examples
- Display the invalid message for reference
- Show bypass option

## Testing Instructions

After setup, verify:
1. Attempt commit to main → should be blocked
2. Create feature branch and commit → should succeed
3. Try invalid commit message → should be blocked (if commit-msg hook installed)
4. Try valid commit message → should succeed

Please implement all of this now.
```

---

## Usage

1. **For New Repositories**: Copy the prompt above and paste it into Claude Code when in a new repository
2. **For AI Assistants**: Use this prompt to instruct the AI to set up the complete workflow
3. **For Manual Setup**: Follow the detailed guide in NEW-PROJECT-TEMPLATE.md

## Quick Setup Command

For faster setup, you can also ask:

```
Set up this repository with branch-based git workflow following the standards in
https://github.com/yourusername/ai-use-case-cli/blob/main/docs/NEW-PROJECT-TEMPLATE.md

Include:
- Pre-commit and commit-msg hooks
- CLAUDE.md for AI assistants
- CONTRIBUTING.md with PR checklist
- CHANGELOG.md initialization
- README.md updates

Follow all specifications exactly as documented.
```

## Minimal Prompt (Essential Only)

If you only want the core essentials:

```
Set up branch protection for this repository:

1. Create `.git/hooks/pre-commit` to block commits to main/master
2. Create `.git/hooks/commit-msg` to enforce conventional commits (feat:, fix:, docs:, etc.)
3. Create `CLAUDE.md` with rules:
   - Never commit to main
   - Update CHANGELOG.md for all changes
   - Update README.md for user-facing changes
   - Use feature/* branch naming
   - Use conventional commit messages
4. Create `CONTRIBUTING.md` with PR workflow and checklist
5. Initialize `CHANGELOG.md` with [Unreleased] section

Make all hooks executable and test the setup.
```

## Customization Options

When using the prompt, you can add:

```
Additional requirements:
- Protect additional branches: [branch-names]
- Add custom commit types: [types]
- Project-specific conventions: [describe]
- Custom PR checklist items: [items]
```

## Validation Prompt

After setup, verify with:

```
Verify the git workflow setup:
1. Check all files were created (CLAUDE.md, CONTRIBUTING.md, CHANGELOG.md, hooks)
2. Test pre-commit hook by attempting commit to main
3. Test commit-msg hook with invalid message
4. Create test feature branch and make valid commit
5. Confirm README.md was updated with development section

Show me the results of each test.
```
