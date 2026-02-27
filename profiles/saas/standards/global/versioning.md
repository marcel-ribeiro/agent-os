# Dependency Versioning Standards

## Critical Rules

### 1. ALWAYS Use Exact Versions

**ALL dependencies MUST use exact version pinning. No ranges, no flexibility.**

❌ **NEVER use version ranges:**
- Python: `>=`, `~=`, `^`, `*`
- JavaScript: `^`, `~`, `*`, `latest`, `x`
- Java: `[1.0,2.0)`, `+`, `LATEST`

✅ **ALWAYS use exact versions:**
- Python: `==5.0.1`
- JavaScript: `"5.0.1"` (no prefix)
- Java: `5.0.1` (in properties)

### 2. MANDATORY: Use Context7 MCP for Version Selection

**Before adding or updating ANY dependency, you MUST:**

1. **Query Context7 MCP** to identify the latest stable, production-ready version
2. **Verify compatibility** with your existing dependencies
3. **Use the exact version** returned by Context7

**Example workflow:**
```
Step 1: Query Context7 MCP
"What is the latest stable version of react that supports TypeScript 5?"

Step 2: Use the exact version returned
"react": "19.2.3"  ← NOT "^19.2.3"
```

### Rationale

- **Reproducibility**: Exact versions ensure identical builds across environments
- **Stability**: Prevents unexpected breaking changes from patch/minor updates
- **Security**: Explicit control over when to adopt updates
- **Debugging**: Easy to identify which version caused issues
- **Best Practices**: Context7 ensures you're using tested, stable versions

## Version Format by Language

### Python

**Use exact pinning with `==`:**

```txt
# requirements.txt
Django==5.0.1
djangorestframework==3.14.0
psycopg2-binary==2.9.9
celery==5.3.6
redis==5.0.1
```

**Poetry (pyproject.toml):**
```toml
[tool.poetry.dependencies]
python = "3.11.7"
django = "5.0.1"
djangorestframework = "3.14.0"
```

### JavaScript/TypeScript

**Use exact versions (no ^ or ~):**

```json
{
  "dependencies": {
    "react": "18.2.0",
    "react-dom": "18.2.0",
    "@tanstack/react-query": "5.17.9",
    "zustand": "4.4.7",
    "tailwindcss": "3.4.1"
  },
  "devDependencies": {
    "vite": "5.0.11",
    "typescript": "5.3.3",
    "@types/react": "18.2.48",
    "vitest": "1.1.3",
    "playwright": "1.40.1"
  }
}
```

### Java

**Maven (pom.xml) - exact versions:**
```xml
<properties>
    <spring-boot.version>3.2.1</spring-boot.version>
    <postgresql.version>42.7.1</postgresql.version>
</properties>
```

**Gradle - exact versions:**
```gradle
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web:3.2.1'
    implementation 'org.postgresql:postgresql:42.7.1'
}
```

## Updating Dependencies

### MANDATORY Process

**Every dependency update MUST follow these steps:**

1. **Query Context7 MCP** to identify the latest stable version
   - Ask: "What is the latest stable production version of [package]?"
   - Verify it's compatible with your tech stack
   - Get the exact version number (no ranges)

2. **Test in development** environment with the exact version

3. **Review changelog** for breaking changes (Context7 can help with this)

4. **Update to the exact new version** (no `^` or `~`)

5. **Run full test suite** to verify compatibility

6. **Deploy to staging** for verification

7. **Document the update** in commit message with version numbers

### When to Update

- **Security patches**: Immediately
- **Bug fixes**: Within 1 week of release
- **Minor/major versions**: Planned quarterly review
- **Critical dependencies**: Monthly review

### Lock Files

**Always commit lock files:**
- Python: `poetry.lock`, `Pipfile.lock`
- JavaScript: `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
- Java: Not applicable (versions in pom.xml/build.gradle)

## No Exceptions - Zero Tolerance Policy

**This is a HARD REQUIREMENT. No compromises, no exceptions.**

### ❌ ABSOLUTELY FORBIDDEN:

**Python:**
- `Django>=5.0` ← WRONG
- `requests~=2.31` ← WRONG
- `numpy^1.24` ← WRONG
- `pandas*` ← WRONG

**JavaScript/TypeScript:**
- `"react": "^19.2.3"` ← WRONG
- `"next": "~16.1.0"` ← WRONG
- `"typescript": "*"` ← WRONG
- `"axios": "latest"` ← WRONG

**Java:**
- `<version>[1.0,2.0)</version>` ← WRONG
- `<version>1.0.+</version>` ← WRONG

### ✅ REQUIRED FORMAT:

**Python:**
- `Django==5.0.1` ← CORRECT
- `requests==2.31.0` ← CORRECT

**JavaScript/TypeScript:**
- `"react": "19.2.3"` ← CORRECT
- `"next": "16.1.4"` ← CORRECT

**Java:**
- `<version>5.0.1</version>` ← CORRECT
- `<spring-boot.version>3.2.1</spring-boot.version>` ← CORRECT

### If You See Version Ranges Anywhere:

1. **STOP immediately**
2. **Query Context7 MCP** for the correct exact version
3. **Replace the range** with the exact version
4. **Test thoroughly**

## CI/CD Enforcement

Add checks to CI/CD pipeline:

```bash
# Python - verify no range operators
grep -E '(>=|~=|\^)' requirements.txt && exit 1

# JavaScript - verify no ^ or ~
grep -E '"\^|"~|"\*' package.json && exit 1
```
