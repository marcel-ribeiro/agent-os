# Optimize Dependencies Workflow

Use Context7 MCP to determine optimal versions and configurations for all project dependencies.

## Overview

This workflow ensures that all dependencies use the latest stable, compatible versions with up-to-date documentation and best practices. It should be invoked whenever:
- A new dependency is added to the project
- Dependencies are being updated
- Setting up a new project
- Verifying implementation quality

## Process

### Step 1: Identify Dependencies

Scan the project for dependency files:

**Backend:**
- Python: `requirements.txt`, `pyproject.toml`, `Pipfile`
- Java: `pom.xml`, `build.gradle`
- Node.js: `package.json`

**Frontend:**
- `package.json` in frontend directory

**Infrastructure:**
- `Dockerfile`, `docker-compose.yml`
- Terraform configurations
- Kubernetes manifests

### Step 2: Categorize Dependencies

Organize dependencies by type:
- **Framework**: Main application framework (Django, Spring Boot, Express, React)
- **Core Libraries**: Essential functionality (ORMs, authentication, validation)
- **UI Libraries**: Frontend components and styling (Tailwind, shadcn/ui)
- **Testing**: Test frameworks and utilities
- **Dev Tools**: Linting, formatting, build tools
- **Infrastructure**: Database clients, caching, message queues

### Step 3: Resolve Optimal Versions with Context7

For each dependency, use Context7 MCP to determine the optimal version:

#### Using Context7 MCP Tools

```typescript
// 1. Resolve library ID
const libraryId = await mcp__context7__resolve_library_id({
  libraryName: "django",
  query: "Python web framework for building SaaS applications with REST APIs"
});

// 2. Query for latest stable version and best practices
const docs = await mcp__context7__query_docs({
  libraryId: libraryId,
  query: "What is the latest stable version? What are the recommended dependencies and configuration for production SaaS applications?"
});
```

#### What to Check for Each Dependency

1. **Latest Stable Version**: Not beta/alpha unless explicitly needed
2. **Compatibility**: Works with other dependencies (check peer dependencies)
3. **Security**: No known vulnerabilities
4. **Maintenance**: Actively maintained, recent updates
5. **Documentation**: Good documentation available
6. **Best Practices**: Recommended configuration and setup

#### Priority Order

Research dependencies in this order:
1. **Core Framework** (Django, Spring Boot, React, etc.)
2. **Runtime/Language** (Python, Java, Node.js versions)
3. **Database & ORM** (PostgreSQL client, SQLAlchemy, Prisma)
4. **Essential Libraries** (Authentication, validation, state management)
5. **UI Components** (Tailwind, shadcn/ui, Lucide icons)
6. **Testing Tools** (pytest, JUnit, Vitest, Playwright)
7. **Development Tools** (linters, formatters, build tools)

### Step 4: Document Findings

Create a summary of optimal versions and rationale:

```markdown
## Dependency Optimization Report

### Core Framework
- **Django**: 5.0.x (latest stable)
  - Rationale: Current LTS version with security updates
  - Breaking changes: None from 4.2
  - Documentation: [link from Context7]

- **React**: 18.2.0
  - Rationale: Current stable, concurrent features available
  - Peer deps: react-dom@18.2.0
  - Documentation: [link from Context7]

### Database & ORM
- **PostgreSQL**: 16.x
  - Rationale: Latest stable with performance improvements
  - Compatible with: psycopg2@2.9.x

- **SQLAlchemy**: 2.0.x
  - Rationale: New API, better typing, async support
  - Migration notes: [link to migration guide from Context7]

### [Continue for all dependencies...]
```

### Step 5: Check Compatibility Matrix

Verify that all dependencies work together:

**Common Compatibility Checks:**
- React version matches react-dom
- TypeScript version compatible with all @types packages
- Django version compatible with djangorestframework
- Spring Boot version compatible with Spring Data JPA
- Node.js version supports all JavaScript dependencies
- Tailwind CSS version compatible with plugins

Use Context7 to check: "What versions of [dependency B] are compatible with [dependency A] version X?"

### Step 6: Update Dependency Files

Update the appropriate files with optimal versions:

**Python (requirements.txt):**
```txt
# Core Framework
Django==5.0.1
djangorestframework==3.14.0

# Database
psycopg2-binary==2.9.9
SQLAlchemy==2.0.25

# Authentication
djangorestframework-simplejwt==5.3.1

# Testing
pytest==7.4.3
pytest-django==4.7.0
```

**Python (pyproject.toml with Poetry):**
```toml
[tool.poetry.dependencies]
python = "^3.11"
django = "^5.0"
djangorestframework = "^3.14"
psycopg2-binary = "^2.9"
```

**JavaScript (package.json):**
```json
{
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.21.0",
    "@tanstack/react-query": "^5.17.0",
    "zustand": "^4.4.7",
    "tailwindcss": "^3.4.0"
  },
  "devDependencies": {
    "vite": "^5.0.10",
    "typescript": "^5.3.3",
    "@types/react": "^18.2.47",
    "vitest": "^1.1.0",
    "playwright": "^1.40.1"
  }
}
```

**Java (pom.xml):**
```xml
<properties>
    <java.version>21</java.version>
    <spring-boot.version>3.2.1</spring-boot.version>
</properties>

<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
        <version>${spring-boot.version}</version>
    </dependency>
    <!-- ... -->
</dependencies>
```

### Step 7: Verify No Breaking Changes

For each updated dependency, check Context7 for:
- Migration guides
- Breaking changes
- Deprecation warnings
- Required code changes

Document any necessary code updates:

```markdown
## Required Code Changes

### Django 4.2 → 5.0
- Update `STORAGES` setting (replaces `DEFAULT_FILE_STORAGE`)
- Review async view compatibility
- Update deprecated imports

### SQLAlchemy 1.4 → 2.0
- Use new declarative syntax
- Update session queries (no more `.query()`)
- Async engine configuration
```

### Step 8: Add Installation Notes

Document how to install/update dependencies:

**Python:**
```bash
# Install/update from requirements.txt
pip install -r requirements.txt

# Or with Poetry
poetry install
poetry update
```

**JavaScript:**
```bash
# Install/update from package.json
npm install

# Or with pnpm
pnpm install
```

**Java:**
```bash
# Maven
mvn clean install

# Gradle
./gradlew build
```

## Important Guidelines

### Always Use Context7 First

Before adding any dependency, use Context7 to:
1. Verify it's the right library for the use case
2. Find the latest stable version
3. Check for better alternatives
4. Understand proper usage and configuration

### Query Examples for Context7

**Finding the right library:**
```
"What is the best library for form validation in React with TypeScript support?"
```

**Version information:**
```
"What is the latest stable version of Django and what are the key features?"
```

**Compatibility:**
```
"Is Django 5.0 compatible with Python 3.11? What about djangorestframework 3.14?"
```

**Best practices:**
```
"What are the recommended dependencies and configuration for a production Django REST API?"
```

**Migration guidance:**
```
"How do I migrate from SQLAlchemy 1.4 to 2.0? What are the breaking changes?"
```

### Version Pinning Strategy

**Production Dependencies:**
- Pin exact versions for stability: `Django==5.0.1`
- Use caret (^) for JavaScript: `"react": "^18.2.0"` (allows patch updates)

**Development Dependencies:**
- More flexible versioning acceptable
- Still document tested versions

**Security:**
- Always use latest patch versions for security fixes
- Subscribe to security advisories
- Run `npm audit` / `pip-audit` regularly

## Output

Generate a comprehensive dependency report that includes:

1. **Current State**: List of all current dependencies and versions
2. **Recommended Updates**: Optimal versions with rationale
3. **Compatibility Matrix**: Verified compatibility between dependencies
4. **Breaking Changes**: Any migrations or code changes required
5. **Installation Commands**: How to apply the updates
6. **Testing Plan**: What to test after updating

## Success Criteria

✅ All dependencies use latest stable versions (not beta/alpha)
✅ No known security vulnerabilities
✅ All dependencies are compatible with each other
✅ Documentation available via Context7 for each dependency
✅ Migration path documented for any breaking changes
✅ Dependency files updated with optimal versions
✅ Installation process documented
