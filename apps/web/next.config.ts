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
  experimental: { optimizePackageImports: ["lucide-react"] },
  poweredByHeader: false,
  async headers() {
    return [{ source: "/(.*)", headers: [
      { key: "X-Content-Type-Options", value: "nosniff" },
      { key: "Referrer-Policy", value: "strict-origin-when-cross-origin" },
      { key: "Permissions-Policy", value: "camera=(), microphone=(), geolocation=()" },
      { key: "Content-Security-Policy", value: "default-src 'self'; img-src 'self' data:; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; connect-src 'self'" }
    ] }];
  }
};
export default config;
