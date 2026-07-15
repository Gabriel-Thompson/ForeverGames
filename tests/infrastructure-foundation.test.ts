import {describe,expect,it} from "vitest";
import {readFileSync} from "node:fs";

const read=(file:string)=>readFileSync(file,"utf8");
describe("Azure foundation",()=>{
  const main=read("infra/main.bicep");
  const postgres=read("infra/modules/postgresql.bicep");
  const vault=read("infra/modules/key-vault.bicep");
  const app=read("infra/modules/container-app.bicep");
  it("keeps data services private",()=>{expect(postgres).toMatch(/publicNetworkAccess:\s*'Disabled'/);expect(vault).toMatch(/publicNetworkAccess:\s*'Disabled'/)});
  it("uses immutable image input and controlled app bootstrap",()=>{expect(main).toContain("param imageTag string");expect(main).toMatch(/param deployApplication bool\s*=\s*false/)});
  it("uses managed identities, Key Vault references, and safe probes",()=>{expect(app).toContain("SystemAssigned, UserAssigned");expect(app).toContain("keyVaultUrl");expect(app).toContain("/health/live");expect(app).toContain("/health/ready")});
  it("disables unsafe production features",()=>{expect(app).toContain("ENABLE_SYNTHETIC_FALLBACK");expect(app).toContain("ENABLE_EVIDENCE_UPLOADS");expect(app.match(/value:\s*'false'/g)?.length??0).toBeGreaterThanOrEqual(3)});
});
