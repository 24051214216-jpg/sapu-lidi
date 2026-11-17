import jwt from 'jsonwebtoken';

import { jwtConfig } from '../config/jwt.config.js';
import { createPasswordFingerprint } from './hash.js';

export function createAccessToken(user) {
  return jwt.sign(
    {
      role: user.role,
      type: 'access',
    },
    jwtConfig.accessSecret,
    {
      subject: user.id,
      expiresIn: jwtConfig.accessExpiresIn,
    },
  );
}

export function verifyAccessToken(token) {
  return jwt.verify(token, jwtConfig.accessSecret);
}

export function createResetToken(user) {
  return jwt.sign(
    {
      type: 'password_reset',
      passwordFingerprint: createPasswordFingerprint(user.password),
    },
    jwtConfig.resetSecret,
    {
      subject: user.id,
      expiresIn: jwtConfig.resetExpiresIn,
    },
  );
}

export function verifyResetToken(token) {
  return jwt.verify(token, jwtConfig.resetSecret);
}