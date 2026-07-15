# Architecture and network paths

Internet clients reach HTTPS-only Container Apps ingress. The app subnet is `10.20.0.0/23`; PostgreSQL uses delegated `10.20.2.0/24` and private DNS; Key Vault uses a private endpoint in `10.20.3.0/24`. The VNet is `10.20.0.0/16`.

Runtime identity reads application secrets and pulls images. Migration identity pulls the immutable image and reads only the migration URL. The application database role has no DDL permission. ACR has no anonymous/admin access. Logs flow to Log Analytics and Application Insights. Approved provider endpoints remain reachable through outbound internet; inbound callbacks terminate at HTTPS ingress.

Deferred: Redis/global rate limiting, WAF, NAT Gateway, Front Door, HA PostgreSQL, geo-backups, PgBouncer, private ACR, CIAM, and blob evidence storage. Add them from measured risk and scale.
