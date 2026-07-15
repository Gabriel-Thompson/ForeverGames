# Azure deployment foundation

This repository defines—but does not deploy—a production foundation for `myforevergames.com`. Bicep provisions a resource group, VNet, private PostgreSQL Flexible Server, private Key Vault, ACR, Log Analytics, Application Insights, a Container Apps environment, a manual migration job, the web app, managed identities, DNS hooks, and a subscription budget.

## Deployment order

1. Install Azure CLI with Bicep, Docker, Node 22, and pnpm 11.4.0. Run `./scripts/validate-infra.sh`.
2. Establish GitHub OIDC identities and least-privilege role assignments described in `github-configuration.md`.
3. Export `ENVIRONMENT` and a generated `POSTGRES_ADMIN_PASSWORD`, then run `bootstrap-azure.sh`. This creates the platform with no web revision.
4. From a machine or self-hosted runner connected to the VNet, set the five environment variables named in `populate-key-vault.sh` and run it. Do not place values in files, shell history, workflow logs, or Bicep parameter files.
5. Create restricted `application-user` and privileged `migration-user` roles per `database.md`; store `DATABASE_URL` and `DIRECT_URL` in Key Vault. PgBouncer is not enabled, so use port 5432 and omit `pgbouncer=true`.
6. Configure GitHub environments and run staging. Promote the exact verified SHA to production after approval. Workflows run migrations first, keep the stable revision at 100%, probe the candidate label, then shift traffic.
7. Add the custom domain and certificate in Container Apps, then enable the Bicep DNS module. See `domain-and-tls.md`.

Secrets are Key Vault references resolved with managed identities. PostgreSQL and Key Vault have no public data-plane path. Provider API egress uses normal Container Apps outbound internet access; no costly firewall or gateway is included.

The container runs as UID 1001 and writes no durable production data. Next.js may need ephemeral framework cache paths, so a read-only root filesystem is not asserted until compatibility is tested. Production disables synthetic fallback and local evidence uploads.

## Validation

Run `pnpm lint`, `pnpm typecheck`, `pnpm test`, `pnpm build`, `pnpm audit --audit-level high`, `./scripts/validate-infra.sh`, and a container smoke test. Azure `what-if` is the final non-mutating review. Nothing here authorizes a deployment.
