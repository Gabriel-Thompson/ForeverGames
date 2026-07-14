import {describe,expect,it} from "vitest";import {MockSteamConnector} from "../../packages/connectors/src/index";
describe("mock connector contract",()=>{it("reports only supported capabilities and idempotent fixtures",async()=>{const connector=new MockSteamConnector();expect(connector.capabilities()).toContain("LIBRARY_READ");expect(await connector.syncEntitlements("same")).toEqual(await connector.syncEntitlements("same"))})});

