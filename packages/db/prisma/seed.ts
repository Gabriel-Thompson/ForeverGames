import { PrismaClient, AccessType, ConnectionStatus, PhysicalStatus, ProviderCode, SyncStatus, VerificationLevel } from "../generated/client/client";
import { createHash } from "node:crypto";

try { process.loadEnvFile(".env.local"); } catch { /* CI can provide environment variables directly. */ }
const db = new PrismaClient();
const catalog = [
  ["signal-below", "Signal Below", 2024, "Northstar Studio", "Adventure", "DIGITAL_ONLY", "PURCHASED", "VERIFIED_PROVIDER"],
  ["ashfall-circuit", "Ashfall Circuit", 2022, "Ember Arc", "Racing", "PHYSICAL_AVAILABLE", "PURCHASED", "VERIFIED_PROVIDER"],
  ["the-last-cartographer", "The Last Cartographer", 2025, "Quiet Giant", "Strategy", "DIGITAL_ONLY", "PURCHASED", "VERIFIED_PROVIDER"],
  ["fallow-moon", "Fallow Moon", 2021, "Morrow Works", "RPG", "UNKNOWN", "SUBSCRIPTION_ACCESS", "IMPORTED_UNVERIFIED"],
  ["hollow-frequency", "Hollow Frequency", 2023, "Glass Hours", "Horror", "DIGITAL_ONLY", "PURCHASED", "VERIFIED_PROVIDER"],
  ["paper-kingdoms", "Paper Kingdoms", 2019, "Folded Fox", "Puzzle", "PHYSICAL_AVAILABLE", "PURCHASED", "VERIFIED_PROVIDER"],
] as const;

async function main() {
  const user = await db.user.upsert({ where: { email: "demo@forevergames.local" }, update: {}, create: { email: "demo@forevergames.local", displayName: "Demo Collector", region: "US" } });
  for (const type of ["TERMS", "PRIVACY", "AGE_18"]) await db.consent.upsert({ where: { userId_type_version: { userId: user.id, type, version: "2026-07-13.1" } }, update: { accepted: true }, create: { userId: user.id, type, version: "2026-07-13.1", accepted: true } });
  const accountHash = createHash("sha256").update("synthetic-steam-001").digest("hex");
  const connection = await db.providerConnection.upsert({ where: { provider_externalAccountHash: { provider: ProviderCode.MOCK_STEAM, externalAccountHash: accountHash } }, update: { status: ConnectionStatus.CONNECTED, lastSyncedAt: new Date() }, create: { userId: user.id, provider: ProviderCode.MOCK_STEAM, externalAccountHash: accountHash, status: ConnectionStatus.CONNECTED, capabilities: ["AUTHENTICATE", "PROFILE_READ", "LIBRARY_READ", "PLAYTIME_READ"], lastSyncedAt: new Date() } });
  for (const [slug, title, year, publisher, genre, physical, access, verification] of catalog) {
    const game = await db.catalogGame.upsert({ where: { slug }, update: { title, releaseYear: year, publisher, genre }, create: { slug, title, releaseYear: year, publisher, genre, description: `Synthetic licensed-catalog fixture for ${title}.` } });
    const release = await db.catalogRelease.upsert({ where: { gameId_platform_region_edition: { gameId: game.id, platform: "PC", region: "GLOBAL", edition: "DIGITAL" } }, update: { physicalStatus: physical as PhysicalStatus }, create: { gameId: game.id, platform: "PC", physicalStatus: physical as PhysicalStatus, source: "MOCK_LICENSED_CATALOG", sourceRights: "SYNTHETIC_LOCAL_ONLY" } });
    await db.productMapping.upsert({ where: { provider_externalProductId: { provider: ProviderCode.MOCK_STEAM, externalProductId: `mock-${slug}` } }, update: { releaseId: release.id }, create: { provider: ProviderCode.MOCK_STEAM, externalProductId: `mock-${slug}`, releaseId: release.id, status: "AUTO_MATCHED", confidence: 1, method: "SYNTHETIC_EXACT_ID" } });
    await db.entitlement.upsert({ where: { connectionId_externalProductId_accessType: { connectionId: connection.id, externalProductId: `mock-${slug}`, accessType: access as AccessType } }, update: { releaseId: release.id, lastSeenAt: new Date() }, create: { connectionId: connection.id, externalProductId: `mock-${slug}`, releaseId: release.id, accessType: access as AccessType, verification: verification as VerificationLevel, sourcePayloadHash: createHash("sha256").update(slug).digest("hex") } });
    if (slug === "signal-below") await db.reservation.upsert({ where: { userId_releaseId_editionType: { userId: user.id, releaseId: release.id, editionType: "STANDARD" } }, update: {}, create: { userId: user.id, releaseId: release.id, editionType: "STANDARD", targetPriceBand: "USD_30_39", shippingCountry: "US", platformPreference: "PC", disclosureVersion: "2026-07-13.1", history: { create: { action: "CREATED", snapshot: { source: "seed" } } } } });
  }
  const existingRun = await db.syncRun.findFirst({ where: { connectionId: connection.id, status: SyncStatus.SUCCEEDED } });
  if (!existingRun) await db.syncRun.create({ data: { connectionId: connection.id, status: SyncStatus.SUCCEEDED, imported: catalog.length, mapped: catalog.length, unmatched: 0, attempt: 1, startedAt: new Date(Date.now() - 284), completedAt: new Date() } });
}
main().then(() => console.log("Seeded local Forever Games data.")).finally(() => db.$disconnect());
