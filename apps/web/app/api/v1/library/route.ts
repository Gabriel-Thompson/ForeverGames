import {NextResponse} from "next/server";import {getLibrary} from "@/lib/repository";
export async function GET(){return NextResponse.json(await getLibrary())}

