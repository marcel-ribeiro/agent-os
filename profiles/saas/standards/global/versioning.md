# Dependency Versioning Standards

## Version Pinning Policy

**ALL dependencies MUST use exact version pinning. No ranges, no flexibility.**

### Rationale

- **Reproducibility**: Exact versions ensure identical builds across environments
- **Stability**: Prevents unexpected breaking changes from patch/minor updates
- **Security**: Explicit control over when to adopt updates
- **Debugging**: Easy to identify which version caused issues

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

### Process

1. **Use Context7 MCP** to identify latest stable version
2. **Test in development** environment
3. **Review changelog** for breaking changes
4. **Update to exact new version**
5. **Run full test suite**
6. **Deploy to staging** for verification
7. **Document the update** in commit message

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

## No Exceptions

**NEVER use:**
- Python: `>=`, `~=`, `^`
- JavaScript: `^`, `~`, `*`, `latest`
- Java: `[1.0,2.0)`, `+`

**Only use:**
- Python: `==`
- JavaScript: exact version (no prefix)
- Java: exact version in properties

## CI/CD Enforcement

Add checks to CI/CD pipeline:

```bash
# Python - verify no range operators
grep -E '(>=|~=|\^)' requirements.txt && exit 1

# JavaScript - verify no ^ or ~
grep -E '"\^|"~|"\*' package.json && exit 1
```
