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
git commit -m "feat: add version checking to CLI

Implements automatic version checking that runs once per day
in the background. Notifies users when updates are available.

Resolves #123"
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

- [ ] **Update CHANGELOG.md** - Add entry under "Unreleased" section
- [ ] **Check HUB-SYNC-CHECKLIST.md** - Review if changes affect hub repository
- [ ] **Test changes locally** - Verify all scripts and CLI commands work
- [ ] **Update documentation** - Update README.md or CLAUDE.md if behavior changes

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

Then review **HUB-SYNC-CHECKLIST.md** and ensure corresponding updates are made to the hub repository.

#### Testing

Test your changes thoroughly:

```bash
# Test CLI commands
./ai-use-case --help
./ai-use-case --version

# Test scripts directly
./setup-project.sh /tmp/test-project
./sync-ai-use-cases.sh /tmp/test-project
./document-ai-session.sh /tmp/test-project

# Test VS Code extension
cd vscode-extension
npm install
npm run compile
# Press F5 in VS Code to test
```

#### Documentation Updates

Update relevant documentation:
- **README.md** - User-facing documentation, installation, usage
- **CLAUDE.md** - Instructions for Claude Code when working in this repo
- **CHANGELOG.md** - Version history and changes
- **HUB-SYNC-CHECKLIST.md** - If adding features that affect the hub

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
- Check HUB-SYNC-CHECKLIST.md for hub-related changes
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
   # Update version in ai-use-case script
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
