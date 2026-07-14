import { db } from "@forever-games/db";
import { games as fallbackGames, type Game } from "./demo-data";
import { currentUser } from "./session";

async function portalEmail(){return (await currentUser())?.email??"__unauthenticated__"}
export type PortalSource = "database" | "synthetic-fallback";

export async function getLibrary(): Promise<{ games: Game[]; source: PortalSource }> {
  try {
    const email=await portalEmail();
    const records = await db.catalogGame.findMany({
      where: { releases: { some: { entitlements: { some: { connection: { user: { email } }, status: "ACTIVE" } } } } },
      include: { releases: { include: { entitlements: { where: { connection: { user: { email } } }, include: { connection: true } }, reservations: { where: { user: { email }, status: "ACTIVE" } } } } },
      orderBy: { title: "asc" },
    });
    const games = records.map((record): Game => {
      const releases = record.releases.filter((release) => release.entitlements.length > 0);
      const entitlement = releases.flatMap((release) => release.entitlements)[0];
      const fallback = fallbackGames.find((game) => game.slug === record.slug);
      return {
        slug: record.slug, title: record.title, year: record.releaseYear ?? 0, publisher: record.publisher ?? "Unknown publisher",
        platforms: [...new Set(releases.map((release) => release.platform))], genre: record.genre ?? "Unknown",
        access: entitlement?.accessType === "SUBSCRIPTION_ACCESS" ? "SUBSCRIPTION_ACCESS" : "PURCHASED",
        verified: entitlement?.verification === "VERIFIED_PROVIDER" || entitlement?.verification === "VERIFIED_EVIDENCE",
        physical: releases[0]?.physicalStatus ?? "UNKNOWN", reserved: releases.some((release) => release.reservations.length > 0),
        cover: record.slug.startsWith("steam-") ? `linear-gradient(transparent 45%,rgba(4,8,18,.78)),url("/api/v1/assets/steam/${record.slug.slice(6)}")` : fallback?.cover ?? "linear-gradient(145deg,#25314d,#63708a)", description: record.description ?? fallback?.description ?? "Catalog details pending.",
      };
    });
    return { games, source: "database" };
  } catch { return { games: fallbackGames, source: "synthetic-fallback" }; }
}

export async function getGame(slug: string) { const library = await getLibrary(); return { game: library.games.find((game) => game.slug === slug), source: library.source }; }

export async function getDashboard() {
  const library = await getLibrary();
  const verified = library.games.filter((game) => game.verified).length;
  return { source: library.source, total: library.games.length, verified, verifiedPercent: library.games.length ? Math.round(verified / library.games.length * 100) : 0, digitalOnly: library.games.filter((game) => game.physical === "DIGITAL_ONLY").length, reserved: library.games.filter((game) => game.reserved).length, subscription: library.games.filter((game) => game.access === "SUBSCRIPTION_ACCESS").length };
}

export async function getReservations() {
  try { const email=await portalEmail();const rows=await db.reservation.findMany({where:{user:{email}},include:{release:{include:{game:true}}},orderBy:{updatedAt:"desc"}});return{source:"database" as PortalSource,rows:rows.map(row=>({slug:row.release.game.slug,title:row.release.game.title,edition:row.editionType,price:row.targetPriceBand,region:row.shippingCountry,status:row.status}))}; }
  catch { return {source:"synthetic-fallback" as PortalSource,rows:[{slug:"signal-below",title:"Signal Below",edition:"STANDARD",price:"USD_30_39",region:"US",status:"ACTIVE"}]}; }
}

export async function getOperations() {
  try { const [users,runs,unmatched,reservations,audits]=await Promise.all([db.user.count({where:{status:"ACTIVE"}}),db.syncRun.findMany({include:{connection:true},orderBy:{completedAt:"desc"},take:5}),db.productMapping.count({where:{status:{in:["AMBIGUOUS","UNMATCHED"]}}}),db.reservation.count({where:{status:"ACTIVE"}}),db.auditLog.findMany({orderBy:{createdAt:"desc"},take:5})]);return{source:"database" as PortalSource,users,runs,unmatched,reservations,audits}; }
  catch { return {source:"synthetic-fallback" as PortalSource,users:1,runs:[],unmatched:0,reservations:1,audits:[]}; }
}

export async function databaseStatus() { try { await db.$queryRaw`SELECT 1`; return "connected" as const; } catch { return "unavailable" as const; } }
