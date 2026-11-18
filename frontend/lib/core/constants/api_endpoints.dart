abstract final class ApiEndpoints {
  ApiEndpoints._();

  // Base URL backend SapuLidi.
  static const String baseUrl = 'http://localhost:3000/api/v1';

  // Authentication endpoints.
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String requestOtp = '/auth/otp/request';
  static const String verifyOtp = '/auth/otp/verify';
  static const String resetPassword = '/auth/password/reset';
  static const String currentUser = '/auth/me';

  // Health check.
  static const String health = '/health';
}
