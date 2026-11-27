# Code Review Workflow

Comprehensive code review process covering quality, security, dependencies, and best practices.

## Agent

This workflow should be executed by the **code-reviewer agent** (`{{agents/code-reviewer}}`).

## Overview

This workflow guides you through a systematic code review process:
1. **Identify Changes**: Understand what files have been modified
2. **Review Quality**: Assess code quality and adherence to standards
3. **Security Check**: Identify security vulnerabilities
4. **Optimize Dependencies**: Verify dependencies are using optimal versions (if dependencies changed)
5. **Generate Report**: Compile findings into actionable feedback

---

## Phase 1: Identify Changes

Use git to determine what files have been modified in the current branch compared to the main branch.

### Steps

1. Run `git status` to see current branch state
2. Run `git diff main...HEAD --name-status` to see all changed files
3. Run `git log main..HEAD --oneline` to see commit history
4. Create a list of files to review, organized by:
   - Backend code changes
   - Frontend code changes
   - Configuration changes
   - Test changes
   - Documentation changes

### Output

Store the list of changed files and their categories for use in subsequent review steps.

---

## Phase 2: Review Code Quality

Systematically review code changes against established standards and best practices.

### Review Checklist

#### Code Organization
- [ ] Files are properly organized according to project structure
- [ ] Naming conventions follow project standards
- [ ] Related functionality is grouped together
- [ ] No unnecessary code duplication

#### Code Readability
- [ ] Variable and function names are descriptive
- [ ] Complex logic has explanatory comments
- [ ] Code follows consistent formatting
- [ ] Functions are focused and not too long

#### Best Practices
- [ ] DRY principle applied appropriately
- [ ] SOLID principles followed (where applicable)
- [ ] Error handling is comprehensive
- [ ] Edge cases are considered
- [ ] No hardcoded values (use configuration/constants)

#### Tech Stack Specific
- [ ] Framework conventions followed
- [ ] ORM/database queries are efficient
- [ ] API patterns are consistent
- [ ] Component patterns match project standards

#### Performance
- [ ] No obvious performance bottlenecks
- [ ] Database queries are optimized
- [ ] Large datasets handled appropriately
- [ ] Caching used where beneficial

#### Testing
- [ ] Unit tests cover new functionality
- [ ] Integration tests for complex flows
- [ ] Edge cases are tested
- [ ] Tests are clear and maintainable

### Output

Document any issues found, categorized by severity (Critical, High, Medium, Low).

---

## Phase 3: Security Analysis

Check for common security vulnerabilities and ensure secure coding practices.

### Security Checklist

#### Input Validation
- [ ] All user inputs are validated
- [ ] Input types are enforced
- [ ] Input length limits are applied
- [ ] Special characters are handled safely

#### Authentication & Authorization
- [ ] Authentication checks are present
- [ ] Authorization rules are enforced
- [ ] Session management is secure
- [ ] Password handling follows best practices

#### Data Protection
- [ ] Sensitive data is encrypted
- [ ] Database queries use parameterization
- [ ] No SQL injection vulnerabilities
- [ ] No secrets in code (use environment variables)

#### XSS Prevention
- [ ] User-generated content is sanitized
- [ ] Output encoding is applied
- [ ] Content Security Policy considerations

#### CSRF Protection
- [ ] State-changing operations use CSRF tokens
- [ ] Safe HTTP methods (GET) don't modify data

#### API Security
- [ ] Rate limiting implemented
- [ ] API authentication required
- [ ] Proper CORS configuration
- [ ] Input validation on all endpoints

#### Dependency Security
- [ ] No known vulnerable dependencies
- [ ] Dependencies are up to date
- [ ] Minimal dependency footprint

#### Common Vulnerabilities (OWASP Top 10)
- [ ] No injection flaws
- [ ] No broken authentication
- [ ] No sensitive data exposure
- [ ] No XML external entities (XXE)
- [ ] No broken access control
- [ ] No security misconfiguration
- [ ] No XSS vulnerabilities
- [ ] No insecure deserialization
- [ ] No components with known vulnerabilities
- [ ] Sufficient logging and monitoring

### Output

Document any security issues found with HIGH priority, including:
- Specific vulnerability description
- Affected code location
- Potential impact
- Recommended fix

---

## Phase 4: Optimize Dependencies (Conditional)

If the code changes include modifications to dependency files, verify that all dependencies use optimal versions.

### When to Perform This Phase

Check if any of these files were modified:
- Python: `requirements.txt`, `pyproject.toml`, `Pipfile`, `setup.py`
- JavaScript/Node: `package.json`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
- Java: `pom.xml`, `build.gradle`, `gradle.properties`

**Check for dependency changes:**
```bash
git diff main...HEAD --name-status | grep -E '(requirements\.txt|pyproject\.toml|package\.json|pom\.xml|build\.gradle)'
```

If dependency files were modified, proceed with this phase. Otherwise, skip to Phase 5.

### Dependency Review Process

Follow the comprehensive dependency optimization workflow:

{{workflows/optimize-dependencies}}

### Key Checks

For each new or updated dependency:
- [ ] Uses latest stable version (verified via Context7 MCP)
- [ ] No known security vulnerabilities
- [ ] Compatible with other dependencies
- [ ] Actively maintained (recent updates)
- [ ] Documentation available via Context7
- [ ] Proper usage follows best practices

### Context7 MCP Usage

Use the Context7 MCP tools to verify each dependency:

```typescript
// 1. Resolve the library to get Context7 ID
const libraryId = await mcp__context7__resolve_library_id({
  libraryName: "django",
  query: "Python web framework for building SaaS REST APIs"
});

// 2. Query for version and best practices
const docs = await mcp__context7__query_docs({
  libraryId: libraryId,
  query: "What is the latest stable version? What are security best practices and recommended configuration?"
});
```

### Output

Document dependency review findings:
- **New Dependencies Added**: List with rationale
- **Version Updates**: Old version → New version with justification
- **Security Concerns**: Any vulnerable dependencies found
- **Compatibility Issues**: Dependencies that conflict
- **Recommendations**: Suggested changes to dependency versions
- **Context7 References**: Links to documentation for each dependency

Include in the final review report as a dedicated section.

---

## Phase 5: Generate Review Report

Compile all findings into a comprehensive, actionable code review report.

### Report Structure

#### 1. Executive Summary
- Brief overview of changes reviewed
- Number of files changed
- Overall quality assessment
- Key recommendations

#### 2. Critical Issues (Blockers)
For each critical issue:
- **Location**: File path and line number
- **Issue**: Clear description of the problem
- **Impact**: Why this is critical
- **Recommendation**: How to fix it

#### 3. High Priority Issues
For each high priority issue:
- **Location**: File path and line number
- **Issue**: Clear description of the problem
- **Impact**: Why this matters
- **Recommendation**: Suggested fix

#### 4. Medium Priority Issues
For each medium priority issue:
- **Location**: File path and line number
- **Issue**: Clear description
- **Recommendation**: How to improve

#### 5. Low Priority (Nitpicks)
Brief list of minor suggestions for improvement

#### 6. Dependency Review (if applicable)
If dependencies were modified:
- New dependencies added with rationale
- Version updates with justification
- Security concerns identified
- Compatibility verification results
- Context7 documentation references

#### 7. Positive Findings
Highlight things done well:
- Good design patterns used
- Excellent test coverage
- Clear documentation
- Performance optimizations
- Security best practices

#### 8. Overall Recommendations
- Summary of must-fix items
- Suggestions for future improvements
- Process recommendations (if applicable)

### Tone Guidelines

- **Constructive**: Focus on improvement, not criticism
- **Specific**: Include file paths, line numbers, and examples
- **Actionable**: Make it clear what needs to change
- **Balanced**: Acknowledge good work alongside issues
- **Professional**: Maintain respectful, collaborative tone

### Example Format

```markdown
# Code Review Report

## Executive Summary
Reviewed 15 files with changes to the user authentication system. Overall code quality is good with comprehensive test coverage. Found 1 security issue that must be addressed before merge, and several opportunities for improvement.

## 🚨 Critical Issues

### 1. SQL Injection Vulnerability
**Location**: `src/users/user_repository.py:45`
**Issue**: Raw SQL query uses string interpolation with user input
**Impact**: Allows potential SQL injection attacks
**Recommendation**: Use parameterized queries or ORM methods

## 🔴 High Priority
[...]

## 🟡 Medium Priority
[...]

## 💡 Nitpicks
[...]

## 📦 Dependency Review

### New Dependencies Added
- **djangorestframework-simplejwt** (5.3.1): For JWT authentication
  - Latest stable version confirmed via Context7
  - No security vulnerabilities
  - Compatible with Django 5.0 and djangorestframework 3.14

### Version Updates
- **Django**: 4.2.8 → 5.0.1
  - Rationale: Security updates and new features
  - Breaking changes: Updated STORAGES setting (migration applied)
  - Context7 docs: [link]

### Security & Compatibility
✅ All dependencies scanned - no vulnerabilities
✅ Compatibility matrix verified
✅ All dependencies actively maintained

## ✅ What Works Well
- Excellent test coverage (95%+)
- Clear variable naming
- Good error handling patterns
- Dependencies are up-to-date and well-documented

## Overall Recommendations
1. Fix SQL injection vulnerability immediately
2. Add rate limiting to login endpoint
3. Consider extracting common validation logic
4. Dependencies look good - no changes needed
```

### Delivery

Save the report to a file or present it directly, depending on the context of the review.
