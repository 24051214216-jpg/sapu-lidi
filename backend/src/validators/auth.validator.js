
import { z } from 'zod';
import {
  isValidPhoneNumber,
  normalizePhoneNumber,
} from '../utils/phone.js';

const phoneSchema = z.string()
  .trim()
  .min(1, 'Nomor HP wajib diisi.')
  .max(30, 'Nomor HP terlalu panjang.')
  .transform(normalizePhoneNumber)
  .refine(
    isValidPhoneNumber,
    'Nomor WhatsApp Indonesia tidak valid.',
  );

export const registerSchema = z.object({
  nama: z.string()
    .trim()
    .min(3, 'Nama minimal 3 karakter.')
    .max(100, 'Nama maksimal 100 karakter.'),

  noHp: phoneSchema,

  blokRumah: z.string()
    .trim()
    .min(1, 'Blok rumah wajib diisi.')
    .max(30),

  noRumah: z.string()
    .trim()
    .min(1, 'Nomor rumah wajib diisi.')
    .max(30),

  password: z.string()
    .min(8, 'Password minimal 8 karakter.')
    .max(72, 'Password maksimal 72 karakter.'),
});

export const loginSchema = z.object({
  noHp: phoneSchema,
  password: z.string().min(1, 'Password wajib diisi.'),
});

export const otpRequestSchema = z.object({
  noHp: phoneSchema,
  purpose: z.enum(['LOGIN', 'RESET_PASSWORD']),
});

export const otpVerifySchema = z.object({
  noHp: phoneSchema,
  purpose: z.enum(['LOGIN', 'RESET_PASSWORD']),
  otp: z.string()
    .regex(/^[0-9]{6}$/, 'OTP harus terdiri dari 6 digit.'),
});

export const resetPasswordSchema = z.object({
  resetToken: z.string().min(1, 'Reset token wajib diisi.'),
  newPassword: z.string()
    .min(8, 'Password minimal 8 karakter.')
    .max(72, 'Password maksimal 72 karakter.'),
});
