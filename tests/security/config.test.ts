import {describe,expect,it} from "vitest";import {readFileSync} from "node:fs";
describe("secret hygiene",()=>{it("ignores local environment files",()=>{const ignore=readFileSync(".gitignore","utf8");expect(ignore).toContain(".env.local")});it("does not ship enabled checkout",()=>{const example=readFileSync(".env.example","utf8");expect(example).toContain("ENABLE_CHECKOUT=false")})});

