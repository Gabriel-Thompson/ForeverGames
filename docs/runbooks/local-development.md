# Local development runbook

If PostgreSQL is unavailable, confirm Docker Desktop is running and use `docker compose ps`. Resetting local data is destructive; stop the stack, remove the named volume only when intentionally discarding synthetic data, then rerun migrations and seed.

Provider failures must leave the stored library readable. `GET /api/v1/health` reports enabled local adapters without exposing configuration values. Secrets must be redacted from logs and support views.

