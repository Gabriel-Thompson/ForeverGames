import { PrismaClient } from "../generated/client/client";

const globalForDb = globalThis as unknown as { foreverGamesDb?: PrismaClient };
export const db = globalForDb.foreverGamesDb ?? new PrismaClient();
if (process.env.NODE_ENV !== "production") globalForDb.foreverGamesDb = db;
export * from "../generated/client/enums";

