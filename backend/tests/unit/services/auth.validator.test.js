import test from 'node:test';
import assert from 'node:assert/strict';

import {
  otpRequestSchema,
  otpVerifySchema,
} from '../../../src/validators/auth.validator.js';

const challengeId = '4c686522-04a1-4063-9bbd-003f64ba6fc1';

test('OTP login request menerima challengeId', () => {
  const result = otpRequestSchema.safeParse({
    challengeId,
  });

  assert.equal(result.success, true);
});

test('OTP login request menolak request tanpa challengeId', () => {
  const result = otpRequestSchema.safeParse({
    noHp: '+6281234567890',
    purpose: 'LOGIN',
  });

  assert.equal(result.success, false);
});

test('OTP reset password tetap menerima nomor HP dan purpose', () => {
  const result = otpRequestSchema.safeParse({
    noHp: '+6281234567890',
    purpose: 'RESET_PASSWORD',
  });

  assert.equal(result.success, true);
});

test('OTP login verification menerima challengeId dan OTP 6 digit', () => {
  const result = otpVerifySchema.safeParse({
    challengeId,
    otp: '123456',
  });

  assert.equal(result.success, true);
});

test('OTP login verification menolak OTP kurang dari 6 digit', () => {
  const result = otpVerifySchema.safeParse({
    challengeId,
    otp: '12345',
  });

  assert.equal(result.success, false);
});

test('OTP reset password tetap menerima format lama', () => {
  const result = otpVerifySchema.safeParse({
    noHp: '+6281234567890',
    purpose: 'RESET_PASSWORD',
    otp: '123456',
  });

  assert.equal(result.success, true);
});