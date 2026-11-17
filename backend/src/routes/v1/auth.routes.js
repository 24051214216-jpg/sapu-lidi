
import { Router } from 'express';

import {
  register,
  login,
  requestOtpController,
  verifyOtpController,
  resetPasswordController,
  me,
} from '../../controllers/auth.controller.js';

import {
  authenticateToken,
} from '../../middlewares/auth.middleware.js';

import {
  authLimiter,
  otpRequestLimiter,
  otpVerifyLimiter,
  passwordResetLimiter,
} from '../../middlewares/rate_limiter.middleware.js';

const router = Router();

// Registrasi warga
router.post('/register', authLimiter, register);

// Login menggunakan nomor HP dan password
router.post('/login', authLimiter, login);

// Meminta OTP
router.post('/otp/request', otpRequestLimiter, requestOtpController);

// Verifikasi OTP
router.post('/otp/verify', otpVerifyLimiter, verifyOtpController);

// Reset password
router.post('/password/reset', passwordResetLimiter, resetPasswordController);

// Mendapatkan profil pengguna yang sedang login
router.get('/me', authenticateToken, me);

export default router;
