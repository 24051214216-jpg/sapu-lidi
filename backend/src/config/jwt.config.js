import { env } from './env.config.js';

export const jwtConfig = Object.freeze({
  accessSecret: env.jwt.secret,
  accessExpiresIn: env.jwt.expiresIn,
  resetSecret: env.jwt.resetSecret,
  resetExpiresIn: '10m',
});