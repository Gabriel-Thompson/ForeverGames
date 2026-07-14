import {describe,expect,it} from "vitest";import {readFileSync} from "node:fs";
const schema=readFileSync("packages/db/prisma/schema.prisma","utf8");
describe("database invariants",()=>{it("deduplicates external accounts and entitlements",()=>{expect(schema).toContain("@@unique([provider, externalAccountHash])");expect(schema).toContain("@@unique([connectionId, externalProductId, accessType])")});it("enforces one reservation per user, release, and edition",()=>{expect(schema).toContain("@@unique([userId, releaseId, editionType])")});it("tracks reservation history and transactional outbox records",()=>{expect(schema).toContain("model ReservationHistory");expect(schema).toContain("model OutboxEvent")})});

