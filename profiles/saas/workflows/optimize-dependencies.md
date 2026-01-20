# Optimize Dependencies

Verify all dependencies use exact stable versions via Context7 MCP.

## When to Run

- New dependency added
- Dependency updated
- During implementation verification
- During code review (if dependency files changed)

## Process

### 1. Identify Changed Dependencies

```bash
git diff main...HEAD --name-status | grep -E '(requirements\.txt|package\.json|pom\.xml|pyproject\.toml|build\.gradle)'
```

Scan files: `requirements.txt`, `package.json`, `pom.xml`, `pyproject.toml`, `build.gradle`

### 2. For Each Dependency, Use Context7 MCP

```typescript
// Resolve library
const libId = await mcp__context7__resolve_library_id({
  libraryName: "django",
  query: "Python web framework for SaaS REST APIs"
});

// Get latest stable version
const docs = await mcp__context7__query_docs({
  libraryId: libId,
  query: "Latest stable version? Recommended for production SaaS? Security best practices?"
});
```

### 3. Verify Each Dependency

- [ ] **Exact version** (no `^`, `~`, `>=`)
- [ ] **Latest stable** (not beta/alpha)
- [ ] **No vulnerabilities**
- [ ] **Compatible** with other deps
- [ ] **Actively maintained**
- [ ] **Documented** via Context7

### 4. Update Dependency Files

**Python:**
```txt
Django==5.0.1
djangorestframework==3.14.0
```

**JavaScript:**
```json
{
  "dependencies": {
    "react": "18.2.0",
    "react-dom": "18.2.0"
  }
}
```

**Java:**
```xml
<spring-boot.version>3.2.1</spring-boot.version>
```

### 5. Check Compatibility

Query Context7: "Is [dep A] version X compatible with [dep B] version Y?"

### 6. Document Breaking Changes

If version updated, note migration requirements from Context7.

## Output

Document in review report:
- **New deps**: Name, version, rationale
- **Updated deps**: Old → New, breaking changes, migration notes
- **Security**: Vulnerabilities found/fixed
- **Context7 refs**: Documentation links

## See Also

{{standards/global/versioning}} - Exact version pinning standards
