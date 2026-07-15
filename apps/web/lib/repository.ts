/* eslint-disable prefer-const */
import { db } from "@forever-games/db";
import { games as fallbackGames, type Game } from "./demo-data";
import { currentUser } from "./session";
import { config } from "./config";

function fallbackAllowed(){return config().ENABLE_SYNTHETIC_FALLBACK}

async function portalEmail(){return (await currentUser())?.email??"__unauthenticated__"}
export type PortalSource = "database" | "synthetic-fallback";

export async function getLibrary(): Promise<{ games: Game[]; source: PortalSource }> {
  try {
    const email=await portalEmail();
    const records = await db.catalogGame.findMany({
      where: { releases: { some: { entitlements: { some: { connection: { user: { email } }, status: "ACTIVE" } } } } },
      include: { releases: { include: { entitlements: { where: { connection: { user: { email } } }, include: { connection: true, evidence: true } }, reservations: { where: { user: { email }, status: "ACTIVE" } } } } },
      orderBy: { title: "asc" },
    });
    const games = records.map((record): Game => {
      const releases = record.releases.filter((release) => release.entitlements.length > 0);
      const allEntitlements = releases.flatMap((release) => release.entitlements.map(entitlement=>({entitlement,release})));const entitlement = allEntitlements.sort((a,b)=>a.entitlement.verification==="VERIFIED_PROVIDER"?-1:b.entitlement.verification==="VERIFIED_PROVIDER"?1:a.entitlement.verification==="VERIFIED_EVIDENCE"?-1:1)[0]?.entitlement;
      const fallback = fallbackGames.find((game) => game.slug === record.slug);
      return {
        slug: record.slug, title: record.title, year: record.releaseYear ?? 0, publisher: record.publisher ?? "Unknown publisher", developer: record.developer??undefined,
        platforms: [...new Set(releases.map((release) => release.platform))], genre: record.genre ?? "Unknown",
        access: entitlement?.accessType === "SUBSCRIPTION_ACCESS" ? "SUBSCRIPTION_ACCESS" : "PURCHASED",
        verified: entitlement?.verification === "VERIFIED_PROVIDER" || entitlement?.verification === "VERIFIED_EVIDENCE", verification: entitlement?.verification,
        accessSource: entitlement?.connection.provider.endsWith("_EVIDENCE") ? `${entitlement.connection.provider.replace("_EVIDENCE","").replaceAll("_"," ")} order evidence` : entitlement?.connection.provider === "STEAM" ? "Steam" : entitlement?.connection.provider.replaceAll("_"," "),
        accessFreshness: entitlement?.connection.provider.endsWith("_EVIDENCE") ? `Imported ${entitlement.firstSeenAt.toLocaleDateString()}` : `Last seen ${entitlement?.lastSeenAt.toLocaleDateString()}`,
        metadataSource: record.metadataSource ?? undefined,
        entitlements: allEntitlements.map(({entitlement:item,release})=>({provider:item.connection.provider,platform:release.platform,access:item.accessType,verification:item.verification,status:item.status,firstSeen:item.firstSeenAt.toISOString(),lastSeen:item.lastSeenAt.toISOString(),evidenceStatus:item.evidence?.validationStatus})),
        physical: releases[0]?.physicalStatus ?? "UNKNOWN", reserved: releases.some((release) => release.reservations.length > 0),
        cover: record.imageUrl ? `linear-gradient(transparent 45%,rgba(4,8,18,.5)),url("${record.imageUrl.replaceAll('"','%22')}")` : record.slug.startsWith("steam-") ? `linear-gradient(transparent 45%,rgba(4,8,18,.78)),url("/api/v1/assets/steam/${record.slug.slice(6)}")` : fallback?.cover ?? "linear-gradient(145deg,#25314d,#63708a)", description: record.description ?? fallback?.description ?? "Catalog details pending.",
      };
    });
    return { games, source: "database" };
  } catch (error) { if(!fallbackAllowed())throw error;return { games: fallbackGames, source: "synthetic-fallback" }; }
}

export async function getGame(slug:string){const library=await getLibrary();const game=library.games.find(item=>item.slug===slug);let demand={total:0,providerVerified:0,evidenceVerified:0,unverified:0,suppressed:true,asOf:new Date().toISOString()};try{const rows=await db.reservation.findMany({where:{status:"ACTIVE",release:{game:{slug}}},include:{user:{include:{connections:{include:{entitlements:{where:{release:{game:{slug}},status:"ACTIVE"}}}}}}}});for(const row of rows){const levels=row.user.connections.flatMap(connection=>connection.entitlements.map(item=>item.verification));if(levels.includes("VERIFIED_PROVIDER"))demand.providerVerified++;else if(levels.includes("VERIFIED_EVIDENCE"))demand.evidenceVerified++;else demand.unverified++}demand.total=rows.length;demand.suppressed=rows.length<Number(process.env.PUBLIC_DEMAND_MIN_CELL??3)}catch{}return{game,source:library.source,demand}}

export async function getDashboard() {
  const library = await getLibrary();
  const verified = library.games.filter((game) => game.verified).length;
  return { source: library.source, total: library.games.length, verified, verifiedPercent: library.games.length ? Math.round(verified / library.games.length * 100) : 0, digitalOnly: library.games.filter((game) => game.physical === "DIGITAL_ONLY").length, reserved: library.games.filter((game) => game.reserved).length, subscription: library.games.filter((game) => game.access === "SUBSCRIPTION_ACCESS").length };
}

export async function getReservations() {
  try { const email=await portalEmail();const rows=await db.reservation.findMany({where:{user:{email}},include:{release:{include:{game:true}}},orderBy:{updatedAt:"desc"}});return{source:"database" as PortalSource,rows:rows.map(row=>({slug:row.release.game.slug,title:row.release.game.title,edition:row.editionType,price:row.targetPriceBand,region:row.shippingCountry,status:row.status}))}; }
  catch (error) { if(!fallbackAllowed())throw error;return {source:"synthetic-fallback" as PortalSource,rows:[{slug:"signal-below",title:"Signal Below",edition:"STANDARD",price:"USD_30_39",region:"US",status:"ACTIVE"}]}; }
}

export async function getOperations() {
  try { const [users,runs,unmatched,reservations,audits]=await Promise.all([db.user.count({where:{status:"ACTIVE"}}),db.syncRun.findMany({include:{connection:true},orderBy:{completedAt:"desc"},take:5}),db.productMapping.count({where:{status:{in:["AMBIGUOUS","UNMATCHED"]}}}),db.reservation.count({where:{status:"ACTIVE"}}),db.auditLog.findMany({orderBy:{createdAt:"desc"},take:5})]);return{source:"database" as PortalSource,users,runs,unmatched,reservations,audits}; }
  catch (error) { if(!fallbackAllowed())throw error;return {source:"synthetic-fallback" as PortalSource,users:1,runs:[],unmatched:0,reservations:1,audits:[]}; }
}

type DemandBucket={label:string;count:number};
export type DemandInsights={asOf:string;active:number;uniqueMembers:number;providerVerified:number;evidenceVerified:number;unverified:number;last7Days:number;previous7Days:number;momentumPercent:number|null;games:Array<DemandBucket&{slug:string;platform:string;providerVerified:number;evidenceVerified:number;unverified:number}>;platforms:DemandBucket[];editions:DemandBucket[];prices:DemandBucket[];regions:DemandBucket[];partnershipVotes:DemandBucket[]};
export async function getDemandInsights():Promise<DemandInsights>{const empty={asOf:new Date().toISOString(),active:0,uniqueMembers:0,providerVerified:0,evidenceVerified:0,unverified:0,last7Days:0,previous7Days:0,momentumPercent:null,games:[],platforms:[],editions:[],prices:[],regions:[],partnershipVotes:[]};try{const [reservations,votes]=await Promise.all([db.reservation.findMany({where:{status:"ACTIVE"},include:{release:{include:{game:true}},user:{include:{connections:{include:{entitlements:{where:{status:"ACTIVE"}}}}}}},orderBy:{updatedAt:"desc"}}),db.partnershipVote.groupBy({by:["provider"],_count:{_all:true},orderBy:{_count:{provider:"desc"}}})]);const now=Date.now(),week=7*24*60*60*1000;const countMap=(map:Map<string,number>,label:string)=>map.set(label,(map.get(label)??0)+1);const platforms=new Map<string,number>(),editions=new Map<string,number>(),prices=new Map<string,number>(),regions=new Map<string,number>(),games=new Map<string,{label:string;slug:string;platform:string;count:number;providerVerified:number;evidenceVerified:number;unverified:number}>();let providerVerified=0,evidenceVerified=0,unverified=0,last7Days=0,previous7Days=0;for(const row of reservations){const levels=row.user.connections.flatMap(connection=>connection.entitlements.filter(item=>item.releaseId===row.releaseId).map(item=>item.verification));const tier=levels.includes("VERIFIED_PROVIDER")?"providerVerified":levels.includes("VERIFIED_EVIDENCE")?"evidenceVerified":"unverified";if(tier==="providerVerified")providerVerified++;else if(tier==="evidenceVerified")evidenceVerified++;else unverified++;const game=games.get(row.release.game.slug)??{label:row.release.game.title,slug:row.release.game.slug,platform:row.release.platform,count:0,providerVerified:0,evidenceVerified:0,unverified:0};game.count++;game[tier]++;games.set(row.release.game.slug,game);countMap(platforms,row.platformPreference||row.release.platform);countMap(editions,row.editionType);countMap(prices,row.targetPriceBand);countMap(regions,row.shippingCountry);const age=now-row.updatedAt.getTime();if(age<=week)last7Days++;else if(age<=2*week)previous7Days++}const buckets=(map:Map<string,number>)=>[...map.entries()].map(([label,count])=>({label,count})).sort((a,b)=>b.count-a.count);return{asOf:new Date().toISOString(),active:reservations.length,uniqueMembers:new Set(reservations.map(row=>row.userId)).size,providerVerified,evidenceVerified,unverified,last7Days,previous7Days,momentumPercent:previous7Days?Math.round((last7Days-previous7Days)/previous7Days*100):last7Days?100:null,games:[...games.values()].sort((a,b)=>b.count-a.count).slice(0,10),platforms:buckets(platforms),editions:buckets(editions),prices:buckets(prices),regions:buckets(regions),partnershipVotes:votes.map(row=>({label:row.provider,count:row._count._all}))}}catch{return empty}}

export async function databaseStatus() { try { await db.$queryRaw`SELECT 1`; return "connected" as const; } catch { return "unavailable" as const; } }
