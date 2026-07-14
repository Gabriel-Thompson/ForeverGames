import {describe,expect,it} from "vitest";import {csvSafe,demandTier} from "../packages/domain/src/index";
describe("credibility classification",()=>{it("counts only verified purchased access as a verified owner",()=>{expect(demandTier("VERIFIED_PROVIDER","PURCHASED")).toBe("VERIFIED_OWNER");expect(demandTier("VERIFIED_PROVIDER","SUBSCRIPTION_ACCESS")).toBe("SELF_REPORTED")});it("protects CSV exports from formulas",()=>{expect(csvSafe("=IMPORTXML()" )).toBe("'=IMPORTXML()");expect(csvSafe("Signal Below")).toBe("Signal Below")})});

