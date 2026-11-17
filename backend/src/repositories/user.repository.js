import { pool } from '../config/database.js';

const USER_COLUMNS = `
  id,
  nama,
  "noHp",
  role,
  status,
  "blokRumah",
  "noRumah",
  "fotoProfil",
  rt,
  rw,
  "createdAt",
  "updatedAt"
`;

export async function findUserByPhone(phone, client = pool) {
  const result = await client.query(
    `SELECT ${USER_COLUMNS}, password, "deletedAt"
     FROM public."User"
     WHERE "noHp" = $1
     LIMIT 1`,
    [phone],
  );

  return result.rows[0] || null;
}

export async function findUserById(id, client = pool) {
  const result = await client.query(
    `SELECT ${USER_COLUMNS}, password, "deletedAt"
     FROM public."User"
     WHERE id = $1
     LIMIT 1`,
    [id],
  );

  return result.rows[0] || null;
}

export async function createUser(data, client = pool) {
  const result = await client.query(
    `INSERT INTO public."User" (
      id,
      nama,
      "noHp",
      password,
      role,
      status,
      "blokRumah",
      "noRumah",
      "createdAt",
      "updatedAt"
    )
    VALUES (
      gen_random_uuid(),
      $1,
      $2,
      $3,
      'WARGA',
      'AKTIF',
      $4,
      $5,
      CURRENT_TIMESTAMP,
      CURRENT_TIMESTAMP
    )
    RETURNING ${USER_COLUMNS}`,
    [
      data.nama,
      data.noHp,
      data.password,
      data.blokRumah,
      data.noRumah,
    ],
  );

  return result.rows[0];
}

export async function updateUserPassword(id, password, client = pool) {
  const result = await client.query(
    `UPDATE public."User"
     SET password = $1,
         "updatedAt" = CURRENT_TIMESTAMP
     WHERE id = $2
       AND "deletedAt" IS NULL
     RETURNING id`,
    [password, id],
  );

  return result.rowCount > 0;
}