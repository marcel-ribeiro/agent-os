## Tech Stack

This tech stack is optimized for building scalable, modern SaaS applications with a focus on developer productivity, maintainability, and performance.

> **Note on Versions:** This document intentionally omits specific version numbers. Always use the **Context7 MCP** (`mcp__context7__resolve_library_id` and `mcp__context7__query_docs`) to determine the latest stable versions and best practices for each dependency. See {{workflows/optimize-dependencies}} for the complete process.

### Framework & Runtime

**Primary (Recommended)**
- **Application Framework:** Django or FastAPI
- **Language/Runtime:** Python (latest stable)
- **Package Manager:** pip with requirements.txt or Poetry

**Alternative Options**
- **Application Framework:** Spring Boot
- **Language/Runtime:** Java (latest LTS)
- **Package Manager:** Maven or Gradle

- **Application Framework:** Express.js or NestJS
- **Language/Runtime:** Node.js (latest LTS)
- **Package Manager:** npm or pnpm

### Frontend

- **JavaScript Framework:** React with TypeScript
- **Build Tool:** Vite
- **CSS Framework:** Tailwind CSS
- **UI Components:** shadcn/ui (recommended) or Radix UI primitives
- **Icons:** Lucide React
- **Forms:** React Hook Form with Zod validation
- **State Management:** React Context + Hooks or Zustand (for complex apps)
- **Data Fetching:** TanStack Query (React Query)
- **Routing:** React Router

### Database & Storage

- **Primary Database:** PostgreSQL (latest stable)
- **ORM/Query Builder:**
  - Python: SQLAlchemy (Django ORM for Django projects)
  - Java: Spring Data JPA / Hibernate
  - Node.js: Prisma or TypeORM
- **Caching:** Redis (latest stable)
- **File Storage:** AWS S3 or compatible (MinIO for local dev)
- **Search Engine:** ElasticSearch or OpenSearch (for complex search)

### Authentication & Authorization

- **Authentication:**
  - Python: Django Auth + Django REST Framework SimpleJWT
  - Java: Spring Security with JWT
  - Node.js: Passport.js or NextAuth
- **OAuth/SSO:** Auth0, Okta, or Keycloak
- **RBAC:** Custom role-based access control per framework

### API & Integration

- **API Style:** RESTful APIs + GraphQL (optional for complex data fetching)
- **API Documentation:**
  - Python: Django REST Framework + drf-spectacular (OpenAPI)
  - Java: Springdoc OpenAPI
  - Node.js: Swagger/OpenAPI
- **API Versioning:** URL versioning (e.g., `/api/v1/`)
- **Webhooks:** Background job processing with callbacks

### Background Jobs & Async Processing

- **Task Queue:**
  - Python: Celery with Redis broker
  - Java: Spring Batch or Quartz Scheduler
  - Node.js: BullMQ or Bee-Queue
- **Cron Jobs:** Framework-specific schedulers or system cron
- **Message Queue:** RabbitMQ or AWS SQS (for event-driven architecture)

### Testing & Quality

- **Backend Testing:**
  - Python: pytest with pytest-django or pytest-asyncio
  - Java: JUnit + Mockito + Spring Test
  - Node.js: Jest or Vitest
- **Frontend Testing:**
  - Unit: Vitest + React Testing Library
  - E2E: Playwright
- **API Testing:**
  - Python: pytest with requests
  - Java: REST Assured
  - Node.js: Supertest
- **Code Coverage:** Min 80% for business logic
- **Linting/Formatting:**
  - Python: ruff (linter + formatter) or black + flake8
  - Java: Checkstyle + SpotBugs
  - JavaScript/TypeScript: ESLint + Prettier
- **Type Checking:**
  - Python: mypy
  - TypeScript: strict mode enabled

### Monitoring & Observability

- **Application Monitoring:** Sentry, Datadog, or New Relic
- **Logging:**
  - Structured JSON logging
  - Python: structlog
  - Java: Logback with JSON encoder
  - Node.js: Winston or Pino
- **Metrics:** Prometheus + Grafana
- **Uptime Monitoring:** UptimeRobot or StatusCake
- **Performance Monitoring:** New Relic or Datadog APM

### Deployment & Infrastructure

- **Containerization:** Docker with multi-stage builds
- **Orchestration:** Kubernetes (EKS, GKE) or Docker Swarm
- **Hosting:**
  - AWS (ECS Fargate, EKS, or EC2)
  - Google Cloud Platform (Cloud Run, GKE)
  - Azure (AKS, Container Apps)
- **Frontend Hosting:** Vercel, Netlify, or Cloudflare Pages
- **CDN:** AWS CloudFront, Cloudflare CDN
- **Database Hosting:**
  - AWS RDS (PostgreSQL)
  - Google Cloud SQL
  - Azure Database for PostgreSQL
- **CI/CD:** GitHub Actions (preferred), GitLab CI, or CircleCI
- **Infrastructure as Code:** Terraform or AWS CDK

### Email & Communications

- **Transactional Email:** SendGrid, AWS SES, or Postmark
- **Email Templates:** MJML or React Email
- **SMS:** Twilio or AWS SNS
- **Push Notifications:** Firebase Cloud Messaging or OneSignal

### Payments & Billing

- **Payment Processing:** Stripe (recommended)
- **Subscription Management:** Stripe Billing or Chargebee
- **Invoicing:** Stripe Invoicing or custom with PDF generation

### Analytics & Tracking

- **Product Analytics:** Mixpanel, Amplitude, or PostHog
- **Web Analytics:** Google Analytics 4 or Plausible (privacy-focused)
- **Session Recording:** LogRocket, FullStory, or Hotjar
- **Feature Flags:** LaunchDarkly, Flagsmith, or custom

### Development Tools

- **Version Control:** Git + GitHub/GitLab
- **Code Review:** GitHub Pull Requests with required reviews
- **API Development:** Postman or Insomnia
- **Database Tools:** DBeaver, pgAdmin, or TablePlus
- **Local Development:** Docker Compose
- **Environment Variables:** .env files with python-decouple/dotenv

### Security

- **Secrets Management:** AWS Secrets Manager, HashiCorp Vault, or Doppler
- **SSL/TLS:** Let's Encrypt via cert-manager or AWS Certificate Manager
- **CORS:** Properly configured per framework
- **Rate Limiting:** Framework middleware or NGINX/API Gateway
- **WAF:** AWS WAF or Cloudflare WAF
- **DDoS Protection:** Cloudflare or AWS Shield

### Documentation

- **Code Documentation:** Docstrings (PEP 257 for Python) + auto-generated docs
- **API Documentation:** OpenAPI/Swagger UI
- **User Documentation:** Notion, GitBook, or Docusaurus
- **Architecture Diagrams:** Mermaid.js or draw.io

## Technology Selection Philosophy

1. **Proven over Trendy**: Choose mature, well-supported technologies
2. **Community & Ecosystem**: Prefer technologies with large, active communities
3. **Developer Experience**: Optimize for productivity and maintainability
4. **Scalability**: Select technologies that scale with your SaaS growth
5. **Type Safety**: Use TypeScript for frontend, type hints for Python, strong typing for Java
6. **Security First**: Default to secure configurations and best practices
7. **Cloud Native**: Design for containerization and cloud deployment
8. **Monitoring Built-in**: Include observability from day one
