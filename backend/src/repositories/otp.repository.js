import { pool } from '../config/database.js';

export async function findLatestActiveOtp(phone, purpose, client = pool) {
  const result = await client.query(
    `SELECT *
     FROM public."AuthOtp"
     WHERE "noHp" = $1
       AND purpose = $2
       AND "consumedAt" IS NULL
     ORDER BY "createdAt" DESC
     LIMIT 1`,
    [phone, purpose],
  );

  return result.rows[0] || null;
}

export async function createOtp({
  phone,
  purpose,
  otpHash,
  expiresAt,
}, client = pool) {
  const result = await client.query(
    `INSERT INTO public."AuthOtp" (
      id,
      "noHp",
      purpose,
      "otpHash",
      "expiresAt",
      attempts,
      "createdAt"
    )
    VALUES (
      gen_random_uuid(),
      $1,
      $2,
      $3,
      $4,
      0,
      CURRENT_TIMESTAMP
    )
    RETURNING id, "noHp", purpose, "expiresAt", "createdAt"`,
    [phone, purpose, otpHash, expiresAt],
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

export async function consumePreviousOtps(phone, purpose, client = pool) {
  await client.query(
    `UPDATE public."AuthOtp"
     SET "consumedAt" = CURRENT_TIMESTAMP
     WHERE "noHp" = $1
       AND purpose = $2
       AND "consumedAt" IS NULL`,
    [phone, purpose],
  );
}