# Operations runbook

For an incident, declare severity and owner, preserve correlation/revision identifiers, disable the affected feature, and route traffic to the last verified revision with `rollback.sh`. Rotate exposed secrets, revoke compromised sessions/identities, preserve sanitized evidence, and complete a blameless review.

Rollback changes traffic only and never reverses migrations. If schema compatibility fails, deploy forward-compatible code or a reviewed corrective migration. Failed migrations and smoke tests stop workflows before traffic shift.

Tune alerts after baseline data: availability, 5xx, P95 latency, restarts, unhealthy revisions, workflow/migration/smoke failures, authentication/reservation spikes, Key Vault denials, database CPU/storage/connections, and spend. Avoid full request bodies/provider responses.
