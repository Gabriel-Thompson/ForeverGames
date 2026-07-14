# Forever Games local portal

A local demand-validation MVP based on `forever-games-docs/FOREVER_GAMES_PORTAL_BUILD_SPECIFICATION.md`. It uses synthetic data by default and does not sell products, scrape providers, or imply platform authorization.

## Run locally

1. Install Node 22+, pnpm, and Docker Desktop.
2. Copy `.env.example` to `.env.local`; replace the session and encryption placeholders. Leave third-party keys blank for mock mode.
3. Run `docker compose up -d`.
4. Run `pnpm install`, `pnpm db:generate`, `pnpm db:migrate`, and `pnpm db:seed`.
5. Run `pnpm dev` and open http://localhost:3000. Mailpit is at http://localhost:8025.

The UI can be explored without a database. The reservation API and seed-backed persistence require PostgreSQL. Staging, production, real CIAM, licensed catalog feeds, and real Steam linking are deliberately deferred.

## Quality commands

`pnpm lint`, `pnpm typecheck`, `pnpm test`, `pnpm db:migration:test`, and `pnpm build`.

## Secret handling

`.env.local` and all `.env.*.local` files are ignored. Never put a provider password, API token, real provider payload, or user information in code, fixtures, screenshots, or logs. `.env.example` contains names and safe placeholders only.

