import { env } from './config/env.config.js';
import app from './app.js';
import { pool } from './config/database.js';

let server;

async function startServer() {
  try {
    await pool.query('SELECT 1');

    console.log('====================================');
    console.log(' SapuLidi Backend');
    console.log('====================================');
    console.log('Database PostgreSQL berhasil terhubung.');

    server = app.listen(env.port, env.host, () => {
      console.log(`Server berjalan di http://localhost:${env.port}`);
      console.log(`Health check: http://localhost:${env.port}/api/health`);
      console.log('====================================');
    });

    server.on('error', (error) => {
      console.error('Server gagal dijalankan:', error.message);
      process.exitCode = 1;
    });
  } catch (error) {
    console.error('Gagal menjalankan backend:', error.message);

    await pool.end().catch(() => {});
    process.exitCode = 1;
  }
}

async function shutdown(signal) {
  console.log(`\nMenerima ${signal}. Menghentikan server...`);

  if (server) {
    await new Promise((resolve) => {
      server.close(resolve);
    });
  }

  await pool.end();
  console.log('Koneksi database ditutup.');
  process.exit(0);
}

process.once('SIGINT', () => shutdown('SIGINT'));
process.once('SIGTERM', () => shutdown('SIGTERM'));

startServer();