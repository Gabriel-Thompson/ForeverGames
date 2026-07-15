ALTER TABLE "Reservation" ADD COLUMN "caseType" TEXT,
ADD COLUMN "extras" TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
ADD COLUMN "comments" TEXT;
CREATE TABLE "ReservationCommand" (
  "id" TEXT NOT NULL,
  "reservationId" TEXT NOT NULL,
  "idempotencyKey" TEXT NOT NULL,
  "response" JSONB NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "ReservationCommand_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "ReservationCommand_idempotencyKey_key" ON "ReservationCommand"("idempotencyKey");
ALTER TABLE "ReservationCommand" ADD CONSTRAINT "ReservationCommand_reservationId_fkey" FOREIGN KEY ("reservationId") REFERENCES "Reservation"("id") ON DELETE CASCADE ON UPDATE CASCADE;
