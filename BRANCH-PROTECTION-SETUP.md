# GitHub Branch Protection Setup Guide

This guide walks you through setting up branch protection rules for the `main` branch to enforce the PR workflow.

## Prerequisites

- Repository admin access
- GitHub repository: `mt-osiris-tools/ai-use-case-cli`

## Setup Steps

### 1. Navigate to Branch Protection Settings

1. Go to your GitHub repository: https://github.com/mt-osiris-tools/ai-use-case-cli
2. Click **Settings** (top navigation)
3. Click **Branches** (left sidebar under "Code and automation")
4. Under "Branch protection rules", click **Add rule** (or **Add classic branch protection rule**)

### 2. Configure Branch Name Pattern

**Branch name pattern:** `main`

This will apply the protection rules to the main branch.

### 3. Enable Required Settings

Check the following boxes:

#### ✅ Require a pull request before merging

This prevents direct commits to main and requires all changes to go through PRs.

**Sub-options:**
- **Require approvals:** Set to `1` (or `0` for solo development)
  - For solo development: You can set this to 0 and merge your own PRs **without additional approval**
  - For team development: Set to 1+ to require peer reviews

  **Important:** Setting approvals to 0 does NOT bypass the PR requirement itself. You must still:
  1. Create a feature branch
  2. Push your changes to that branch
  3. Create a pull request
  4. Merge the PR (no approval needed if set to 0)

  You cannot push directly to `main` even with 0 approvals required.

- [ ] Dismiss stale pull request approvals when new commits are pushed (optional)
- [ ] Require review from Code Owners (optional, if you have CODEOWNERS file)
- [ ] Restrict who can dismiss pull request reviews (optional)

#### ✅ Require status checks to pass before merging (Optional - for CI/CD)

Only enable this if you plan to add GitHub Actions or other CI/CD:

- Require branches to be up to date before merging
- Search for status checks (if you have CI/CD workflows configured)

**Note:** You can enable this later when you add automated tests.

#### ✅ Require conversation resolution before merging (Recommended)

Ensures all PR comments are addressed before merging.

#### ✅ Require linear history (Recommended)

Prevents merge commits. Options:
- Only allow squash merging
- Only allow rebase merging

This keeps the git history clean and linear.

### 4. Optional but Recommended Settings

#### ✅ Require signed commits (Optional)

Requires all commits to be signed with GPG:
- Adds extra security
- Verifies commit authorship
- Requires local Git configuration

**Skip this if:**
- You're not familiar with GPG commit signing
- You want to start simple and add it later

#### ✅ Include administrators

Applies all protection rules even to repository administrators.

**Recommended:** Check this to enforce the workflow for everyone, including yourself.

**What this means:**
- Administrators must still create PRs (cannot push directly to `main`)
- Administrators must still follow all protection rules
- With `Require approvals: 0` + `Include administrators`: You can create and merge your own PRs without additional approval
- With `Require approvals: 1+` + `Include administrators`: Even admins need the specified number of approvals

**In practice for solo development:** This ensures you always follow the PR workflow, which maintains clean git history and enables proper code review habits. You'll still be able to merge your own PRs when approvals are set to 0.

#### ✅ Restrict who can push to matching branches (Optional)

Allows you to specify which users/teams can push to the branch.

**For solo development:** Leave unchecked
**For team development:** Consider restricting to maintainers only

### 5. Rules Applied to Everyone

The following settings affect all contributors:

- [ ] Allow force pushes (Leave UNCHECKED)
- [ ] Allow deletions (Leave UNCHECKED)

These should remain disabled to prevent accidental data loss.

### 6. Save the Rule

Click **Create** (or **Save changes**) at the bottom of the page.

## Verification

After saving, verify the rule is active:

1. Go to your repository's main page
2. Look for a branch protection badge next to the `main` branch
3. Try to push directly to main (it should be rejected):
   ```bash
   git checkout main
   echo "test" >> test.txt
   git add test.txt
   git commit -m "test direct commit"
   git push origin main
   # Should fail with: "required status checks" or "pull request required" error
   ```

## Recommended Configuration for This Project

### Solo Development

```
✅ Require a pull request before merging
   - Require approvals: 0
✅ Require conversation resolution before merging
✅ Require linear history
✅ Include administrators
❌ Require signed commits (optional)
❌ Require status checks (add later with CI/CD)
```

**Note:** With this configuration:
- ✅ You must create PRs for all changes (no direct pushes to `main`)
- ✅ You can merge your own PRs without waiting for approval (approvals = 0)
- ✅ Maintains clean git history through PR workflow
- ✅ Enforces discipline even for solo work

### Team Development

```
✅ Require a pull request before merging
   - Require approvals: 1
   - Require review from Code Owners: Yes (if using CODEOWNERS)
✅ Require conversation resolution before merging
✅ Require linear history
✅ Require signed commits (recommended)
✅ Include administrators
✅ Require status checks (if CI/CD is configured)
```

## Quick CLI Test

After setup, test the workflow:

```bash
# This should fail (direct push to main)
git checkout main
git commit --allow-empty -m "test"
git push origin main
# ❌ Error: pushing to main is blocked

# This should work (PR workflow)
git checkout -b feature/test-branch-protection
git commit --allow-empty -m "test: verify branch protection"
git push origin feature/test-branch-protection
gh pr create --title "Test PR" --body "Testing branch protection"
# ✅ Success: PR created

# Merge the PR on GitHub, then:
git checkout main
git pull origin main
# ✅ Success: changes merged via PR
```

## Troubleshooting

### "Required status checks are not passing"

- You may have accidentally enabled "Require status checks to pass"
- Either disable this setting or add CI/CD workflows

### "You need at least 1 approving review"

- If working solo, set "Require approvals" to 0
- If working with a team, get someone to review your PR

### "You can't bypass branch protection"

- This means the rule is working correctly!
- Create a feature branch and PR instead of pushing directly

### "Administrator bypass"

- If "Include administrators" is unchecked, admins can bypass rules
- Check this box to enforce rules for everyone

## Next Steps

1. Update your local workflow to use feature branches
2. Test creating a PR with the new rules
3. Consider adding CI/CD later (GitHub Actions for testing)
4. Document any project-specific branch protection customizations

## References

- [GitHub Branch Protection Documentation](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [CONTRIBUTING.md](./CONTRIBUTING.md) - Full contribution guidelines
- [CLAUDE.md](./CLAUDE.md) - Instructions for Claude Code workflow
