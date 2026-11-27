# Error Handling Standards

## HTTP Status Codes

Use correct status codes:

**2xx Success**
- `200 OK` - Successful GET, PUT, PATCH
- `201 Created` - Successful POST
- `204 No Content` - Successful DELETE

**4xx Client Errors**
- `400 Bad Request` - Validation errors
- `401 Unauthorized` - Not authenticated
- `403 Forbidden` - Not authorized
- `404 Not Found` - Resource doesn't exist
- `409 Conflict` - Duplicate resource
- `422 Unprocessable Entity` - Semantic errors
- `429 Too Many Requests` - Rate limited

**5xx Server Errors**
- `500 Internal Server Error` - Unexpected error
- `503 Service Unavailable` - Temporarily down

## Error Response Format

**Consistent JSON structure:**

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {
        "field": "email",
        "message": "Email is required"
      },
      {
        "field": "password",
        "message": "Password must be at least 8 characters"
      }
    ],
    "request_id": "req_abc123"
  }
}
```

## Error Codes

Use semantic error codes:

```
VALIDATION_ERROR
AUTHENTICATION_REQUIRED
PERMISSION_DENIED
RESOURCE_NOT_FOUND
DUPLICATE_RESOURCE
RATE_LIMIT_EXCEEDED
PAYMENT_FAILED
EXTERNAL_SERVICE_ERROR
INTERNAL_ERROR
```

## Error Messages

**User-facing messages:**
- Clear and actionable
- Don't expose internal details
- Don't blame the user
- Suggest how to fix

**Examples:**

❌ Bad:
```json
{"error": "NullPointerException in UserService.java:42"}
{"error": "Query failed"}
{"error": "Something went wrong"}
```

✅ Good:
```json
{"error": "Email address is required"}
{"error": "Payment method declined. Please try another card."}
{"error": "Unable to process request. Please try again in a few minutes."}
```

## Exception Handling

### Python (Django/FastAPI)

```python
from rest_framework.exceptions import APIException

class PaymentFailedException(APIException):
    status_code = 402
    default_detail = 'Payment failed'
    default_code = 'PAYMENT_FAILED'

# In view
try:
    process_payment(amount, card)
except CardDeclined:
    raise PaymentFailedException(
        detail="Card was declined. Please try another payment method."
    )
```

### JavaScript (Express/NestJS)

```javascript
class PaymentFailedException extends HttpException {
  constructor() {
    super({
      error: {
        code: 'PAYMENT_FAILED',
        message: 'Card was declined. Please try another payment method.'
      }
    }, HttpStatus.PAYMENT_REQUIRED);
  }
}

throw new PaymentFailedException();
```

### Java (Spring Boot)

```java
@ResponseStatus(HttpStatus.PAYMENT_REQUIRED)
public class PaymentFailedException extends RuntimeException {
    public PaymentFailedException(String message) {
        super(message);
    }
}

throw new PaymentFailedException(
    "Card was declined. Please try another payment method."
);
```

## Global Exception Handler

Catch all unhandled exceptions:

### Python (Django)

```python
from rest_framework.views import exception_handler

def custom_exception_handler(exc, context):
    response = exception_handler(exc, context)

    if response is not None:
        response.data = {
            'error': {
                'code': getattr(exc, 'code', 'ERROR'),
                'message': str(exc),
                'request_id': context['request'].id
            }
        }

    return response
```

### JavaScript (NestJS)

```javascript
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  catch(exception: any, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse();
    const request = ctx.getRequest();

    response.status(500).json({
      error: {
        code: 'INTERNAL_ERROR',
        message: 'An unexpected error occurred',
        request_id: request.id
      }
    });
  }
}
```

## Logging Errors

Always log errors with context:

```python
logger.error("payment_failed",
             user_id=user.id,
             org_id=user.organization_id,
             amount=amount,
             error=str(e),
             exc_info=True)
```

## Retry Logic

For transient errors:

```python
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=2, max=10)
)
def call_external_api():
    response = requests.get("https://api.example.com/data")
    response.raise_for_status()
    return response.json()
```

## Error Tracking

- Send all 5xx errors to Sentry
- Track 4xx error rates (high rate = bad API design)
- Alert on error rate spikes
- Include request_id in errors for tracing

## User Experience

### Frontend Error Display

```tsx
if (error.code === 'VALIDATION_ERROR') {
  // Show field-specific errors
  setFieldErrors(error.details);
} else if (error.code === 'PAYMENT_FAILED') {
  // Show payment error with retry option
  showPaymentError(error.message);
} else {
  // Show generic error with support contact
  showError('An error occurred. Please contact support.');
}
```

### Provide Context

Include:
- What went wrong
- Why it happened (if safe to share)
- What the user can do
- How to get help (support link, request ID)
