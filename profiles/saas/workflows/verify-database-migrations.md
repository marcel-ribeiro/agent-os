# Verify Database Migrations

Ensure database migrations are safe, reversible, and won't cause downtime or data loss.

## Pre-Deployment Checks

### 1. Identify New Migrations

```bash
# Check for new migration files
git diff main...HEAD --name-status | grep migrations
```

### 2. Review Each Migration

**Critical Safety Checks:**
- [ ] **No data deletion** without explicit backup
- [ ] **No column drops** without deprecation period
- [ ] **No destructive renames** (use add + migrate + drop pattern)
- [ ] **Indexes added with `CONCURRENTLY`** (PostgreSQL)
- [ ] **Large tables** - migrations tested on staging with production-size data
- [ ] **Reversible** - has `down` migration or rollback plan

### 3. Dangerous Operations

**Avoid in production:**
```python
# ❌ BAD - blocking, data loss
operations = [
    migrations.RemoveField('User', 'email'),  # Data loss!
    migrations.AlterField('Product', 'price'),  # Locks table!
]

# ✅ GOOD - safe pattern
operations = [
    # Phase 1: Add new field (nullable)
    migrations.AddField('User', 'email_new', null=True),
    # Phase 2: Data migration (separate release)
    migrations.RunPython(copy_email_to_new_field),
    # Phase 3: Remove old field (separate release)
    migrations.RemoveField('User', 'email_old'),
]
```

### 4. Test Migrations

**On staging with production-like data:**
```bash
# Apply migration
python manage.py migrate

# Verify data integrity
python manage.py check_data_integrity

# Test rollback
python manage.py migrate app_name previous_migration_name
```

**Check:**
- [ ] Migration completes in <30 seconds (or async for large tables)
- [ ] No data loss during migration
- [ ] Application works during migration
- [ ] Rollback works without data loss

### 5. Zero-Downtime Pattern

For production:
1. **Deploy code** that works with both old and new schema
2. **Run migration** (backward compatible)
3. **Verify** application health
4. **Deploy cleanup** (remove old code paths)

## Common Mistakes

- Dropping columns that old code still uses
- Adding NOT NULL without default
- Renaming without transition period
- Large table alterations without CONCURRENTLY
- No rollback plan
- Not testing on production-size data

## Output

- [ ] All migrations reviewed for safety
- [ ] No data loss risks
- [ ] Tested on staging
- [ ] Rollback plan documented
- [ ] Zero-downtime approach if needed
