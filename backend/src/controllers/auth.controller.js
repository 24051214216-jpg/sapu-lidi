
import {
  registerSchema,
  loginSchema,
  otpRequestSchema,
  otpVerifySchema,
  resetPasswordSchema,
} from '../validators/auth.validator.js';

import {
  registerUser,
  loginUser,
  requestOtp,
  verifyOtp,
  resetPassword,
  getCurrentUser,
} from '../services/auth.service.js';

function validate(schema, data) {
  const result = schema.safeParse(data);

  if (!result.success) {
    const error = new Error(
      result.error.issues.map((item) => item.message).join(', '),
    );

    error.statusCode = 400;
    throw error;
  }

  return result.data;
}

function sendError(res, error) {
  const statusCode = Number.isInteger(error.statusCode)
    ? error.statusCode
    : 500;

  if (statusCode >= 500) {
    console.error(error);
  }

  return res.status(statusCode).json({
    success: false,
    message: statusCode >= 500
      ? 'Terjadi kesalahan pada server.'
      : error.message,
  });
}

export async function register(req, res) {
  try {
    const data = validate(registerSchema, req.body);
    const result = await registerUser(data);

    return res.status(201).json({
      success: true,
      message: 'Registrasi berhasil.',
      data: result,
    });
  } catch (error) {
    return sendError(res, error);
  }
}

export async function login(req, res) {
  try {
    const data = validate(loginSchema, req.body);
    const result = await loginUser(data);

    return res.status(200).json({
      success: true,
      message: 'Login berhasil.',
      data: result,
    });
  } catch (error) {
    return sendError(res, error);
  }
}

export async function requestOtpController(req, res) {
  try {
    const data = validate(otpRequestSchema, req.body);
    const result = await requestOtp(data);

    return res.status(200).json({
      success: true,
      ...result,
    });
  } catch (error) {
    return sendError(res, error);
  }
}

export async function verifyOtpController(req, res) {
  try {
    const data = validate(otpVerifySchema, req.body);
    const result = await verifyOtp(data);

    return res.status(200).json({
      success: true,
      message: 'Verifikasi OTP berhasil.',
      data: result,
    });
  } catch (error) {
    return sendError(res, error);
  }
}

export async function resetPasswordController(req, res) {
  try {
    const data = validate(resetPasswordSchema, req.body);
    const result = await resetPassword(data);

    return res.status(200).json({
      success: true,
      ...result,
    });
  } catch (error) {
    return sendError(res, error);
  }
}

export async function me(req, res) {
  try {
    const user = await getCurrentUser(req.user.id);

    return res.status(200).json({
      success: true,
      data: user,
    });
  } catch (error) {
    return sendError(res, error);
  }
}
