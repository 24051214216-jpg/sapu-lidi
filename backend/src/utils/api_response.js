export function successResponse(res, {
  statusCode = 200,
  message = 'Berhasil.',
  data = null,
}) {
  return res.status(statusCode).json({
    success: true,
    message,
    ...(data !== null ? { data } : {}),
  });
}

export function errorResponse(res, {
  statusCode = 500,
  message = 'Terjadi kesalahan pada server.',
}) {
  return res.status(statusCode).json({
    success: false,
    message,
  });
}