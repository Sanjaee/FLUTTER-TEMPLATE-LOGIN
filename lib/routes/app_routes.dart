class AppRoutes {
  // Auth routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyOtp = '/verify-otp';
  static const String resetPassword = '/reset-password';
  static const String changePassword = '/change-password';
  static const String completeProfile = '/complete-profile';
  
  // Main routes
  static const String home = '/home';
  static const String profile = '/profile';
  
  // List of auth routes (no authentication required)
  static const List<String> authRoutes = [
    splash,
    login,
    register,
    verifyOtp,
    resetPassword,
    changePassword,
  ];
  
  // List of protected routes (authentication required)
  static const List<String> protectedRoutes = [
    home,
    profile,
    completeProfile,
  ];
  
  // Check if route is auth route
  static bool isAuthRoute(String route) {
    return authRoutes.contains(route);
  }
  
  // Check if route is protected route
  static bool isProtectedRoute(String route) {
    return protectedRoutes.contains(route);
  }
}
