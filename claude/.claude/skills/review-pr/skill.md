# PR Review with Multi-Service Context

## Metadata
- **Name**: review-pr
- **Description**: Comprehensively review GitHub pull requests with enriched context from Jira tickets, Figma designs, Sentry errors, and project best practices
- **Version**: 1.1.0
- **Author**: PR Review Skill

## Usage

This skill is invoked with:
```
/review-pr <pr-number>
```

Example: `/review-pr 42`

## Prerequisites

Before starting, verify the following:
1. You are in a Git repository with a GitHub remote
2. MCP servers are configured for: GitHub, Jira (optional), Figma (optional), Sentry (optional)
3. User has appropriate access permissions to the repository and linked services

## Process Flow

### Step 1: Validate Environment

First, check the environment:

```bash
# Verify we're in a git repository
git rev-parse --is-inside-work-tree

# Get the GitHub repository info
gh repo view --json owner,name
```

If not in a git repository or no GitHub remote exists, inform the user and exit.

### Step 2: Ask for Checkout Preference

Use the AskUserQuestion tool to prompt the user:

**Question**: "Should I checkout the PR branch for this review?"

**Options**:
1. **No checkout** - Review the diff remotely without checking out the branch. Faster, doesn't affect your working directory.
2. **Yes, use worktree** - Create a git worktree and checkout the PR branch there. Allows running tests and linters without affecting your current work.

Store the user's choice.

**If user selects "Yes, use worktree":**

1. Create a worktree for the PR:
   ```bash
   # Create worktree directory if it doesn't exist
   mkdir -p .worktrees

   # Fetch the PR branch
   gh pr checkout <pr-number> --branch
   PR_BRANCH=$(git branch --show-current)
   git checkout -  # Go back to original branch

   # Create worktree
   git worktree add .worktrees/pr-<pr-number> $PR_BRANCH
   ```

2. Change working directory to the worktree:
   ```bash
   cd .worktrees/pr-<pr-number>
   ```

3. All subsequent commands will run in the worktree context

**Note**: After the review is complete, remind the user to cleanup the worktree:
```bash
git worktree remove .worktrees/pr-<pr-number>
```

### Step 3: Ask for Review Detail Level

Use the AskUserQuestion tool to prompt the user:

**Question**: "How detailed should this review be?"

**Options**:
1. **Concise** - Focus on important issues only. Quick, high-signal comments on critical problems.
2. **Detailed** - Thorough line-by-line review with detailed explanations and suggestions.
3. **High-level** - Architecture and approach feedback only. No line-by-line nitpicks.

Store the user's choice to determine the review style.

### Step 4: Gather Project Best Practices

Before reviewing code, understand the project's standards by checking for these files:

**Required checks** (read if they exist):
1. **`CONTRIBUTING.md`** or **`CONTRIBUTING`** or **`docs/CONTRIBUTING.md`**
   - Contribution guidelines
   - Code style expectations
   - PR requirements
   - Review process

2. **`.github/PULL_REQUEST_TEMPLATE.md`** or **`.github/pull_request_template.md`**
   - Expected PR structure
   - Checklist items
   - Required information

3. **`README.md`** (especially "Development" or "Contributing" sections)
   - Project overview
   - Setup instructions
   - Development workflow

4. **Development docs**: Check for any of these:
   - `docs/DEVELOPMENT.md`
   - `docs/development.md`
   - `DEVELOPMENT.md`
   - `docs/developer-guide.md`

5. **Architecture docs**: Check for:
   - `docs/architecture/`
   - `docs/adr/` (Architecture Decision Records)
   - `ARCHITECTURE.md`

6. **Testing guidelines**: Check for:
   - `docs/TESTING.md`
   - Look at existing test files to understand patterns
   - Check for test coverage requirements in CI configs

7. **Linting and code style configs**:
   - `.eslintrc.js`, `.eslintrc.json` (JavaScript/TypeScript)
   - `.prettierrc` (formatting)
   - `pyproject.toml`, `setup.cfg` (Python)
   - `.rubocop.yml` (Ruby)
   - `rustfmt.toml` (Rust)
   - `.editorconfig` (general)

8. **CI/CD configs**:
   - `.github/workflows/*.yml` - See what checks run on PRs
   - `.gitlab-ci.yml`
   - `Jenkinsfile`

**Use these findings**:
- Verify the PR follows the CONTRIBUTING guidelines
- Check if PR description matches the template
- Apply the project's code style rules to your review
- Validate testing requirements are met
- Ensure CI checks mentioned in workflows are addressed

**If worktree is used**: You can actually run linters and tests:
```bash
# Run linters if they exist
npm run lint  # or yarn lint, pnpm lint
pytest        # Python
cargo clippy  # Rust
rubocop       # Ruby

# Run tests
npm test
pytest
cargo test
```

Include lint/test results in the review.

### Step 5: Fetch PR Data

Use the GitHub MCP server tools to fetch comprehensive PR data:

**Required data to fetch**:
- PR title, description, and author
- PR state (open/closed), created date
- List of changed files with additions/deletions
- Full diff of all changes
- PR comments and reviews (if any exist)
- Commit messages
- PR labels
- CI check status

**Example MCP tool calls** (if GitHub MCP is available):
- `github_get_pull_request(owner, repo, pr_number)`
- `github_get_pull_request_diff(owner, repo, pr_number)`
- `github_list_pull_request_comments(owner, repo, pr_number)`

**Fallback** (if GitHub MCP not available):
Use `gh` CLI via Bash tool:
```bash
gh pr view <pr-number> --json title,body,author,createdAt,state,files,commits,reviews,labels,statusCheckRollup
gh pr diff <pr-number>
```

### Step 5.5: Read All Changed Files

**CRITICAL**: Before analyzing or commenting, read ALL changed files in their entirety to understand full context.

**For remote reviews (no checkout):**
- For files that exist in the current branch: Use Read tool to see "before" state
- For new files being added: Extract the full content from the diff
- Understand what code already exists vs what's being added/modified

**For worktree reviews:**
- Use Read tool to read all changed files directly from the worktree

**Important verification before ANY comment:**
- ❌ **NEVER** comment based only on diff snippets
- ✅ **ALWAYS** verify by reading the complete file
- ✅ Check if documentation/features exist elsewhere in the file
- ✅ Understand the full context around changes
- ✅ Verify related code not shown in the diff

**Example of what NOT to do:**
- Seeing a function in a diff and assuming it lacks documentation
- Suggesting adding something that already exists outside the diff context
- Commenting on line numbers without reading surrounding code

**Example of what TO do:**
- Read the entire file containing the changed code
- Verify assumptions by checking actual file content
- Only comment on issues you can confirm exist after reading full files

### Step 6: Extract External References

Parse the PR body, commit messages, and branch name for:

#### Jira Tickets
Look for patterns:
- `PROJ-1234` (ticket ID)
- `[PROJ-1234]` (in brackets)
- Common prefixes: Uppercase letters followed by dash and numbers

Extract all unique Jira ticket IDs found.

#### Figma Links
Look for URLs matching:
- `https://figma.com/file/...`
- `https://figma.com/proto/...`
- `https://www.figma.com/...`

Extract all unique Figma URLs found.

#### Changed Files
Extract the list of changed file paths from the PR for Sentry correlation.

### Step 7: Fetch Context from MCP Servers

For each external service, attempt to fetch additional context:

#### Jira Context (if tickets found)

For each Jira ticket ID, use Jira MCP tools to fetch:
- Ticket summary and description
- Ticket status (To Do, In Progress, Done, etc.)
- Ticket type (Story, Bug, Task, etc.)
- Priority level
- Acceptance criteria (if available)
- Assignee
- Key comments or discussion points

Graceful degradation: If Jira MCP is not configured or fails, note which tickets were referenced but couldn't be fetched.

#### Figma Context (if design links found)

For each Figma URL, use Figma MCP tools to fetch:
- Design/file name
- Last modified date
- Frame or component names (if specific nodes are linked)
- Design description (if available)

Graceful degradation: If Figma MCP is not configured or fails, include the links in the review but note that metadata couldn't be fetched.

#### Sentry Context (if applicable)

Use Sentry MCP tools to query for:
- Recent errors (last 30 days) in the changed files
- Error frequency and user impact
- Stack traces mentioning changed file paths
- Unresolved errors related to the changes

Query strategy:
- Filter by project/organization
- Search for errors containing changed file paths
- Look for errors in the date range before the PR was created
- Limit to top 5-10 most relevant errors

Graceful degradation: If Sentry MCP is not configured or fails, skip this section.

### Step 8: Analyze the Code

**BEFORE making ANY comment, you MUST:**
1. ✅ Read the complete file containing the code you're commenting on
2. ✅ Verify the issue actually exists (not already documented/handled)
3. ✅ Confirm it's not addressed elsewhere in the file or related files
4. ✅ For Concise mode: Confirm it's truly critical, not just a suggestion
5. ✅ Can point to exact line numbers and quote the problematic code

**If you cannot verify all 5 points above, DO NOT make that comment.**

Based on the selected detail level and project best practices, analyze the PR with focus on:

#### Project-Specific Standards
- **Follows CONTRIBUTING.md guidelines**: Code style, commit messages, PR structure
- **Matches PR template**: All required sections filled out
- **Passes linting**: No linter errors (if worktree used, actually run linters)
- **Test coverage**: Meets project's coverage requirements
- **Documentation**: Updated if required by guidelines
- **Architectural patterns**: Follows established patterns in the codebase

#### Code Quality & Best Practices
- Code organization and structure
- Readability and maintainability
- Following project conventions and patterns (as found in docs)
- Proper naming (variables, functions, classes)
- Code duplication or opportunities for refactoring
- Documentation quality (comments, docstrings)

#### Bugs & Logic Errors
- Edge cases and boundary conditions
- Null/undefined checks
- Error handling completeness
- Race conditions or concurrency issues
- Off-by-one errors
- Incorrect assumptions or logic flaws
- Type safety issues

#### Performance Concerns
- Algorithmic complexity (O(n²) where O(n) is possible)
- Inefficient database queries (N+1 problems)
- Unnecessary re-renders or re-computations
- Memory leaks (unclosed resources, circular references)
- Large file/data handling inefficiencies

#### Security Considerations
- Input validation and sanitization
- SQL injection vulnerabilities
- XSS (Cross-Site Scripting) risks
- Authentication and authorization issues
- Sensitive data exposure (API keys, passwords in code)
- CSRF protection

#### Testing Standards (from project docs)
- Test coverage meets requirements
- Tests follow project patterns
- Edge cases covered
- Integration tests if required
- E2E tests if required

### Step 9: Validate Against Context

Cross-reference the code changes with the gathered context:

#### Project Guidelines Validation
- Does the PR follow CONTRIBUTING.md?
- Is the PR description complete per the template?
- Are all checklist items addressed?
- Do commit messages follow the project format?

#### Jira Validation
- Does the PR address the ticket's requirements?
- Are acceptance criteria met?
- Does the scope match the ticket description?
- Are there any missing requirements?

#### Figma Validation
- Does the implementation match the design?
- Are spacing, colors, and layouts consistent with designs?
- Are there deviations from the design that should be noted?

#### Sentry Validation
- Does the PR address the related errors?
- Are error handling improvements included?
- Could the changes introduce new errors?
- Are there untested edge cases that caused previous errors?

### Step 10: Generate the Draft Review

Create a comprehensive review document with the following structure:

```markdown
# PR Review: [PR Title] (#[PR Number])

**Reviewer**: Claude Code
**Date**: [Current Date]
**Detail Level**: [Concise/Detailed/High-level]
**Reviewed in**: [Worktree / Remote]
**Status**: Draft Review (Not Submitted)

---

## Summary

[2-4 sentence high-level summary of the PR]

**Recommendation**: [Approve / Request Changes / Comment]

---

## Context

### Linked Jira Tickets
[If found]
- **[TICKET-ID]**: [Summary] ([Status])
  - Link: [URL]
  - Key requirements: [List from description/acceptance criteria]

[If none found]
_No Jira tickets referenced in this PR._

### Figma Designs
[If found]
- **[Design Name]**: [URL]
  - Last modified: [Date]
  - Notes: [Any relevant context]

[If none found]
_No Figma designs linked in this PR._

### Sentry Errors
[If found]
- **[Error Title]**: [Brief description]
  - Occurrences: [Count] in last 30 days
  - Link: [URL]
  - Related files: [Which changed files are involved]

[If none found]
_No recent Sentry errors found related to changed files._

### Project Best Practices
[If found]
- ✅ Follows CONTRIBUTING.md guidelines
- ✅ PR description matches template
- ⚠️  Missing test coverage requirement (80% required, 65% actual)
- ✅ Passes all linters
- ❌ Documentation not updated (required per CONTRIBUTING.md)

---

## Requirements Validation

### Project Standards
[Based on CONTRIBUTING.md, PR template, etc.]
- ✅ Requirement 1: Met
- ⚠️  Requirement 2: Partially addressed
- ❌ Requirement 3: Not met

### Jira Requirements
[If Jira tickets were found]
- ✅ Requirement 1: Met
- ⚠️  Requirement 2: Partially addressed
- ❌ Requirement 3: Not implemented

[If no tickets]
_Cannot validate requirements without linked Jira tickets._

### Design Compliance
[If Figma designs were found]
- Assessment of implementation vs. design
- Note any deviations or improvements

[If no designs]
_No design references to validate against._

---

## Code Review

### Strengths
[List positive aspects of the PR]
- [Strength 1]
- [Strength 2]

### Issues & Recommendations

#### Critical Issues
[Bugs, security vulnerabilities, breaking changes, violations of project standards]

[For Concise: Only list critical issues]
[For Detailed: Include file paths, line numbers, code snippets]
[For High-level: Architectural concerns only]

#### Important Suggestions
[Performance issues, code quality improvements, missing tests]

#### Minor Suggestions
[Only for Detailed level - style, naming, etc.]

---

## Lint & Test Results
[If worktree was used and tests/linters were run]

### Linting
```
[Output from linter]
```

### Tests
```
[Output from test run]
```

---

## Testing Recommendations

Based on the changes and project testing guidelines:
- [Test scenario 1]
- [Test scenario 2]
- [Edge cases to verify]

---

## Next Steps

1. [What the PR author should do based on CONTRIBUTING.md]
2. [Any follow-up items]
3. [Questions that need answers]

---

_This is a DRAFT review. Please review these comments before submitting them to the PR._

[If worktree used]
_Worktree location: `.worktrees/pr-[number]`_
_To cleanup: `git worktree remove .worktrees/pr-[number]`_

_To submit this review:_
[If GitHub draft created]
1. _Go to the GitHub PR: [PR URL]_
2. _View your draft review under "Files changed"_
3. _Edit comments if needed_
4. _Click "Submit review" and choose Approve/Request changes/Comment_

[If saved to file]
1. _Review saved to: [file path]_
2. _Edit the file if needed_
3. _Go to GitHub PR: [PR URL]_
4. _Copy/paste your comments into a new review_
5. _Submit your review_
```

### Detail Level Adaptations

**Concise Mode**:
- **QUALITY OVER QUANTITY**: 2-3 high-confidence comments are better than 10 uncertain ones
- **VERIFY EVERYTHING**: Only comment on issues you've personally verified exist by reading the files
- **NO "Consider adding..." suggestions** unless you've confirmed it's actually missing
- **Skip minor improvements** - Focus ONLY on:
  - Bugs that will cause failures
  - Security vulnerabilities
  - Breaking changes
  - Clear violations of project standards (verified in CONTRIBUTING.md)
  - Logic errors that affect correctness
- **When in doubt, don't comment** - Concise means high signal, zero noise
- Keep comments brief (1-2 sentences) when you do comment
- Aim for 2-5 key points maximum (not 5-10)

**Detailed Mode**:
- Include file paths and line numbers for every comment
- Provide code examples showing the issue and suggested fix
- Explain the reasoning behind each suggestion
- Cover critical, important, and minor issues
- Include links to documentation or best practices
- Reference specific sections of CONTRIBUTING.md or style guides

**High-level Mode**:
- Focus on architecture, approach, and design decisions
- No line-by-line comments
- Discuss overall patterns and structure
- Strategic recommendations for improvement
- Big-picture concerns only
- Alignment with architectural docs/ADRs

### Step 10.5: Review Quality Checklist

**CRITICAL**: Before creating any comments on GitHub, verify each planned comment passes ALL checks below.

**For EVERY comment you plan to make, ask yourself:**

1. **Did I read the COMPLETE file?**
   - ❌ NO: Do not make this comment - read the file first
   - ✅ YES: Continue to next check

2. **Can I point to the EXACT line where the problem exists?**
   - ❌ NO: Do not make this comment - it's too vague
   - ✅ YES: Continue to next check

3. **Have I verified this isn't already handled elsewhere in the file?**
   - ❌ NO: Do not make this comment - verify first
   - ✅ YES: Continue to next check

4. **Is this comment based on OBSERVATION, not ASSUMPTION?**
   - ❌ NO: Do not make this comment - verify the facts
   - ✅ YES: Continue to next check

5. **For Concise mode: Is this truly CRITICAL?** (bugs, security, breaking changes, logic errors)
   - ❌ NO: Do not make this comment in Concise mode
   - ✅ YES: This comment can be included

**Quality bar examples:**

❌ **BAD Comment** (assumption-based):
> "Consider adding KDoc to this function"
> (Without reading the file to verify KDoc doesn't already exist)

✅ **GOOD Comment** (observation-based):
> "Line 47: This function processes user input without sanitization, which could lead to XSS. Consider using `sanitizeInput()` like the pattern in `UserController.kt:23`"
> (After reading the file and confirming the issue exists)

**If you answer "NO" to ANY question above, DELETE that comment.**

**Final check before posting:**
- How many comments do I have for Concise mode? (Should be 2-5 max)
- Are ALL my comments about critical issues? (No "nice to have" suggestions)
- Did I read every file I'm commenting on?

### Step 11: Create GitHub Draft Review (Preferred)

Try to create a draft review directly on GitHub using the GitHub API:

**Via GitHub MCP** (if available):
```
github_create_review_comment(owner, repo, pr_number, body, event="COMMENT")
```

**Via `gh` CLI** (fallback):
```bash
# Create a draft review
gh pr review <pr-number> --comment --body "$(cat review-content.md)"
```

**Parameters**:
- `event`: Use "COMMENT" to create a draft (user submits later)
- `body`: The markdown content of the review

**Error handling**:
If creating the GitHub draft fails (permissions, API issues, etc.):
- Log the error
- Fall back to saving as local markdown file
- Inform the user why the draft couldn't be created

### Step 12: Save Local Backup (Always)

Always save a local copy of the review, even if GitHub draft was created:

**Location**:
- If worktree used: `.worktrees/pr-<number>/.claude-reviews/pr-<number>-<timestamp>.md`
- If no worktree: `.claude-reviews/pr-<number>-<timestamp>.md`

**Filename format**: `pr-42-2026-01-06-143022.md`

Create the `.claude-reviews` directory if it doesn't exist:
```bash
mkdir -p .claude-reviews
```

Use the Write tool to save the review content to the file.

### Step 13: Update .gitignore

Check if `.claude-reviews/` is in `.gitignore`:

```bash
grep -q "^\.claude-reviews/" .gitignore || grep -q "^.claude-reviews/" .gitignore
```

If not present, add it:
```bash
echo "" >> .gitignore
echo "# Claude Code PR reviews (drafts)" >> .gitignore
echo ".claude-reviews/" >> .gitignore
```

Also add `.worktrees/` if not present:
```bash
grep -q "^\.worktrees/" .gitignore || grep -q "^.worktrees/" .gitignore
```

If not present:
```bash
echo ".worktrees/" >> .gitignore
```

### Step 14: Display Summary to User

Show the user:
- Path to the saved review file
- Quick summary of key findings
- Link to the PR
- Instructions for next steps
- Worktree cleanup command (if used)

Example output:
```
✅ PR Review Complete

[If GitHub draft created]
✅ Draft review created on GitHub
   View at: https://github.com/owner/repo/pull/42/files

[Always show local file]
📄 Local copy saved to: .claude-reviews/pr-42-2026-01-06-143022.md

Summary:
- Reviewed 12 files with 347 additions, 89 deletions
- Found 2 critical issues, 5 important suggestions
- ⚠️  Missing test coverage (65% vs 80% required)
- ✅ Linked to JIRA-123 (requirements validated)
- ✅ Referenced Figma design (implementation matches)
- ❌ CONTRIBUTING.md: Documentation update required

Lint Results: ✅ Passed
Test Results: ⚠️  3 tests failing

Recommendation: Request Changes

[If worktree used]
Worktree created at: .worktrees/pr-42
To cleanup when done: git worktree remove .worktrees/pr-42

Next steps:
1. [If GitHub draft] Review your draft on GitHub and submit
2. [If file only] Copy review from .claude-reviews/pr-42-2026-01-06-143022.md to GitHub
3. Submit your review at https://github.com/owner/repo/pull/42
```

### Step 15: Send Notification

Use the notification system to alert the user:

```bash
~/.claude-code-notifier/notify.sh custom \
  "PR Review Complete" \
  "Review for PR #42 - 2 critical issues found" \
  "Glass"
```

Check if the notifier exists before calling it:
```bash
if [ -f ~/.claude-code-notifier/notify.sh ]; then
  ~/.claude-code-notifier/notify.sh custom "..." "..." "Glass"
fi
```

## Error Handling

### Missing MCP Servers

If MCP servers are not configured, gracefully degrade:
- GitHub: Fall back to `gh` CLI via Bash
- Jira: Note tickets found but couldn't fetch details
- Figma: Include links but skip metadata
- Sentry: Skip error correlation entirely

Always complete the review with available data.

### Invalid PR Number

If PR doesn't exist:
```
❌ Error: Pull request #999 not found in this repository.

Make sure you're in the correct repository and the PR number is valid.

Try: gh pr list
```

### Not in Git Repository

If not in a git repository:
```
❌ Error: Not in a git repository.

This skill must be run from within a git repository with a GitHub remote.

Navigate to your project directory and try again.
```

### Dirty Working Directory (when creating worktree)

If creating worktree fails due to uncommitted changes:
```
⚠️  Warning: Could not create worktree due to uncommitted changes.

Proceeding with remote diff review instead.

To use worktree, commit or stash your changes first.
```

### API Rate Limiting

If hitting rate limits:
```
⚠️  Warning: API rate limit reached for [Service].

Continuing with partial data. Some context may be missing.
```

### Linter/Test Failures (in worktree)

If linters or tests fail when running in worktree:
- Include the failures in the review
- Don't treat this as a review failure
- Note that the PR has failing checks

## Tips for Effective Reviews

1. **Read files, not just diffs**: ALWAYS read complete files before commenting. Diffs only show snippets and can be misleading.
2. **Verify before commenting**: Never assume - always verify that issues actually exist by reading the code.
3. **Follow project standards**: Always reference CONTRIBUTING.md and project docs
4. **Be constructive**: Phrase suggestions positively
5. **Be specific**: Include file paths, line numbers, and examples
6. **Prioritize**: Mark critical vs. nice-to-have improvements
7. **Ask questions**: When unsure, ask for clarification rather than assuming
8. **Acknowledge good work**: Note positive aspects of the PR
9. **Focus on substance**: Avoid nitpicking formatting if auto-formatters handle it
10. **Context matters**: Consider Jira requirements, Figma designs, and Sentry errors
11. **Respect project culture**: Some teams prefer detailed reviews, others prefer high-level
12. **Quality over quantity**: In Concise mode, 2 high-confidence comments beat 10 uncertain suggestions

## Notes

- This skill creates DRAFT reviews only - never auto-submits
- Reviews are saved locally AND optionally as GitHub drafts
- All external service integrations are optional
- The skill works with GitHub-only data if other services unavailable
- Always respect the user's chosen detail level
- Git worktrees keep your working directory clean during review
- Project best practices (CONTRIBUTING.md, etc.) are prioritized in the review
