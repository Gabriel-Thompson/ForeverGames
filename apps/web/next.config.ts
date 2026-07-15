import type { NextConfig } from "next";
import { resolve } from "node:path";

// Next runs from apps/web, while local secrets intentionally live at the
// repository root. Load them before server modules initialize Prisma.
try {
  process.loadEnvFile(resolve(process.cwd(), "../../.env.local"));
} catch {
  // CI and deployed environments provide variables through the process.
}

const config: NextConfig = {
  output: "standalone",
  outputFileTracingRoot: resolve(process.cwd(), "../.."),
  experimental: { optimizePackageImports: ["lucide-react"] },
  poweredByHeader: false,
};
export default config;
