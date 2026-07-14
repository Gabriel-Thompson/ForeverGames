import {NextResponse} from "next/server";
export function GET(){return NextResponse.json({status:"ok",environment:process.env.APP_ENV??"local",providers:{mockSteam:"available",steam:process.env.ENABLE_REAL_STEAM==="true"?"configured":"disabled"},checkout:"disabled",time:new Date().toISOString()})}

