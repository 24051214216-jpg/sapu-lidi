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
  consumeOtp,
  consumePreviousOtps,
  createOtp,
  findLatestActiveOtp,
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
import { createOtpForPhone, isOtpExpired, hasOtpExceededAttempts } from './otp.service.js';
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

    return publicUser(user);
  } catch (error) {
    if (error.code === '23505') {
      throw new AppError('Nomor WhatsApp sudah terdaftar.', 409);
    }

    throw error;
  }
}

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
    throw new AppError('Akun belum aktif atau tidak dapat digunakan.', 403);
  }

  return createAuthResult(user);
}

export async function requestOtp(data) {
  const user = await findUserByPhone(data.noHp);

  if (!isActiveUser(user)) {
    throw new AppError(
      'Akun tidak ditemukan atau belum aktif.',
      404,
    );
  }

  if (!Object.values(OTP_PURPOSE).includes(data.purpose)) {
    throw new AppError('Tujuan OTP tidak valid.', 400);
  }

  const client = await pool.connect();
  let otpData;

  try {
    await client.query('BEGIN');

    const latestOtp = await findLatestActiveOtp(
      data.noHp,
      data.purpose,
      client,
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
      data.noHp,
      data.purpose,
      client,
    );

    otpData = createOtpForPhone(data.noHp, data.purpose);

    await createOtp({
      phone: data.noHp,
      purpose: data.purpose,
      otpHash: otpData.otpHash,
      expiresAt: otpData.expiresAt,
    }, client);

    await client.query('COMMIT');
  } catch (error) {
    await client.query('ROLLBACK').catch(() => {});
    throw error;
  } finally {
    client.release();
  }

  try {
    await sendWhatsAppOtp(data.noHp, otpData.otp);
  } catch (error) {
    await pool.query(
      `UPDATE public."AuthOtp"
       SET "consumedAt" = CURRENT_TIMESTAMP
       WHERE "noHp" = $1
         AND purpose = $2
         AND "consumedAt" IS NULL`,
      [data.noHp, data.purpose],
    );

    throw new AppError(
      'OTP gagal dikirim. Silakan coba kembali beberapa saat lagi.',
      502,
    );
  }

  return {
    message: 'OTP berhasil dikirim.',
    expiresIn: env.otp.expiresMinutes * 60,
  };
}

export async function verifyOtp(data) {
  const client = await pool.connect();
  let outcome;

  try {
    await client.query('BEGIN');

    const otpResult = await client.query(
      `SELECT *
       FROM public."AuthOtp"
       WHERE "noHp" = $1
         AND purpose = $2
         AND "consumedAt" IS NULL
       ORDER BY "createdAt" DESC
       LIMIT 1
       FOR UPDATE`,
      [data.noHp, data.purpose],
    );

    const otpRecord = otpResult.rows[0];

    if (!otpRecord) {
      throw new AppError(
        'OTP tidak ditemukan atau sudah digunakan.',
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
        data.noHp,
        data.purpose,
        data.otp,
      );

      if (!safeCompareHash(otpRecord.otpHash, submittedHash)) {
        await incrementOtpAttempts(otpRecord.id, client);

        outcome = {
          error: new AppError('Kode OTP salah.', 400),
        };
      } else {
        await consumeOtp(otpRecord.id, client);

        const user = await findUserByPhone(data.noHp, client);

        if (!isActiveUser(user)) {
          outcome = {
            error: new AppError(
              'Akun tidak ditemukan atau belum aktif.',
              403,
            ),
          };
        } else {
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

  if (outcome.error) {
    throw outcome.error;
  }

  if (data.purpose === OTP_PURPOSE.LOGIN) {
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