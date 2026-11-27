# Verify Multi-Tenancy

Ensure tenant data isolation and security in multi-tenant SaaS architecture.

## Critical Checks

### 1. Database Queries Include Tenant Filter

**Check all queries filter by tenant/organization:**

```python
# ✅ GOOD - tenant filtered
users = User.objects.filter(organization_id=request.user.organization_id)

# ❌ BAD - no tenant filter (data leak!)
users = User.objects.all()
```

**Verify:**
- [ ] All model queries include tenant filter
- [ ] No `.all()` without tenant filter
- [ ] Foreign keys include tenant validation
- [ ] Search queries scoped to tenant

### 2. API Endpoints Enforce Tenant Isolation

```python
# Check authorization includes tenant check
def has_object_permission(self, request, view, obj):
    return obj.organization == request.user.organization
```

**Test each endpoint:**
- [ ] Cannot access other tenant's data via ID manipulation
- [ ] Cannot create resources for other tenants
- [ ] Cannot update other tenant's resources
- [ ] Cannot delete other tenant's resources

### 3. Test Tenant Isolation

**Create test:**
```python
def test_tenant_isolation():
    tenant1_user = create_user(org=org1)
    tenant2_data = create_resource(org=org2)

    # Should return 403 or 404, not 200
    response = api_client.get(f"/api/resource/{tenant2_data.id}",
                              headers=auth_header(tenant1_user))
    assert response.status_code in [403, 404]
```

**Required tests:**
- [ ] User cannot read other tenant's data
- [ ] User cannot modify other tenant's data
- [ ] Listing endpoints only show own tenant's data
- [ ] Search only returns own tenant's results

### 4. Database-Level Isolation (if using RLS)

If using PostgreSQL Row-Level Security:
- [ ] RLS policies defined for all tables
- [ ] Policies tested for each tenant
- [ ] Cannot bypass with superuser queries in app

### 5. Shared Resources Handled Correctly

For resources shared across tenants (templates, public data):
- [ ] Clearly marked as public/shared
- [ ] Separate tables or explicit flags
- [ ] Cannot modify shared resources from tenant context

## Critical Vulnerabilities to Check

- **Mass Assignment**: Accepting `organization_id` in request body
- **URL Parameters**: Trusting tenant ID from URL/query params
- **JWT Claims**: Not validating tenant claim in token
- **Admin Overrides**: Admin views bypassing tenant filters

## Run Multi-Tenancy Test Suite

```bash
# Run tenant isolation tests
pytest tests/test_tenant_isolation.py -v
```

Expected: All tests pass, zero data leaks.

## Output

- [ ] All database queries tenant-filtered
- [ ] All API endpoints enforce tenant isolation
- [ ] Tenant isolation tests passing
- [ ] No vulnerabilities found
- [ ] Documentation updated if new patterns added
