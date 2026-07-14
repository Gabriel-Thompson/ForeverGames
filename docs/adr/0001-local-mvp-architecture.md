# ADR 0001: Local MVP architecture

- Status: Accepted for local development
- Date: 2026-07-14

## Context

The build specification requires a modular monolith, background-work boundaries, PostgreSQL, mocked providers for local development, and explicit product-owner decisions before external integrations. Staging and production are outside this milestone.

## Decision

Use a pnpm workspace with Next.js/TypeScript for the web and API, Prisma with PostgreSQL as the source of truth, Redis and Mailpit local services, isolated domain/connector packages, and a transactional outbox table. Identity, catalog, email, provider sync, and analytics are synthetic adapters locally. No real connector is enabled by default.

## Consequences

The local portal is immediately reviewable and core schemas/constraints can be tested. Real passkeys, CIAM sessions, worker execution, field encryption through KMS, licensed assets, Steam OpenID verification, production observability, and cloud infrastructure remain integration work, not silently simulated production readiness.

