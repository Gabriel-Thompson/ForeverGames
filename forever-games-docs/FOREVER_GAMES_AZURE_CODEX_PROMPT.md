# Forever Games Azure Production Deployment Implementation

You are working in the `Gabriel-Thompson/ForeverGames` repository.

The application currently runs locally and is built as a pnpm monorepo containing a Next.js 15 application, Prisma, PostgreSQL, TypeScript, Vitest, and Playwright.

Your task is to create the complete Azure production-deployment foundation for:

**Production domain:** `https://myforevergames.com`

The result must follow software engineering, DevSecOps, infrastructure-as-code, configuration-as-code, security, networking, observability, and maintainability best practices.

Do not deploy anything to Azure during this task unless explicitly instructed later. Create the files, code, workflows, documentation, validation scripts, and placeholders needed for a future deployment.

Do not commit real secrets, provider credentials, Azure subscription IDs, tenant IDs, database passwords, or personally identifiable information.

---

## 1. Primary Objectives

Create a production-ready Azure deployment architecture using:

- Azure Container Apps
- Azure Container Registry
- Azure Database for PostgreSQL Flexible Server
- Azure Key Vault
- Azure Virtual Network
- Private DNS
- Azure Monitor
- Application Insights
- Log Analytics
- Azure DNS-compatible domain configuration
- Azure Budget alerts
- GitHub Actions
- GitHub OpenID Connect authentication to Azure
- Bicep infrastructure as code
- Configuration as code
- Secure Docker containerization
- Controlled Prisma database migrations

The production architecture should be lean and inexpensive while maintaining appropriate security controls.

Use scale-to-zero and Azure free grants where practical, but do not compromise production security merely to reach a zero-dollar deployment.

---

## 2. Required Architecture

Implement the following logical architecture:

```text
Internet
   |
   v
myforevergames.com
   |
   v
Azure Container Apps public HTTPS ingress
   |
   v
Forever Games Next.js container
   |
   +--> Managed Identity --> Azure Key Vault
   |
   +--> Private VNet connection --> Azure PostgreSQL Flexible Server
   |
   +--> Application Insights / Log Analytics
   |
   +--> HTTPS outbound access to approved game-provider APIs

GitHub Actions
   |
   +--> lint, typecheck, tests, security checks
   +--> Bicep validation and Azure what-if
   +--> Docker build
   +--> Azure Container Registry push
   +--> Prisma migration job
   +--> Azure Container Apps revision deployment
```

Do not add the following resources in the initial implementation:

- Azure Firewall
- NAT Gateway
- AKS
- Application Gateway
- Azure Front Door Premium
- Redis
- Service Bus
- Dedicated VM infrastructure
- Geo-redundant database replicas

These may be documented as future scaling options.

---

## 3. Repository Assessment

Before making changes:

1. Inspect the entire repository.
2. Identify:
   - monorepo structure;
   - application entrypoint;
   - current Docker-related files;
   - environment-variable handling;
   - Prisma schema and migration layout;
   - test layout;
   - current health endpoints;
   - authentication implementation;
   - logging implementation;
   - uploaded-file behavior;
   - scripts and package-manager commands.
3. Do not assume paths solely from this prompt.
4. Reuse existing repository conventions where practical.
5. Avoid unnecessary refactoring unrelated to production deployment.

Document any material assumptions in the final implementation summary.

---

## 4. Required Repository Structure

Create or adapt the following structure:

```text
infra/
├── README.md
├── main.bicep
├── modules/
│   ├── resource-group.bicep
│   ├── network.bicep
│   ├── private-dns.bicep
│   ├── managed-identities.bicep
│   ├── container-registry.bicep
│   ├── key-vault.bicep
│   ├── postgresql.bicep
│   ├── monitoring.bicep
│   ├── container-app-environment.bicep
│   ├── container-app.bicep
│   ├── role-assignments.bicep
│   ├── dns.bicep
│   └── budget.bicep
├── environments/
│   ├── dev.bicepparam
│   ├── staging.bicepparam
│   └── prod.bicepparam
├── policies/
│   ├── README.md
│   ├── require-tags.json
│   ├── deny-public-postgres.json
│   ├── require-secure-transfer.json
│   └── allowed-locations.json
└── scripts/
    ├── bootstrap-azure.sh
    ├── validate-infra.sh
    ├── what-if.sh
    ├── deploy-infra.sh
    ├── configure-federated-identity.sh
    └── destroy-nonprod.sh

config/
├── README.md
├── application/
│   ├── defaults.yaml
│   ├── development.yaml
│   ├── staging.yaml
│   ├── production.yaml
│   └── feature-flags.yaml
├── security/
│   ├── headers.yaml
│   ├── content-security-policy.yaml
│   ├── rate-limits.yaml
│   └── data-retention.yaml
├── providers/
│   ├── mock.yaml
│   ├── steam.yaml
│   ├── playstation.yaml
│   ├── xbox.yaml
│   ├── nintendo.yaml
│   ├── epic.yaml
│   └── gog.yaml
└── monitoring/
    ├── alerts.yaml
    ├── availability-tests.yaml
    └── dashboards.json

.github/
└── workflows/
    ├── ci.yml
    ├── infrastructure-plan.yml
    ├── deploy-staging.yml
    ├── deploy-production.yml
    ├── dependency-review.yml
    └── codeql.yml

docs/
├── deployment/
│   ├── AZURE_ARCHITECTURE.md
│   ├── AZURE_BOOTSTRAP.md
│   ├── DOMAIN_AND_TLS.md
│   ├── DATABASE_OPERATIONS.md
│   ├── DEPLOYMENT_RUNBOOK.md
│   ├── ROLLBACK_RUNBOOK.md
│   ├── BACKUP_AND_RESTORE.md
│   ├── INCIDENT_RESPONSE.md
│   ├── COST_MANAGEMENT.md
│   └── PRODUCTION_READINESS_CHECKLIST.md
└── security/
    ├── THREAT_MODEL.md
    ├── SECRET_MANAGEMENT.md
    ├── ACCESS_CONTROL.md
    ├── DATA_CLASSIFICATION.md
    └── LOGGING_AND_PRIVACY.md
```

Adapt names when necessary to align with existing repository conventions, but preserve the logical separation.

---

## 5. Azure Naming and Tagging

Use predictable resource names derived from:

```text
Project: forevergames
Environment: dev | staging | prod
Primary region: configurable
```

Example pattern:

```text
rg-forevergames-prod
vnet-forevergames-prod
cae-forevergames-prod
ca-forevergames-prod-web
acrforevergamesprod
kv-forevergames-prod
psql-forevergames-prod
appi-forevergames-prod
log-forevergames-prod
```

Account for Azure resource-specific naming restrictions.

Required tags:

```text
application = Forever Games
environment = dev|staging|prod
managedBy = Bicep
owner = Gabriel Thompson
repository = Gabriel-Thompson/ForeverGames
dataClassification = public|internal|confidential
costCenter = ForeverGames
```

Make tag values configurable where appropriate.

---

## 6. Networking Requirements

Create a production VNet using a configurable address space.

Default recommendation:

```text
VNet:
10.20.0.0/16

Container Apps infrastructure subnet:
10.20.0.0/23

PostgreSQL delegated subnet:
10.20.2.0/28

Private endpoints subnet:
10.20.3.0/27
```

Requirements:

- PostgreSQL must use private VNet integration.
- PostgreSQL public network access must be disabled.
- The PostgreSQL subnet must be delegated correctly.
- Create and associate the required private DNS zone.
- Do not expose PostgreSQL to the public internet.
- Container Apps must be able to resolve and reach PostgreSQL privately.
- Apply network security controls where supported and appropriate.
- Document all expected ingress and egress paths.
- Keep outbound internet access available for approved provider APIs.
- Do not introduce expensive perimeter resources in the initial version.

---

## 7. Azure Container Apps Requirements

Deploy the Next.js application as a container.

Initial defaults:

```text
CPU: 0.5 vCPU
Memory: 1 GiB
Minimum replicas: 0
Maximum replicas: 3
Target port: 3000
External ingress: enabled
HTTPS only: enabled
Allow insecure traffic: false
```

Requirements:

- Use immutable image tags based on Git commit SHA.
- Also support a human-readable environment tag such as `staging` or `production`.
- Enable revision-based deployments.
- Preserve the previous healthy revision for rollback.
- Add startup, readiness, and liveness probes.
- Use:
  - `/health/live`
  - `/health/ready`
- Do not expose internal debug endpoints.
- Configure graceful shutdown behavior.
- Use a system-assigned managed identity.
- Use Key Vault references for secrets.
- Run the container as a non-root user.
- Use a read-only root filesystem where compatible.
- Store no persistent application data on the local container filesystem.
- Clearly document any framework limitations that prevent read-only filesystem operation.

---

## 8. Docker Requirements

Create or improve the production Dockerfile.

Requirements:

- Multi-stage build.
- Use the existing Node version expected by the repository.
- Use Corepack and the repository’s pinned pnpm version.
- Use `pnpm install --frozen-lockfile`.
- Build only the required production workspace.
- Use Next.js standalone output when practical.
- Exclude development dependencies from the final image.
- Run as a non-root user.
- Add a container health check where practical.
- Minimize image size.
- Include OCI labels:
  - source repository;
  - revision;
  - build date;
  - image title;
  - image description.
- Do not copy `.env` files into the image.
- Add or update `.dockerignore`.
- Ensure Prisma client generation is handled correctly.
- Ensure Linux-compatible native dependencies are included.
- Confirm `sharp` and Prisma engines work in the chosen base image.

Create documentation explaining local container builds and production image behavior.

---

## 9. PostgreSQL Requirements

Use Azure Database for PostgreSQL Flexible Server.

Initial configuration:

```text
Tier: Burstable
SKU: configurable, default to an inexpensive viable SKU
Storage: 32 GiB
Backups: 7 days
Geo-redundant backups: disabled
High availability: disabled
Public access: disabled
TLS: required
```

Requirements:

- Make PostgreSQL version configurable.
- Select a version supported by the current Prisma version.
- Use private DNS and delegated subnet networking.
- Configure sensible backup retention.
- Enable useful diagnostic logs without excessive cost.
- Add alerts for:
  - CPU;
  - storage;
  - memory where available;
  - active connections;
  - failed connections;
  - database availability.
- Do not hardcode credentials.
- Support application and migration database roles separately.
- Do not grant schema-changing permissions to the normal application role.
- Document creation and rotation of both database users.
- Document migration rollback limitations.

Where supported and appropriate, prepare for:

```env
DATABASE_URL=postgresql://application-user:...@host:6432/forevergames?sslmode=require&pgbouncer=true
DIRECT_URL=postgresql://migration-user:...@host:5432/forevergames?sslmode=require
```

Do not assume PgBouncer is enabled without explicitly configuring and documenting it.

---

## 10. Prisma Migration Strategy

Create a safe production migration workflow.

Requirements:

- Do not use `prisma migrate dev` in production.
- Use `prisma migrate deploy`.
- Create a dedicated migration script.
- Run migrations as a separate controlled deployment job before routing traffic to a new revision.
- Use a privileged migration database identity.
- Use a restricted application database identity.
- Fail deployment when migrations fail.
- Do not shift production traffic when migrations or smoke tests fail.
- Document how destructive schema changes must be handled.
- Recommend expand-and-contract migration practices.
- Include a migration validation step in CI.
- Add a migration test against an ephemeral PostgreSQL instance.
- Ensure migration logs do not expose connection strings.

---

## 11. Key Vault and Secret Management

Provision Azure Key Vault.

Expected secrets include:

```text
SESSION-SECRET
FIELD-ENCRYPTION-KEY
POSTGRES-HOST
POSTGRES-DATABASE
POSTGRES-APP-USER
POSTGRES-APP-PASSWORD
POSTGRES-MIGRATION-USER
POSTGRES-MIGRATION-PASSWORD
STEAM-API-KEY
AUTH-CLIENT-SECRETS
EMAIL-PROVIDER-KEY
```

Requirements:

- Do not place secret values in Bicep parameter files.
- Do not place secrets in tracked configuration files.
- Use managed identities and Azure RBAC.
- Disable broad or anonymous access.
- Enable soft delete and purge protection for production.
- Restrict access to the Container App and deployment identities.
- Document secret bootstrap procedures.
- Document secret rotation procedures.
- Document emergency revocation procedures.
- Ensure logs never print secret values.
- Add startup validation that required secrets are present.
- Do not generate production secrets in CI logs.
- Include a script or documented command for generating:
  - a secure session secret;
  - a 32-byte Base64 field-encryption key.

---

## 12. Azure Administrative Identity

Use Microsoft Entra ID and Azure RBAC.

Requirements:

- GitHub Actions must authenticate through OIDC federation.
- Do not use stored Azure service-principal passwords.
- Create separate identities or permission scopes for:
  - infrastructure planning;
  - nonproduction deployment;
  - production deployment;
  - migration execution.
- Follow least privilege.
- Document required Azure role assignments.
- Production deployment should require GitHub environment approval.
- Production secrets should be readable only by the application and narrowly scoped deployment processes.
- Do not give the Container App contributor rights over the subscription.
- Document break-glass administrative access without implementing shared credentials.

---

## 13. Customer Authentication Boundary

The Forever Games account remains the primary customer identity.

Game-provider connections are secondary linked accounts.

Maintain the conceptual flow:

```text
Forever Games account
    |
    +--> Steam account
    +--> PlayStation account
    +--> Xbox account
    +--> Nintendo account
    +--> Epic account
    +--> GOG account
```

Requirements:

- Do not imply that unsupported provider APIs are currently authorized.
- Keep mock connectors clearly marked.
- Encrypt OAuth tokens and provider credentials at the field level.
- Never log provider access tokens.
- Define provider-link revocation behavior.
- Define provider-token refresh behavior.
- Define ownership-evidence levels:
  - verified;
  - imported;
  - subscription;
  - self-reported;
  - synthetic/mock.
- Preserve credibility distinctions in analytics.
- Document redirect URI requirements for `https://myforevergames.com`.

Do not replace the current authentication architecture unless necessary. Prefer adding deployment readiness around the existing implementation.

---

## 14. Configuration as Code

Create typed, validated configuration for non-secret settings.

Include:

- application base URL;
- canonical domain;
- feature flags;
- enabled providers;
- mock mode;
- reservation rules;
- rate limits;
- data-retention settings;
- CSP directives;
- security headers;
- log levels;
- monitoring thresholds;
- sync limits;
- maintenance mode;
- analytics consent behavior;
- provider callback routes;
- public-registration enablement.

Requirements:

- Validate configuration at startup.
- Fail fast for invalid production configuration.
- Distinguish configuration from secrets.
- Do not silently fall back to synthetic data in production unless an explicit safe feature flag enables it.
- Clearly label mock data in every environment where it is enabled.
- Document configuration precedence.
- Avoid creating an unnecessary custom configuration framework when standard environment validation is sufficient.
- Use existing Zod support where practical.

---

## 15. Security Headers

Implement and document production security headers.

Include at minimum:

- Strict-Transport-Security
- Content-Security-Policy
- X-Content-Type-Options
- Referrer-Policy
- Permissions-Policy
- frame-ancestors through CSP
- Cross-Origin-Opener-Policy where compatible
- Cross-Origin-Resource-Policy where compatible

Requirements:

- Do not use unsafe CSP directives without justification.
- Account for Next.js runtime behavior.
- Account for images and assets fetched from game metadata providers.
- Support separate development and production CSP configurations.
- Add automated tests for critical headers.

---

## 16. Application Security

Review and improve production security without unnecessary feature rewrites.

Required checks:

- Secure cookies.
- HTTP-only cookies.
- SameSite configuration.
- CSRF protection for state-changing actions.
- Server-side authorization.
- Input validation.
- Output encoding.
- Rate limiting.
- Login brute-force resistance.
- Reservation abuse prevention.
- Provider-sync abuse prevention.
- Account-deletion authorization.
- Admin-route authorization.
- Open-redirect prevention.
- SSRF prevention for remote images and provider URLs.
- Sensitive-data filtering in errors.
- No stack traces exposed in production responses.
- Safe dependency handling.
- Safe file-upload behavior, if uploads exist.
- No secrets in client-side bundles.

Create or update security tests for these controls.

---

## 17. Rate Limiting

Implement a rate-limiting abstraction suitable for the initial deployment.

At minimum cover:

- login;
- registration;
- password reset;
- provider linking;
- provider sync;
- reservation creation;
- reservation updates;
- reservation cancellation;
- administrative endpoints;
- data export;
- account deletion.

Because Redis is deferred, choose a pragmatic initial implementation.

Document:

- limitations of in-memory rate limiting when Container Apps scales horizontally;
- whether database-backed limits are used;
- when Redis or another distributed limiter becomes necessary.

Do not present an in-memory-only limiter as globally reliable across multiple replicas.

---

## 18. Health and Readiness Endpoints

Create or validate:

```text
GET /health/live
GET /health/ready
```

`/health/live` should verify only that the application process is alive.

`/health/ready` should verify the dependencies required to serve traffic, including the database.

Requirements:

- Do not expose secrets or detailed infrastructure data.
- Use appropriate HTTP status codes.
- Apply short timeouts.
- Ensure failure is observable.
- Add unit and integration tests.
- Configure Container Apps probes to use these endpoints.

---

## 19. Logging

Implement structured JSON logging.

Include fields such as:

```json
{
  "timestamp": "ISO-8601 timestamp",
  "severity": "info",
  "event": "reservation.created",
  "requestId": "correlation identifier",
  "environment": "production",
  "userIdHash": "nonreversible operational identifier",
  "gameId": "internal identifier",
  "provider": "steam"
}
```

Requirements:

- Create request correlation IDs.
- Propagate correlation IDs through major operations.
- Redact:
  - passwords;
  - connection strings;
  - cookies;
  - session tokens;
  - OAuth tokens;
  - API keys;
  - authorization headers;
  - full email addresses where not required;
  - full IP addresses where not required.
- Do not log game-provider payloads containing user data.
- Separate audit events from ordinary diagnostics where practical.
- Document retention recommendations.
- Add logging tests for redaction.

---

## 20. Audit Events

Create an audit-event model or abstraction for security-relevant actions.

Include:

- account created;
- login succeeded;
- login failed;
- password changed;
- provider linked;
- provider disconnected;
- provider sync started;
- provider sync completed;
- provider sync failed;
- reservation created;
- reservation changed;
- reservation cancelled;
- admin action performed;
- user data exported;
- account deletion requested;
- account deleted;
- encryption-key or credential rotation event where applicable.

Audit logs must avoid storing secret material.

Document retention and access expectations.

---

## 21. Monitoring and Observability

Provision:

- Log Analytics workspace;
- Application Insights;
- Container Apps diagnostics;
- PostgreSQL diagnostics;
- Azure Monitor alerts;
- availability tests where supported;
- Azure budget alerts.

Create alert definitions for:

- site unavailable;
- elevated 5xx rate;
- elevated P95 latency;
- container restart loop;
- unhealthy Container Apps revision;
- failed deployment;
- failed migration;
- failed smoke test;
- database CPU above threshold;
- database storage above threshold;
- database connection saturation;
- authentication failure spike;
- reservation error spike;
- Key Vault access failure;
- monthly Azure spend threshold.

Use conservative initial thresholds and document how they should be tuned.

Avoid excessive log ingestion costs.

---

## 22. Cost Controls

Implement or document:

- Container Apps scale-to-zero;
- low minimum replica count;
- inexpensive PostgreSQL SKU;
- short initial backup retention;
- disabled HA initially;
- disabled geo-redundant backups initially;
- reasonable Log Analytics retention;
- log sampling where appropriate;
- Azure budget and threshold notifications;
- resource tags;
- environment-specific sizing;
- nonproduction destruction or shutdown procedures.

Create `docs/deployment/COST_MANAGEMENT.md`.

Include approximate cost drivers without claiming exact prices.

Clearly identify PostgreSQL and ACR as likely recurring baseline costs.

---

## 23. Domain and TLS

Prepare the application and documentation for:

```text
myforevergames.com
www.myforevergames.com
```

Requirements:

- Apex domain is canonical.
- `www` redirects to the apex.
- HTTPS only.
- Azure-managed certificate where supported.
- Document expected:
  - A record;
  - CNAME record;
  - TXT verification record;
  - CAA record.
- Do not hardcode an IP address that does not yet exist.
- Output required DNS values from Bicep where possible.
- Use host-only cookies unless there is a clear requirement for shared subdomain cookies.
- Configure:
  - application base URL;
  - OAuth callback URLs;
  - canonical URL;
  - allowed origins;
  - CSRF origin validation.
- Include DNS validation and rollback steps.

---

## 24. Azure Container Registry

Provision Azure Container Registry using a low-cost SKU.

Requirements:

- Disable anonymous access.
- Do not use admin credentials for normal deployments.
- Use managed identity or OIDC-backed deployment authentication.
- Grant Container Apps image-pull access through RBAC.
- Use immutable Git SHA image tags.
- Document image-retention and cleanup expectations.
- Add container vulnerability scanning through available GitHub or Azure tooling.
- Do not expose registry credentials in workflow logs.

---

## 25. GitHub Actions CI

Create or improve `.github/workflows/ci.yml`.

Run on pull requests and appropriate pushes.

Required steps:

1. Checkout.
2. Setup Node.
3. Enable Corepack.
4. Restore pnpm cache.
5. Install with frozen lockfile.
6. Generate Prisma client.
7. Run lint.
8. Run typecheck.
9. Run unit tests.
10. Run component tests.
11. Run integration tests.
12. Run contract tests.
13. Run security tests.
14. Validate migrations.
15. Build application.
16. Build production Docker image.
17. Run secret scanning.
18. Run dependency review where applicable.
19. Run Bicep lint and validation when infrastructure files change.

Use concurrency controls to cancel obsolete runs.

Use minimal GitHub token permissions.

---

## 26. Infrastructure Plan Workflow

Create `.github/workflows/infrastructure-plan.yml`.

Requirements:

- Trigger on pull requests affecting `infra/**`.
- Authenticate to Azure through OIDC when an Azure `what-if` is needed.
- Run:
  - Bicep format validation;
  - Bicep lint;
  - Bicep build;
  - ARM template validation;
  - Azure `what-if`.
- Never deploy infrastructure from a pull request.
- Publish a readable plan summary.
- Avoid exposing secrets in plan output.
- Use a nonproduction planning identity with minimal permissions.

---

## 27. Staging Deployment Workflow

Create `.github/workflows/deploy-staging.yml`.

On merge to the designated deployment branch:

1. Authenticate through GitHub OIDC.
2. Validate infrastructure.
3. Deploy or update staging infrastructure.
4. Build image.
5. Tag image with commit SHA.
6. Push image to ACR.
7. Run Prisma migration deployment.
8. Deploy new Container Apps revision.
9. Run health checks.
10. Run smoke tests.
11. Confirm readiness.
12. Route staging traffic to the new revision.
13. Preserve the prior revision.
14. Produce a deployment summary.

Do not deploy when CI has failed.

---

## 28. Production Deployment Workflow

Create `.github/workflows/deploy-production.yml`.

Requirements:

- Use a protected GitHub environment named `production`.
- Require manual approval.
- Accept an immutable commit SHA or image tag.
- Do not rebuild a different artifact from the one validated in staging where avoidable.
- Authenticate with production-scoped OIDC identity.
- Run infrastructure validation.
- Apply approved infrastructure changes.
- Run database migration deployment.
- Deploy a new Container Apps revision.
- Run health and smoke tests before traffic migration.
- Shift traffic only after validation.
- Automatically stop or reverse the deployment when validation fails.
- Preserve the previous healthy revision.
- Output rollback instructions.

Do not implement automatic production deployment directly from every merge to `main`.

---

## 29. Rollback Strategy

Create a documented and partially automated rollback procedure.

Application rollback:

- identify previous healthy Container Apps revision;
- shift traffic back;
- validate health;
- confirm user-facing restoration.

Database rollback:

- document that Prisma migrations are generally forward-only;
- use corrective forward migrations;
- require backups before destructive changes;
- follow expand-and-contract practices;
- avoid automatic down migrations in production.

Create:

```text
docs/deployment/ROLLBACK_RUNBOOK.md
```

Include exact commands with placeholders.

---

## 30. Backup and Restore

Create:

```text
docs/deployment/BACKUP_AND_RESTORE.md
```

Cover:

- PostgreSQL automated backup behavior;
- retention settings;
- point-in-time restore;
- restore to a new server;
- private DNS and application reconnection;
- post-restore validation;
- credential rotation following recovery;
- restore testing schedule;
- recovery-time and recovery-point assumptions.

Do not claim a backup is valid until restore testing has occurred.

---

## 31. Incident Response

Create:

```text
docs/deployment/INCIDENT_RESPONSE.md
```

Include response steps for:

- portal outage;
- failed deployment;
- database outage;
- suspected database compromise;
- leaked secret;
- leaked provider token;
- abnormal reservation activity;
- authentication abuse;
- Key Vault access failure;
- domain or certificate issue;
- excessive Azure spend;
- vulnerable dependency;
- compromised GitHub Actions workflow.

Include:

- detection;
- containment;
- eradication;
- recovery;
- communication;
- evidence preservation;
- post-incident review.

---

## 32. Threat Model

Create:

```text
docs/security/THREAT_MODEL.md
```

Use a practical STRIDE-style threat model.

Address:

- account takeover;
- credential stuffing;
- reservation manipulation;
- fake ownership claims;
- provider-token theft;
- cross-user data access;
- administrative privilege abuse;
- SQL injection;
- CSRF;
- XSS;
- SSRF;
- open redirects;
- malicious remote images;
- supply-chain compromise;
- dependency compromise;
- CI/CD credential compromise;
- container escape risk;
- database exposure;
- secret leakage;
- analytics poisoning;
- automated bot reservations;
- denial of service.

For each major threat, document:

- asset;
- threat;
- likely attack path;
- existing or proposed control;
- residual risk;
- future mitigation.

---

## 33. Data Classification

Create:

```text
docs/security/DATA_CLASSIFICATION.md
```

Classify at least:

- public game metadata;
- internal analytics;
- user profile information;
- email addresses;
- account identifiers;
- provider tokens;
- ownership evidence;
- reservation intent;
- pricing preferences;
- authentication data;
- audit logs;
- IP addresses;
- session identifiers;
- encryption keys.

Define:

- storage requirements;
- encryption expectations;
- logging rules;
- retention expectations;
- access controls;
- deletion behavior.

---

## 34. Data Retention and Privacy

Create configuration and documentation for:

- inactive-account retention;
- provider-token retention;
- reservation-history retention;
- operational-log retention;
- audit-log retention;
- analytics aggregation;
- deletion requests;
- account export;
- provider disconnect;
- consent handling;
- synthetic data separation.

Ensure deletion workflows do not silently retain linked-provider secrets.

Document where aggregated, anonymized demand analytics may remain after account deletion, subject to future legal review.

Do not provide legal conclusions. Mark legal and privacy-policy language as requiring attorney review.

---

## 35. Azure Policy Definitions

Create starter Azure Policy definitions or policy documentation for:

- required resource tags;
- PostgreSQL public access denied;
- secure transfer required where applicable;
- approved Azure regions;
- HTTPS-only web ingress where enforceable;
- diagnostic settings expectations.

Do not automatically assign subscription-wide policies unless explicitly requested.

Provide deployment examples and explain scope.

---

## 36. Environment Strategy

Support:

```text
development
staging
production
```

Requirements:

- Separate Bicep parameter files.
- Separate Azure resource names.
- Separate Key Vault secrets.
- Separate databases.
- Separate deployment identities.
- Separate application URLs.
- Separate provider callback URLs.
- Production must never use development secrets.
- Synthetic data should be disabled by default in production.
- Production deployment must be approval-gated.
- Nonproduction resources should use smaller or disposable configurations.

Document the differences between environments.

---

## 37. Application Production Readiness

Inspect the application and implement or document the following:

- environment validation;
- canonical URL handling;
- proxy-header handling;
- HTTPS-aware cookie behavior;
- graceful shutdown;
- stateless operation;
- health endpoints;
- structured logging;
- production error handling;
- no development debug pages;
- no synthetic fallback in production unless explicitly enabled;
- safe database connection pooling;
- safe Prisma client lifecycle;
- secure image-domain allowlisting;
- secure redirect handling;
- request-size limits where applicable;
- server-action or API-route authorization;
- feature flags;
- maintenance mode;
- build metadata endpoint or internal diagnostic output.

Do not expose sensitive deployment metadata publicly.

---

## 38. Testing Requirements

Add or update tests for:

### Unit tests

- configuration validation;
- secret redaction;
- connection-string construction;
- reservation authorization;
- rate-limit logic;
- health endpoint logic;
- audit-event creation;
- provider ownership-evidence classification.

### Integration tests

- PostgreSQL connectivity;
- Prisma migrations;
- reservation create/update/cancel;
- account isolation;
- provider-link persistence;
- readiness endpoint dependency failure;
- configuration loading;
- audit-log persistence.

### Security tests

- unauthenticated protected routes;
- cross-user access attempts;
- CSRF protection;
- open redirects;
- dangerous callback URLs;
- malicious URL input;
- security headers;
- secret redaction;
- oversized payloads;
- repeated login or reservation attempts.

### End-to-end tests

- create Forever Games account;
- sign in;
- browse library;
- view game details;
- reserve a game;
- change reservation preferences;
- cancel reservation;
- view analytics;
- provider-link mock flow;
- account settings;
- logout;
- health smoke test.

### Infrastructure tests

- Bicep compiles;
- required tags exist;
- PostgreSQL public access is disabled;
- TLS-only ingress is configured;
- managed identity exists;
- Key Vault access is scoped;
- production minimum and maximum replicas are valid;
- diagnostic settings are present;
- budget alert exists.

Do not make tests depend on real production provider accounts.

---

## 39. Documentation Quality

Every README and runbook must be usable by a future engineer or coding agent.

Documentation should contain:

- purpose;
- prerequisites;
- configuration;
- commands;
- expected outputs;
- security considerations;
- validation steps;
- rollback steps;
- troubleshooting guidance.

Use placeholders such as:

```text
<AZURE_SUBSCRIPTION_ID>
<AZURE_TENANT_ID>
<AZURE_LOCATION>
<GITHUB_ORG>
<GITHUB_REPOSITORY>
<DOMAIN_VALIDATION_TOKEN>
```

Do not invent actual identifiers.

---

## 40. Main Deployment README

Create or update a top-level production deployment section in the repository README.

Include:

- architecture summary;
- local development;
- container build;
- infrastructure validation;
- Azure bootstrap;
- GitHub OIDC setup;
- staging deployment;
- production deployment;
- domain configuration;
- secret bootstrap;
- database migration;
- monitoring;
- rollback;
- cost expectations.

Link to all deeper documentation.

Do not remove existing local-development instructions.

---

## 41. Production Readiness Checklist

Create:

```text
docs/deployment/PRODUCTION_READINESS_CHECKLIST.md
```

Include checkboxes for:

### Application

- [ ] Production build succeeds
- [ ] Health checks pass
- [ ] No synthetic fallback is enabled
- [ ] Security headers are verified
- [ ] Secure cookies are enabled
- [ ] Rate limiting is active
- [ ] Error responses contain no sensitive data

### Infrastructure

- [ ] Bicep validation passes
- [ ] Azure what-if reviewed
- [ ] PostgreSQL public access disabled
- [ ] Managed identity configured
- [ ] Key Vault references working
- [ ] Diagnostic settings enabled
- [ ] Budget alerts configured

### Database

- [ ] Migration test passes
- [ ] Production migration reviewed
- [ ] Backup policy confirmed
- [ ] Restore test completed
- [ ] Application role has restricted permissions

### CI/CD

- [ ] OIDC configured
- [ ] No Azure client secret stored in GitHub
- [ ] Production approval enabled
- [ ] Rollback procedure tested
- [ ] Image is immutable and traceable

### Domain

- [ ] DNS records validated
- [ ] TLS certificate active
- [ ] HTTP redirects to HTTPS
- [ ] `www` redirects to apex
- [ ] OAuth callback URLs updated

### Security and Privacy

- [ ] Threat model reviewed
- [ ] Secret scanning passes
- [ ] Dependency scan passes
- [ ] Provider tokens encrypted
- [ ] Logging redaction verified
- [ ] Data-retention settings approved
- [ ] Privacy and terms reviewed by counsel

### Operations

- [ ] Availability alert tested
- [ ] Database alert tested
- [ ] Incident runbook reviewed
- [ ] Deployment runbook tested
- [ ] Cost dashboard reviewed

---

## 42. Coding Standards

Follow existing repository conventions.

Additionally:

- TypeScript strict mode where already supported.
- Avoid `any` unless justified.
- Validate external inputs.
- Use descriptive naming.
- Keep modules focused.
- Avoid duplicated infrastructure definitions.
- Parameterize environment differences.
- Never expose secret values in outputs.
- Add comments for security-sensitive behavior.
- Prefer stable Azure API versions.
- Avoid preview Azure resource versions unless necessary.
- Document preview dependencies.
- Format Bicep and YAML consistently.
- Keep GitHub Action permissions minimal.

---

## 43. Change-Scope Rules

You may:

- add infrastructure;
- add deployment workflows;
- add configuration validation;
- add production readiness code;
- add documentation;
- improve Docker support;
- add health endpoints;
- add security controls;
- add tests.

Do not:

- redesign the user interface;
- replace the database technology;
- replace Prisma;
- replace Next.js;
- change the Forever Games business model;
- imply Sony, Microsoft, Nintendo, Steam, Epic, or GOG authorization;
- add real provider credentials;
- deploy Azure resources;
- modify GitHub repository settings;
- commit directly to the default branch unless explicitly instructed.

---

## 44. Work Sequence

Perform the task in this order:

1. Inspect and summarize repository architecture.
2. Identify implementation gaps.
3. Create a dedicated working branch.
4. Add or improve the production Docker implementation.
5. Add environment and configuration validation.
6. Add health endpoints.
7. Add logging and secret redaction.
8. Add security headers and rate-limiting abstraction.
9. Add Bicep modules.
10. Add environment parameter files.
11. Add Azure bootstrap and validation scripts.
12. Add GitHub Actions workflows.
13. Add database migration deployment strategy.
14. Add infrastructure and application tests.
15. Add deployment and security documentation.
16. Run all available checks.
17. Fix failures caused by the implementation.
18. Review the final diff for secrets and unsafe defaults.
19. Provide a final implementation summary.

---

## 45. Validation Commands

Run the applicable repository commands, including:

```bash
corepack pnpm install --frozen-lockfile
corepack pnpm db:generate
corepack pnpm lint
corepack pnpm typecheck
corepack pnpm test
corepack pnpm db:migration:test
corepack pnpm build
```

Also run:

```bash
docker build .
az bicep build --file infra/main.bicep
az bicep lint --file infra/main.bicep
```

Run targeted tests for any new functionality.

When Docker or Azure CLI is unavailable, clearly state that validation was not run and provide the exact command required.

Do not falsely claim successful validation.

---

## 46. Deliverables

The completed branch should contain:

- production Dockerfile;
- `.dockerignore`;
- Bicep modules;
- environment parameter files;
- Azure scripts;
- GitHub Actions workflows;
- configuration-as-code files;
- health endpoints;
- production configuration validation;
- structured logging and redaction;
- security-header implementation;
- rate-limiting abstraction;
- monitoring and alert definitions;
- deployment documentation;
- security documentation;
- production readiness checklist;
- tests;
- updated root README.

---

## 47. Final Response Format

At completion, provide:

### Summary

A concise description of what was implemented.

### Architecture

The final Azure architecture and major design decisions.

### Files Created

List the major files and directories created.

### Files Modified

List the important existing files changed.

### Validation Performed

List every command run and whether it passed.

### Security Controls

Summarize the implemented controls.

### Cost Controls

Summarize how initial Azure costs are minimized.

### Manual Azure Steps Remaining

List actions that cannot safely be automated without account-specific values.

### Required GitHub Configuration

List:

- environments;
- approval rules;
- OIDC variables;
- secrets, only where unavoidable;
- branch protection expectations.

### Required DNS Records

List record types and placeholder values.

### Known Limitations

Clearly identify unresolved issues or deferred capabilities.

### Recommended Next Step

State the next concrete deployment activity.

Do not deploy production resources or push changes unless explicitly instructed.
