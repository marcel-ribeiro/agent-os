## CRITICAL: Frontend Testing Requirements

### ❌ NO Unit Tests for Frontend/UI Components

**ABSOLUTE RULE: DO NOT write unit tests for frontend code.**

- ❌ NO React component unit tests
- ❌ NO Jest/Vitest tests for UI components
- ❌ NO testing-library tests for individual components
- ❌ NO snapshot tests
- ❌ NO isolated component rendering tests

**Why:** Unit tests for UI components are brittle, maintenance-heavy, and don't catch real user experience issues. They test implementation details rather than user value.

### ✅ ONLY E2E Tests with Playwright MCP for Frontend

**MANDATORY: ALL frontend/UI changes MUST be verified with Playwright E2E tests.**

- ✅ Use Playwright MCP for ALL UI changes
- ✅ Test complete user flows end-to-end
- ✅ Test in real browser environment
- ✅ Test actual user interactions (click, type, navigate)
- ✅ Verify visual rendering and behavior
- ✅ Check accessibility in real browser
- ✅ Test responsive design across viewports

**Exception:** For tests that would contact 3rd party providers (Stripe, Clerk, etc.), write **integration tests** that mock the external service at the network boundary. These are still browser-based tests using Playwright, but with network mocking.

### Backend Testing

Backend code should have:
- ✅ Unit tests for business logic
- ✅ Integration tests for database operations
- ✅ API endpoint tests

## Test coverage best practices

- **Write Minimal Tests During Development**: Do NOT write tests for every change or intermediate step. Focus on completing the feature implementation first, then add strategic tests only at logical completion points
- **Test Only Core User Flows**: Write tests exclusively for critical paths and primary user workflows. Skip writing tests for non-critical utilities and secondary workflows until if/when you're instructed to do so.
- **Defer Edge Case Testing**: Do NOT test edge cases, error states, or validation logic unless they are business-critical. These can be addressed in dedicated testing phases, not during feature development.
- **Test Behavior, Not Implementation**: Focus tests on what the code does, not how it does it, to reduce brittleness
- **Clear Test Names**: Use descriptive names that explain what's being tested and the expected outcome
- **Mock External Dependencies**: Isolate units by mocking databases, APIs, file systems, and other external services
- **Fast Execution**: Keep unit tests fast (milliseconds) so developers run them frequently during development
