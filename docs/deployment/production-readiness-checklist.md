# Production readiness checklist

- [ ] CI, tests, build, image/dependency/secret scans, Bicep lint, and what-if pass.
- [ ] Key Vault secrets, rotation owners, and expiry reminders exist.
- [ ] Runtime and migration database roles are distinct and least privilege.
- [ ] Private DNS works; PostgreSQL and Key Vault public access are disabled.
- [ ] Migration, candidate smoke, rollback, and restore drill pass in staging.
- [ ] Production approval promotes a staging-verified SHA.
- [ ] Alerts, recipients, budget, dashboard, and retention are confirmed.
- [ ] Domain, certificate, apex/www records, redirect, and renewal pass.
- [ ] Privacy, consent, export/deletion, audit access, and incident contacts are approved.
- [ ] Fallback, uploads, checkout, debug routes, and public registration are disabled.
- [ ] Provider agreements/API rights are documented.
