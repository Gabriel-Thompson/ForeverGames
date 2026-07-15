import { PrismaClient } from "../generated/client-v3/client";
process.env.DIRECT_URL ??= process.env.DATABASE_URL;

const globalForDb = globalThis as unknown as { foreverGamesDb?: PrismaClient };
export const db = globalForDb.foreverGamesDb ?? new PrismaClient();
if (process.env.NODE_ENV !== "production") globalForDb.foreverGamesDb = db;
export * from "../generated/client-v3/enums";
