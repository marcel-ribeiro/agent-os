## Memory and Tracking Files Management

**CRITICAL REQUIREMENT**: All tracking, progress, summary, report, and memory files created during agent operations MUST be stored in a centralized location to keep project directories clean and organized.

### Memory Directory Location

All files created for tracking progress, storing summaries, reports, or serving as agent memory MUST be placed in:

```
@agent-os/memory/
```

This directory is specifically designated for:
- Task completion reports (e.g., `TASK_1.3_1.4_COMPLETION.md`)
- Implementation summaries (e.g., `TASK_4_5_SUMMARY.md`)
- Test execution reports (e.g., `TEST_EXECUTION_REPORT.md`)
- Dependency reports (e.g., `DEPENDENCY_OPTIMIZATION_REPORT.md`)
- Project structure files (e.g., `PROJECT_STRUCTURE.txt`)
- Integration setup files (e.g., `STRIPE_INTEGRATION.md`)
- UI setup completion files (e.g., `AUTH_UI_SETUP.md`, `CLERK_SETUP_COMPLETE.md`)
- Component creation logs (e.g., `COMPONENTS_CREATED.md`)
- Implementation completion markers (e.g., `EMPLOYEE_UI_IMPLEMENTATION_COMPLETE.md`)
- Any other temporary or tracking files that help maintain context

### Prohibited Locations

**NEVER** create tracking or memory files in:
- Project root directory (e.g., `/Users/username/projects/my-project/`)
- Backend directory (e.g., `backend/PROJECT_STRUCTURE.txt`)
- Frontend directory (e.g., `frontend/AUTH_UI_SETUP.md`)
- Any application source code directories
- Any other location besides `@agent-os/memory/`

### File Organization Within Memory Directory

Within `@agent-os/memory/`, organize files by category when appropriate:

```
@agent-os/memory/
├── task-reports/          # Task completion and progress reports
├── test-reports/          # Test execution and coverage reports
├── implementation/        # Implementation summaries and notes
├── integrations/          # Third-party integration setup files
├── verification/          # Verification and validation reports
└── general/               # Other tracking files
```

### Examples

**❌ INCORRECT:**
```
/Users/username/projects/my-project/TASK_COMPLETION.md
/Users/username/projects/my-project/backend/PROJECT_STRUCTURE.txt
/Users/username/projects/my-project/frontend/CLERK_SETUP_COMPLETE.md
```

**✅ CORRECT:**
```
@agent-os/memory/task-reports/TASK_COMPLETION.md
@agent-os/memory/general/PROJECT_STRUCTURE.txt
@agent-os/memory/integrations/CLERK_SETUP_COMPLETE.md
```

### When Creating Memory Files

Before creating any tracking or memory file, always:

1. Determine if this file is for tracking, progress, or memory purposes
2. If yes, use `@agent-os/memory/` as the base directory
3. Choose an appropriate subdirectory if applicable
4. Create the file with a descriptive name

### Exception: Official Documentation

This rule does NOT apply to:
- Files specified in `agent-os/specs/` (these are official spec documents)
- Files specified in standard project locations (e.g., `README.md`, `package.json`)
- Test files in the test directories
- Source code and configuration files

**Summary**: Keep the project clean. All ad-hoc tracking, memory, and progress files go in `@agent-os/memory/`.
