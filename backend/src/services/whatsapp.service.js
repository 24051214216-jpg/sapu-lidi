import { sendOtp } from '../providers/whatsapp_otp.provider.js';

export async function sendWhatsAppOtp(phone, otp) {
  return sendOtp(phone, otp);
}