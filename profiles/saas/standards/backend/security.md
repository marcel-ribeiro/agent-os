# Backend Security Standards

Comprehensive security guidelines for building secure SaaS applications.

## Authentication

### Password Security

**Requirements:**
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one number
- At least one special character (optional but recommended)

**Storage:**
- NEVER store plain text passwords
- Use bcrypt, Argon2, or PBKDF2
- Use high work factor (bcrypt: 12+, Argon2: appropriate parameters)

**Python/Django Example:**
```python
from django.contrib.auth.hashers import make_password, check_password

# Django handles this automatically for User models
password_hash = make_password('user_password')

# Verify password
is_valid = check_password('user_password', password_hash)
```

**Java/Spring Boot Example:**
```java
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

@Service
public class AuthService {
    private final BCryptPasswordEncoder encoder =
        new BCryptPasswordEncoder(12);

    public String hashPassword(String plainPassword) {
        return encoder.encode(plainPassword);
    }

    public boolean verifyPassword(String plainPassword,
                                   String hashedPassword) {
        return encoder.matches(plainPassword, hashedPassword);
    }
}
```

### JWT Tokens

**Configuration:**
- Use strong secret key (min 256 bits)
- Set appropriate expiration times:
  - Access tokens: 15 minutes to 1 hour
  - Refresh tokens: 7-30 days
- Include minimal claims (user ID, roles)
- Sign with HS256 or RS256

**Python/Django Example:**
```python
from rest_framework_simplejwt.tokens import RefreshToken
from datetime import timedelta

# settings.py
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=15),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
    'ALGORITHM': 'HS256',
    'SIGNING_KEY': os.environ['JWT_SECRET_KEY'],
}

# Generate tokens
def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }
```

**Java/Spring Boot Example:**
```java
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import java.util.Date;

@Service
public class JwtService {
    @Value("${jwt.secret}")
    private String secret;

    @Value("${jwt.expiration}")
    private Long expiration;

    public String generateToken(User user) {
        return Jwts.builder()
            .setSubject(user.getId().toString())
            .claim("email", user.getEmail())
            .claim("role", user.getRole())
            .setIssuedAt(new Date())
            .setExpiration(new Date(
                System.currentTimeMillis() + expiration))
            .signWith(SignatureAlgorithm.HS256, secret)
            .compact();
    }

    public Claims validateToken(String token) {
        return Jwts.parser()
            .setSigningKey(secret)
            .parseClaimsJws(token)
            .getBody();
    }
}
```

### Session Management

- Use secure, httpOnly cookies for session tokens
- Implement session timeout (30 minutes of inactivity)
- Regenerate session ID after login
- Invalidate sessions on logout
- Store sessions in Redis for scalability

## Authorization

### Role-Based Access Control (RBAC)

**Python/Django Example:**
```python
from rest_framework.permissions import BasePermission

class IsAdminOrOwner(BasePermission):
    """
    Permission check: user is admin or owns the object
    """
    def has_object_permission(self, request, view, obj):
        if request.user.role == 'admin':
            return True
        return obj.owner == request.user

# In view
class DocumentViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated, IsAdminOrOwner]

    def get_queryset(self):
        user = self.request.user
        if user.role == 'admin':
            return Document.objects.all()
        return Document.objects.filter(owner=user)
```

**Java/Spring Boot Example:**
```java
@RestController
@RequestMapping("/api/v1/documents")
public class DocumentController {

    @PreAuthorize("hasRole('ADMIN') or @documentSecurity.isOwner(#id, principal)")
    @GetMapping("/{id}")
    public ResponseEntity<DocumentDTO> getDocument(@PathVariable UUID id) {
        return ResponseEntity.ok(documentService.findById(id));
    }
}

@Component
public class DocumentSecurity {
    @Autowired
    private DocumentRepository documentRepository;

    public boolean isOwner(UUID documentId, UserDetails principal) {
        Optional<Document> doc = documentRepository.findById(documentId);
        return doc.isPresent() &&
               doc.get().getOwner().getEmail().equals(principal.getUsername());
    }
}
```

### Multi-Tenancy Security

Always filter queries by organization/tenant ID:

```python
# Python/Django
class TenantAwareViewSet(viewsets.ModelViewSet):
    def get_queryset(self):
        return super().get_queryset().filter(
            organization=self.request.user.organization
        )

    def perform_create(self, serializer):
        serializer.save(
            organization=self.request.user.organization
        )
```

```java
// Java/Spring Boot with Aspect
@Aspect
@Component
public class TenantFilterAspect {
    @Before("@annotation(TenantFiltered)")
    public void filterByTenant(JoinPoint joinPoint) {
        Authentication auth = SecurityContextHolder
            .getContext().getAuthentication();
        User user = (User) auth.getPrincipal();
        // Set tenant filter in Hibernate or repository
    }
}
```

## Input Validation

### Validate All Input

**Never trust user input.** Validate on:
- Type (string, int, email, etc.)
- Length (min/max)
- Format (regex patterns)
- Range (for numbers)
- Allowed values (enums, whitelists)

**Python Example:**
```python
from pydantic import BaseModel, EmailStr, constr, validator

class CreateUserRequest(BaseModel):
    email: EmailStr
    name: constr(min_length=1, max_length=100)
    password: constr(min_length=8, max_length=128)
    role: Literal['admin', 'member', 'viewer'] = 'member'

    @validator('password')
    def validate_password_strength(cls, v):
        if not any(c.isupper() for c in v):
            raise ValueError('Password must have uppercase')
        if not any(c.islower() for c in v):
            raise ValueError('Password must have lowercase')
        if not any(c.isdigit() for c in v):
            raise ValueError('Password must have digit')
        return v
```

**Java Example:**
```java
public class CreateUserRequest {
    @NotNull
    @Email(message = "Invalid email format")
    private String email;

    @NotBlank
    @Size(min = 1, max = 100)
    private String name;

    @NotBlank
    @Size(min = 8, max = 128)
    @Pattern(regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).+$",
             message = "Password must contain uppercase, lowercase, and digit")
    private String password;

    @Pattern(regexp = "^(admin|member|viewer)$")
    private String role = "member";
}
```

### SQL Injection Prevention

**Always use parameterized queries or ORM methods:**

```python
# ✅ GOOD - Using ORM
users = User.objects.filter(email=user_email)

# ✅ GOOD - Parameterized raw query
users = User.objects.raw(
    'SELECT * FROM users WHERE email = %s',
    [user_email]
)

# ❌ BAD - SQL injection vulnerability
users = User.objects.raw(
    f'SELECT * FROM users WHERE email = "{user_email}"'
)
```

```java
// ✅ GOOD - Using JPA
@Query("SELECT u FROM User u WHERE u.email = :email")
Optional<User> findByEmail(@Param("email") String email);

// ✅ GOOD - Named parameters
String jpql = "SELECT u FROM User u WHERE u.email = :email";
TypedQuery<User> query = em.createQuery(jpql, User.class);
query.setParameter("email", email);

// ❌ BAD - SQL injection vulnerability
String sql = "SELECT * FROM users WHERE email = '" + email + "'";
```

## XSS Prevention

### Output Encoding

Always escape user-generated content before rendering:

**Python/Django:**
Django templates auto-escape by default. For manual escaping:
```python
from django.utils.html import escape

safe_text = escape(user_input)
```

**React:**
React auto-escapes by default. For raw HTML:
```jsx
// ✅ GOOD - Auto-escaped
<div>{userInput}</div>

// ⚠️ USE WITH CAUTION - Only for trusted content
<div dangerouslySetInnerHTML={{__html: sanitizedHtml}} />
```

### Content Security Policy (CSP)

**Python/Django:**
```python
# settings.py
CSP_DEFAULT_SRC = ("'self'",)
CSP_SCRIPT_SRC = ("'self'", "'unsafe-inline'", "cdn.example.com")
CSP_STYLE_SRC = ("'self'", "'unsafe-inline'")
CSP_IMG_SRC = ("'self'", "data:", "https:")
CSP_FONT_SRC = ("'self'", "fonts.googleapis.com")
```

**Java/Spring Boot:**
```java
@Configuration
public class SecurityConfig {
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) {
        http.headers()
            .contentSecurityPolicy(
                "default-src 'self'; " +
                "script-src 'self' cdn.example.com; " +
                "style-src 'self' 'unsafe-inline'"
            );
        return http.build();
    }
}
```

## CSRF Protection

### Enable CSRF Tokens

**Python/Django:**
```python
# Django has CSRF protection by default
# In templates:
<form method="post">
    {% csrf_token %}
    ...
</form>

# For AJAX:
const csrfToken = document.querySelector('[name=csrfmiddlewaretoken]').value;
fetch('/api/endpoint', {
    method: 'POST',
    headers: {
        'X-CSRFToken': csrfToken,
        'Content-Type': 'application/json'
    },
    body: JSON.stringify(data)
});
```

**Java/Spring Boot:**
```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) {
        http
            .csrf()
            .csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse());
        return http.build();
    }
}
```

## Rate Limiting

### API Rate Limiting

**Python/Django with django-ratelimit:**
```python
from django_ratelimit.decorators import ratelimit

@ratelimit(key='ip', rate='100/h', method='POST')
def login_view(request):
    # Login logic
    pass

# For DRF
from rest_framework.throttling import UserRateThrottle

class CustomRateThrottle(UserRateThrottle):
    rate = '1000/hour'
```

**Java/Spring Boot with Bucket4j:**
```java
@Service
public class RateLimitService {
    private final Map<String, Bucket> cache = new ConcurrentHashMap<>();

    public Bucket resolveBucket(String key) {
        return cache.computeIfAbsent(key, k ->
            Bucket4j.builder()
                .addLimit(Bandwidth.classic(100,
                    Refill.intervally(100, Duration.ofHours(1))))
                .build()
        );
    }

    public boolean allowRequest(String key) {
        return resolveBucket(key).tryConsume(1);
    }
}
```

## Secrets Management

### Never Hardcode Secrets

❌ **Bad:**
```python
DATABASE_URL = "postgresql://user:password@localhost/db"
API_KEY = "sk_live_abc123xyz"
```

✅ **Good:**
```python
import os
from decouple import config

DATABASE_URL = config('DATABASE_URL')
API_KEY = config('API_KEY')
```

### Environment Variables

**Store in .env file (never commit to Git):**
```env
DATABASE_URL=postgresql://user:password@localhost/db
JWT_SECRET_KEY=your-secret-key-min-256-bits
STRIPE_SECRET_KEY=sk_test_...
```

**Load environment variables:**
```python
# Python
from dotenv import load_dotenv
load_dotenv()
```

```java
// Java/Spring Boot - application.yml
spring:
  datasource:
    url: ${DATABASE_URL}
jwt:
  secret: ${JWT_SECRET_KEY}
```

### Use Secret Management Services

For production:
- AWS Secrets Manager
- HashiCorp Vault
- Azure Key Vault
- Google Cloud Secret Manager

## Security Headers

### Essential Security Headers

```python
# Python/Django
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = 'DENY'
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
CSRF_COOKIE_HTTPONLY = True
```

```java
// Java/Spring Boot
@Configuration
public class SecurityConfig {
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) {
        http.headers()
            .xssProtection()
            .and()
            .contentTypeOptions()
            .and()
            .frameOptions().deny()
            .and()
            .httpStrictTransportSecurity()
                .maxAgeInSeconds(31536000)
                .includeSubDomains(true);
        return http.build();
    }
}
```

## File Upload Security

### Validate Uploads

```python
# Python/Django
from django.core.exceptions import ValidationError

ALLOWED_EXTENSIONS = {'.jpg', '.jpeg', '.png', '.pdf'}
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB

def validate_file(file):
    # Check file extension
    ext = os.path.splitext(file.name)[1].lower()
    if ext not in ALLOWED_EXTENSIONS:
        raise ValidationError(
            f'Invalid file type. Allowed: {ALLOWED_EXTENSIONS}'
        )

    # Check file size
    if file.size > MAX_FILE_SIZE:
        raise ValidationError(
            'File too large. Max size: 10MB'
        )

    # Verify file content matches extension
    import magic
    mime = magic.from_buffer(file.read(1024), mime=True)
    file.seek(0)
    if mime not in ['image/jpeg', 'image/png', 'application/pdf']:
        raise ValidationError('Invalid file content')
```

### Store Files Securely

- Store uploads outside web root
- Generate random filenames (don't trust user-provided names)
- Scan files for malware
- Use cloud storage (S3) with private access

```python
import uuid
import boto3

def upload_to_s3(file, bucket_name):
    s3 = boto3.client('s3')
    filename = f"{uuid.uuid4()}{os.path.splitext(file.name)[1]}"
    s3.upload_fileobj(
        file,
        bucket_name,
        filename,
        ExtraArgs={
            'ContentType': file.content_type,
            'ServerSideEncryption': 'AES256'
        }
    )
    return filename
```

## Logging & Monitoring

### Security Event Logging

Log these events:
- Failed login attempts
- Authorization failures
- Suspicious activity (rate limit violations)
- Data access by admins
- Password changes
- Account deletions

```python
import logging

security_logger = logging.getLogger('security')

def log_failed_login(email, ip_address):
    security_logger.warning(
        'Failed login attempt',
        extra={
            'email': email,
            'ip_address': ip_address,
            'event_type': 'failed_login'
        }
    )
```

### Never Log Sensitive Data

❌ **Never log:**
- Passwords (plain or hashed)
- Credit card numbers
- API keys or tokens
- Personal identifiable information (PII)

✅ **Safe to log:**
- User IDs
- Timestamps
- Event types
- IP addresses (consider GDPR)

## Security Checklist

- [ ] All passwords hashed with bcrypt/Argon2
- [ ] JWT tokens expire appropriately
- [ ] HTTPS enforced everywhere
- [ ] CSRF protection enabled
- [ ] XSS protection via output encoding
- [ ] SQL injection prevented (parameterized queries)
- [ ] Input validation on all endpoints
- [ ] Rate limiting implemented
- [ ] Security headers configured
- [ ] Secrets in environment variables
- [ ] File uploads validated
- [ ] Role-based authorization enforced
- [ ] Multi-tenancy data isolation
- [ ] Security events logged
- [ ] Dependencies regularly updated
- [ ] Security scanning in CI/CD
- [ ] Regular penetration testing
- [ ] Incident response plan documented
