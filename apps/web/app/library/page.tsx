import {PortalShell} from "@/components/shell";import {LibraryClient} from "@/components/library-client";import {getLibrary} from "@/lib/repository";
export const dynamic="force-dynamic";
export default async function LibraryPage(){const {games,source}=await getLibrary();return <PortalShell><div className="pagehead"><div><h1>Your library</h1><p>{games.length} canonical games · {source==="database"?"persisted PostgreSQL data":"synthetic fallback (database unavailable)"}</p></div><span className={`badge ${source==="database"?"verified":"digital"}`}>{source==="database"?"● Database connected":"Fallback mode"}</span></div><LibraryClient games={games}/></PortalShell>}

