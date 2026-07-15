# Security, privacy, and threat model

Threats include credential theft, session abuse, authorization bypass, CSRF, provider-sync abuse, malicious uploads, SSRF through remote content, reservation manipulation, secret leakage, supply-chain compromise, and admin misuse. Controls include server authorization, Zod validation, origin checks, secure cookies, CSP/nonces, HSTS, least-privilege identities, private data services, immutable tags, scanning, audit events, redaction, and production-disabled uploads/fallbacks.

Credentials/tokens and connection strings are Restricted; email, sessions, provider identifiers, evidence, and entitlement history are Confidential; aggregated demand is Internal until minimum-cell suppression permits publication; catalog content is Public. Never log Restricted data or raw provider payloads. Limit audit access to production operators. Follow `config/retention.yaml`, honor export/deletion requests, and approve legal retention before launch.

The in-memory limiter is per replica and resets on restart. Add Redis or database-backed atomic limits before higher traffic, strict quotas, or abuse-sensitive public registration.
