import { env } from '../config/env.config.js';
import {
  generateOtp,
  hashOtp,
} from '../utils/hash.js';

export function createOtpForPhone(phone, purpose) {
  const otp = generateOtp();

  const expiresAt = new Date(
    Date.now() + env.otp.expiresMinutes * 60 * 1000,
  );

  return {
    otp,
    otpHash: hashOtp(phone, purpose, otp),
    expiresAt,
  };
}

export function isOtpExpired(otpRecord) {
  return new Date(otpRecord.expiresAt).getTime() <= Date.now();
}

export function hasOtpExceededAttempts(otpRecord) {
  return otpRecord.attempts >= env.otp.maxAttempts;
}