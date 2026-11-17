import 'dotenv/config';

const requiredVariables = [
  'DB_HOST',
  'DB_PORT',
  'DB_NAME',
  'DB_USER',
  'DB_PASSWORD',
  'JWT_SECRET',
  'OTP_RESET_SECRET',
  'OTP_HASH_SECRET',
];

for (const variable of requiredVariables) {
  if (!process.env[variable]?.trim()) {
    throw new Error(`Environment variable ${variable} belum diatur.`);
  }
}

for (const variable of [
  'JWT_SECRET',
  'OTP_RESET_SECRET',
  'OTP_HASH_SECRET',
]) {
  if (process.env[variable].length < 32) {
    throw new Error(`${variable} minimal harus 32 karakter.`);
  }
}

const port = Number(process.env.DB_PORT);

if (!Number.isInteger(port) || port < 1 || port > 65535) {
  throw new Error('DB_PORT tidak valid.');
}

export const env = Object.freeze({
  nodeEnv: process.env.NODE_ENV || 'development',
  port: Number(process.env.PORT) || 3000,
  host: process.env.HOST || '0.0.0.0',
  database: {
    host: process.env.DB_HOST,
    port,
    name: process.env.DB_NAME,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    ssl: process.env.DB_SSL === 'true',
  },
  jwt: {
    secret: process.env.JWT_SECRET,
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
    resetSecret: process.env.OTP_RESET_SECRET,
  },
  otp: {
    hashSecret: process.env.OTP_HASH_SECRET,
    expiresMinutes: Number(process.env.OTP_EXPIRES_MINUTES) || 5,
    maxAttempts: Number(process.env.OTP_MAX_ATTEMPTS) || 5,
  },
  corsOrigins: (process.env.CORS_ORIGIN || '')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean),
});