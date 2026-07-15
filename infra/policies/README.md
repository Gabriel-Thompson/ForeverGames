# Policy definitions

These initial definitions deny public PostgreSQL and audit image provenance/tagging. Validate aliases with `az policy definition create --mode Indexed --rules ...` in a sandbox before assignment. Assign deny policies only after `what-if` and exemption review; policy assignment is intentionally a separate administrative approval from application deployment.
