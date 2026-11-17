import express from 'express';
import helmet from 'helmet';

import { corsMiddleware } from './config/cors.config.js';
import authRoutes from './routes/v1/auth.routes.js';

const app = express();

app.disable('x-powered-by');

app.use(helmet());
app.use(corsMiddleware);

app.use(express.json({ limit: '10kb' }));
app.use(express.urlencoded({
  extended: true,
  limit: '10kb',
}));

app.get('/api/health', (req, res) => {
  return res.status(200).json({
    success: true,
    message: 'SapuLidi API berjalan.',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
  });
});

app.use('/api/v1/auth', authRoutes);

app.use((req, res) => {
  return res.status(404).json({
    success: false,
    message: 'Endpoint tidak ditemukan.',
  });
});

app.use((error, req, res, next) => {
  if (res.headersSent) {
    return next(error);
  }

  const statusCode = Number.isInteger(error.statusCode)
    ? error.statusCode
    : 500;

  if (statusCode >= 500) {
    console.error('Application error:', error);
  }

  return res.status(statusCode).json({
    success: false,
    message: statusCode >= 500
      ? 'Terjadi kesalahan pada server.'
      : error.message,
  });
});

export default app;