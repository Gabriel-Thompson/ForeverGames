CREATE TYPE "UserRole" AS ENUM ('MEMBER', 'SUPPORT', 'CURATOR', 'ANALYST', 'ADMIN');
CREATE TYPE "EvidenceValidationStatus" AS ENUM ('PENDING_REVIEW', 'APPROVED', 'REJECTED');
ALTER TABLE "User" ADD COLUMN "role" "UserRole" NOT NULL DEFAULT 'MEMBER';
ALTER TABLE "PurchaseEvidence" ADD COLUMN "validationStatus" "EvidenceValidationStatus" NOT NULL DEFAULT 'PENDING_REVIEW',
ADD COLUMN "storageRef" TEXT NOT NULL DEFAULT '',
ADD COLUMN "reviewedBy" TEXT,
ADD COLUMN "reviewedAt" TIMESTAMP(3),
ADD COLUMN "reviewNotes" TEXT;

-- Preserve access to the local operations console for the first-created local account.
UPDATE "User" SET "role" = 'ADMIN' WHERE "id" = (SELECT "id" FROM "User" ORDER BY "createdAt" ASC LIMIT 1);

-- Existing evidence was not reviewed by the application and must not remain verified.
UPDATE "Entitlement" SET "verification" = 'IMPORTED_UNVERIFIED'
WHERE "id" IN (SELECT "entitlementId" FROM "PurchaseEvidence");
