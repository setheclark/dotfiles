# Detailed Review Template

## Style Guidelines
- **Focus**: Comprehensive line-by-line review
- **Length**: Full explanations with context and examples
- **Tone**: Educational and thorough
- **Scope**: Cover critical, important, and minor issues
- **Include**: Code examples, links to docs, reasoning

## Example Comments

### Critical Issue Format
**[File:Line-Range] Detailed explanation**
```
auth/AuthProvider.tsx:45-52 - Authentication token not validated before use

Current code:
```typescript
const token = localStorage.getItem('auth_token');
return fetch('/api/user', {
  headers: { Authorization: `Bearer ${token}` }
});
```

Issue: If token is null or expired, this will send an invalid request and expose the endpoint without authentication.

Recommendation:
```typescript
const token = localStorage.getItem('auth_token');
if (!token || isTokenExpired(token)) {
  redirectToLogin();
  return;
}
return fetch('/api/user', {
  headers: { Authorization: `Bearer ${token}` }
});
```

Reference: See CONTRIBUTING.md section on "Authentication Best Practices"
```

### Important Suggestion Format
**[File:Line] Detailed analysis with alternatives**
```
components/UserList.tsx:78-95 - Inefficient rendering pattern

Current implementation re-renders entire list on every state change. With 1000+ users, this causes noticeable lag.

Suggested improvements:
1. Memoize UserListItem components: `React.memo(UserListItem)`
2. Use virtualization for large lists: `react-window` or `react-virtualized`
3. Move filter state to parent to prevent re-renders

Example with memoization:
```typescript
const UserListItem = React.memo(({ user, onSelect }) => {
  return <div onClick={() => onSelect(user.id)}>{user.name}</div>;
});
```

Performance impact: Reduces re-renders from O(n) to O(1) for unchanged items.
Reference: [React Performance Optimization](https://react.dev/learn/render-and-commit)
```

### Minor Suggestion Format
**[File:Line] Improvement with explanation**
```
utils/formatDate.ts:12 - Consider using Intl.DateTimeFormat for i18n support

Current: `return date.toLocaleDateString('en-US')`

While this works, it hardcodes US format. For future internationalization:
```typescript
return new Intl.DateTimeFormat(userLocale, {
  year: 'numeric',
  month: 'long',
  day: 'numeric'
}).format(date);
```

Not urgent, but sets up for easier i18n later.
```

## Review Structure

### Summary
4-5 sentences providing comprehensive overview. Include PR goals, approach taken, and overall assessment.

### Context
- Full details on Jira tickets with acceptance criteria
- Figma design links with implementation notes
- Sentry errors with impact analysis
- Project standards validation (CONTRIBUTING.md, etc.)

### Critical Issues
- Complete explanation of each issue
- Why it's critical
- Potential impact if not fixed
- Suggested fix with code examples
- References to documentation or standards

### Important Suggestions
- Detailed analysis
- Performance implications
- Alternative approaches
- Code examples for improvements
- Links to best practices

### Minor Suggestions
- Naming improvements
- Code organization
- Future-proofing opportunities
- Documentation additions

### Strengths
- Specific examples of good practices
- Highlight clever solutions
- Note adherence to project standards

### Testing Coverage
- Current coverage analysis
- Missing test scenarios
- Suggested test cases with examples

## Example

```markdown
## Summary
This PR implements a dark mode toggle in the user settings page, addressing PROJ-234. The implementation uses CSS custom properties for theme variables and provides a clean UI component. However, there are several important issues around persistence, accessibility, and test coverage that should be addressed before merging. The overall approach is sound and follows the project's React patterns well.

**Recommendation**: Request Changes

## Context

### Jira Ticket PROJ-234
- **Summary**: Implement dark mode for application
- **Status**: In Progress
- **Acceptance Criteria**:
  1. ✅ Toggle visible in settings page
  2. ❌ User preference persists across sessions (NOT IMPLEMENTED)
  3. ⚠️  Respects system theme preference (PARTIAL - no auto-detection)

### Figma Design
- [Settings Page Redesign](https://figma.com/file/abc123)
- Last modified: Dec 15, 2025
- Implementation matches design ✅
- Toggle placement and styling are accurate

### Project Standards
- ⚠️  CONTRIBUTING.md requires accessibility review - missing ARIA labels
- ❌ PR Template checklist item "Tests added" - unchecked
- ✅ Code style follows ESLint rules
- ⚠️  Test coverage: 45% (project minimum: 80%)

## Critical Issues

### 1. Theme preference not persisted (settings/ThemeSettings.tsx:45-52)

**Current code:**
```typescript
const [isDarkMode, setIsDarkMode] = useState(false);

const toggleTheme = () => {
  setIsDarkMode(!isDarkMode);
  document.body.classList.toggle('dark-mode');
};
```

**Problem**: User preference is stored only in component state. When the user refreshes the page or navigates away and returns, the theme resets to light mode. This violates Jira acceptance criteria #2.

**Impact**: Poor user experience - users must re-enable dark mode every session.

**Recommended fix:**
```typescript
const [isDarkMode, setIsDarkMode] = useState(() => {
  const saved = localStorage.getItem('theme');
  return saved === 'dark';
});

const toggleTheme = async () => {
  const newMode = !isDarkMode;
  setIsDarkMode(newMode);
  document.body.classList.toggle('dark-mode');

  // Persist to localStorage
  localStorage.setItem('theme', newMode ? 'dark' : 'light');

  // Sync to backend for cross-device support
  await api.updateUserPreferences({
    theme: newMode ? 'dark' : 'light'
  });
};
```

**Why localStorage + backend**:
- localStorage: Instant theme application on page load
- Backend: Syncs across user's devices

**Reference**: See `docs/DEVELOPMENT.md` section 4.2 on "User Preference Management"

[Continue with more critical issues...]

## Important Suggestions

### 1. Accessibility: Missing ARIA attributes (components/ThemeToggle.tsx:12-28)

**Current implementation** doesn't announce state to screen readers.

**Problem**: Users with screen readers won't know:
- What the button does
- Current theme state
- When state changes

**Recommended additions:**
```typescript
<button
  onClick={toggleTheme}
  aria-label="Toggle dark mode"
  aria-pressed={isDarkMode}
  role="switch"
>
  {isDarkMode ? <MoonIcon /> : <SunIcon />}
  <span className="sr-only">
    {isDarkMode ? 'Dark mode enabled' : 'Light mode disabled'}
  </span>
</button>
```

**WCAG Compliance**: This meets WCAG 2.1 Level AA (required per CONTRIBUTING.md)

**Reference**: [ARIA Switch Pattern](https://www.w3.org/WAI/ARIA/apg/patterns/switch/)

[Continue with more suggestions...]

## Minor Suggestions

### 1. Extract theme values to constants (styles/themes.ts)

**Current**: Theme colors hardcoded in CSS:
```css
:root {
  --bg-color: #ffffff;
  --text-color: #000000;
}
```

**Suggestion**: Create a TypeScript theme config for better maintainability:
```typescript
export const themes = {
  light: {
    bg: '#ffffff',
    text: '#000000',
    primary: '#007bff',
  },
  dark: {
    bg: '#1a1a1a',
    text: '#e0e0e0',
    primary: '#4da6ff',
  }
} as const;
```

**Benefits**:
- Type-safe theme usage in components
- Easier to add new themes (high contrast, etc.)
- Can reference in tests

**Not urgent**, but improves maintainability for future theme work.

[Continue with more minor suggestions...]

## Strengths

1. **Clean component architecture** (components/ThemeToggle.tsx)
   - Well-separated concerns
   - Reusable component design
   - Clear prop types

2. **Smooth transitions** (styles/transitions.css:8-15)
   - Prefers-reduced-motion support
   - Hardware-accelerated properties
   - Good UX attention to detail

3. **Follows project patterns**
   - Uses established component structure
   - Consistent with existing settings components
   - Proper TypeScript usage

4. **CSS custom properties approach**
   - Makes theme switching efficient
   - Follows modern best practices
   - Easy to extend

## Testing Coverage

### Current Coverage: 45%
Missing coverage for:
- Theme toggle functionality
- Persistence layer
- Error handling for API calls
- Reduced-motion preference

### Recommended test cases:

**Unit tests for ThemeToggle component:**
```typescript
describe('ThemeToggle', () => {
  it('toggles theme on click', () => {
    const { getByRole } = render(<ThemeToggle />);
    const toggle = getByRole('switch');

    expect(toggle).toHaveAttribute('aria-pressed', 'false');
    fireEvent.click(toggle);
    expect(toggle).toHaveAttribute('aria-pressed', 'true');
  });

  it('persists theme to localStorage', () => {
    // Test localStorage persistence
  });

  it('syncs theme to backend', async () => {
    // Test API call
  });
});
```

**Integration test:**
- Navigate to settings
- Toggle theme
- Refresh page
- Verify theme persists

**Coverage goal**: Bring this feature to 80% to meet project standards.

## Next Steps

1. **Required before merge:**
   - Fix theme persistence (critical issue #1)
   - Add ARIA attributes for accessibility
   - Add test coverage (minimum 80%)
   - Update CONTRIBUTING.md checklist in PR description

2. **Nice to have:**
   - System theme auto-detection
   - Theme preview before applying
   - High contrast theme option

3. **Follow-up work** (can be separate PR):
   - Apply dark mode to remaining pages
   - Add theme to mobile app
   - User-customizable theme colors
```
