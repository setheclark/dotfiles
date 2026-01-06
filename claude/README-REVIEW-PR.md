# PR Review Skill

Comprehensive GitHub pull request reviews powered by Claude Code with enriched context from Jira, Figma, and Sentry.

## Features

- **Intelligent code review** - Analyzes code quality, bugs, performance, and security
- **Multi-source context** - Pulls in Jira tickets, Figma designs, and Sentry errors
- **Project-aware** - Reads CONTRIBUTING.md, PR templates, and project best practices
- **Git worktrees** - Review PRs without disrupting your current work
- **Flexible detail levels** - Concise, Detailed, or High-level reviews
- **Draft reviews** - Creates GitHub draft reviews or saves locally for your approval
- **macOS notifications** - Get notified when reviews are complete

## Prerequisites

### Required
- **Claude Code** - This is a Claude Code skill
- **Git** - Git repository with GitHub remote
- **GitHub CLI (`gh`)** - Already in your Brewfile

```bash
# Verify gh is installed and authenticated
gh auth status
```

### Optional (but recommended)
- **MCP Servers** - For Jira, Figma, and Sentry integration (see setup below)
- **Node.js** - To run MCP servers (already in Brewfile)

## Quick Start

### 1. The skill is already installed
If you've run `./scripts/install.sh`, the skill is already stowed to `~/.claude/skills/review-pr/`.

### 2. Use the skill

```bash
cd /path/to/your/work/repo
claude
```

Then in Claude Code:
```
/review-pr 42
```

The skill will:
1. Ask if you want to checkout the PR (uses git worktree)
2. Ask for review detail level (concise/detailed/high-level)
3. Gather PR data and context
4. Analyze the code
5. Create a draft review on GitHub (or save locally)
6. Notify you when complete

## MCP Server Setup

To get the full benefit of context from Jira, Figma, and Sentry, set up MCP servers.

### GitHub MCP Server (Recommended)

Add to `~/.claude/settings.json`:

```json
{
  "model": "sonnet",
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "$(gh auth token)"
      }
    }
  }
}
```

**Why**: Faster PR data fetching, can create draft reviews via API.

**Fallback**: If not configured, the skill uses `gh` CLI via Bash.

### Atlassian (Jira) MCP Server

**Option 1: Official Atlassian Rovo MCP Server**

```json
"jira": {
  "command": "npx",
  "args": ["-y", "@atlassian/mcp-server"],
  "env": {
    "ATLASSIAN_URL": "https://your-org.atlassian.net",
    "ATLASSIAN_EMAIL": "you@example.com",
    "ATLASSIAN_API_TOKEN": "${JIRA_API_TOKEN}"
  }
}
```

**Option 2: Community MCP Server**

```bash
# Install community Jira MCP
npm install -g mcp-jira

# Add to settings.json
"jira": {
  "command": "mcp-jira",
  "env": {
    "JIRA_BASE_URL": "https://your-org.atlassian.net",
    "JIRA_EMAIL": "you@example.com",
    "JIRA_API_TOKEN": "${JIRA_API_TOKEN}"
  }
}
```

**Create Jira API token**:
1. Go to https://id.atlassian.com/manage-profile/security/api-tokens
2. Click "Create API token"
3. Store in `~/.zshrc.local`:
   ```bash
   export JIRA_API_TOKEN="your-token-here"
   ```

### Figma MCP Server

Add to `~/.claude/settings.json`:

```json
"figma": {
  "command": "npx",
  "args": ["-y", "@figma/mcp-server-figma"],
  "env": {
    "FIGMA_TOKEN": "${FIGMA_TOKEN}"
  }
}
```

**Create Figma token**:
1. Go to https://www.figma.com/settings (Personal Access Tokens section)
2. Create a new token
3. Store in `~/.zshrc.local`:
   ```bash
   export FIGMA_TOKEN="your-token-here"
   ```

### Sentry MCP Server

Add to `~/.claude/settings.json`:

```json
"sentry": {
  "command": "npx",
  "args": ["-y", "@getsentry/mcp-server"],
  "env": {
    "SENTRY_ORG": "your-org-slug",
    "SENTRY_TOKEN": "${SENTRY_TOKEN}"
  }
}
```

**Create Sentry token**:
1. Go to https://sentry.io/settings/account/api/auth-tokens/
2. Create a new token with `project:read` and `event:read` scopes
3. Store in `~/.zshrc.local`:
   ```bash
   export SENTRY_TOKEN="your-token-here"
   ```

### Full settings.json Example

```json
{
  "model": "sonnet",
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "$(gh auth token)"
      }
    },
    "jira": {
      "command": "npx",
      "args": ["-y", "@atlassian/mcp-server"],
      "env": {
        "ATLASSIAN_URL": "https://your-org.atlassian.net",
        "ATLASSIAN_EMAIL": "you@example.com",
        "ATLASSIAN_API_TOKEN": "${JIRA_API_TOKEN}"
      }
    },
    "figma": {
      "command": "npx",
      "args": ["-y", "@figma/mcp-server-figma"],
      "env": {
        "FIGMA_TOKEN": "${FIGMA_TOKEN}"
      }
    },
    "sentry": {
      "command": "npx",
      "args": ["-y", "@getsentry/mcp-server"],
      "env": {
        "SENTRY_ORG": "your-org-slug",
        "SENTRY_TOKEN": "${SENTRY_TOKEN}"
      }
    }
  },
  "hooks": {
    "Notification": [
      {
        "matcher": "idle_prompt",
        "hooks": [{"type": "command", "command": "$HOME/.claude-code-notifier/notify.sh input"}]
      },
      {
        "matcher": "permission_prompt",
        "hooks": [{"type": "command", "command": "$HOME/.claude-code-notifier/notify.sh choice"}]
      }
    ]
  }
}
```

## Environment Variables

Store API tokens in `~/.zshrc.local` (not tracked by git):

```bash
# API tokens for PR review workflow
export JIRA_API_TOKEN="your-jira-token"
export FIGMA_TOKEN="your-figma-token"
export SENTRY_TOKEN="your-sentry-token"
```

After adding, reload your shell:
```bash
source ~/.zshrc
```

## Usage

### Basic Review

```bash
cd /path/to/your/repo
claude
> /review-pr 42
```

You'll be prompted for:
1. **Checkout preference** - Review remotely or use git worktree
2. **Detail level** - Concise, Detailed, or High-level

### Review Detail Levels

**Concise** - Focus on critical issues only
- Best for: Quick reviews, simple PRs
- Output: 5-10 key issues
- Time: 2-5 minutes

**Detailed** - Comprehensive line-by-line review
- Best for: Important features, security reviews
- Output: All issues with examples and suggestions
- Time: 5-15 minutes

**High-level** - Architecture and approach only
- Best for: Large PRs, architectural changes
- Output: Strategic feedback, no line-by-line
- Time: 3-7 minutes

### With Git Worktree

If you choose "Yes, use worktree", the skill will:
1. Create worktree at `.worktrees/pr-<number>/`
2. Checkout the PR branch there
3. Run linters and tests if configured
4. Include results in the review

**Benefits**:
- Your current work is untouched
- Can run actual tests and linters
- More accurate review with real execution

**Cleanup**:
```bash
git worktree remove .worktrees/pr-42
```

### Review Output

**GitHub Draft Review** (preferred):
- Created automatically on GitHub
- View under PR > "Files changed"
- Edit and submit when ready

**Local Markdown File** (fallback):
- Saved to `.claude-reviews/pr-<number>-<timestamp>.md`
- Copy/paste into GitHub manually

## What Gets Reviewed

### Code Analysis
- ✅ Code quality and best practices
- ✅ Bugs and logic errors
- ✅ Performance concerns
- ✅ Security vulnerabilities
- ✅ Type safety and error handling

### Project Standards
- ✅ CONTRIBUTING.md guidelines
- ✅ PR template completion
- ✅ Code style (linting rules)
- ✅ Test coverage requirements
- ✅ Documentation updates

### Context Validation
- ✅ Jira ticket requirements
- ✅ Figma design compliance
- ✅ Sentry error resolution
- ✅ Architectural alignment

### Testing (if using worktree)
- ✅ Runs linters (eslint, prettier, etc.)
- ✅ Runs tests (jest, pytest, etc.)
- ✅ Includes results in review

## Troubleshooting

### "Not in a git repository"

Make sure you're in a directory that's a git repository:
```bash
git status
```

### "PR not found"

Verify the PR number exists:
```bash
gh pr list
gh pr view 42
```

### "GitHub authentication failed"

Re-authenticate with GitHub CLI:
```bash
gh auth login
```

### "MCP server not responding"

Check MCP server configuration in `~/.claude/settings.json`:
```bash
# Test GitHub MCP
gh auth token

# Test environment variables
echo $JIRA_API_TOKEN
echo $FIGMA_TOKEN
echo $SENTRY_TOKEN
```

### "Permission denied" creating worktree

Ensure you have uncommitted changes stashed or committed:
```bash
git status
git stash  # or git commit
```

### "Can't create GitHub draft review"

This is normal if you don't have GitHub MCP configured or if the `gh` CLI doesn't support draft reviews for your GitHub version. The skill will automatically fall back to saving a local markdown file.

Check for the review in `.claude-reviews/`.

### MCP server installation fails

Some MCP servers may not be published yet. Use alternatives:

**Jira**: Use `gh` CLI to manually fetch ticket info:
```bash
# The skill will still extract ticket IDs from PR
```

**Figma**: Links will be included in review, metadata skipped

**Sentry**: Context will be skipped if MCP unavailable

The skill degrades gracefully - it works without any MCP servers.

## Examples

### Example Workflow

```bash
$ cd ~/work/my-app
$ claude
Claude Code > /review-pr 156

? Should I checkout the PR branch for this review?
  › No checkout
    Yes, use worktree

? How detailed should this review be?
  › Concise
    Detailed
    High-level

Fetching PR #156...
Found Jira ticket: PROJ-234
Found Figma design: Settings Page Redesign
Running linters...
Running tests...

✅ PR Review Complete

✅ Draft review created on GitHub
   View at: https://github.com/myorg/my-app/pull/156/files

📄 Local copy: .claude-reviews/pr-156-2026-01-06-143022.md

Summary:
- Reviewed 12 files (347 additions, 89 deletions)
- Found 2 critical issues, 5 important suggestions
- ⚠️  Missing test coverage (65% vs 80% required)
- ✅ Linked Jira ticket requirements validated
- ✅ Figma design implementation matches

Lint Results: ✅ Passed
Test Results: ⚠️  3 tests failing

Recommendation: Request Changes

Worktree: .worktrees/pr-156
Cleanup: git worktree remove .worktrees/pr-156
```

## Tips

### For best results

1. **Set up all MCP servers** - Richer context = better reviews
2. **Use worktrees for important PRs** - Run actual tests and linters
3. **Choose detail level carefully** - Detailed for critical PRs, concise for simple ones
4. **Review the draft before submitting** - Claude is helpful but not perfect
5. **Add project docs** - The more CONTRIBUTING.md, ADRs, etc., the better

### When to use which detail level

| Situation | Detail Level |
|-----------|--------------|
| Simple bug fix | Concise |
| New feature with tests | Detailed |
| Large refactoring | High-level |
| Security-critical change | Detailed |
| Documentation update | Concise |
| Architecture change | High-level |
| Junior developer PR | Detailed |
| Senior developer PR | Concise or High-level |

## Advanced Usage

### Review multiple PRs

```bash
for pr in 42 43 44; do
  claude "/review-pr $pr"
done
```

### Auto-accept concise reviews for trusted authors

You can ask Claude to use concise mode by default for specific authors in your project's documentation.

### Custom review criteria

Add review criteria to `.github/PULL_REQUEST_TEMPLATE.md` or `CONTRIBUTING.md`. The skill will read and follow these guidelines.

## File Locations

- Skill definition: `~/.claude/skills/review-pr/skill.md`
- Review templates: `~/.claude/skills/review-pr/prompts/`
- Settings: `~/.claude/settings.json`
- Review output: `.claude-reviews/` (in each repo)
- Worktrees: `.worktrees/` (in each repo)

## Updating the Skill

To update the skill:

```bash
cd ~/git/dotfiles
git pull
stow -R claude  # Restow to update symlinks
```

## Resources

- [GitHub MCP Server](https://github.com/github/github-mcp-server)
- [Atlassian MCP Server](https://github.com/atlassian/atlassian-mcp-server)
- [Figma MCP Server](https://www.figma.com/blog/introducing-figma-mcp-server/)
- [Sentry MCP Server](https://github.com/getsentry/sentry-mcp-stdio)
- [Model Context Protocol Docs](https://modelcontextprotocol.io/)
- [Claude Code Documentation](https://docs.anthropic.com/claude/docs/claude-code)

## Contributing

Found a bug or want to improve the skill? Edit the skill files in `~/git/dotfiles/claude/.claude/skills/review-pr/` and submit a PR!
