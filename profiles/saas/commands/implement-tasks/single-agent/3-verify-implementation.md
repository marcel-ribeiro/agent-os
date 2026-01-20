Now that we've implemented all tasks in tasks.md, we must run final verifications and produce a verification report using the following MULTI-PHASE workflow:

## Workflow

### Step 1: Ensure tasks.md has been updated

{{workflows/implementation/verification/verify-tasks}}

### Step 2: Update roadmap (if applicable)

{{workflows/implementation/verification/update-roadmap}}

### Step 3: Run entire tests suite

{{workflows/implementation/verification/run-all-tests}}

### Step 4: Optimize dependencies using Context7 MCP

Before finalizing, ensure all dependencies are using optimal versions:

{{workflows/optimize-dependencies}}

This step verifies that:
- All new dependencies use latest stable versions
- No critical security vulnerabilities exist
- Dependencies are compatible with each other
- Documentation is available for each dependency

**When to perform this step:**
- Always run when new dependencies were added
- Skip if no dependency changes were made

### Step 5: Review design implementation (Frontend changes only)

If the implementation includes frontend/UI changes, perform a comprehensive design review:

{{workflows/review-design}}

This step verifies:
- UI/UX design quality and consistency
- Cross-viewport responsiveness
- WCAG 2.1 AA accessibility compliance
- Visual polish and design system adherence
- Interactive user flows work correctly
- Edge cases and error states handled properly

**When to perform this step:**
Perform design review if changes include:
- `.tsx`, `.jsx`, `.vue`, `.html` files (UI components)
- `.css`, `.scss`, `.module.css` files (styling)
- Page/route components
- UI component libraries

**How to determine if frontend changes exist:**
```bash
# Check for frontend file changes
git diff main...HEAD --name-status | grep -E '\.(tsx|jsx|vue|html|css|scss)$'
```

If no frontend files were modified, skip this step.

### Step 6: Create final verification report

{{workflows/implementation/verification/create-verification-report}}

## Important Notes

- **All steps are mandatory** except Step 5 (design review), which is conditional
- Each step must complete successfully before proceeding to the next
- Document any issues found during verification
- Update tasks.md with any additional work identified
- Do not skip verification steps to save time

## Success Criteria

✅ All tasks in tasks.md marked as completed
✅ Roadmap updated (if applicable)
✅ All tests passing
✅ Dependencies optimized and documented
✅ Design review passed (if frontend changes present)
✅ Verification report generated
