import {NextResponse} from "next/server";
import {db} from "@forever-games/db";
import {requireUser} from "@/lib/session";
import {findXboxMetadata,openXblConfigured} from "@/lib/openxbl";

export async function POST(_:Request,{params}:{params:Promise<{id:string}>}){
  try{
    const user=await requireUser();
    if(!openXblConfigured())return NextResponse.json({error:"OpenXBL access is pending. Add OPENXBL_API_KEY to .env.local after approval."},{status:503});
    const {id}=await params;
    const evidence=await db.purchaseEvidence.findFirst({
      where:{id,userId:user.id},
      include:{entitlement:{include:{release:{include:{game:true}}}}},
    });
    const game=evidence?.entitlement.release?.game;
    if(!game)return NextResponse.json({error:"Evidence item not found."},{status:404});
    if(evidence.provider!=="XBOX_EVIDENCE")return NextResponse.json({error:"OpenXBL enrichment is available only for Xbox evidence."},{status:400});
    const metadata=await findXboxMetadata(game.title);
    if(!metadata)return NextResponse.json({error:"No matching game was found in the currently listed OpenXBL marketplace categories."},{status:404});
    await db.catalogGame.update({where:{id:game.id},data:{title:metadata.title,description:metadata.description??game.description,publisher:metadata.publisher??game.publisher,developer:metadata.developer??game.developer,releaseYear:metadata.releaseYear??game.releaseYear,genre:metadata.genre??game.genre,imageUrl:metadata.imageUrl??game.imageUrl,metadataSource:"OPENXBL_MARKETPLACE",externalStoreId:metadata.productId}});
    return NextResponse.json({data:{title:metadata.title,imageFound:Boolean(metadata.imageUrl)}});
  }catch(error){console.error(error);return NextResponse.json({error:"OpenXBL metadata enrichment failed."},{status:502})}
}
