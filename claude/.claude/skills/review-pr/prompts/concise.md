# Concise Review Template

## Style Guidelines
- **Focus**: Critical issues only (bugs, security, project standard violations)
- **Length**: 1-2 sentences per issue
- **Tone**: Direct and actionable
- **Scope**: 5-10 key points maximum
- **Skip**: Minor style issues, formatting, subjective preferences

## Example Comments

### Critical Issue Format
**[File:Line] Brief description**
```
auth.tsx:45 - Missing null check will cause crash when user is logged out
Recommendation: Add `if (!user) return null;` before accessing user.id
```

### Important Suggestion Format
**[File] Actionable improvement**
```
UserService.ts - N+1 query in getUserPosts() will slow down with scale
Recommendation: Use JOIN or prefetch posts in single query
```

## Review Structure

### Summary
2-3 sentences max. State the PR's purpose and your recommendation.

### Critical Issues
- List only showstoppers (bugs, security, breaking changes)
- Each issue: file:line, what's wrong, quick fix

### Important Suggestions
- Performance problems
- Missing tests for critical paths
- Violations of CONTRIBUTING.md

### Strengths
- 1-2 bullet points on what's done well
- Keep it brief but genuine

## Example

```markdown
## Summary
Adds dark mode toggle to settings. Implementation is solid but missing persistence layer and accessibility labels.

**Recommendation**: Request Changes

## Critical Issues
1. **settings.tsx:45** - User preference not saved to backend. Theme resets on reload.
   - Fix: Call `saveUserPreference('theme', isDark)` after toggle

## Important Suggestions
1. **ThemeToggle.tsx:12** - Missing ARIA labels. Screen readers won't announce state.
   - Add: `aria-label="Toggle dark mode"` and `aria-pressed={isDark}`

2. **Missing tests** - No tests for theme persistence or toggle functionality

## Strengths
- Clean component structure
- Smooth CSS transitions
```
