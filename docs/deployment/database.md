# Database operations

Create `migration-user` as schema owner and `application-user` with CONNECT, USAGE, and required table/sequence DML only. Revoke schema CREATE from runtime. Rotate each password independently, update Key Vault, and create a new app revision.

Deployments run `prisma migrate deploy` in a manual Container Apps job before a candidate web revision. Use expand-and-contract changes: add compatible structures, deploy compatible code, backfill, then remove old structures later. Prisma does not automatically reverse destructive/data-changing migrations; application rollback never rolls back the database.

Backups retain seven days. Quarterly, run `restore-drill.sh` into a disposable private server, validate critical data, record RPO/RTO, and remove it through approved change. Never restore over production. Alert on CPU, storage, connections, failed connections, and availability before scaling the default B1ms/32 GiB server.
