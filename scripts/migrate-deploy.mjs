import {spawnSync} from "node:child_process";import {resolve} from "node:path";
if(!process.env.DIRECT_URL){console.error("DIRECT_URL is required for controlled production migrations.");process.exit(1)}
const script=resolve(import.meta.dirname,"run-prisma.mjs");const result=spawnSync(process.execPath,[script,"migrate","deploy"],{stdio:"inherit",env:{...process.env,DATABASE_URL:process.env.DIRECT_URL}});process.exit(result.status??1);
