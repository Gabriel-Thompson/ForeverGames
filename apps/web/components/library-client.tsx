"use client";
import { useMemo, useState } from "react";
import { Download, Grid2X2, Search } from "lucide-react";
import { GameCard } from "@/components/game-card";
import type { Game } from "@/lib/demo-data";

export function LibraryClient({ games }: { games: Game[] }) {
  const [query, setQuery] = useState("");
  const [access, setAccess] = useState("ALL");
  const shown = useMemo(() => games.filter((game) => game.title.toLowerCase().includes(query.toLowerCase()) && (access === "ALL" || game.access === access)), [games, query, access]);
  function exportLibrary() {
    const safe = (value: string) => /^[=+\-@\t\r]/.test(value) ? `'${value}` : value;
    const rows = ["title,year,publisher,platforms,access,verification,source", ...games.map((game) => `"${safe(game.title)}",${game.year},"${safe(game.publisher)}","${game.platforms.join("|")}",${game.access},${game.verified ? "VERIFIED_PROVIDER" : "IMPORTED_UNVERIFIED"},LOCAL_PORTAL`)];
    const link = document.createElement("a");
    link.href = URL.createObjectURL(new Blob([rows.join("\n")], { type: "text/csv" }));
    link.download = "forever-games-library.csv";
    link.click();
    URL.revokeObjectURL(link.href);
  }
  return <><div className="toolbar"><label style={{ position: "relative" }}><span className="skip">Search library</span><Search size={16} style={{ position: "absolute", left: 13, top: 14, color: "#63708a" }}/><input className="search" style={{ paddingLeft: 38 }} placeholder="Search titles…" value={query} onChange={(event) => setQuery(event.target.value)}/></label><select className="select" aria-label="Access type" value={access} onChange={(event) => setAccess(event.target.value)}><option value="ALL">All access types</option><option value="PURCHASED">Purchased</option><option value="SUBSCRIPTION_ACCESS">Subscription access</option></select><select className="select" aria-label="Provider"><option>All providers</option><option>Mock Steam</option><option>Manual import</option></select><button className="btn btn-secondary" title="Export CSV" onClick={exportLibrary}><Download size={16}/>Export</button><button className="btn btn-secondary" title="Grid view"><Grid2X2 size={16}/></button></div>{shown.length ? <div className="game-grid">{shown.map((game) => <GameCard key={game.slug} game={game}/>)}</div> : <div className="panel"><h2>No games found</h2><p>Try changing your search or filters. Unmatched imported items are never hidden automatically.</p></div>}</>;
}
