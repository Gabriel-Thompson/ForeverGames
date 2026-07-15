import {mkdir,readFile,unlink} from "node:fs/promises";import path from "node:path";
const root=path.resolve(process.cwd(),"..","..",".data","evidence");
export async function saveEvidence(id:string,bytes:Buffer){await mkdir(root,{recursive:true});const file=`${id}.pdf`;await import("node:fs/promises").then(fs=>fs.writeFile(path.join(root,file),bytes,{flag:"wx"}));return file}
export async function readEvidence(ref:string){if(!/^[a-zA-Z0-9_-]+\.pdf$/.test(ref))throw new Error("INVALID_EVIDENCE_REF");return readFile(path.join(root,ref))}
export async function deleteEvidence(ref:string){if(!/^[a-zA-Z0-9_-]+\.pdf$/.test(ref))return;await unlink(path.join(root,ref)).catch(()=>undefined)}
