# Design Review Workflow

Comprehensive UI/UX design review process for frontend changes.

## Agent

This workflow should be executed by the **design-reviewer agent** (`{{agents/design-reviewer}}`), which has access to Playwright for automated browser testing and visual verification.

## Overview

This workflow guides you through a systematic design review process:
1. **Analyze PR**: Understand scope and setup environment
2. **Test User Flows**: Verify interactive functionality
3. **Test Responsiveness**: Ensure cross-device compatibility
4. **Assess Visual Polish**: Evaluate visual quality and consistency
5. **Validate Accessibility**: Check WCAG 2.1 AA compliance
6. **Test Edge Cases**: Verify error handling and unusual scenarios
7. **Check Code Quality**: Review technical implementation

---

## Phase 1: Analyze PR and Setup Environment

Understand the scope of UI changes and prepare for comprehensive testing.

### Steps

#### 1. Identify Changed Files
```bash
git status
git diff main...HEAD --name-status
git log main..HEAD --oneline
```

Focus on:
- `.tsx`, `.jsx`, `.vue`, `.html` files (UI components)
- `.css`, `.scss`, `.module.css` files (styling)
- Page/route files
- Component directories

#### 2. Review Commit Messages
Understand the intent behind changes:
- What feature/bug is being addressed?
- Are there design system references?
- Any breaking changes mentioned?

#### 3. Check for Related Documentation
Look for:
- Design specifications or mockups
- Figma/design tool links
- Accessibility requirements
- User flow diagrams

#### 4. Understand the Context
Read the related:
- Pull request description
- Issue or ticket details
- Design principles from `standards/frontend/general.md`
- Component standards from `standards/frontend/components.md`

#### 5. Setup Testing Environment
Ensure you can:
- Run the application locally
- Access Playwright for browser testing
- Navigate to affected pages/components
- Test in different browsers if needed

### Output

Create a summary including:
- List of UI components/pages changed
- Intent of the changes
- Testing approach needed
- Relevant design standards to check against

---

## Phase 2: Test Interactive User Flows

Test the actual user experience with real interactions in a live environment.

### Approach

#### 1. Identify Key User Flows
For each changed component/page, identify:
- Primary user action (e.g., "user submits form")
- Secondary actions (e.g., "user cancels", "user edits")
- Navigation paths to/from this component

#### 2. Test Each Flow End-to-End
Using Playwright:

```javascript
// Example flow test approach
- Navigate to the component/page
- Interact with UI elements (click, type, select)
- Verify expected behavior occurs
- Check for visual feedback (loading states, success messages)
- Test error scenarios
```

#### 3. Interaction Testing Checklist
- [ ] All buttons/links are clickable and respond correctly
- [ ] Forms validate input properly
- [ ] Modals/dialogs open and close correctly
- [ ] Dropdowns/selects work and display properly
- [ ] Hover states provide appropriate feedback
- [ ] Focus states are visible for keyboard navigation
- [ ] Loading states appear during async operations
- [ ] Success/error messages display correctly
- [ ] Animations/transitions feel smooth

#### 4. Document Issues
For each problem found:
- Take screenshot showing the issue
- Describe expected vs. actual behavior
- Note steps to reproduce
- Assess severity (Blocker, High, Medium, Low)

### Testing Principles

- **Real Environment**: Test in actual browser, not just code review
- **User Perspective**: Think like an end user, not a developer
- **Edge Cases**: Try unusual but valid interactions
- **Accessibility**: Test keyboard navigation alongside mouse/touch

### Output

List of interaction issues found, with:
- Component/page affected
- Issue description
- Screenshot evidence
- Severity level
- Reproduction steps

---

## Phase 3: Test Cross-Viewport Responsiveness

Verify the UI works correctly across different screen sizes and devices.

### Standard Breakpoints

Test at these viewport widths:
- **Mobile**: 375px (iPhone SE, small phones)
- **Mobile Large**: 428px (iPhone Pro Max)
- **Tablet**: 768px (iPad portrait)
- **Desktop Small**: 1024px (small laptops)
- **Desktop**: 1440px (standard desktop)
- **Desktop Large**: 1920px+ (large monitors)

### Using Playwright for Testing

```javascript
// Resize viewport and capture screenshots
await page.setViewportSize({ width: 375, height: 667 });
await page.screenshot({ path: 'mobile-view.png' });

await page.setViewportSize({ width: 768, height: 1024 });
await page.screenshot({ path: 'tablet-view.png' });

await page.setViewportSize({ width: 1440, height: 900 });
await page.screenshot({ path: 'desktop-view.png' });
```

### Responsive Testing Checklist

#### Layout
- [ ] Content is readable at all sizes
- [ ] No horizontal scrolling (unless intentional)
- [ ] Spacing scales appropriately
- [ ] Columns/grids reflow correctly
- [ ] Navigation adapts (hamburger menu on mobile, etc.)

#### Typography
- [ ] Font sizes are readable on small screens
- [ ] Line length is comfortable (45-75 characters)
- [ ] Headings have appropriate hierarchy
- [ ] Text doesn't overflow containers

#### Images & Media
- [ ] Images scale properly
- [ ] Icons remain clear and recognizable
- [ ] Videos/embeds are responsive
- [ ] Aspect ratios are maintained

#### Interactive Elements
- [ ] Buttons are touch-friendly on mobile (min 44x44px)
- [ ] Forms are easy to use on small screens
- [ ] Dropdowns work on touch devices
- [ ] Hover states have touch equivalents

#### Navigation
- [ ] Mobile menu is accessible
- [ ] Links are easy to tap (not too small/close)
- [ ] Breadcrumbs adapt or hide appropriately
- [ ] Back/forward navigation works

#### Tables & Data
- [ ] Tables scroll or reformat on mobile
- [ ] Data remains comprehensible
- [ ] Filters/actions remain accessible

#### Modals & Overlays
- [ ] Modals fit on screen at all sizes
- [ ] Can scroll content if needed
- [ ] Close button is accessible
- [ ] Overlays don't trap users

### Common Issues to Catch

- Text truncation without ellipsis
- Overlapping elements
- Invisible or unclickable buttons
- Images pushing content off-screen
- Fixed-width elements breaking layout
- Excessive scrolling on mobile
- Touch targets too small
- Text too small to read

### Output

Document responsive issues with:
- Viewport size where issue occurs
- Screenshot showing the problem
- Description of the issue
- Expected behavior
- Severity level

---

## Phase 4: Assess Visual Polish

Evaluate the visual quality and consistency of the UI implementation.

### Visual Polish Checklist

#### Alignment & Spacing
- [ ] Elements are properly aligned (use grid/guides mentally)
- [ ] Consistent spacing between related elements
- [ ] Adequate white space (not cramped)
- [ ] Margins and padding follow design system
- [ ] Optical alignment considered (not just mathematical)

#### Typography
- [ ] Font families match design system
- [ ] Font sizes follow type scale
- [ ] Font weights are appropriate
- [ ] Line heights provide good readability
- [ ] Letter spacing (tracking) is consistent
- [ ] Text hierarchy is clear
- [ ] No orphans or widows in important text

#### Color
- [ ] Colors match design system palette
- [ ] Color usage is consistent
- [ ] Sufficient contrast (see accessibility section)
- [ ] Semantic colors used appropriately (error = red, success = green)
- [ ] No jarring color combinations
- [ ] Dark mode (if applicable) works well

#### Visual Hierarchy
- [ ] Most important elements stand out
- [ ] Clear visual flow guides user attention
- [ ] Grouping indicates relationships
- [ ] Size/weight/color establish importance

#### Components & Patterns
- [ ] Components match existing design system
- [ ] No invented patterns (use established ones)
- [ ] States are visually distinct (default, hover, active, disabled)
- [ ] Consistent component styling across pages

#### Icons & Imagery
- [ ] Icons are from consistent icon set
- [ ] Icon sizes are appropriate
- [ ] Icons align with text baseline
- [ ] Images have appropriate aspect ratios
- [ ] No pixelated or blurry images
- [ ] Alt text provided for images

#### Borders & Shadows
- [ ] Border widths are consistent
- [ ] Border radius follows design system
- [ ] Shadows match design system elevation
- [ ] Shadows used appropriately for hierarchy

#### Interactive Feedback
- [ ] Hover states provide clear feedback
- [ ] Active/pressed states are visible
- [ ] Focus indicators are prominent
- [ ] Disabled states are clearly differentiated
- [ ] Loading states are smooth and clear
- [ ] Transitions feel polished (not too fast or slow)

#### Forms
- [ ] Input fields have consistent styling
- [ ] Labels are clearly associated with inputs
- [ ] Validation messages are clear and helpful
- [ ] Required fields are indicated
- [ ] Form layout is logical and scannable

#### Empty States
- [ ] Empty states are designed (not just blank)
- [ ] Helpful messaging explains why empty
- [ ] Clear call-to-action to add content

#### Error States
- [ ] Error messages are clear and helpful
- [ ] Error styling is consistent
- [ ] Errors don't blame the user
- [ ] Suggest how to fix the error

#### Loading States
- [ ] Skeleton screens or spinners present
- [ ] Loading doesn't block entire interface
- [ ] Optimistic updates where appropriate

#### Micro-interactions
- [ ] Transitions are smooth
- [ ] Animations have purpose (not gratuitous)
- [ ] Motion respects prefers-reduced-motion
- [ ] Timing feels natural (150-300ms typically)

### Common Polish Issues

- Inconsistent spacing
- Misaligned elements
- Wrong font weights
- Colors not from design system
- Missing hover/focus states
- Jarring transitions
- Unclear button hierarchy
- Poor contrast
- Inconsistent border radius
- Shadow overuse or underuse

### Assessment Approach

1. Take screenshots of each component/page
2. Compare to existing design system examples
3. Note any deviations or inconsistencies
4. Evaluate whether it "feels" polished
5. Check details (spacing, alignment, states)

### Output

Document visual issues with:
- Component/area affected
- Screenshot highlighting issue
- Description of the problem
- Reference to design system standard
- Severity level

---

## Phase 5: Validate WCAG 2.1 AA Accessibility

Ensure the UI meets accessibility standards for all users.

### Accessibility Testing Checklist

#### Keyboard Navigation
- [ ] All interactive elements reachable via Tab
- [ ] Tab order is logical
- [ ] Enter/Space activates buttons/links
- [ ] Escape closes modals/dropdowns
- [ ] Arrow keys work in menus/lists
- [ ] No keyboard traps
- [ ] Skip links present for main content

#### Focus Management
- [ ] Focus indicators are clearly visible
- [ ] Focus indicators have sufficient contrast (3:1 minimum)
- [ ] Focus moves logically through page
- [ ] Focus returns appropriately (e.g., after closing modal)
- [ ] No invisible focused elements

#### Color Contrast
Test with browser dev tools or online checker:
- [ ] Normal text: 4.5:1 minimum
- [ ] Large text (18pt+/14pt+ bold): 3:1 minimum
- [ ] UI components: 3:1 minimum
- [ ] Focus indicators: 3:1 minimum
- [ ] Information not conveyed by color alone

#### Screen Reader Compatibility
- [ ] Semantic HTML used (`<button>`, `<nav>`, `<main>`, etc.)
- [ ] Headings in logical order (h1 → h2 → h3)
- [ ] Images have descriptive alt text
- [ ] Decorative images have empty alt (`alt=""`)
- [ ] Form labels properly associated
- [ ] Required fields indicated in label
- [ ] Error messages read correctly

#### ARIA Attributes
- [ ] `role` attributes used appropriately
- [ ] `aria-label` for icon buttons
- [ ] `aria-labelledby` for complex labels
- [ ] `aria-describedby` for helper text
- [ ] `aria-live` for dynamic content
- [ ] `aria-expanded` for collapsible sections
- [ ] `aria-hidden` only for decorative elements
- [ ] `aria-current` for current page/step

#### Forms
- [ ] All inputs have associated labels
- [ ] Labels are visible (not just placeholder)
- [ ] Required fields clearly marked
- [ ] Error messages associated with inputs
- [ ] Fieldsets and legends for grouped inputs
- [ ] Autocomplete attributes where appropriate

#### Interactive Components
- [ ] Buttons use `<button>` (not `<div>`)
- [ ] Links use `<a>` with href
- [ ] Clickable elements have accessible names
- [ ] Custom controls have appropriate ARIA
- [ ] Modals trap focus while open
- [ ] Modals announce to screen readers

#### Content Structure
- [ ] Page has single h1
- [ ] Heading hierarchy is logical
- [ ] Lists use proper markup (`<ul>`, `<ol>`)
- [ ] Tables have headers and captions
- [ ] Content is in logical reading order
- [ ] Language specified (`lang` attribute)

#### Media
- [ ] Videos have captions
- [ ] Audio has transcripts
- [ ] Auto-playing media can be paused
- [ ] No flashing content (risk of seizures)

#### Touch Targets
- [ ] Interactive elements min 44x44px
- [ ] Adequate spacing between touch targets
- [ ] Works with touch, mouse, and keyboard

#### Motion & Animation
- [ ] Respects `prefers-reduced-motion`
- [ ] Animations can be disabled
- [ ] No parallax that causes motion sickness
- [ ] Essential animations have alternatives

### Testing Tools

#### Browser DevTools
- Chrome DevTools Accessibility panel
- Firefox Accessibility Inspector
- Edge Accessibility Insights

#### Automated Testing
```javascript
// Run axe-core accessibility tests
const { injectAxe, checkA11y } = require('axe-playwright');
await injectAxe(page);
const violations = await checkA11y(page);
```

#### Manual Testing
- Navigate with keyboard only (hide mouse)
- Use screen reader (NVDA, JAWS, VoiceOver)
- Test with browser zoom at 200%
- Simulate color blindness
- Check with contrast checker tool

### Common Accessibility Issues

- Missing alt text
- Insufficient color contrast
- Poor focus indicators
- Keyboard navigation broken
- Missing form labels
- Heading hierarchy skipped
- ARIA misuse or overuse
- Click handlers on non-interactive elements
- Modals that don't trap focus
- Auto-playing content

### Testing Approach

1. **Automated scan**: Run axe-core or similar tool
2. **Keyboard test**: Navigate entire UI with keyboard only
3. **Screen reader test**: Use with NVDA/VoiceOver
4. **Contrast check**: Verify all text and UI elements
5. **Zoom test**: Test at 200% zoom level
6. **Focus test**: Tab through and verify visible focus

### Output

Document accessibility issues with:
- WCAG criterion violated (e.g., "1.4.3 Contrast")
- Element/component affected
- Description of the issue
- How to reproduce
- Impact on users
- Recommended fix
- **Always mark as HIGH priority or BLOCKER**

### Resources

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- [ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)

---

## Phase 6: Test Edge Cases & Error States

Verify the UI handles unusual scenarios and error conditions gracefully.

### Edge Case Testing

#### Data Variations

**Very Long Content**
- [ ] Long user names (50+ characters)
- [ ] Long product titles or descriptions
- [ ] Long email addresses
- [ ] Long URLs
- [ ] Text with no spaces (unbreakable)
- [ ] Text in other languages/scripts (Arabic, Chinese, emoji)

Test: Does content truncate gracefully with ellipsis? Or does it overflow and break layout?

**Very Short Content**
- [ ] Single character names
- [ ] Single item in lists
- [ ] Minimal data in tables
- [ ] One-word descriptions

Test: Does UI look broken or awkward with minimal content?

**Empty or Missing Data**
- [ ] Empty lists/tables
- [ ] Missing profile images (show default avatar?)
- [ ] Missing optional fields
- [ ] Null/undefined values
- [ ] Empty search results
- [ ] No notifications/alerts

Test: Are empty states designed and helpful?

**Large Datasets**
- [ ] 1000+ items in list
- [ ] Very wide tables (20+ columns)
- [ ] Deep navigation structures
- [ ] Large file uploads

Test: Does UI remain performant? Is pagination/virtualization used?

**Special Characters**
- [ ] Apostrophes and quotes in text
- [ ] HTML/script tags in input
- [ ] Unicode characters (emoji, symbols)
- [ ] RTL text (if internationalized)

Test: Is text escaped properly? No XSS vulnerabilities?

#### User Actions

**Rapid Interactions**
- [ ] Double-clicking buttons
- [ ] Clicking submit multiple times
- [ ] Rapid form submissions
- [ ] Quick navigation between pages

Test: Are actions debounced? No duplicate submissions?

**Backwards Navigation**
- [ ] Browser back button
- [ ] Returning to previous step in flow
- [ ] Canceling operations

Test: Does state restore correctly?

**Incomplete Actions**
- [ ] Partially filled forms
- [ ] Abandoned uploads
- [ ] Timed-out sessions
- [ ] Navigating away mid-action

Test: Is data saved/restored? Are there warnings?

**Permission Changes**
- [ ] User logs out
- [ ] Permissions revoked mid-session
- [ ] Account suspended
- [ ] Subscription expired

Test: Is user informed and redirected appropriately?

#### Network Conditions

**Slow Connection**
- [ ] Page load on 3G
- [ ] Image loading delays
- [ ] API request delays

Test: Are there loading states? Does it feel responsive?

**Offline Mode**
- [ ] No internet connection
- [ ] API unavailable
- [ ] Service maintenance

Test: Are there offline messages? Can user continue working?

**Failed Requests**
- [ ] 404 errors
- [ ] 500 server errors
- [ ] Timeout errors
- [ ] Network errors

Test: Are error messages helpful and actionable?

#### Device & Browser Variations

**Browser Features**
- [ ] JavaScript disabled
- [ ] Cookies disabled
- [ ] Ad blocker enabled
- [ ] Browser extensions interfering

Test: Graceful degradation? Informative messages?

**Device Capabilities**
- [ ] Touch-only device (no hover)
- [ ] Small screen (320px width)
- [ ] Very large screen (4K+)
- [ ] Different pixel densities

Test: UI works across all device types?

### Error State Testing

#### Form Validation Errors
- [ ] Required field empty
- [ ] Invalid email format
- [ ] Password too weak
- [ ] Mismatched passwords
- [ ] Invalid date ranges
- [ ] Value out of range

Test: Error messages clear, specific, and actionable?

#### Server Errors
- [ ] 400 Bad Request
- [ ] 401 Unauthorized
- [ ] 403 Forbidden
- [ ] 404 Not Found
- [ ] 500 Internal Server Error
- [ ] 503 Service Unavailable

Test: User-friendly error pages? Recovery options?

#### Business Logic Errors
- [ ] Insufficient permissions
- [ ] Duplicate entries
- [ ] Resource conflicts
- [ ] Quota exceeded
- [ ] Invalid state transitions

Test: Errors explain why and what to do next?

#### Upload Errors
- [ ] File too large
- [ ] Invalid file type
- [ ] Upload interrupted
- [ ] Virus detected

Test: Clear error messages? Retry option?

#### Payment Errors
- [ ] Card declined
- [ ] Insufficient funds
- [ ] Payment timeout
- [ ] Invalid card details

Test: Secure and clear messaging? Next steps provided?

### Testing Approach

1. **Systematic**: Test each edge case category
2. **Realistic**: Use actual long/short/missing data
3. **Document**: Screenshot each issue found
4. **Severity**: Assess impact on user experience

### Output

Document edge case issues with:
- Scenario tested
- Expected behavior
- Actual behavior
- Screenshot/recording
- Severity level (Blocker if data loss, otherwise High/Medium)
- Steps to reproduce

---

## Phase 7: Check Code Quality & Console

Verify the technical implementation quality and runtime behavior.

### Browser Console Checks

#### Console Errors
- [ ] No JavaScript errors
- [ ] No unhandled promise rejections
- [ ] No 404s for assets
- [ ] No CORS errors
- [ ] No deprecation warnings

#### Console Warnings
- [ ] No React/Vue warnings
- [ ] No accessibility warnings
- [ ] No performance warnings
- [ ] No missing key warnings (React)

#### Network Tab
- [ ] All API requests succeed
- [ ] No failed asset loads
- [ ] Reasonable number of requests
- [ ] No excessive payload sizes
- [ ] Images optimized
- [ ] Appropriate caching headers

### Code Quality Review

#### Component Structure
- [ ] Components are focused and single-purpose
- [ ] Proper separation of concerns
- [ ] No overly large components (>300 lines)
- [ ] Reusable components extracted
- [ ] Props/interface well-defined

#### Code Organization
- [ ] Files properly organized by feature/type
- [ ] Consistent naming conventions
- [ ] Related code grouped together
- [ ] No duplicate code
- [ ] Clear folder structure

#### Styling Implementation
- [ ] CSS follows project conventions
- [ ] No inline styles (unless necessary)
- [ ] Tailwind classes (if used) are organized
- [ ] No hardcoded colors (use design tokens)
- [ ] Responsive utilities used correctly
- [ ] No unnecessary !important

#### Performance Considerations
- [ ] Images lazy-loaded where appropriate
- [ ] Large lists virtualized
- [ ] Expensive computations memoized
- [ ] Debouncing/throttling for frequent events
- [ ] Code splitting for large pages
- [ ] No unnecessary re-renders

#### Accessibility in Code
- [ ] Semantic HTML elements used
- [ ] ARIA attributes present where needed
- [ ] Labels associated with inputs
- [ ] Focus management implemented
- [ ] Keyboard handlers present

#### State Management
- [ ] State appropriately scoped
- [ ] No prop drilling (if avoidable)
- [ ] Side effects properly handled
- [ ] Loading/error states managed
- [ ] Form state handled correctly

#### Error Handling
- [ ] Try-catch around risky operations
- [ ] Error boundaries implemented (React)
- [ ] User-friendly error messages
- [ ] Logging for debugging
- [ ] Graceful fallbacks

### Testing Code

#### Test Coverage
- [ ] Components have unit tests
- [ ] Critical user flows tested
- [ ] Edge cases covered
- [ ] Accessibility tests included
- [ ] Tests are maintainable

#### Test Quality
- [ ] Tests are clear and readable
- [ ] No overly complex mocking
- [ ] Tests actually test behavior
- [ ] Good test descriptions

### Documentation

#### Code Comments
- [ ] Complex logic explained
- [ ] Non-obvious decisions documented
- [ ] No outdated comments
- [ ] No commented-out code

#### Component Documentation
- [ ] Props documented (TypeScript/PropTypes)
- [ ] Usage examples clear
- [ ] Storybook stories (if used)
- [ ] README updated if needed

### Common Code Quality Issues

- Console errors/warnings
- Large component files
- Inline styles everywhere
- Hardcoded values
- Missing error handling
- Poor performance
- Accessibility missing in code
- No tests
- Duplicate code
- Complex, unreadable code

### Testing Tools

#### Browser DevTools
```javascript
// Check console
console.log() // Remove debug logs before merge

// Performance profiling
Performance tab in DevTools

// Memory profiling
Memory tab in DevTools
```

#### Lighthouse Audit
```bash
# Run Lighthouse for performance/accessibility/best practices
lighthouse https://your-app.com --view
```

#### Bundle Analysis
```bash
# Analyze bundle size
npm run build -- --analyze
```

### Output

Document code quality issues with:
- File/component affected
- Issue description
- Code reference or screenshot
- Impact on maintenance/performance
- Recommended improvement
- Severity level (typically Medium unless critical)

---

## Final Report Format

After completing all phases, compile findings into a comprehensive design review report:

```markdown
# Design Review Report

## Overview
[Summary of changes reviewed and testing approach]

## 🚨 Blockers
[Critical issues that must be fixed]

## 🔴 High Priority
[Important issues affecting UX]

## 🟡 Medium Priority
[Polish issues to address]

## ✅ What Works Well
[Positive findings and good practices]

## 💡 Suggestions for Future
[Nice-to-have improvements]

## Testing Evidence
[Links to screenshots, recordings, or test results]
```
