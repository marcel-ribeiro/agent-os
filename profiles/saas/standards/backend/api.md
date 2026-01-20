# Backend API Standards

Comprehensive guidelines for building RESTful APIs in SaaS applications.

## API Design Principles

### REST Best Practices

- **Use HTTP methods correctly**:
  - GET: Retrieve resources (idempotent, no side effects)
  - POST: Create new resources
  - PUT: Replace entire resource
  - PATCH: Partial update of resource
  - DELETE: Remove resource

- **Resource naming**:
  - Use plural nouns: `/api/v1/users`, `/api/v1/products`
  - Use kebab-case for multi-word resources: `/api/v1/order-items`
  - Nest related resources: `/api/v1/users/:id/orders`
  - Keep URLs shallow (max 2-3 levels)

- **HTTP status codes**:
  - 200: Success (GET, PUT, PATCH)
  - 201: Resource created (POST)
  - 204: Success with no content (DELETE)
  - 400: Bad request (validation errors)
  - 401: Unauthenticated
  - 403: Unauthorized (no permission)
  - 404: Resource not found
  - 409: Conflict (duplicate resource)
  - 422: Unprocessable entity (semantic errors)
  - 429: Too many requests
  - 500: Internal server error

## API Structure

### Request Format

```json
// POST /api/v1/users
{
  "email": "user@example.com",
  "name": "John Doe",
  "role": "member"
}
```

### Response Format

**Success Response:**
```json
{
  "data": {
    "id": "usr_abc123",
    "email": "user@example.com",
    "name": "John Doe",
    "role": "member",
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  }
}
```

**List Response:**
```json
{
  "data": [
    { "id": 1, "name": "Item 1" },
    { "id": 2, "name": "Item 2" }
  ],
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 150,
    "total_pages": 8
  },
  "links": {
    "first": "/api/v1/items?page=1",
    "prev": null,
    "next": "/api/v1/items?page=2",
    "last": "/api/v1/items?page=8"
  }
}
```

**Error Response:**
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
    ]
  }
}
```

## Pagination

### Query Parameters
- `page`: Current page number (default: 1)
- `per_page`: Items per page (default: 20, max: 100)
- `limit`: Alternative to per_page
- `offset`: Alternative to page-based pagination

### Implementation
```python
# Python/Django example
from rest_framework.pagination import PageNumberPagination

class StandardPagination(PageNumberPagination):
    page_size = 20
    page_size_query_param = 'per_page'
    max_page_size = 100
```

```java
// Java/Spring Boot example
@GetMapping("/users")
public ResponseEntity<Page<UserDTO>> getUsers(
    @RequestParam(defaultValue = "0") int page,
    @RequestParam(defaultValue = "20") int size
) {
    Pageable pageable = PageRequest.of(page, size);
    Page<UserDTO> users = userService.findAll(pageable);
    return ResponseEntity.ok(users);
}
```

## Filtering & Sorting

### Query Parameters
- **Filtering**: Use query parameters for field-specific filters
  - `/api/v1/users?role=admin&status=active`
  - `/api/v1/products?category=electronics&price_min=100&price_max=500`

- **Sorting**: Use `sort` parameter with field name and direction
  - `/api/v1/users?sort=-created_at` (descending)
  - `/api/v1/users?sort=name` (ascending)
  - `/api/v1/users?sort=-created_at,name` (multiple fields)

- **Search**: Use `q` or `search` parameter for full-text search
  - `/api/v1/products?q=laptop`

### Implementation Examples

**Python/Django:**
```python
from django_filters import rest_framework as filters

class UserFilter(filters.FilterSet):
    role = filters.CharFilter(field_name='role')
    created_after = filters.DateTimeFilter(
        field_name='created_at',
        lookup_expr='gte'
    )

    class Meta:
        model = User
        fields = ['role', 'status']
```

**Java/Spring Boot:**
```java
@GetMapping("/users")
public ResponseEntity<Page<UserDTO>> getUsers(
    @RequestParam(required = false) String role,
    @RequestParam(required = false) String status,
    @RequestParam(defaultValue = "createdAt") String sortBy,
    @RequestParam(defaultValue = "DESC") String sortDir,
    Pageable pageable
) {
    Sort sort = Sort.by(
        sortDir.equals("DESC") ? Sort.Direction.DESC : Sort.Direction.ASC,
        sortBy
    );
    Page<UserDTO> users = userService.findAll(role, status,
        PageRequest.of(pageable.getPageNumber(),
                      pageable.getPageSize(),
                      sort));
    return ResponseEntity.ok(users);
}
```

## Authentication & Authorization

### JWT Authentication

**Request Header:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Implementation:**
```python
# Python/Django REST Framework
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework.permissions import IsAuthenticated

class UserViewSet(viewsets.ModelViewSet):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]
    queryset = User.objects.all()
    serializer_class = UserSerializer
```

```java
// Java/Spring Boot
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) {
        http
            .csrf().disable()
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/v1/auth/**").permitAll()
                .anyRequest().authenticated()
            )
            .oauth2ResourceServer()
            .jwt();
        return http.build();
    }
}
```

### Permission Checks

```python
# Python custom permission
from rest_framework.permissions import BasePermission

class IsOwnerOrAdmin(BasePermission):
    def has_object_permission(self, request, view, obj):
        return (
            request.user.is_staff or
            obj.owner == request.user
        )
```

## Validation

### Input Validation

**Python/Django:**
```python
from rest_framework import serializers

class CreateUserSerializer(serializers.Serializer):
    email = serializers.EmailField(required=True)
    password = serializers.CharField(
        min_length=8,
        write_only=True
    )
    name = serializers.CharField(
        max_length=100,
        required=True
    )

    def validate_email(self, value):
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError(
                "Email already exists"
            )
        return value
```

**Java/Spring Boot:**
```java
public class CreateUserRequest {
    @NotNull
    @Email(message = "Invalid email format")
    private String email;

    @NotBlank
    @Size(min = 8, message = "Password must be at least 8 characters")
    private String password;

    @NotBlank
    @Size(max = 100, message = "Name must be less than 100 characters")
    private String name;
}

@PostMapping("/users")
public ResponseEntity<UserDTO> createUser(
    @Valid @RequestBody CreateUserRequest request
) {
    // validation happens automatically
}
```

## Rate Limiting

### Implementation

**Python/Django:**
```python
# settings.py
REST_FRAMEWORK = {
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',
        'rest_framework.throttling.UserRateThrottle'
    ],
    'DEFAULT_THROTTLE_RATES': {
        'anon': '100/hour',
        'user': '1000/hour'
    }
}
```

**Java/Spring Boot with Bucket4j:**
```java
@GetMapping("/api/v1/data")
public ResponseEntity<DataDTO> getData() {
    Bucket bucket = Bucket4j.builder()
        .addLimit(Bandwidth.classic(100,
            Refill.intervally(100, Duration.ofHours(1))))
        .build();

    if (bucket.tryConsume(1)) {
        return ResponseEntity.ok(dataService.getData());
    }
    return ResponseEntity.status(429).build();
}
```

**Response Headers:**
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1640000000
```

## Versioning

### URL Versioning (Recommended)
```
/api/v1/users
/api/v2/users
```

### Implementation
- Keep old versions running during deprecation period
- Document breaking changes clearly
- Provide migration guides
- Set deprecation timeline (e.g., 6 months notice)

## CORS Configuration

**Python/Django:**
```python
# settings.py
CORS_ALLOWED_ORIGINS = [
    "https://app.example.com",
    "https://staging.example.com",
]

CORS_ALLOW_CREDENTIALS = True

CORS_ALLOW_METHODS = [
    'GET',
    'POST',
    'PUT',
    'PATCH',
    'DELETE',
    'OPTIONS'
]
```

**Java/Spring Boot:**
```java
@Configuration
public class CorsConfig {
    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/api/**")
                    .allowedOrigins("https://app.example.com")
                    .allowedMethods("GET", "POST", "PUT", "DELETE")
                    .allowCredentials(true);
            }
        };
    }
}
```

## API Documentation

### Use OpenAPI/Swagger

**Python/Django with drf-spectacular:**
```python
# settings.py
INSTALLED_APPS = [
    # ...
    'drf_spectacular',
]

REST_FRAMEWORK = {
    'DEFAULT_SCHEMA_CLASS':
        'drf_spectacular.openapi.AutoSchema',
}

# urls.py
from drf_spectacular.views import (
    SpectacularAPIView,
    SpectacularSwaggerView
)

urlpatterns = [
    path('api/schema/', SpectacularAPIView.as_view(),
         name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(
        url_name='schema'), name='swagger-ui'),
]
```

**Java/Spring Boot with Springdoc:**
```java
@Configuration
public class OpenApiConfig {
    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
            .info(new Info()
                .title("SaaS API")
                .version("1.0")
                .description("API documentation"));
    }
}
```

## Error Handling

### Centralized Error Handling

**Python/Django:**
```python
from rest_framework.views import exception_handler
from rest_framework.response import Response

def custom_exception_handler(exc, context):
    response = exception_handler(exc, context)

    if response is not None:
        return Response({
            'error': {
                'code': exc.default_code.upper(),
                'message': str(exc),
                'details': response.data
            }
        }, status=response.status_code)

    return response
```

**Java/Spring Boot:**
```java
@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ValidationException.class)
    public ResponseEntity<ErrorResponse> handleValidation(
        ValidationException ex
    ) {
        ErrorResponse error = new ErrorResponse(
            "VALIDATION_ERROR",
            ex.getMessage(),
            ex.getFieldErrors()
        );
        return ResponseEntity
            .status(HttpStatus.BAD_REQUEST)
            .body(error);
    }

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(
        ResourceNotFoundException ex
    ) {
        ErrorResponse error = new ErrorResponse(
            "NOT_FOUND",
            ex.getMessage(),
            null
        );
        return ResponseEntity
            .status(HttpStatus.NOT_FOUND)
            .body(error);
    }
}
```

## Performance Best Practices

1. **Use database query optimization**:
   - Select only needed fields
   - Use joins to avoid N+1 queries
   - Add database indexes on frequently queried fields

2. **Implement caching**:
   - Cache expensive computations
   - Use Redis for session and API response caching
   - Set appropriate cache TTL

3. **Compress responses**:
   - Enable gzip compression
   - Use smaller payload formats (avoid unnecessary nesting)

4. **Async processing**:
   - Move heavy operations to background jobs
   - Return 202 Accepted with job ID for long-running tasks

5. **Database connection pooling**:
   - Configure appropriate pool size
   - Monitor connection usage

## Security Checklist

- [ ] All endpoints require authentication (except public ones)
- [ ] Input validation on all fields
- [ ] Parameterized queries (no SQL injection)
- [ ] HTTPS only (enforce SSL/TLS)
- [ ] CORS properly configured
- [ ] Rate limiting implemented
- [ ] Sensitive data not in logs
- [ ] API keys in environment variables
- [ ] CSRF protection enabled
- [ ] Security headers set (Content-Security-Policy, X-Frame-Options, etc.)

## Testing APIs

### Unit Tests
```python
# Python/pytest
def test_create_user_success(api_client):
    payload = {
        'email': 'test@example.com',
        'name': 'Test User',
        'password': 'securepass123'
    }
    response = api_client.post('/api/v1/users', payload)
    assert response.status_code == 201
    assert response.json()['data']['email'] == 'test@example.com'
```

### Integration Tests
```java
// Java/Spring Boot
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
class UserControllerIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    void testCreateUser() {
        CreateUserRequest request = new CreateUserRequest(
            "test@example.com", "password123", "Test User"
        );

        ResponseEntity<UserDTO> response = restTemplate
            .postForEntity("/api/v1/users", request, UserDTO.class);

        assertEquals(HttpStatus.CREATED, response.getStatusCode());
        assertNotNull(response.getBody().getId());
    }
}
```

## Monitoring & Logging

- Log all API requests with: method, path, status code, duration
- Log errors with full stack trace
- Monitor response times and set alerts
- Track error rates per endpoint
- Use structured JSON logging
- Add correlation IDs to trace requests across services
