import {mkdir,readFile,unlink,writeFile} from "node:fs/promises";
import path from "node:path";
import {config} from "./config";

const root=path.resolve(process.cwd(),"..","..",".data","evidence");
const validRef=(ref:string)=>/^[a-zA-Z0-9_-]+\.pdf$/.test(ref);

export async function saveEvidence(id:string,bytes:Buffer){
  if(!config().ENABLE_EVIDENCE_UPLOADS)throw new Error("Evidence uploads are disabled in this environment");
  await mkdir(root,{recursive:true});
  const file=`${id}.pdf`;
  await writeFile(path.join(root,file),bytes,{flag:"wx"});
  return file;
}
export async function readEvidence(ref:string){if(!validRef(ref))throw new Error("INVALID_EVIDENCE_REF");return readFile(path.join(root,ref))}
export async function deleteEvidence(ref:string){if(!validRef(ref))return;await unlink(path.join(root,ref)).catch(()=>undefined)}
