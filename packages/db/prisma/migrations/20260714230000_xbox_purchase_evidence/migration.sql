ALTER TYPE "ProviderCode" ADD VALUE 'XBOX_EVIDENCE';

CREATE TABLE "PurchaseEvidence" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "entitlementId" TEXT NOT NULL,
    "provider" "ProviderCode" NOT NULL,
    "originalName" TEXT NOT NULL,
    "mimeType" TEXT NOT NULL,
    "fileSize" INTEGER NOT NULL,
    "documentHash" TEXT NOT NULL,
    "orderReference" TEXT,
    "purchaseDate" TIMESTAMP(3),
    "importedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "PurchaseEvidence_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "PurchaseEvidence_entitlementId_key" ON "PurchaseEvidence"("entitlementId");
CREATE INDEX "PurchaseEvidence_userId_importedAt_idx" ON "PurchaseEvidence"("userId", "importedAt");
CREATE UNIQUE INDEX "PurchaseEvidence_userId_documentHash_key" ON "PurchaseEvidence"("userId", "documentHash");
ALTER TABLE "PurchaseEvidence" ADD CONSTRAINT "PurchaseEvidence_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "PurchaseEvidence" ADD CONSTRAINT "PurchaseEvidence_entitlementId_fkey" FOREIGN KEY ("entitlementId") REFERENCES "Entitlement"("id") ON DELETE CASCADE ON UPDATE CASCADE;
