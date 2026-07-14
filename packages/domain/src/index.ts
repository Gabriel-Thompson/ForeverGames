export const RESERVATION_DISCLOSURE_VERSION="2026-07-13.1";
export type CredibilityTier="VERIFIED_OWNER"|"VERIFIED_EVIDENCE"|"IMPORTED_UNVERIFIED"|"SELF_REPORTED";
export function demandTier(verification:string,access:string):CredibilityTier{if(verification==="VERIFIED_PROVIDER"&&access==="PURCHASED")return "VERIFIED_OWNER";if(verification==="VERIFIED_EVIDENCE")return "VERIFIED_EVIDENCE";if(verification==="IMPORTED_UNVERIFIED")return "IMPORTED_UNVERIFIED";return "SELF_REPORTED"}
export function csvSafe(value:string){return /^[=+\-@\t\r]/.test(value)?`'${value}`:value}

