import {NextRequest,NextResponse} from "next/server";
const protectedPrefixes=["/library","/connections","/legacy","/reservations","/settings","/games","/admin"];
export function middleware(request:NextRequest){if(protectedPrefixes.some(prefix=>request.nextUrl.pathname===prefix||request.nextUrl.pathname.startsWith(`${prefix}/`))&&!request.cookies.has("fg_session")){const url=new URL("/sign-in",request.url);url.searchParams.set("next",request.nextUrl.pathname);return NextResponse.redirect(url)}return NextResponse.next()}
export const config={matcher:["/library/:path*","/connections/:path*","/legacy/:path*","/reservations/:path*","/settings/:path*","/games/:path*","/admin/:path*"]};
