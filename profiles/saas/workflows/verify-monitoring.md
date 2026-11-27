# Verify Monitoring & Observability

Ensure errors, performance issues, and security events are tracked and alerted.

## Error Tracking

### 1. Sentry/Error Tracking Setup

**Verify integration:**
- [ ] Sentry (or equivalent) initialized in application
- [ ] Environment set correctly (production/staging)
- [ ] Release version tagged
- [ ] User context included in errors

**Test error capture:**
```python
# Trigger test error
raise Exception("Test error - verify Sentry capture")
```

- [ ] Error appears in Sentry dashboard
- [ ] Stack trace is complete
- [ ] User info attached
- [ ] Request context included

### 2. Structured Logging

**Verify logs include:**
- [ ] **User ID** - who performed action
- [ ] **Tenant/Org ID** - which tenant
- [ ] **Request ID** - trace across services
- [ ] **Timestamp** - when it happened
- [ ] **Log level** - ERROR, WARN, INFO
- [ ] **Context** - relevant business data

**Format:**
```json
{
  "timestamp": "2024-01-19T10:30:00Z",
  "level": "ERROR",
  "user_id": "usr_123",
  "org_id": "org_456",
  "request_id": "req_789",
  "message": "Payment failed",
  "context": {"amount": 99.99, "reason": "card_declined"}
}
```

### 3. Security Event Logging

**Verify these events are logged:**
- [ ] Failed login attempts
- [ ] Password changes
- [ ] Permission changes
- [ ] Access to sensitive data
- [ ] Admin actions
- [ ] Rate limit violations
- [ ] Suspicious activity

## Performance Monitoring

### 1. Application Performance Monitoring (APM)

**Verify metrics tracked:**
- [ ] API response times (p50, p95, p99)
- [ ] Database query times
- [ ] External API call times
- [ ] Error rates
- [ ] Request throughput

### 2. Database Performance

**Monitor:**
- [ ] Slow query log enabled
- [ ] Query performance tracked
- [ ] Connection pool metrics
- [ ] Long-running queries identified

### 3. Infrastructure Metrics

**Verify collected:**
- [ ] CPU usage
- [ ] Memory usage
- [ ] Disk I/O
- [ ] Network I/O
- [ ] Container/pod health

## Alerting

### 1. Critical Alerts Configured

**Must alert on:**
- [ ] **Error rate spike** (>1% of requests)
- [ ] **Response time degradation** (p95 >2s)
- [ ] **Database connection exhaustion**
- [ ] **Disk space critical** (<10% free)
- [ ] **Service down** (health check fails)
- [ ] **Security events** (repeated failed logins)

### 2. Alert Routing

- [ ] Alerts sent to on-call engineer
- [ ] Escalation policy defined
- [ ] Runbook linked in alerts

## Health Checks

### 1. Endpoint Exists

```bash
curl https://api.example.com/health
```

**Response should include:**
```json
{
  "status": "healthy",
  "database": "connected",
  "redis": "connected",
  "version": "1.2.3"
}
```

### 2. Health Check Monitors

- [ ] Database connectivity
- [ ] Redis/cache connectivity
- [ ] Critical external APIs
- [ ] Disk space
- [ ] Background job processing

### 3. Uptime Monitoring

- [ ] External uptime monitor configured
- [ ] Checks every 1-5 minutes
- [ ] Alerts on downtime

## Output

- [ ] Error tracking functional and tested
- [ ] Structured logging in place
- [ ] Security events logged
- [ ] APM collecting metrics
- [ ] Critical alerts configured
- [ ] Health checks working
- [ ] Uptime monitoring active
