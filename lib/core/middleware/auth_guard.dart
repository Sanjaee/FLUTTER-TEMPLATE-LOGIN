import 'package:flutter/material.dart';
import '../utils/storage_helper.dart';
import '../../routes/app_routes.dart';

class AuthGuard {
  /// Guard for auth routes (login, register, etc.)
  /// If user is logged in, redirect to home
  static Future<String?> guardAuthRoute(String route, BuildContext context) async {
    if (!AppRoutes.isAuthRoute(route)) {
      return null;
    }
    
    final isLoggedIn = await StorageHelper.isLoggedIn();
    
    if (isLoggedIn) {
      // User is logged in, redirect to home
      return AppRoutes.home;
    }
    
    return null;
  }
  
  /// Guard for protected routes (home, profile, etc.)
  /// If user is not logged in, redirect to login
  static Future<String?> guardProtectedRoute(String route, BuildContext context) async {
    if (!AppRoutes.isProtectedRoute(route)) {
      return null;
    }
    
    final isLoggedIn = await StorageHelper.isLoggedIn();
    
    if (!isLoggedIn) {
      // User is not logged in, redirect to login
      return AppRoutes.login;
    }
    
    return null;
  }
  
  /// Check if user is logged in
  static Future<bool> isAuthenticated() async {
    return await StorageHelper.isLoggedIn();
  }
  
  /// Get the redirect route based on auth status
  static Future<String> getInitialRoute() async {
    final isLoggedIn = await StorageHelper.isLoggedIn();
    
    if (isLoggedIn) {
      return AppRoutes.home;
    }
    
    return AppRoutes.login;
  }
}
