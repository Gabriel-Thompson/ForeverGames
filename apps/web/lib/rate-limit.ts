type Entry={count:number;resetAt:number};const buckets=new Map<string,Entry>();
export type RateLimitResult={allowed:boolean;limit:number;remaining:number;resetAt:number};
export function checkRateLimit(key:string,limit:number,windowMs=Number(process.env.RATE_LIMIT_WINDOW_MS??60000),now=Date.now()):RateLimitResult{const current=buckets.get(key);const entry=!current||current.resetAt<=now?{count:0,resetAt:now+windowMs}:current;entry.count++;buckets.set(key,entry);return{allowed:entry.count<=limit,limit,remaining:Math.max(0,limit-entry.count),resetAt:entry.resetAt}}
export function clearRateLimits(){buckets.clear()}
// This process-local limiter is a low-cost first line of defense only. It is not global across Container Apps replicas.
