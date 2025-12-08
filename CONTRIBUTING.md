# Contributing to AI Use Case CLI

Thank you for contributing to the AI Use Case CLI! This document outlines the development workflow and contribution guidelines.

## Development Workflow

All changes to this repository **must** follow a branch-based workflow with pull requests. Direct commits to the `main` branch are not allowed.

### Branch Naming Convention

Use the following format for all feature branches:

```
feature/description
```

**Examples:**
- `feature/add-version-check`
- `feature/improve-sync-performance`
- `feature/support-research-sessions`

**Branch Types:**
- `feature/` - New features or enhancements
- `fix/` - Bug fixes
- `docs/` - Documentation-only changes
- `refactor/` - Code refactoring without behavior changes
- `test/` - Adding or updating tests

### Pull Request Workflow

#### Step 1: Create a Branch

```bash
# Create and checkout a new branch
git checkout -b feature/your-feature-description

# Or create from specific base branch
git checkout -b feature/your-feature main
```

#### Step 2: Make Your Changes

Implement your changes following the requirements checklist below.

#### Step 3: Commit Your Changes

Use conventional commit messages:

```bash
git add .
git commit -m "feat: add version checking to CLI" \
  -m "Implements automatic version checking that runs once per day in the background. Notifies users when updates are available."
```

**Commit message format:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `refactor:` - Code refactoring
- `test:` - Test changes
- `chore:` - Maintenance tasks

#### Step 4: Push Your Branch

```bash
git push -u origin feature/your-feature-description
```

#### Step 5: Create Pull Request

Create a PR on GitHub with:
- Clear title describing the change
- Description explaining what and why
- Reference to related issues (if any)
- Screenshots or examples (if applicable)

### PR Requirements Checklist

Before creating a pull request, ensure you have completed:

- [ ] **MANDATORY: Update CHANGELOG.md** - Add entry under "Unreleased" section (non-negotiable for ALL changes)
- [ ] **MANDATORY: Review and update README.md** - Update if any user-facing functionality changed (non-negotiable)
- [ ] **MANDATORY: Validate version consistency** - Run `./scripts/utils/validate-versions.sh --unreleased` before creating PR
- [ ] **Check docs/HUB-SYNC-CHECKLIST.md** - Review if changes affect hub repository
- [ ] **Test changes locally** - Verify all scripts and CLI commands work
- [ ] **Update all related documentation** - Update docs/*, docs/agents/claude/README.md, CONTRIBUTING.md if behavior/architecture changes

**⚠️ DOCUMENTATION REVISION RULE (NON-NEGOTIABLE):**

Every code change MUST trigger a documentation review:

1. **CHANGELOG.md** - MUST be updated for ALL changes
   - Describe what changed, why, and any breaking changes
   - Add entry under `## [Unreleased]` section

2. **README.md** - MUST be reviewed and updated if user-facing changes
   - New features → add to feature list and usage section
   - Changed commands → update command examples
   - New options/flags → document in usage section

3. **Related documentation** - MUST be updated if applicable
   - docs/USAGE-GUIDE.md - Update usage guide for new commands
   - docs/CONFIGURATION.md - Update configuration guide for new options
   - docs/FEATURES.md - Update feature descriptions for new capabilities
   - docs/agents/claude/GUIDE.md - Update developer guide for new features
   - Use proper version markers for new features (e.g., `v3.6.0+`)

---

## Version Consistency Rules

**CRITICAL**: Version references must be consistent across all files to avoid user confusion.

### Version Validation

Before creating any PR that touches version-related files, run:

```bash
# During development (allows unreleased version references)
./scripts/utils/validate-versions.sh --unreleased

# Before release (strict mode)
./scripts/utils/validate-versions.sh
```

### Files That Must Match

| File | What to Update |
|------|----------------|
| `scripts/utils/version.sh` | Source of truth (CLI_VERSION) |
| `README.md` | Header version badge + footer version |
| `CHANGELOG.md` | Latest release section |
| `docs/USAGE-GUIDE.md` | Version markers for new commands |
| `docs/CONFIGURATION.md` | Version markers for new configuration options |
| `docs/FEATURES.md` | Version markers for new features |
| `docs/agents/claude/GUIDE.md` | Version markers + version history |

### Version Marker Format

When documenting new features, use this format:

```markdown
### Feature Name (v3.6.0+)

Description of the feature...
```

**Rules**:
- ✅ **DO** add version markers for NEW features
- ✅ **DO** use the NEXT version number if feature is unreleased
- ❌ **DON'T** change historical version markers (keep `v3.1.0+` as is)
- ❌ **DON'T** use version markers on every heading, only on major features

**Example**:
```markdown
# Good
### Tracing System (v3.6.0+)
Monitor CLI performance with OpenTelemetry...

### Project Registry (v3.1.0+)
Track registered projects...

# Bad
### Configuration
Shows configuration... (← no version needed for core features)
```

### Common Version Issues

#### Issue: Future version references
**Problem**: Documentation refers to `v3.6.0` but `version.sh` still shows `v3.5.0`

**Solution**:
- During development: This is OK, run validator with `--unreleased`
- Before release: Bump version in `version.sh` or update docs

#### Issue: Inconsistent version numbers
**Problem**: README shows `v3.5.0` but CHANGELOG latest is `v3.4.3`

**Solution**:
- Run `./scripts/utils/validate-versions.sh` to find all inconsistencies
- Use `ai-use-case bump-version` to update all locations automatically

#### Issue: Missing version history
**Problem**: New version released but not in docs/agents/claude/GUIDE.md version history

**Solution**:
- Add entry to version history section in docs/agents/claude/GUIDE.md
- Format: `- **v3.6.0**: Brief description of main features`

### Complete Documentation

See [docs/VERSION-UPDATE-CHECKLIST.md](docs/VERSION-UPDATE-CHECKLIST.md) for complete version management guidelines.

---

**PRs without proper documentation updates will be rejected.**

#### CHANGELOG.md Format

Add your changes under the `## [Unreleased]` section:

```markdown
## [Unreleased]

### Added
- Version checking feature with 24-hour cache

### Changed
- Improved sync script performance

### Fixed
- Bug in filename parsing for research sessions
```

#### Hub Sync Checklist

If your changes affect:
- Session types (implementation/research)
- File naming conventions
- Template structure
- CLI commands or workflow

Then review **docs/HUB-SYNC-CHECKLIST.md** and ensure corresponding updates are made to the hub repository.

#### Running Tests

The project uses [bats-core](https://github.com/bats-core/bats-core) for automated testing.

**Setup** (one-time):
```bash
git submodule update --init --recursive
```

**Running Tests**:
```bash
# Run all tests
./run-tests.sh

# Run specific test file
./run-tests.sh version
./run-tests.sh config-manager

# Run with verbose output
./run-tests.sh --verbose

# Run tests matching a pattern
./run-tests.sh --filter "help"

# List available test files
./run-tests.sh --list
```

**Writing Tests**:

Test files are located in `tests/` with `.bats` extension. Each test file should:

1. Load the test helper: `load 'test_helper'`
2. Use `setup()` and `teardown()` for test isolation
3. Follow existing patterns in the codebase

Example test:
```bash
#!/usr/bin/env bats
load 'test_helper'

setup() {
    common_setup
}

teardown() {
    common_teardown
}

@test "descriptive test name" {
    run some_command
    assert_success
    assert_output --partial "expected output"
}
```

#### Manual Testing

In addition to automated tests, verify your changes work end-to-end:

```bash
# Test CLI commands
./ai-use-case --help
./ai-use-case --version

# Test scripts directly
./setup-project.sh /tmp/test-project
./sync-ai-use-cases.sh /tmp/test-project
./document-ai-session.sh /tmp/test-project
```

#### Documentation Updates

Update relevant documentation:
- **README.md** - Quick start and overview
- **docs/USAGE-GUIDE.md** - Detailed usage instructions
- **docs/CONFIGURATION.md** - Configuration options
- **docs/FEATURES.md** - Feature descriptions
- **docs/agents/claude/README.md** - Quick reference for Claude Code
- **CHANGELOG.md** - Version history and changes
- **docs/HUB-SYNC-CHECKLIST.md** - If adding features that affect the hub

## Working with Claude Code

When using Claude Code (Anthropic's AI coding assistant) in this repository:

### Creating Features with Claude Code

1. **Start a session**: Ask Claude to implement your feature
2. **Claude creates branch**: Claude will create a feature branch automatically
3. **Claude implements**: Claude makes changes, commits with proper messages
4. **Claude asks about PR**: Claude will ask if you want to create a PR
5. **Review and approve**: Review the changes and approve PR creation

### Claude Code Guidelines

Claude Code is instructed to:
- Always create a feature branch (never commit directly to main)
- Follow the `feature/description` naming convention
- Make atomic commits with conventional commit messages
- Update CHANGELOG.md with all changes
- Check docs/HUB-SYNC-CHECKLIST.md for hub-related changes
- Test changes before creating PR
- Update documentation as needed
- Ask before creating the pull request

### Example Claude Code Session

```
You: "Add a --dry-run flag to the sync command"

Claude: [Creates feature/add-dry-run-flag branch]
Claude: [Implements the feature with proper commits]
Claude: [Updates CHANGELOG.md, tests locally, updates docs]
Claude: "I've implemented the --dry-run flag. Would you like me to create a pull request?"

You: "Yes, please create the PR"

Claude: [Creates PR with detailed description]
```

## Branch Protection Rules

To enforce this workflow on GitHub, configure branch protection for `main`:

### GitHub Settings > Branches > Add rule

**Branch name pattern:** `main`

**Required settings:**
- ✅ Require a pull request before merging
  - ✅ Require approvals: 1 (or 0 for solo development)
- ✅ Require status checks to pass before merging (if you add CI/CD)
- ✅ Require branches to be up to date before merging
- ✅ Do not allow bypassing the above settings

**Optional but recommended:**
- ✅ Require linear history (no merge commits, use rebase or squash)
- ✅ Require signed commits
- ✅ Include administrators (enforces rules even for repo admins)

## Code Review Guidelines

When reviewing pull requests:

### For Reviewers

- **Functionality**: Does it work as intended?
- **Testing**: Has it been tested locally?
- **Documentation**: Are docs updated?
- **Changelog**: Is CHANGELOG.md updated?
- **Hub sync**: If applicable, is hub repo updated?
- **Code quality**: Is the code clean and maintainable?
- **Breaking changes**: Are they necessary and documented?

### For Authors

- Respond to feedback promptly
- Keep PRs focused and atomic (one feature/fix per PR)
- Update your PR based on review comments
- Squash/rebase before merge if requested

## Release Process

When ready to release a new version:

1. Create a release PR with version bump:
   ```bash
   git checkout -b release/v2.3.0
   # Update the VERSION constant in ./ai-use-case (at the top of the file)
   # Move "Unreleased" changes in CHANGELOG.md to new version section
   git commit -m "chore: prepare release v2.3.0"
   git push -u origin release/v2.3.0
   ```

2. Create PR and get approval

3. Merge to main

4. Create GitHub release:
   - Tag: `v2.3.0`
   - Title: "Release v2.3.0"
   - Description: Copy from CHANGELOG.md

5. Users will be notified via automatic version checking

## Questions or Issues?

- **Bugs**: Open an issue with reproduction steps
- **Features**: Open an issue for discussion before implementing
- **Questions**: Use GitHub Discussions or open an issue

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (check LICENSE file).
