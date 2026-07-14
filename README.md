# Forever Games local portal

A local demand-validation MVP based on `forever-games-docs/FOREVER_GAMES_PORTAL_BUILD_SPECIFICATION.md`. It uses synthetic data by default and does not sell products, scrape providers, or imply platform authorization.

## Run locally

1. Install Node 22+, pnpm, and Docker Desktop.
2. Copy `.env.example` to `.env.local`; replace the session and encryption placeholders. Leave third-party keys blank for mock mode.
3. Start Docker Desktop and wait for its Linux engine to report that it is running.
4. Run `docker compose up -d`.
5. Run `corepack pnpm install`, `corepack pnpm db:generate`, `corepack pnpm db:migrate`, and `corepack pnpm db:seed`.
6. Run `corepack pnpm dev` and open http://localhost:3000. Mailpit is at http://localhost:8025.

The UI can be explored without a database: repository reads fall back to clearly labeled synthetic fixtures and the health endpoint reports `degraded`. With PostgreSQL running, the library, game details, analytics, admin metrics, sync history, and reservation create/update/cancel paths use persisted records. Staging, production, real CIAM, licensed catalog feeds, and real Steam linking are deliberately deferred.

If Docker reports that `dockerDesktopLinuxEngine` cannot be found, Docker Desktop is not running yet. This is an engine problem rather than an application error.

## Quality commands

`pnpm lint`, `pnpm typecheck`, `pnpm test`, `pnpm db:migration:test`, and `pnpm build`.

## Secret handling

`.env.local` and all `.env.*.local` files are ignored. Never put a provider password, API token, real provider payload, or user information in code, fixtures, screenshots, or logs. `.env.example` contains names and safe placeholders only.
