export const USER_ROLES = Object.freeze({
  WARGA: 'WARGA',
  KOORDINATOR: 'KOORDINATOR',
  BENDAHARA: 'BENDAHARA',
  KETUA_RT: 'KETUA_RT',
  PETUGAS_KEAMANAN: 'PETUGAS_KEAMANAN',
});

export const USER_STATUS = Object.freeze({
  PENDING: 'PENDING',
  AKTIF: 'AKTIF',
  DITOLAK: 'DITOLAK',
});

export const OTP_PURPOSE = Object.freeze({
  LOGIN: 'LOGIN',
  RESET_PASSWORD: 'RESET_PASSWORD',
});

export const OTP_LENGTH = 6;
export const OTP_RESEND_INTERVAL_SECONDS = 60;
export const PASSWORD_MIN_LENGTH = 8;