# Optimize Hub Organization

**Command:** `/use-case:optimize-organization`
**Purpose:** Analyze hub organization and suggest improvements for better documentation discoverability
**Agent:** Organization Optimizer (Phase 5)

---

## Your Task

When the user invokes this command, you will analyze the organizational structure of their AI Use Case documentation hub, detect suboptimal organization patterns, map relationships between documents, and provide actionable recommendations to improve discoverability.

## Workflow

### Step 0: Determine Hub Path

**Get hub path:**
1. Check if hub is configured: Look for `.ai-use-case-config` or run `ai-use-case config show`
2. Default hub path: `~/.local/share/ai-use-case-cli/hub`
3. Environment override: `AI_USECASES_DIR` if set
4. If hub doesn't exist, show error and exit

**Verify hub structure:**
- Check that `by-project/` directory exists
- Verify at least some documents exist
- If < 10 documents, proceed but note limited analysis

### Step 1: Collect Hub Data

**Build document inventory:**

1. **Find all documents:**
   - Scan `by-project/` directory recursively
   - Find all `.md` files matching pattern: `YYYY-Wxx-MM-DD_TICKET-XXX_*.md`
     - YYYY = year (4 digits)
     - W = literal capital W
     - xx = week number (2 digits, e.g., W49)
     - MM = month (2 digits)
     - DD = day (2 digits)
   - Build list of documents with metadata

2. **Extract metadata from each document:**
   ```javascript
   const documents = [];
   for (const file of mdFiles) {
     const filename = path.basename(file);
     const filepath = file;
     const content = await fs.readFile(file, 'utf-8');

     // Parse filename: YYYY-Wxx-MM-DD_TICKET-XXX_topic-slug.md
     // Example: 2025-W49-12-01_TICKET-001_topic-slug.md
     // Captures: (year)-(W)(week)-(month)-(day)_(ticket)_(topicSlug).md
     const match = filename.match(/^(\d{4})-W(\d{2})-(\d{2})-(\d{2})_([A-Z]+-\d+)_(.+)\.md$/);
     if (match) {
       const [_, year, week, month, day, ticket, topicSlug] = match;

       // Extract frontmatter
       const frontmatterMatch = content.match(/^\*\*Date:\*\* (.+)$/m);
       const complexityMatch = content.match(/^\*\*Complexity:\*\* (.+)$/m);
       const toolMatch = content.match(/^\*\*AI Tool Used:\*\* (.+)$/m);
       const timeSavedMatch = content.match(/^\*\*Time Saved:\*\* (.+)$/m);

       documents.push({
         project: path.basename(path.dirname(file)),
         filename,
         filepath,
         date: `${year}-${month}-${day}`,
         week: `W${week}`,
         ticket,
         topic_slug: topicSlug,
         frontmatter: {
           ai_tool: toolMatch ? toolMatch[1] : null,
           complexity: complexityMatch ? complexityMatch[1] : null,
           time_saved: timeSavedMatch ? timeSavedMatch[1] : null
         },
         full_content: content
       });
     }
   }
   ```

3. **Gather topic information:**
   - List existing topics from `by-topic/` directory
   - Count documents per topic
   - List projects per topic

4. **Build hub metadata:**
   ```javascript
   const hubMetadata = {
     total_documents: documents.length,
     total_projects: [...new Set(documents.map(d => d.project))].length,
     topics: fs.readdirSync(path.join(hubPath, 'by-topic')).map(topic => ({
       name: topic,
       document_count: fs.readdirSync(path.join(hubPath, 'by-topic', topic)).length,
       projects: [...new Set(/* extract from symlinks */)]
     }))
   };
   ```

### Step 2: Show Analysis Progress

Show user that analysis is starting:

```
═══════════════════════════════════════════════
Hub Organization Analysis
═══════════════════════════════════════════════

Hub: ~/.local/share/ai-use-case-cli/hub
Documents: 127
Projects: 12
Topics: 34

Analyzing hub organization...
```

### Step 3: Invoke Organization Agent

Use the Task tool to invoke the organization agent:

```javascript
const agentResult = await Task({
  subagent_type: "use-case-organization-agent",
  description: "Analyze hub organization",
  prompt: `You are the Organization Intelligence Agent. Analyze the following hub data and provide recommendations for improving documentation discoverability.

Hub Path: ${hubPath}

Hub Metadata:
${JSON.stringify(hubMetadata, null, 2)}

Documents (${documents.length} total):
${JSON.stringify(documents, null, 2)}

Please analyze:
1. Topic organization (merge/split/rename opportunities)
2. Relationships between documents (sequential, technical similarity, prerequisite, alternative)

Provide recommendations in JSON format as specified in the agent prompt.

Focus on HIGH priority recommendations that significantly improve discoverability.
Confidence threshold: 0.7 (reject recommendations below this)
Phase 5.0 scope: Topic analysis and relationship mapping only (tags deferred to Phase 5.1)

Output the complete JSON analysis structure.`
});
```

**Handle agent invocation:**
- Show progress indicator while agent runs (typically 30-60 seconds)
- If agent fails, show error and offer to retry
- Parse JSON response from agent

### Step 4: Parse Agent Response

```javascript
const analysis = JSON.parse(agentResult);

// Validate response structure
if (!analysis.analysis_summary || !analysis.topic_analysis || !analysis.relationship_mapping) {
  throw new Error('Invalid agent response format');
}

// Extract key metrics
const summary = analysis.analysis_summary;
const topicRecs = analysis.topic_analysis.recommendations || [];
const relationshipRecs = analysis.relationship_mapping.recommendations || [];
const insights = analysis.insights || [];

// Group recommendations by priority
const highPriority = [...topicRecs, ...relationshipRecs].filter(r => r.priority === 'HIGH');
const mediumPriority = [...topicRecs, ...relationshipRecs].filter(r => r.priority === 'MEDIUM');
const lowPriority = [...topicRecs, ...relationshipRecs].filter(r => r.priority === 'LOW');
```

### Step 5: Present Analysis Summary

Show high-level summary to user:

```
✓ Analysis complete (45 seconds)

═══════════════════════════════════════════════
Organization Analysis Results
═══════════════════════════════════════════════

Hub Health: 7.5/10

Key Findings:
✓ Strong: Consistent naming (98% compliance)
✓ Good: Clear topic structure (34 topics)
⚠ Opportunity: 3 topic groups could be merged
⚠ Info: 156 relationships detected

Recommendations:
  8 HIGH priority (+25% discoverability)
  12 MEDIUM priority
  10 LOW priority

Estimated Impact: +25-30% improved discoverability
Estimated Time: 5-10 minutes to apply all recommendations

───────────────────────────────────────────────

What would you like to do?
1. Review all recommendations (detailed view)
2. Apply HIGH priority recommendations
3. Apply specific recommendations (choose which)
4. Save analysis and exit
5. Cancel

Enter your choice (1-5):
```

### Step 6: Handle User Selection

#### Option 1: Review All Recommendations

Generate detailed markdown report grouped by priority:

```markdown
# Organization Optimization Recommendations

## Hub: ~/.local/share/ai-use-case-cli/hub
**Analyzed:** 127 documents across 12 projects
**Generated:** 2025-12-15 14:30:00

---

## HIGH Priority (8 recommendations)

### REC-TOPIC-001: Merge Topics (Confidence: 0.92)
**Impact:** 8 files, +25% discoverability

**Current state:**
- Topic: `auth` (3 documents)
- Topic: `authentication` (2 documents)
- Topic: `jwt-auth` (3 documents)

**Recommendation:**
Consolidate all three topics into `authentication`

**Rationale:**
All three topics cover authentication domain with 85% content overlap. Fragmentation makes it harder to find related work. Merging creates a single, comprehensive authentication knowledge base.

**Evidence:**
- Shared technologies: JWT, OAuth, Express, Passport
- Common patterns: token validation, session management
- Cross-references: 4 documents reference each other
- Content similarity: 0.87 average

**Affected files:**
1. 2025-W48-11-25_AUTH-001_jwt-implementation.md
2. 2025-W48-11-28_AUTH-003_oauth-setup.md
3. 2025-W49-12-01_AUTH-005_token-refresh.md
[... 5 more files]

**Actions required:**
1. Move all symlinks from `auth` and `jwt-auth` to `authentication/`
2. Remove empty `auth` and `jwt-auth` directories
3. Update `.meta/optimization-history.json`

**Estimated time:** 30 seconds

---

### REC-TOPIC-002: Split Large Topic (Confidence: 0.88)
**Impact:** 15 files, +20% discoverability

**Current state:**
- Topic: `database-work` (15 documents covering migrations, optimization, schema)

**Recommendation:**
Split into three focused topics:
- `database-migrations` (6 documents) - Schema changes, migration scripts, versioning
- `database-optimization` (5 documents) - Query performance, indexing, caching
- `database-schema` (4 documents) - Schema design, relationships, constraints

**Rationale:**
Topic too broad with low average similarity (0.52). Documents cluster into 3 distinct patterns. Splitting enables better discovery by intent.

**Evidence:**
- Distinct clusters detected: 3
- Cluster similarity scores: 0.82, 0.79, 0.76
- Keyword divergence: High (migration vs optimization vs design terminology)

**Actions required:**
1. Create three new directories: `database-migrations/`, `database-optimization/`, `database-schema/`
2. Move symlinks to appropriate directories based on content
3. Remove `database-work/` directory
4. Update `.meta/optimization-history.json`

**Estimated time:** 60 seconds

---

### REC-REL-001: Add Sequential Relationship (Confidence: 0.94)
**Type:** Sequential
**From:** 2025-W48-11-25_AUTH-001_jwt-implementation.md
**To:** 2025-W49-12-02_AUTH-002_jwt-refresh-tokens.md

**Rationale:**
AUTH-002 explicitly builds upon JWT implementation from AUTH-001. Creating this relationship makes the progression visible.

**Evidence:**
- Explicit reference: "This work extends the JWT implementation from AUTH-001"
- Ticket sequence: AUTH-001 → AUTH-002
- Shared files: auth/jwt.ts, middleware/auth.ts
- Time gap: 7 days (typical iteration cycle)

**Action:** Add relationship to `.meta/relationships.json`

---

[... more HIGH priority recommendations]

## MEDIUM Priority (12 recommendations)

### REC-TOPIC-003: Rename Topic (Confidence: 0.85)
**Current:** `api-stuff`
**Suggested:** `api-development`
**Rationale:** Topic name too casual/vague. More professional name improves searchability.

[... more MEDIUM priority recommendations]

## LOW Priority (10 recommendations)

[... LOW priority recommendations]

---

## Summary

Applying all recommendations will:
- Consolidate 3 fragmented topic groups
- Split 1 overly broad topic
- Establish 22 document relationships
- Improve discoverability by an estimated 25-30%

Recommended approach:
1. Start with HIGH priority recommendations (biggest impact)
2. Review results before applying MEDIUM/LOW priority

```

After showing detailed view, ask:

```
Would you like to:
1. Apply HIGH priority recommendations
2. Apply specific recommendations (choose which)
3. Apply all recommendations
4. Save and exit

Enter your choice (1-4):
```

#### Option 2: Apply HIGH Priority Recommendations

**Confirmation step:**

```
You're about to apply 8 HIGH priority recommendations:

Changes:
- Merge 3 topic groups (8 symlinks moved)
- Split 1 large topic (15 symlinks reorganized)
- Add 22 relationships to .meta/relationships.json
- Rename 1 topic directory

Files affected: 23 symlinks
Source files: Unchanged (preserves git history)
Estimated time: 2-3 minutes

A backup will be created in .meta/.backup/ before applying changes.

Continue? (yes/no):
```

If user confirms `yes`, proceed to Step 7.

#### Option 3: Apply Specific Recommendations

Show numbered list of all recommendations:

```
Select recommendations to apply (comma-separated numbers):

HIGH Priority:
  1. [TOPIC] Merge: auth + authentication + jwt-auth → authentication (8 files)
  2. [TOPIC] Split: database-work → 3 topics (15 files)
  3. [REL] Add sequential: AUTH-001 → AUTH-002
  [... more HIGH]

MEDIUM Priority:
  9. [TOPIC] Rename: api-stuff → api-development (6 files)
  [... more MEDIUM]

LOW Priority:
  [... LOW priority]

Enter numbers (e.g., 1,2,5,9) or 'all' for all:
```

Parse user input and proceed to Step 7 with selected recommendations.

#### Option 4: Save Analysis and Exit

```
Saving analysis to .meta/organization-analysis-2025-12-15.json...
✓ Saved

You can review this analysis later or apply recommendations using:
  ai-use-case apply-organization --analysis .meta/organization-analysis-2025-12-15.json

[Note: CLI command for Phase 5.1]
```

### Step 7: Apply Selected Recommendations

**Pre-flight checks:**
1. Verify write permissions on hub directory
2. Check for broken symlinks (warn if found)
3. Detect files changed since analysis started (warn if any)
4. Create backup directory: `.meta/.backup/optimization-YYYY-MM-DD-HHMMSS/`

**Backup current state:**
```javascript
const backupDir = path.join(hubPath, '.meta/.backup', `optimization-${timestamp}`);
await fs.mkdir(backupDir, { recursive: true });
await fs.copyFile(
  path.join(hubPath, '.meta/relationships.json'),
  path.join(backupDir, 'relationships.json.bak')
);
// Backup topic structure (list of topics and symlinks)
```

**Apply recommendations with progress:**

```
Applying recommendations...

[1/4] Merging topics: auth + authentication → authentication
      ✓ Moved 8 symlinks
      ✓ Removed empty directories

[2/4] Splitting topic: database-work → 3 topics
      ✓ Created database-migrations/
      ✓ Created database-optimization/
      ✓ Created database-schema/
      ✓ Moved 15 symlinks
      ✓ Removed database-work/

[3/4] Adding relationships to .meta/relationships.json
      ✓ Added 22 new relationships
      ✓ 156 total relationships

[4/4] Updating audit log
      ✓ Logged to .meta/optimization-history.json

═══════════════════════════════════════════════
✅ Optimization Complete
═══════════════════════════════════════════════

Changes applied:
  • 23 symlinks updated
  • 2 directories removed
  • 3 directories created
  • 22 relationships added

Source files unchanged (preserves git history)
Backup saved to: .meta/.backup/optimization-2025-12-15-143000/

Discoverability improvement: +25% (estimated)

Run 'ai-use-case view' to explore your optimized hub!
```

**Log changes to audit file:**
```javascript
const historyEntry = {
  timestamp: new Date().toISOString(),
  recommendations_applied: selectedRecs.map(r => ({
    id: r.id,
    type: r.type,
    priority: r.priority,
    affected_files: r.affected_file_count
  })),
  changes: {
    symlinks_moved: 23,
    directories_removed: 2,
    directories_created: 3,
    relationships_added: 22
  },
  user_confirmed: true,
  backup_location: backupDir
};

await appendToFile(
  path.join(hubPath, '.meta/optimization-history.json'),
  JSON.stringify(historyEntry, null, 2)
);
```

### Step 8: Offer Follow-Up Actions

```
What would you like to do next?
1. View optimized hub (open in file browser)
2. Re-run analysis (see if more improvements possible)
3. Sync hub to remote (if using git mode)
4. Exit

Enter your choice (1-4):
```

## Key Principles

1. **Always Confirm:** Never modify the hub without explicit user confirmation
2. **Show Impact:** Clearly communicate what will change and why
3. **Preserve History:** Only update symlinks, never modify source files
4. **Be Specific:** Show exact files affected, not just counts
5. **Enable Rollback:** Create backups before applying changes
6. **Track Changes:** Log all modifications to audit file

## Error Handling

### Hub Not Found
```
❌ Error: Hub directory not found

The hub should be at: ~/.local/share/ai-use-case-cli/hub

Initialize your hub first:
  ai-use-case --init

Or check your configuration:
  ai-use-case config show
```

### Insufficient Documents
```
ℹ Hub Analysis: Insufficient Data

Your hub has only 8 documents. Organization analysis works best with 20+ documents.

Current state:
  • 8 documents across 3 projects
  • 5 topics (good granularity)
  • Continue building your knowledge base!

Minimal recommendations generated based on available data.

Continue with analysis? (y/N):
```

### Permission Denied
```
❌ Error: Permission Denied

Cannot write to hub directory: ~/.local/share/ai-use-case-cli/hub

Fix permissions:
  sudo chown -R $USER ~/.local/share/ai-use-case-cli/hub

Or run in analysis-only mode (no modifications).
```

### Agent Not Enabled
```
❌ Organization Agent Not Enabled

The organization optimizer agent needs to be enabled first.

Enable it:
  ai-use-case agents enable organization-optimizer

Then try this command again.
```

### Broken Symlinks Detected
```
⚠ Warning: Broken Symlinks Detected

Found 2 broken symlinks in hub:
  • by-topic/auth/old-file.md → target not found
  • by-topic/api/deleted.md → target not found

Recommendations:
1. Fix symlinks manually
2. Run: ai-use-case sync --validate (auto-cleanup)
3. Continue with analysis (broken links ignored)

Continue? (y/N):
```

### Files Changed Since Analysis
```
⚠ Warning: Hub Modified Since Analysis

3 files have been modified since analysis started:
  • AUTH-001_jwt-implementation.md (modified 5 minutes ago)
  • DATABASE-005_optimization.md (modified 2 minutes ago)

Recommendations:
1. Re-run analysis (recommended) - ensures recommendations are current
2. Continue anyway (not recommended) - may apply outdated recommendations

Continue? (1 to re-run, 2 to proceed, 3 to cancel):
```

### Agent Invocation Failed
```
❌ Analysis Failed

The organization agent encountered an error during analysis.

Error: [specific error message from agent]

Possible causes:
  • Claude Code not available
  • Hub data format issue
  • Agent configuration problem

Try:
1. Verify Claude Code is running
2. Check agent status: ai-use-case agents status
3. Re-run with verbose logging: /use-case:optimize-organization --verbose

Need help? Check logs at: ~/.local/share/ai-use-case-cli/logs/
```

### No Recommendations Generated
```
✅ Your Hub is Already Well-Organized!

═══════════════════════════════════════════════

Hub Health: 9.2/10

Strengths:
✓ Excellent topic coherence (all topics well-scoped)
✓ Clear naming conventions (100% compliance)
✓ Strong relationship mapping (178 relationships detected)
✓ Optimal topic granularity (5-15 docs per topic)

Minor Suggestions (LOW priority):
  • 2 additional cross-references could be added

Great work maintaining your knowledge base! 🎉

Run this command again after adding 20+ more documents to see if new patterns emerge.
```

## Implementation Details

### Topic Merge Implementation

```javascript
async function mergeTopics(sourceTopics, targetTopic) {
  const byTopicDir = path.join(hubPath, 'by-topic');
  const targetDir = path.join(byTopicDir, targetTopic);

  // Create target directory if it doesn't exist
  await fs.mkdir(targetDir, { recursive: true });

  // Move symlinks from source topics to target
  for (const sourceTopic of sourceTopics) {
    const sourceDir = path.join(byTopicDir, sourceTopic);
    const symlinks = await fs.readdir(sourceDir);

    for (const symlink of symlinks) {
      const oldPath = path.join(sourceDir, symlink);
      const newPath = path.join(targetDir, symlink);

      // Move symlink (or recreate if needed)
      await fs.rename(oldPath, newPath);
    }

    // Remove empty source directory
    await fs.rmdir(sourceDir);
  }

  return {
    symlinks_moved: totalSymlinks,
    directories_removed: sourceTopics.length
  };
}
```

### Topic Split Implementation

```javascript
async function splitTopic(sourceTopic, targetTopics) {
  const byTopicDir = path.join(hubPath, 'by-topic');
  const sourceDir = path.join(byTopicDir, sourceTopic);

  // Create target directories
  for (const target of targetTopics) {
    await fs.mkdir(path.join(byTopicDir, target.name), { recursive: true });
  }

  // Distribute symlinks based on recommendation
  const symlinks = await fs.readdir(sourceDir);
  for (const symlink of symlinks) {
    // Find which target this file should go to (based on agent recommendation)
    const targetTopic = findTargetForFile(symlink, targetTopics, recommendation);
    const targetDir = path.join(byTopicDir, targetTopic.name);

    await fs.rename(
      path.join(sourceDir, symlink),
      path.join(targetDir, symlink)
    );
  }

  // Remove source directory
  await fs.rmdir(sourceDir);

  return {
    symlinks_moved: symlinks.length,
    directories_created: targetTopics.length,
    directories_removed: 1
  };
}
```

### Relationship File Update

```javascript
async function addRelationships(recommendations) {
  const relFile = path.join(hubPath, '.meta/relationships.json');

  // Read existing relationships or create new structure
  let relationships = { version: "1.0", relationships: [] };
  if (await fs.exists(relFile)) {
    relationships = JSON.parse(await fs.readFile(relFile, 'utf-8'));
  }

  // Add new relationships from recommendations
  for (const rec of recommendations) {
    relationships.relationships.push({
      id: `rel-${Date.now()}-${Math.random().toString(36).slice(2, 9)}`,
      source: rec.source_file,
      target: rec.target_file,
      type: rec.relationship_type,
      confidence: rec.confidence,
      created_by: "organization-agent",
      created_at: new Date().toISOString(),
      evidence: rec.evidence.explicit_reference || rec.reason
    });
  }

  relationships.last_updated = new Date().toISOString();

  // Write updated relationships
  await fs.writeFile(relFile, JSON.stringify(relationships, null, 2));

  return relationships.relationships.length;
}
```

## Examples

### Example 1: Full Optimization Workflow

**User:** `/use-case:optimize-organization`

**You:**
1. Determine hub path: `~/.local/share/ai-use-case-cli/hub`
2. Collect hub data (127 documents, 12 projects, 34 topics)
3. Show progress: "Analyzing hub organization..."
4. Invoke organization agent with full context
5. Parse response (8 HIGH, 12 MEDIUM, 10 LOW recommendations)
6. Present summary with options
7. User selects "2. Apply HIGH priority recommendations"
8. Show confirmation with detailed change preview
9. User confirms "yes"
10. Apply changes with progress indicators
11. Show success summary
12. Offer follow-up actions

### Example 2: Well-Organized Hub

**User:** `/use-case:optimize-organization`

**You:**
1. Collect hub data
2. Invoke agent
3. Agent returns: no HIGH priority, 2 LOW priority recommendations
4. Show: "Your hub is already well-organized! (9.2/10)"
5. List strengths
6. Show optional LOW priority suggestions
7. Exit

### Example 3: Small Hub

**User:** `/use-case:optimize-organization`

**You:**
1. Collect hub data (only 8 documents)
2. Show: "Hub has insufficient data for comprehensive analysis"
3. Ask: "Continue with limited analysis? (y/N)"
4. If user says yes:
   - Run analysis with caveat
   - Show basic recommendations
   - Encourage building knowledge base

### Example 4: Detailed Review Before Applying

**User:** `/use-case:optimize-organization`

**You:**
1. Run full analysis
2. User selects "1. Review all recommendations"
3. Show detailed markdown report with all HIGH/MEDIUM/LOW recommendations
4. User reviews carefully
5. Ask: "Apply which recommendations?"
6. User selects: "1,2,5" (specific recommendations)
7. Confirm selected changes
8. Apply only selected recommendations
9. Show results

---

## Notes

- **Phase 5.0 Implementation:** Topic analysis and relationship mapping only (tags deferred to Phase 5.1)
- **Agent Required:** Organization optimizer must be enabled
- **Claude Code Required:** This command only works in Claude Code (uses Task tool)
- **Performance:** Analysis of 100-200 documents takes 30-90 seconds
- **Safety:** Always creates backup before modifications
- **Reversible:** Changes can be undone by restoring from `.meta/.backup/`
- **Git-friendly:** Only modifies symlinks, never source files (git history preserved)
- **Audit Trail:** All changes logged to `.meta/optimization-history.json`

---

**Remember:** Your goal is to help users create a well-organized hub where related documentation is easy to find. Always confirm before making changes, show clear previews, and preserve the integrity of source files!
