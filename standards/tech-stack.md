# Tech Stack

## Context

Global tech stack defaults for Agent OS projects, overridable in project-specific `.agent-os/product/tech-stack.md`.

- App Framework: SpringBoot 3.5+
- Language: Java 21+
- Primary Database: PostgreSQL 17+
- ORM: Spring Data JPA
- JavaScript Framework: React latest stable
- Build Tool: Vite
- Import Strategy: Node.js modules
- Package Manager: npm
- Node Version: 22 LTS
- CSS Framework: TailwindCSS 4.0+
- UI Components: Instrumental Components latest
- Font Provider: Google Fonts
- Font Loading: Self-hosted for performance
- Icons: Lucide React components
- Application Hosting: AWS ECS Fargate / Local Docker containers
- Hosting Region: US-EAST
- Database Hosting: AWS RDS Aurora PostgreSQL
- Database Backups: Daily automated
- Asset Storage: AWS S3
- CDN: AWS CloudFront
- Asset Access: Private with signed URLs
- CI/CD Platform: GitHub Actions
- CI/CD Trigger: Push to main/staging branches
- Tests: Run before deployment
- Production Environment: main branch
- Staging Environment: staging branch
- Deployment Solution: Docker Compose with health checks
- Code Repository: Git-based version control
- Development Environment: Local containers with volume mounts for live reload