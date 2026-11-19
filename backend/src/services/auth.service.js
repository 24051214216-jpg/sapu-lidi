import { pool } from '../config/database.js';
import { env } from '../config/env.config.js';
import { OTP_PURPOSE, USER_STATUS } from '../config/constants.config.js';

import {
  createUser,
  findUserById,
  findUserByPhone,
  updateUserPassword,
} from '../repositories/user.repository.js';

import {
  consumeLoginChallenge,
  consumeOtp,
  consumePreviousOtps,
  createLoginChallenge,
  createOtp,
  findLatestActiveOtp,
  findLoginChallengeByIdForUpdate,
  incrementOtpAttempts,
} from '../repositories/otp.repository.js';

import {
  comparePassword,
  hashPassword,
  hashOtp,
  safeCompareHash,
  createPasswordFingerprint,
} from '../utils/hash.js';

import {
  createAccessToken,
  createResetToken,
  verifyResetToken,
} from '../utils/jwt.js';

import { AppError } from '../utils/app_error.js';

import {
  createOtpForPhone,
  isOtpExpired,
  hasOtpExceededAttempts,
} from './otp.service.js';

import { sendWhatsAppOtp } from './whatsapp.service.js';

function isActiveUser(user) {
  return Boolean(
    user
    && !user.deletedAt
    && user.status === USER_STATUS.AKTIF,
  );
}

function publicUser(user) {
  return {
    id: user.id,
    nama: user.nama,
    noHp: user.noHp,
    role: user.role,
    status: user.status,
    blokRumah: user.blokRumah,
    noRumah: user.noRumah,
    fotoProfil: user.fotoProfil,
    rt: user.rt,
    rw: user.rw,
  };
}

function createAuthResult(user) {
  return {
    user: publicUser(user),
    accessToken: createAccessToken(user),
    tokenType: 'Bearer',
    expiresIn: env.jwt.expiresIn,
  };
}

function maskPhone(phone) {
  const digits = String(phone).replace(/\D/g, '');

  if (digits.length <= 5) {
    return digits;
  }

  return `${digits.slice(0, 4)}${'*'.repeat(
    Math.max(3, digits.length - 7),
  )}${digits.slice(-3)}`;
}

function challengeIsExpired(challenge) {
  return new Date(challenge.expiresAt).getTime() <= Date.now();
}

async function sendOtpOrConsume({
  phone,
  purpose,
  challengeId = null,
  otpData,
}) {
  try {
    await sendWhatsAppOtp(phone, otpData.otp);
  } catch (error) {
    if (challengeId) {
      await pool.query(
        `UPDATE public."AuthOtp"
         SET "consumedAt" = CURRENT_TIMESTAMP
         WHERE "challengeId" = $1
           AND "consumedAt" IS NULL`,
        [challengeId],
      );
    } else {
      await pool.query(
        `UPDATE public."AuthOtp"
         SET "consumedAt" = CURRENT_TIMESTAMP
         WHERE "noHp" = $1
           AND purpose = $2
           AND "consumedAt" IS NULL`,
        [phone, purpose],
      );
    }

    throw new AppError(
      'OTP gagal dikirim. Silakan coba kembali beberapa saat lagi.',
      502,
    );
  }
}

export async function registerUser(data) {
  const existingUser = await findUserByPhone(data.noHp);

  if (existingUser && !existingUser.deletedAt) {
    throw new AppError('Nomor WhatsApp sudah terdaftar.', 409);
  }

  if (existingUser?.deletedAt) {
    throw new AppError(
      'Nomor WhatsApp pernah digunakan pada akun yang dihapus. Hubungi administrator.',
      409,
    );
  }

  const password = await hashPassword(data.password);

  try {
    const user = await createUser({
      ...data,
      password,
    });

    // Registrasi warga tetap langsung aktif.
    return createAuthResult(user);
  } catch (error) {
    if (error.code === '23505') {
      throw new AppError('Nomor WhatsApp sudah terdaftar.', 409);
    }

    throw error;
  }
}

/*
 * Login tahap pertama:
 * - Validasi nomor dan password.
 * - Pastikan akun AKTIF.
 * - Buat challenge.
 * - Belum menerbitkan access token.
 */
export async function loginUser(data) {
  const user = await findUserByPhone(data.noHp);

  if (!user || user.deletedAt) {
    throw new AppError('Nomor WhatsApp atau password salah.', 401);
  }

  const passwordMatches = await comparePassword(
    data.password,
    user.password,
  );

  if (!passwordMatches) {
    throw new AppError('Nomor WhatsApp atau password salah.', 401);
  }

  if (!isActiveUser(user)) {
    throw new AppError(
      'Akun belum aktif atau tidak dapat digunakan.',
      403,
    );
  }

  const expiresAt = new Date(
    Date.now() + env.otp.expiresMinutes * 60 * 1000,
  );

  const challenge = await createLoginChallenge({
    userId: user.id,
    phone: user.noHp,
    expiresAt,
  });

  return {
    challengeId: challenge.id,
    phoneMasked: maskPhone(user.noHp),
    expiresIn: env.otp.expiresMinutes * 60,
  };
}

/*
 * Meminta OTP:
 * - LOGIN menggunakan challengeId.
 * - RESET_PASSWORD tetap menggunakan noHp.
 */
export async function requestOtp(data) {
  const isLogin = Boolean(data.challengeId);
  const purpose = isLogin
    ? OTP_PURPOSE.LOGIN
    : OTP_PURPOSE.RESET_PASSWORD;

  const client = await pool.connect();

  let phone;
  let challengeId = null;
  let otpData;

  try {
    await client.query('BEGIN');

    if (isLogin) {
      challengeId = data.challengeId;

      const challenge = await findLoginChallengeByIdForUpdate(
        challengeId,
        client,
      );

      if (
        !challenge
        || challenge.consumedAt
        || challengeIsExpired(challenge)
      ) {
        throw new AppError(
          'Sesi login sudah kedaluwarsa. Silakan login kembali.',
          401,
        );
      }

      phone = challenge.noHp;

      const user = await findUserByPhone(phone, client);

      if (
        !isActiveUser(user)
        || user.id !== challenge.userId
      ) {
        throw new AppError(
          'Akun tidak ditemukan atau tidak aktif.',
          403,
        );
      }
    } else {
      phone = data.noHp;

      const user = await findUserByPhone(phone, client);

      if (!isActiveUser(user)) {
        throw new AppError(
          'Akun tidak ditemukan atau belum aktif.',
          404,
        );
      }
    }

    const latestOtp = await findLatestActiveOtp(
      phone,
      purpose,
      client,
      challengeId,
    );

    if (latestOtp) {
      const elapsedSeconds =
        (Date.now() - new Date(latestOtp.createdAt).getTime()) / 1000;

      if (elapsedSeconds < 60) {
        throw new AppError(
          'Mohon tunggu 60 detik sebelum meminta OTP kembali.',
          429,
        );
      }
    }

    await consumePreviousOtps(
      phone,
      purpose,
      client,
      challengeId,
    );

    otpData = createOtpForPhone(phone, purpose);

    await createOtp({
      phone,
      purpose,
      otpHash: otpData.otpHash,
      expiresAt: otpData.expiresAt,
      challengeId,
    }, client);

    await client.query('COMMIT');
  } catch (error) {
    await client.query('ROLLBACK').catch(() => {});
    throw error;
  } finally {
    client.release();
  }

  await sendOtpOrConsume({
    phone,
    purpose,
    challengeId,
    otpData,
  });

  return {
    message: 'OTP berhasil dikirim.',
    expiresIn: env.otp.expiresMinutes * 60,
  };
}

/*
 * Verifikasi:
 * - LOGIN harus menyertakan challengeId.
 * - OTP harus berasal dari challenge yang sama.
 * - Challenge hanya dapat diselesaikan satu kali.
 * - Access token baru dibuat setelah OTP valid.
 * - RESET_PASSWORD tetap memakai mekanisme lama.
 */
export async function verifyOtp(data) {
  const isLogin = Boolean(data.challengeId);
  const purpose = isLogin
    ? OTP_PURPOSE.LOGIN
    : OTP_PURPOSE.RESET_PASSWORD;

  const client = await pool.connect();

  let outcome;

  try {
    await client.query('BEGIN');

    let phone = data.noHp;
    let challenge = null;

    if (isLogin) {
      challenge = await findLoginChallengeByIdForUpdate(
        data.challengeId,
        client,
      );

      if (
        !challenge
        || challenge.consumedAt
        || challengeIsExpired(challenge)
      ) {
        throw new AppError(
          'Sesi login sudah kedaluwarsa. Silakan login kembali.',
          401,
        );
      }

      phone = challenge.noHp;
    }

    const otpResult = isLogin
      ? await client.query(
        `SELECT *
         FROM public."AuthOtp"
         WHERE "challengeId" = $1
           AND purpose = $2
           AND "consumedAt" IS NULL
         ORDER BY "createdAt" DESC
         LIMIT 1
         FOR UPDATE`,
        [data.challengeId, purpose],
      )
      : await client.query(
        `SELECT *
         FROM public."AuthOtp"
         WHERE "noHp" = $1
           AND purpose = $2
           AND "challengeId" IS NULL
           AND "consumedAt" IS NULL
         ORDER BY "createdAt" DESC
         LIMIT 1
         FOR UPDATE`,
        [phone, purpose],
      );

    const otpRecord = otpResult.rows[0];

    if (!otpRecord) {
      throw new AppError(
        'OTP tidak ditemukan atau sudah digunakan. Silakan minta OTP baru.',
        400,
      );
    }

    if (isOtpExpired(otpRecord)) {
      await consumeOtp(otpRecord.id, client);

      outcome = {
        error: new AppError('OTP sudah kedaluwarsa.', 400),
      };
    } else if (hasOtpExceededAttempts(otpRecord)) {
      await consumeOtp(otpRecord.id, client);

      outcome = {
        error: new AppError(
          'Batas percobaan OTP telah tercapai. Minta OTP baru.',
          429,
        ),
      };
    } else {
      const submittedHash = hashOtp(
        phone,
        purpose,
        data.otp,
      );

      if (!safeCompareHash(otpRecord.otpHash, submittedHash)) {
        await incrementOtpAttempts(otpRecord.id, client);

        outcome = {
          error: new AppError('Kode OTP salah.', 400),
        };
      } else {
        await consumeOtp(otpRecord.id, client);

        const user = await findUserByPhone(phone, client);

        if (
          !isActiveUser(user)
          || (isLogin && user.id !== challenge.userId)
        ) {
          outcome = {
            error: new AppError(
              'Akun tidak ditemukan atau belum aktif.',
              403,
            ),
          };
        } else {
          if (isLogin) {
            await consumeLoginChallenge(
              data.challengeId,
              client,
            );
          }

          outcome = { user };
        }
      }
    }

    await client.query('COMMIT');
  } catch (error) {
    await client.query('ROLLBACK').catch(() => {});
    throw error;
  } finally {
    client.release();
  }

  if (outcome?.error) {
    throw outcome.error;
  }

  if (isLogin) {
    return createAuthResult(outcome.user);
  }

  return {
    resetToken: createResetToken(outcome.user),
    tokenType: 'Bearer',
    expiresIn: '10m',
  };
}

export async function resetPassword(data) {
  let payload;

  try {
    payload = verifyResetToken(data.resetToken);
  } catch {
    throw new AppError(
      'Reset token tidak valid atau sudah kedaluwarsa.',
      401,
    );
  }

  if (
    payload.type !== 'password_reset'
    || !payload.sub
    || !payload.passwordFingerprint
  ) {
    throw new AppError('Reset token tidak valid.', 401);
  }

  const user = await findUserById(payload.sub);

  if (!isActiveUser(user)) {
    throw new AppError('Akun tidak ditemukan atau tidak aktif.', 404);
  }

  const currentFingerprint = createPasswordFingerprint(user.password);

  if (currentFingerprint !== payload.passwordFingerprint) {
    throw new AppError(
      'Reset token sudah digunakan atau tidak berlaku.',
      401,
    );
  }

  const newHashedPassword = await hashPassword(data.newPassword);

  const updated = await updateUserPassword(
    user.id,
    newHashedPassword,
  );

  if (!updated) {
    throw new AppError('Gagal memperbarui password.', 500);
  }

  return {
    message: 'Password berhasil diperbarui.',
  };
}

export async function getCurrentUser(userId) {
  const user = await findUserById(userId);

  if (!isActiveUser(user)) {
    throw new AppError(
      'Pengguna tidak ditemukan atau akun tidak aktif.',
      404,
    );
  }

  return publicUser(user);
}