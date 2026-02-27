# Logging Standards

## Log Format

**Use structured JSON logging:**

```json
{
  "timestamp": "2024-01-19T10:30:00.123Z",
  "level": "ERROR",
  "user_id": "usr_abc123",
  "org_id": "org_xyz789",
  "request_id": "req_def456",
  "message": "Payment processing failed",
  "context": {
    "amount": 99.99,
    "currency": "USD",
    "payment_method": "card",
    "error_code": "card_declined"
  },
  "stack_trace": "..."
}
```

## Required Fields

**Every log entry must include:**
- `timestamp` - ISO 8601 format with timezone
- `level` - ERROR, WARN, INFO, DEBUG
- `message` - Human-readable description
- `user_id` - Who performed the action (if authenticated)
- `org_id` - Which tenant/organization (for multi-tenancy)
- `request_id` - Trace requests across services

## Log Levels

**ERROR** - Application errors requiring immediate attention
- Unhandled exceptions
- Failed critical operations (payments, data persistence)
- External service failures

**WARN** - Potentially harmful situations
- Deprecated API usage
- Rate limit approaching
- Degraded performance
- Retry attempts

**INFO** - Important business events
- User registration
- Login/logout
- Payment successful
- Data exports
- Admin actions

**DEBUG** - Detailed diagnostic information
- Request/response payloads
- Query execution details
- Cache hits/misses
- Use only in development/staging

## What to Log

### Always Log
- Authentication events (login, logout, password changes)
- Authorization failures (403s)
- Financial transactions
- Data modifications by admins
- API errors (4xx, 5xx)
- External service calls (success/failure)
- Background job execution
- Security events (rate limit violations, suspicious activity)

### Never Log
- Passwords (plain or hashed)
- Credit card numbers
- API keys, tokens, secrets
- Social security numbers
- Full request bodies with sensitive data

## Implementation

### Python (Django/FastAPI)

```python
import structlog

logger = structlog.get_logger()

# Bind context
logger = logger.bind(
    user_id=request.user.id,
    org_id=request.user.organization_id,
    request_id=request.id
)

# Log events
logger.info("payment_processed",
            amount=99.99,
            payment_method="card")

logger.error("payment_failed",
             amount=99.99,
             error="card_declined",
             exc_info=True)
```

### JavaScript (Node.js)

```javascript
import pino from 'pino';

const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  formatters: {
    level: (label) => ({ level: label })
  }
});

logger.info({
  user_id: req.user.id,
  org_id: req.user.orgId,
  request_id: req.id,
  msg: 'Payment processed',
  amount: 99.99,
  payment_method: 'card'
});
```

### Java (Spring Boot)

```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import net.logstash.logback.argument.StructuredArguments;

Logger logger = LoggerFactory.getLogger(PaymentService.class);

logger.info("Payment processed",
    StructuredArguments.kv("user_id", userId),
    StructuredArguments.kv("org_id", orgId),
    StructuredArguments.kv("amount", 99.99),
    StructuredArguments.kv("payment_method", "card"));
```

## Log Aggregation

- Send logs to centralized system (CloudWatch, Datadog, ELK)
- Retain logs for 90 days minimum
- Archive critical logs (audit trail) for 7 years
- Index by user_id, org_id, request_id for searching

## Performance

- Log asynchronously to avoid blocking
- Sample DEBUG logs in production (1%)
- Avoid logging in hot paths
- Buffer logs before sending to aggregation service
