import { pool } from '../config/database.js';

export async function createLoginChallenge({
  userId,
  phone,
  expiresAt,
}, client = pool) {
  const result = await client.query(
    `INSERT INTO public."AuthLoginChallenge" (
      id,
      "userId",
      "noHp",
      "expiresAt",
      "createdAt"
    )
    VALUES (
      gen_random_uuid(),
      $1,
      $2,
      $3,
      CURRENT_TIMESTAMP
    )
    RETURNING id, "userId", "noHp", "expiresAt", "consumedAt"`,
    [userId, phone, expiresAt],
  );

  return result.rows[0];
}

export async function findLoginChallengeById(
  challengeId,
  client = pool,
) {
  const result = await client.query(
    `SELECT *
     FROM public."AuthLoginChallenge"
     WHERE id = $1
     LIMIT 1`,
    [challengeId],
  );

  return result.rows[0] || null;
}

export async function findLoginChallengeByIdForUpdate(
  challengeId,
  client,
) {
  const result = await client.query(
    `SELECT *
     FROM public."AuthLoginChallenge"
     WHERE id = $1
     LIMIT 1
     FOR UPDATE`,
    [challengeId],
  );

  return result.rows[0] || null;
}

export async function consumeLoginChallenge(
  challengeId,
  client = pool,
) {
  await client.query(
    `UPDATE public."AuthLoginChallenge"
     SET "consumedAt" = CURRENT_TIMESTAMP
     WHERE id = $1
       AND "consumedAt" IS NULL`,
    [challengeId],
  );
}

export async function findLatestActiveOtp(
  phone,
  purpose,
  client = pool,
  challengeId = null,
) {
  const result = await client.query(
    `SELECT *
     FROM public."AuthOtp"
     WHERE "noHp" = $1
       AND purpose = $2
       AND "consumedAt" IS NULL
       AND "challengeId" IS NOT DISTINCT FROM $3::uuid
     ORDER BY "createdAt" DESC
     LIMIT 1`,
    [phone, purpose, challengeId],
  );

  return result.rows[0] || null;
}

export async function createOtp({
  phone,
  purpose,
  otpHash,
  expiresAt,
  challengeId = null,
}, client = pool) {
  const result = await client.query(
    `INSERT INTO public."AuthOtp" (
      id,
      "noHp",
      purpose,
      "otpHash",
      "expiresAt",
      attempts,
      "createdAt",
      "challengeId"
    )
    VALUES (
      gen_random_uuid(),
      $1,
      $2,
      $3,
      $4,
      0,
      CURRENT_TIMESTAMP,
      $5
    )
    RETURNING
      id,
      "noHp",
      purpose,
      "expiresAt",
      "createdAt",
      "challengeId"`,
    [phone, purpose, otpHash, expiresAt, challengeId],
  );

  return result.rows[0];
}

export async function consumeOtp(id, client = pool) {
  await client.query(
    `UPDATE public."AuthOtp"
     SET "consumedAt" = CURRENT_TIMESTAMP
     WHERE id = $1
       AND "consumedAt" IS NULL`,
    [id],
  );
}

export async function incrementOtpAttempts(id, client = pool) {
  await client.query(
    `UPDATE public."AuthOtp"
     SET attempts = attempts + 1
     WHERE id = $1`,
    [id],
  );
}

export async function consumePreviousOtps(
  phone,
  purpose,
  client = pool,
  challengeId = null,
) {
  await client.query(
    `UPDATE public."AuthOtp"
     SET "consumedAt" = CURRENT_TIMESTAMP
     WHERE "noHp" = $1
       AND purpose = $2
       AND "consumedAt" IS NULL
       AND "challengeId" IS NOT DISTINCT FROM $3::uuid`,
    [phone, purpose, challengeId],
  );
}