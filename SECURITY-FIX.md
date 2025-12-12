# Safety Fix: Uninstall Script Directory Detection Issue

## Issue Summary

**Severity**: HIGH (Data Loss Risk)
**Impact**: Potential accidental deletion of documentation hub
**Component**: `scripts/install/uninstall.sh`

## Problem Description

The uninstall script's directory detection logic was insufficient and could accidentally delete the documentation hub instead of the CLI installation:

### Original Code (Unsafe)
```bash
if [ -f "ai-use-case" ] && [ -d ".git" ]; then
    CLI_DIR="$(pwd)"
```

### Problem
This check only verified:
1. Current directory has a file named "ai-use-case"
2. Current directory has a .git directory

This logic could match ANY git repository that happens to contain a file named "ai-use-case", including:
- The documentation hub (if user copied/symlinked the ai-use-case file)
- Any other project with similar naming

### Risk Scenario
1. User accidentally creates `ai-use-case` file in hub directory (copy, symlink, etc.)
2. User runs `ai-use-case uninstall` from hub directory
3. Script incorrectly detects hub as CLI directory
4. User confirms deletion
5. **Entire hub with all documentation is accidentally deleted** (`rm -rf`)

## Fix Implementation

### Three-Layer Protection

#### Layer 1: Strict Directory Verification
```bash
# Requires MULTIPLE CLI-specific files/directories
if [ -f "ai-use-case" ] && [ -d ".git" ] && [ -d "scripts/install" ]; then
    if [ -f "scripts/install/uninstall.sh" ] && [ -f "scripts/core/sync-ai-use-cases.sh" ]; then
        CLI_DIR="$(pwd)"
    fi
fi
```

#### Layer 2: Hub Signature Detection
```bash
# Explicitly check for hub-specific directories
if [ -n "$CLI_DIR" ] && { [ -d "$CLI_DIR/by-project" ] || [ -d "$CLI_DIR/by-date" ] || [ -d "$CLI_DIR/by-topic" ]; }; then
    # Display formatted error message (simplified here for readability)
    # Actual implementation uses color-coded box border
    echo "ERROR: Detected directory looks like the documentation hub!"
    echo "Refusing to remove: $CLI_DIR"
    echo "The hub should NEVER be removed by this script."
    CLI_DIR=""
fi
```

*Note: Actual implementation displays a formatted red error box. Simplified for documentation.*

#### Layer 3: Keyword Warning
```bash
# Warn if path contains "hub" keyword
if [[ "$CLI_DIR" =~ hub ]]; then
    echo "Warning: Path contains 'hub' keyword"
    read -p "Is this the CLI directory? (y/N): " verify_cli
    if [[ ! "$verify_cli" =~ ^[Yy]$ ]]; then
        CLI_DIR=""
    fi
fi
```

### Additional Improvements

1. **Symlink-based detection**: Added Method 3 to detect CLI location from symlink
2. **Standard location verification**: Enhanced Method 2 to verify actual CLI files exist
3. **Multiple detection methods**: Falls back through 3 different detection approaches

## Testing

Created comprehensive test suite: `scripts/install/test-uninstall-detection.sh`

All tests passing:
- ✅ Correctly detects CLI directory when running from CLI repo
- ✅ Rejects hub directory (prevents accidental deletion)
- ✅ Identifies paths with "hub" keyword
- ✅ Verifies CLI-specific files exist

## Impact Assessment

**Before Fix:**
- Risk of complete hub deletion if "ai-use-case" file exists in hub
- No safety checks for hub-like directories
- Weak directory verification

**After Fix:**
- Multiple layers of protection against accidental deletion
- Explicit hub detection and rejection
- Stronger directory verification with multiple CLI-specific file checks
- User confirmation for ambiguous paths

## Recommendations

1. **Immediate**: Deploy this fix in next release
2. **User Communication**: Notify users to update their CLI installation
3. **Documentation**: Add warning about running uninstall from correct location
4. **Future**: Consider adding `--force` flag for advanced users while keeping safe defaults

## Files Changed

- `scripts/install/uninstall.sh` - Enhanced directory detection logic
- `scripts/install/test-uninstall-detection.sh` - New test suite (added)

## Version

- Fixed in: v3.13.0 (pending)
- Affects: All versions prior to v3.13.0
