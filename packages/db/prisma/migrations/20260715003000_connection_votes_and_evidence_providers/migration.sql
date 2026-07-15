ALTER TYPE "ProviderCode" ADD VALUE 'PLAYSTATION_EVIDENCE';
ALTER TYPE "ProviderCode" ADD VALUE 'NINTENDO_EVIDENCE';
ALTER TYPE "ProviderCode" ADD VALUE 'EPIC_EVIDENCE';
ALTER TYPE "ProviderCode" ADD VALUE 'GOG_EVIDENCE';

CREATE TABLE "PartnershipVote" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "provider" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "PartnershipVote_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "PartnershipVote_userId_provider_key" ON "PartnershipVote"("userId", "provider");
CREATE INDEX "PartnershipVote_provider_idx" ON "PartnershipVote"("provider");
ALTER TABLE "PartnershipVote" ADD CONSTRAINT "PartnershipVote_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
