## Test coverage best practices

- **Write Minimal Tests During Development**: Do NOT write tests for every change or intermediate step. Focus on completing the feature implementation first, then add strategic tests only at logical completion points
- **Test Only Core User Flows**: Write tests exclusively for critical paths and primary user workflows. Skip writing tests for non-critical utilities and secondary workflows until if/when you're instructed to do so.
- **Defer Edge Case Testing**: Do NOT test edge cases, error states, or validation logic unless they are business-critical. These can be addressed in dedicated testing phases, not during feature development.
- **Test Behavior, Not Implementation**: Focus tests on what the code does, not how it does it, to reduce brittleness
- **Clear Test Names**: Use descriptive names that explain what's being tested and the expected outcome
- **Mock External Dependencies**: Isolate units by mocking databases, APIs, file systems, and other external services
- **Fast Execution**: Keep unit tests fast (milliseconds) so developers run them frequently during development

## Verification During Implementation

**CRITICAL REQUIREMENT: Verify each step before moving on to the next change.**

This applies to ALL implementation tasks and ensures quality at every step of the development process.

### Frontend Verification Process

After EVERY frontend change:

```bash
# 1. Verify that a test covers the change made
npm test

# 2. Check exit code
echo $?

# 3. Evaluate results:
#    - If 0, tests passed
#    - If not 0, tests failed
#
# 4. Look at actual test output, not assumptions

# 5. Ensure documents (markdown files) are updated
```

**Do not proceed to the next change until all tests pass.**

### Backend Verification Process

After EVERY backend change:

```bash
# 1. Verify that a test covers the change made
./mvnw clean package

# 2. Check exit code
echo $?

# 3. Evaluate results:
#    - If 0, build and tests passed
#    - If not 0, build or tests failed
#
# 4. Look at actual test output, not assumptions

# 5. Ensure documents (markdown files) are updated
```

**Do not proceed to the next change until the build and all tests pass.**

### Verification Checklist

Before moving to the next change, confirm:

- ✅ Exit code is 0 (tests passed)
- ✅ Actual test output has been reviewed (not just assumed)
- ✅ Test coverage exists for the change made
- ✅ Relevant documentation has been updated
- ✅ The change works as intended

**Skipping verification steps will lead to accumulated technical debt and harder-to-debug issues later.**
