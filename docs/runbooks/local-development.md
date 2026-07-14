# Local development runbook

If PostgreSQL is unavailable, confirm Docker Desktop is running and use `docker compose ps`. Resetting local data is destructive; stop the stack, remove the named volume only when intentionally discarding synthetic data, then rerun migrations and seed.

Provider failures must leave the stored library readable. `GET /api/v1/health` reports enabled local adapters without exposing configuration values. Secrets must be redacted from logs and support views.

Expected health states:

- `ok` with `database: connected`: persisted local mode.
- `degraded` with `database: unavailable`: safe synthetic fallback; start Docker and run migration/seed commands.

Prisma commands run through `scripts/run-prisma.mjs`, which provides the Corepack pnpm shim Prisma needs on Windows. A global pnpm installation is not required.
