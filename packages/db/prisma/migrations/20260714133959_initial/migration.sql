-- CreateEnum
CREATE TYPE "UserStatus" AS ENUM ('ACTIVE', 'SUSPENDED', 'DELETION_PENDING', 'DELETED');

-- CreateEnum
CREATE TYPE "ProviderCode" AS ENUM ('MOCK_STEAM', 'STEAM', 'MANUAL');

-- CreateEnum
CREATE TYPE "ConnectionStatus" AS ENUM ('PENDING', 'CONNECTED', 'BLOCKED_PRIVACY', 'EXPIRED', 'ERROR', 'DISCONNECTED');

-- CreateEnum
CREATE TYPE "SyncStatus" AS ENUM ('QUEUED', 'RUNNING', 'RETRY_WAIT', 'SUCCEEDED', 'PARTIAL', 'FAILED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "AccessType" AS ENUM ('PURCHASED', 'SUBSCRIPTION_ACCESS', 'FREE_ACCESS', 'IMPORTED', 'SELF_REPORTED', 'UNKNOWN');

-- CreateEnum
CREATE TYPE "VerificationLevel" AS ENUM ('VERIFIED_PROVIDER', 'VERIFIED_EVIDENCE', 'IMPORTED_UNVERIFIED', 'SELF_REPORTED');

-- CreateEnum
CREATE TYPE "EntitlementStatus" AS ENUM ('ACTIVE', 'NOT_SEEN', 'REMOVED_OR_INACCESSIBLE', 'DISPUTED');

-- CreateEnum
CREATE TYPE "MappingStatus" AS ENUM ('AUTO_MATCHED', 'APPROVED', 'AMBIGUOUS', 'UNMATCHED', 'REJECTED');

-- CreateEnum
CREATE TYPE "PhysicalStatus" AS ENUM ('PHYSICAL_AVAILABLE', 'DIGITAL_ONLY', 'LIMITED_PHYSICAL', 'UNKNOWN', 'PARTNER_APPROVED_FUTURE');

-- CreateEnum
CREATE TYPE "ReservationStatus" AS ENUM ('ACTIVE', 'CANCELLED', 'CONVERTED_TO_OFFER', 'EXPIRED');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "displayName" TEXT NOT NULL,
    "region" TEXT NOT NULL,
    "status" "UserStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Consent" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "version" TEXT NOT NULL,
    "accepted" BOOLEAN NOT NULL,
    "acceptedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Consent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProviderConnection" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "provider" "ProviderCode" NOT NULL,
    "externalAccountHash" TEXT NOT NULL,
    "status" "ConnectionStatus" NOT NULL DEFAULT 'PENDING',
    "capabilities" TEXT[],
    "credentialCiphertext" TEXT,
    "lastSyncedAt" TIMESTAMP(3),

    CONSTRAINT "ProviderConnection_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SyncRun" (
    "id" TEXT NOT NULL,
    "connectionId" TEXT NOT NULL,
    "status" "SyncStatus" NOT NULL DEFAULT 'QUEUED',
    "cursor" TEXT,
    "imported" INTEGER NOT NULL DEFAULT 0,
    "mapped" INTEGER NOT NULL DEFAULT 0,
    "unmatched" INTEGER NOT NULL DEFAULT 0,
    "attempt" INTEGER NOT NULL DEFAULT 0,
    "startedAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),

    CONSTRAINT "SyncRun_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CatalogGame" (
    "id" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "publisher" TEXT,
    "developer" TEXT,
    "releaseYear" INTEGER,
    "genre" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "CatalogGame_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CatalogRelease" (
    "id" TEXT NOT NULL,
    "gameId" TEXT NOT NULL,
    "platform" TEXT NOT NULL,
    "region" TEXT NOT NULL DEFAULT 'GLOBAL',
    "edition" TEXT NOT NULL DEFAULT 'DIGITAL',
    "physicalStatus" "PhysicalStatus" NOT NULL DEFAULT 'UNKNOWN',
    "source" TEXT NOT NULL,
    "sourceRights" TEXT NOT NULL,

    CONSTRAINT "CatalogRelease_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProductMapping" (
    "id" TEXT NOT NULL,
    "provider" "ProviderCode" NOT NULL,
    "externalProductId" TEXT NOT NULL,
    "releaseId" TEXT,
    "status" "MappingStatus" NOT NULL,
    "confidence" DOUBLE PRECISION,
    "method" TEXT,

    CONSTRAINT "ProductMapping_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Entitlement" (
    "id" TEXT NOT NULL,
    "connectionId" TEXT NOT NULL,
    "externalProductId" TEXT NOT NULL,
    "releaseId" TEXT,
    "accessType" "AccessType" NOT NULL,
    "verification" "VerificationLevel" NOT NULL,
    "status" "EntitlementStatus" NOT NULL DEFAULT 'ACTIVE',
    "firstSeenAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastSeenAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "sourcePayloadHash" TEXT NOT NULL,

    CONSTRAINT "Entitlement_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Reservation" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "releaseId" TEXT NOT NULL,
    "editionType" TEXT NOT NULL,
    "targetPriceBand" TEXT NOT NULL,
    "shippingCountry" TEXT NOT NULL,
    "platformPreference" TEXT,
    "disclosureVersion" TEXT NOT NULL,
    "status" "ReservationStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Reservation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ReservationHistory" (
    "id" TEXT NOT NULL,
    "reservationId" TEXT NOT NULL,
    "action" TEXT NOT NULL,
    "snapshot" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ReservationHistory_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AuditLog" (
    "id" TEXT NOT NULL,
    "actorId" TEXT,
    "action" TEXT NOT NULL,
    "resourceType" TEXT NOT NULL,
    "resourceId" TEXT,
    "reason" TEXT,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "OutboxEvent" (
    "id" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "aggregateId" TEXT NOT NULL,
    "payload" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "publishedAt" TIMESTAMP(3),

    CONSTRAINT "OutboxEvent_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE UNIQUE INDEX "Consent_userId_type_version_key" ON "Consent"("userId", "type", "version");

-- CreateIndex
CREATE UNIQUE INDEX "ProviderConnection_provider_externalAccountHash_key" ON "ProviderConnection"("provider", "externalAccountHash");

-- CreateIndex
CREATE UNIQUE INDEX "CatalogGame_slug_key" ON "CatalogGame"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "CatalogRelease_gameId_platform_region_edition_key" ON "CatalogRelease"("gameId", "platform", "region", "edition");

-- CreateIndex
CREATE UNIQUE INDEX "ProductMapping_provider_externalProductId_key" ON "ProductMapping"("provider", "externalProductId");

-- CreateIndex
CREATE UNIQUE INDEX "Entitlement_connectionId_externalProductId_accessType_key" ON "Entitlement"("connectionId", "externalProductId", "accessType");

-- CreateIndex
CREATE UNIQUE INDEX "Reservation_userId_releaseId_editionType_key" ON "Reservation"("userId", "releaseId", "editionType");

-- CreateIndex
CREATE INDEX "AuditLog_createdAt_idx" ON "AuditLog"("createdAt");

-- CreateIndex
CREATE INDEX "OutboxEvent_publishedAt_createdAt_idx" ON "OutboxEvent"("publishedAt", "createdAt");

-- AddForeignKey
ALTER TABLE "Consent" ADD CONSTRAINT "Consent_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProviderConnection" ADD CONSTRAINT "ProviderConnection_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SyncRun" ADD CONSTRAINT "SyncRun_connectionId_fkey" FOREIGN KEY ("connectionId") REFERENCES "ProviderConnection"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CatalogRelease" ADD CONSTRAINT "CatalogRelease_gameId_fkey" FOREIGN KEY ("gameId") REFERENCES "CatalogGame"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProductMapping" ADD CONSTRAINT "ProductMapping_releaseId_fkey" FOREIGN KEY ("releaseId") REFERENCES "CatalogRelease"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Entitlement" ADD CONSTRAINT "Entitlement_connectionId_fkey" FOREIGN KEY ("connectionId") REFERENCES "ProviderConnection"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Entitlement" ADD CONSTRAINT "Entitlement_releaseId_fkey" FOREIGN KEY ("releaseId") REFERENCES "CatalogRelease"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Reservation" ADD CONSTRAINT "Reservation_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Reservation" ADD CONSTRAINT "Reservation_releaseId_fkey" FOREIGN KEY ("releaseId") REFERENCES "CatalogRelease"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ReservationHistory" ADD CONSTRAINT "ReservationHistory_reservationId_fkey" FOREIGN KEY ("reservationId") REFERENCES "Reservation"("id") ON DELETE CASCADE ON UPDATE CASCADE;
