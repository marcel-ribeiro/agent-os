# Verify Performance

Test API performance, database queries, and frontend load times.

## When to Run

- API endpoints added/modified
- Database queries changed
- Frontend components added
- Before major releases

## Backend Performance

### 1. API Response Times

**Target:** <200ms (p95), <500ms (p99)

**Test critical endpoints:**
```bash
# Using Apache Bench
ab -n 1000 -c 10 https://api.example.com/api/v1/users

# Or curl with timing
curl -w "@curl-timing.txt" -o /dev/null -s https://api.example.com/api/v1/users
```

**Check:**
- [ ] p95 < 200ms for read endpoints
- [ ] p95 < 500ms for write endpoints
- [ ] No timeouts under load

### 2. Database Query Performance

**Identify slow queries:**
```python
# Django - enable query logging
from django.db import connection
print(connection.queries)

# Look for queries >100ms
```

**Optimize:**
- [ ] N+1 queries eliminated (use `select_related`, `prefetch_related`)
- [ ] Indexes exist for filtered/joined fields
- [ ] Large datasets paginated
- [ ] No `SELECT *` on large tables

### 3. Load Testing

**Test with realistic load:**
```bash
# Using k6 or locust
k6 run --vus 50 --duration 30s load-test.js
```

**Verify:**
- [ ] System handles 2x expected peak load
- [ ] Response times stable under load
- [ ] No memory leaks
- [ ] Error rate <0.1%

## Frontend Performance

### 1. Page Load Times

**Target:** <2s (LCP), <100ms (FID), <0.1 (CLS)

**Measure with Lighthouse:**
```bash
lighthouse https://app.example.com --view
```

**Check Core Web Vitals:**
- [ ] LCP (Largest Contentful Paint) <2.5s
- [ ] FID (First Input Delay) <100ms
- [ ] CLS (Cumulative Layout Shift) <0.1

### 2. Bundle Size

**Check JavaScript bundle:**
```bash
npm run build -- --analyze
```

**Verify:**
- [ ] Main bundle <200KB gzipped
- [ ] Code splitting used for routes
- [ ] Lazy loading for heavy components
- [ ] Tree shaking removes unused code

### 3. Asset Optimization

- [ ] Images optimized (WebP format)
- [ ] Images lazy loaded
- [ ] CSS minified
- [ ] Fonts self-hosted and preloaded
- [ ] Static assets cached (CDN)

## Database Performance

### 1. Query Analysis

**Run EXPLAIN on slow queries:**
```sql
EXPLAIN ANALYZE SELECT * FROM users WHERE organization_id = 123;
```

- [ ] Queries use indexes (no Seq Scan on large tables)
- [ ] Join strategy optimal
- [ ] No unnecessary sorting

### 2. Connection Pooling

- [ ] Pool size appropriate (10-20 connections)
- [ ] No connection exhaustion
- [ ] Connections reused efficiently

### 3. Caching Strategy

- [ ] Expensive queries cached (Redis)
- [ ] Cache TTL appropriate
- [ ] Cache invalidation on updates

## Output

- [ ] API response times within targets
- [ ] Database queries optimized
- [ ] Frontend loads in <2s
- [ ] System handles expected load
- [ ] No performance regressions
