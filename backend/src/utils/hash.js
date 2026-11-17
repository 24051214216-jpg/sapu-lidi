import bcrypt from 'bcryptjs';
import crypto from 'node:crypto';

import { env } from '../config/env.config.js';

const BCRYPT_ROUNDS = 12;

export async function hashPassword(password) {
  return bcrypt.hash(password, BCRYPT_ROUNDS);
}

export async function comparePassword(password, hashedPassword) {
  return bcrypt.compare(password, hashedPassword);
}

export function hashOtp(phone, purpose, otp) {
  return crypto
    .createHmac('sha256', env.otp.hashSecret)
    .update(`${phone}:${purpose}:${otp}`)
    .digest('hex');
}

export function generateOtp() {
  return crypto.randomInt(0, 1000000).toString().padStart(6, '0');
}

export function safeCompareHash(firstHash, secondHash) {
  if (
    typeof firstHash !== 'string'
    || typeof secondHash !== 'string'
    || !/^[a-f0-9]{64}$/i.test(firstHash)
    || !/^[a-f0-9]{64}$/i.test(secondHash)
  ) {
    return false;
  }

  return crypto.timingSafeEqual(
    Buffer.from(firstHash, 'hex'),
    Buffer.from(secondHash, 'hex'),
  );
}

export function createPasswordFingerprint(passwordHash) {
  return crypto
    .createHash('sha256')
    .update(passwordHash)
    .digest('hex');
}