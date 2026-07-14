import { mkdirSync, writeFileSync } from "node:fs";
import { delimiter, join, resolve } from "node:path";
import { spawnSync } from "node:child_process";

const root = resolve(import.meta.dirname, "..");
try { process.loadEnvFile(join(root, ".env.local")); } catch { /* Commands may provide DATABASE_URL directly. */ }
const tools = join(root, ".tools");
mkdirSync(tools, { recursive: true });
writeFileSync(join(tools, "pnpm.cmd"), "@echo off\r\ncorepack pnpm %*\r\n");

const prisma = join(root, "node_modules", ".bin", process.platform === "win32" ? "prisma.cmd" : "prisma");
const args = [...process.argv.slice(2), "--schema", join(root, "packages", "db", "prisma", "schema.prisma")];
const result = spawnSync(prisma, args, {
  cwd: root,
  stdio: "inherit",
  shell: process.platform === "win32",
  env: { ...process.env, PATH: `${tools}${delimiter}${process.env.PATH ?? ""}` },
});
if (result.error) console.error(result.error);
process.exit(result.status ?? 1);
