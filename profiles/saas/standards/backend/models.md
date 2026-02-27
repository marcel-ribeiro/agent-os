# Backend Models Standards

Comprehensive guidelines for designing and implementing data models in SaaS applications.

## Model Design Principles

### 1. Single Responsibility
Each model should represent a single, well-defined business entity.

### 2. Clear Relationships
Define relationships explicitly and use appropriate cardinality (one-to-one, one-to-many, many-to-many).

### 3. Immutable IDs
Use UUIDs or auto-incrementing integers for primary keys. Never change primary keys.

### 4. Soft Deletes
Implement soft deletes for important data to prevent accidental data loss.

### 5. Audit Fields
Include `created_at`, `updated_at`, and optionally `deleted_at` timestamps on all models.

## Model Structure

### Python/Django Example

```python
from django.db import models
from django.contrib.auth.models import AbstractUser
import uuid

class TimestampedModel(models.Model):
    """Abstract base model with timestamp fields"""
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True
        ordering = ['-created_at']


class SoftDeleteModel(TimestampedModel):
    """Abstract base model with soft delete"""
    deleted_at = models.DateTimeField(null=True, blank=True)
    is_deleted = models.BooleanField(default=False)

    class Meta:
        abstract = True

    def delete(self, *args, **kwargs):
        """Soft delete instead of hard delete"""
        self.is_deleted = True
        self.deleted_at = timezone.now()
        self.save()

    def hard_delete(self):
        """Permanently delete the record"""
        super().delete()


class User(AbstractUser, TimestampedModel):
    """User model with extended fields"""
    email = models.EmailField(unique=True)
    name = models.CharField(max_length=100)
    avatar_url = models.URLField(blank=True, null=True)
    role = models.CharField(
        max_length=20,
        choices=[
            ('admin', 'Administrator'),
            ('member', 'Member'),
            ('viewer', 'Viewer')
        ],
        default='member'
    )
    organization = models.ForeignKey(
        'Organization',
        on_delete=models.CASCADE,
        related_name='users'
    )

    class Meta:
        db_table = 'users'
        indexes = [
            models.Index(fields=['email']),
            models.Index(fields=['organization', 'role'])
        ]

    def __str__(self):
        return f"{self.name} ({self.email})"


class Organization(SoftDeleteModel):
    """Organization/tenant model for multi-tenancy"""
    name = models.CharField(max_length=100)
    slug = models.SlugField(unique=True)
    plan = models.CharField(
        max_length=20,
        choices=[
            ('free', 'Free'),
            ('pro', 'Professional'),
            ('enterprise', 'Enterprise')
        ],
        default='free'
    )
    settings = models.JSONField(default=dict)

    class Meta:
        db_table = 'organizations'

    def __str__(self):
        return self.name
```

### Java/Spring Boot Example

```java
import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.time.LocalDateTime;
import java.util.UUID;

@MappedSuperclass
public abstract class BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID id;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;

    // Getters and setters
    public UUID getId() { return id; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
}

@MappedSuperclass
public abstract class SoftDeletableEntity extends BaseEntity {
    @Column
    private LocalDateTime deletedAt;

    @Column(nullable = false)
    private Boolean isDeleted = false;

    public void softDelete() {
        this.isDeleted = true;
        this.deletedAt = LocalDateTime.now();
    }

    // Getters and setters
    public Boolean getIsDeleted() { return isDeleted; }
    public LocalDateTime getDeletedAt() { return deletedAt; }
}

@Entity
@Table(name = "users", indexes = {
    @Index(name = "idx_user_email", columnList = "email"),
    @Index(name = "idx_user_org_role",
           columnList = "organization_id,role")
})
public class User extends BaseEntity {
    @Column(nullable = false, unique = true, length = 255)
    private String email;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(name = "avatar_url", length = 500)
    private String avatarUrl;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private UserRole role = UserRole.MEMBER;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "organization_id",
                nullable = false)
    private Organization organization;

    // Getters and setters
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public UserRole getRole() { return role; }
    public void setRole(UserRole role) { this.role = role; }

    public Organization getOrganization() {
        return organization;
    }
    public void setOrganization(Organization organization) {
        this.organization = organization;
    }
}

public enum UserRole {
    ADMIN("Administrator"),
    MEMBER("Member"),
    VIEWER("Viewer");

    private final String displayName;

    UserRole(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}

@Entity
@Table(name = "organizations")
public class Organization extends SoftDeletableEntity {
    @Column(nullable = false, length = 100)
    private String name;

    @Column(nullable = false, unique = true, length = 100)
    private String slug;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private SubscriptionPlan plan = SubscriptionPlan.FREE;

    @Column(columnDefinition = "jsonb")
    @Convert(converter = JsonNodeConverter.class)
    private JsonNode settings;

    @OneToMany(mappedBy = "organization",
               cascade = CascadeType.ALL,
               fetch = FetchType.LAZY)
    private List<User> users = new ArrayList<>();

    // Getters and setters
}
```

## Field Naming Conventions

### Use Descriptive Names
- `user_id` instead of `uid`
- `created_at` instead of `ts`
- `is_active` instead of `active` (for booleans)

### Boolean Fields
- Prefix with `is_`, `has_`, `can_`, `should_`
- Examples: `is_active`, `has_subscription`, `can_edit`

### Foreign Keys
- Suffix with `_id`
- Examples: `user_id`, `organization_id`, `parent_id`

### Date/Time Fields
- Suffix with `_at` for timestamps
- Suffix with `_date` for dates
- Examples: `created_at`, `expires_at`, `birth_date`

## Relationships

### One-to-Many
```python
# Python/Django
class Organization(models.Model):
    name = models.CharField(max_length=100)

class User(models.Model):
    organization = models.ForeignKey(
        Organization,
        on_delete=models.CASCADE,
        related_name='users'
    )
```

```java
// Java/Spring Boot
@Entity
public class Organization {
    @OneToMany(mappedBy = "organization",
               cascade = CascadeType.ALL)
    private List<User> users;
}

@Entity
public class User {
    @ManyToOne
    @JoinColumn(name = "organization_id")
    private Organization organization;
}
```

### Many-to-Many
```python
# Python/Django with explicit through table
class User(models.Model):
    name = models.CharField(max_length=100)

class Team(models.Model):
    name = models.CharField(max_length=100)
    members = models.ManyToManyField(
        User,
        through='TeamMembership',
        related_name='teams'
    )

class TeamMembership(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    team = models.ForeignKey(Team, on_delete=models.CASCADE)
    role = models.CharField(max_length=20)
    joined_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('user', 'team')
```

```java
// Java/Spring Boot with join table
@Entity
public class User {
    @ManyToMany
    @JoinTable(
        name = "team_memberships",
        joinColumns = @JoinColumn(name = "user_id"),
        inverseJoinColumns = @JoinColumn(name = "team_id")
    )
    private Set<Team> teams;
}

@Entity
public class Team {
    @ManyToMany(mappedBy = "teams")
    private Set<User> members;
}
```

## Validation

### Model-Level Validation

**Python/Django:**
```python
from django.core.exceptions import ValidationError
from django.core.validators import MinValueValidator, MaxValueValidator

class Product(models.Model):
    name = models.CharField(max_length=200)
    price = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        validators=[
            MinValueValidator(0.01),
            MaxValueValidator(999999.99)
        ]
    )
    stock = models.IntegerField(
        validators=[MinValueValidator(0)]
    )

    def clean(self):
        """Custom validation logic"""
        if self.price > 10000 and not self.requires_approval:
            raise ValidationError(
                'Products over $10,000 require approval'
            )

    def save(self, *args, **kwargs):
        """Run validation before save"""
        self.full_clean()
        super().save(*args, **kwargs)
```

**Java/Spring Boot:**
```java
import jakarta.validation.constraints.*;

@Entity
public class Product extends BaseEntity {
    @NotBlank(message = "Name is required")
    @Size(max = 200, message = "Name must be less than 200 characters")
    private String name;

    @NotNull(message = "Price is required")
    @DecimalMin(value = "0.01", message = "Price must be positive")
    @DecimalMax(value = "999999.99",
                message = "Price too high")
    @Digits(integer = 8, fraction = 2)
    private BigDecimal price;

    @Min(value = 0, message = "Stock cannot be negative")
    private Integer stock;

    @AssertTrue(message = "High-value products require approval")
    private boolean isValidPrice() {
        return price.compareTo(new BigDecimal("10000")) <= 0
            || requiresApproval;
    }
}
```

## Indexes

### When to Add Indexes
- Foreign key columns
- Columns used in WHERE clauses frequently
- Columns used in JOIN conditions
- Columns used for sorting (ORDER BY)
- Unique constraints

### Index Types
- **Single column**: `CREATE INDEX idx_user_email ON users(email)`
- **Composite**: `CREATE INDEX idx_user_org_role ON users(organization_id, role)`
- **Partial**: `CREATE INDEX idx_active_users ON users(email) WHERE is_active = true`

### Examples

**Python/Django:**
```python
class User(models.Model):
    email = models.EmailField()
    organization_id = models.IntegerField()
    role = models.CharField(max_length=20)
    is_active = models.BooleanField(default=True)

    class Meta:
        indexes = [
            models.Index(fields=['email']),
            models.Index(
                fields=['organization_id', 'role'],
                name='idx_org_role'
            ),
            models.Index(
                fields=['email'],
                condition=models.Q(is_active=True),
                name='idx_active_user_email'
            )
        ]
```

**Java/Spring Boot:**
```java
@Entity
@Table(name = "users", indexes = {
    @Index(name = "idx_user_email",
           columnList = "email"),
    @Index(name = "idx_org_role",
           columnList = "organization_id,role")
})
public class User extends BaseEntity {
    // fields...
}
```

## JSON Fields

Use JSON fields for flexible, schema-less data (settings, metadata, etc.).

**Python/Django:**
```python
class Organization(models.Model):
    settings = models.JSONField(default=dict)
    metadata = models.JSONField(default=dict)

    def get_setting(self, key, default=None):
        return self.settings.get(key, default)

    def set_setting(self, key, value):
        self.settings[key] = value
        self.save(update_fields=['settings'])
```

**Java/Spring Boot:**
```java
@Entity
public class Organization extends BaseEntity {
    @Type(type = "jsonb")
    @Column(columnDefinition = "jsonb")
    private Map<String, Object> settings = new HashMap<>();

    public Object getSetting(String key) {
        return settings.get(key);
    }

    public void setSetting(String key, Object value) {
        this.settings.put(key, value);
    }
}
```

## Multi-Tenancy Patterns

### Shared Database, Shared Schema
Use a tenant identifier column (e.g., `organization_id`) on all models.

```python
# Python/Django middleware for filtering by tenant
class TenantMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if request.user.is_authenticated:
            request.tenant_id = request.user.organization_id
        return self.get_response(request)

# Model with tenant filtering
class TenantAwareModel(models.Model):
    organization = models.ForeignKey(Organization,
                                     on_delete=models.CASCADE)

    class Meta:
        abstract = True

    @classmethod
    def filter_by_tenant(cls, tenant_id):
        return cls.objects.filter(organization_id=tenant_id)
```

## Optimistic Locking

Prevent concurrent update conflicts using version fields.

**Python/Django:**
```python
class Document(models.Model):
    title = models.CharField(max_length=200)
    content = models.TextField()
    version = models.IntegerField(default=1)

    def save(self, *args, **kwargs):
        if self.pk:  # Update
            updated = Document.objects.filter(
                pk=self.pk,
                version=self.version
            ).update(
                title=self.title,
                content=self.content,
                version=models.F('version') + 1
            )
            if not updated:
                raise ConcurrentUpdateError(
                    'Document was modified by another user'
                )
        else:  # Create
            super().save(*args, **kwargs)
```

**Java/Spring Boot:**
```java
@Entity
public class Document extends BaseEntity {
    private String title;
    private String content;

    @Version
    private Long version;

    // JPA automatically handles optimistic locking
    // Throws OptimisticLockException on conflict
}
```

## Soft Deletes

Preserve deleted records for audit trails and recovery.

```python
# Python/Django with custom manager
class SoftDeleteManager(models.Manager):
    def get_queryset(self):
        return super().get_queryset().filter(is_deleted=False)

class SoftDeleteModel(models.Model):
    is_deleted = models.BooleanField(default=False)
    deleted_at = models.DateTimeField(null=True, blank=True)

    objects = SoftDeleteManager()
    all_objects = models.Manager()  # Access deleted too

    class Meta:
        abstract = True

    def delete(self, *args, **kwargs):
        self.is_deleted = True
        self.deleted_at = timezone.now()
        self.save()

    def restore(self):
        self.is_deleted = False
        self.deleted_at = None
        self.save()
```

## Best Practices Checklist

- [ ] All models extend base model with timestamps
- [ ] Primary keys are UUIDs or auto-incrementing integers
- [ ] Foreign keys have `on_delete` behavior specified
- [ ] All models have `__str__` method (Python) or `toString()` (Java)
- [ ] Indexes added for frequently queried fields
- [ ] Validation rules defined at model level
- [ ] Soft deletes implemented for important data
- [ ] Multi-tenancy support for SaaS (organization_id)
- [ ] JSON fields used sparingly (structured data preferred)
- [ ] Model docstrings explain purpose and relationships
- [ ] Database constraints match model validations
- [ ] No business logic in models (keep in services)
- [ ] Related name specified for reverse relationships
- [ ] Appropriate fetch types (lazy vs. eager loading)
- [ ] Database table names explicitly defined
