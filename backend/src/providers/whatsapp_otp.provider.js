import { env } from '../config/env.config.js';

export async function sendOtp(phone, otp) {
  const provider = process.env.OTP_PROVIDER || 'console';

  if (provider === 'console') {
    if (env.nodeEnv === 'production') {
      throw new Error(
        'Provider console tidak boleh digunakan di production.',
      );
    }

    console.log('================================');
    console.log('SAPULIDI OTP');
    console.log(`Nomor HP : ${phone}`);
    console.log(`Kode OTP : ${otp}`);
    console.log('================================');

    return { provider: 'console' };
  }

  if (provider !== 'meta') {
    throw new Error('OTP_PROVIDER tidak dikenal.');
  }

  const {
    WA_PHONE_NUMBER_ID,
    WA_ACCESS_TOKEN,
    WA_TEMPLATE_NAME,
    WA_TEMPLATE_LANGUAGE,
    WA_GRAPH_API_VERSION,
  } = process.env;

  if (
    !WA_PHONE_NUMBER_ID
    || !WA_ACCESS_TOKEN
    || !WA_TEMPLATE_NAME
    || !WA_GRAPH_API_VERSION
  ) {
    throw new Error('Konfigurasi WhatsApp Cloud API belum lengkap.');
  }

  const url =
    `https://graph.facebook.com/${WA_GRAPH_API_VERSION}`
    + `/${WA_PHONE_NUMBER_ID}/messages`;

  const response = await fetch(url, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${WA_ACCESS_TOKEN}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      messaging_product: 'whatsapp',
      to: phone.replace('+', ''),
      type: 'template',
      template: {
        name: WA_TEMPLATE_NAME,
        language: {
          code: WA_TEMPLATE_LANGUAGE || 'id',
        },
        components: [
          {
            type: 'body',
            parameters: [
              {
                type: 'text',
                text: otp,
              },
            ],
          },
        ],
      },
    }),
  });

  const result = await response.json().catch(() => ({}));

  if (!response.ok) {
    console.error('WhatsApp Cloud API gagal:', {
      status: response.status,
      error: result.error?.message || 'Unknown error',
    });

    throw new Error('Gagal mengirim OTP melalui WhatsApp.');
  }

  return result;
}