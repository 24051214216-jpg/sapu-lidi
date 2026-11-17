
/**
 * Normalisasi nomor HP Indonesia.
 *
 * Format penyimpanan:
 * +628xxxxxxxxxx
 *
 * Format input yang didukung:
 * 08xxxxxxxxxx
 * 8xxxxxxxxxx
 * 628xxxxxxxxxx
 * +628xxxxxxxxxx
 * 00628xxxxxxxxxx
 * Nomor dengan spasi, tanda hubung, dan tanda kurung.
 */

export function normalizePhoneNumber(phone) {
  if (typeof phone !== 'string') {
    return '';
  }

  const input = phone.trim();

  if (!input) {
    return '';
  }

  // Hanya mengizinkan angka dan separator umum nomor telepon.
  if (!/^[0-9+\s().-]+$/.test(input)) {
    return '';
  }

  let digits = input.replace(/\D/g, '');

  // Format internasional 0062 menjadi 62.
  if (digits.startsWith('0062')) {
    digits = digits.slice(2);
  }

  // Format lokal 08 menjadi 628.
  if (digits.startsWith('0')) {
    digits = `62${digits.slice(1)}`;
  }

  // Format tanpa kode negara, misalnya 81234567890.
  else if (digits.startsWith('8')) {
    digits = `62${digits}`;
  }

  // Validasi kode negara Indonesia.
  if (!digits.startsWith('62')) {
    return '';
  }

  return `+${digits}`;
}

/**
 * Memeriksa format nomor HP Indonesia.
 *
 * Format:
 * +628 + 7 sampai 12 digit berikutnya.
 */
export function isValidPhoneNumber(phone) {
  if (typeof phone !== 'string') {
    return false;
  }

  return /^\+628[0-9]{7,12}$/.test(phone);
}
