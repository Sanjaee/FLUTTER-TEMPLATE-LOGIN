class ApiEndpoints {
  // Base URL - sesuaikan dengan backend server
  // Untuk development lokal, gunakan IP address atau localhost
  static const String baseUrl = 'http://192.168.194.248:5000';
  
  // API version prefix
  static const String apiV1 = '$baseUrl/api/v1';

  // Auth endpoints (sesuai dengan Go router.go)
  static const String register = '$apiV1/auth/register';
  static const String login = '$apiV1/auth/login';
  static const String verifyOtp = '$apiV1/auth/verify-otp';
  static const String resendOtp = '$apiV1/auth/resend-otp';
  static const String googleOAuth = '$apiV1/auth/google-oauth';
  static const String refreshToken = '$apiV1/auth/refresh-token';
  static const String forgotPassword = '$apiV1/auth/forgot-password';
  static const String verifyResetPassword = '$apiV1/auth/verify-reset-password';
  static const String resetPassword = '$apiV1/auth/reset-password';
  static const String verifyEmail = '$apiV1/auth/verify-email';
  static const String getMe = '$apiV1/auth/me';

  // WebSocket endpoints
  static const String wsBaseUrl = 'ws://192.168.194.248:5000';

  // Health check
  static const String health = '$baseUrl/health';
}
