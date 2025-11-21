import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'features/auth/pages/login_page.dart';
import 'features/auth/pages/register_page.dart';
import 'features/auth/pages/verify_otp_page.dart';
import 'features/auth/pages/reset_password_page.dart';
import 'features/auth/pages/verify_otp_reset_page.dart';
import 'features/auth/pages/verify_reset_password_page.dart';
import 'features/home/pages/home_page.dart';
import 'features/profile/pages/profile_page.dart';
import 'routes/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeRealTime',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          surface: AppColors.background,
          onSurface: AppColors.textPrimary,
        ),
        scaffoldBackgroundColor: AppColors.background,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.backgroundDark,
          onSurface: AppColors.textPrimaryDark,
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,
      ),
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.login,
      onGenerateRoute: (settings) {
        return _buildRoute(settings);
      },
    );
  }

  Route<dynamic> _buildRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return _createRoute(
          const LoginPage(),
          settings,
        );
      case AppRoutes.register:
        return _createRoute(
          const RegisterPage(),
          settings,
        );
      case AppRoutes.verifyOtp:
        final args = settings.arguments as Map<String, dynamic>?;
        return _createRoute(
          VerifyOtpPage(email: args?['email'] ?? ''),
          settings,
        );
      case AppRoutes.resetPassword:
        return _createRoute(
          const ResetPasswordPage(),
          settings,
        );
      case AppRoutes.verifyOtpReset:
        final args = settings.arguments as Map<String, dynamic>?;
        return _createRoute(
          VerifyOtpResetPage(email: args?['email'] ?? ''),
          settings,
        );
      case AppRoutes.verifyResetPassword:
        final args = settings.arguments as Map<String, dynamic>?;
        return _createRoute(
          VerifyResetPasswordPage(
            email: args?['email'] ?? '',
            otp: args?['otp'] ?? '',
          ),
          settings,
        );
      case AppRoutes.home:
        return _createRoute(
          const HomePage(),
          settings,
        );
      case AppRoutes.profile:
        return _createRoute(
          const ProfilePage(),
          settings,
        );
      default:
        return _createRoute(
          const Scaffold(
            body: Center(
              child: Text('Page Not Found'),
            ),
          ),
          settings,
        );
    }
  }

  Route<dynamic> _createRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Fade transition
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
        );

        // Slide transition
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.3, 0.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

