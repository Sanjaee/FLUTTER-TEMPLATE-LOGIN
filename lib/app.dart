import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_text_styles.dart';
import 'core/middleware/auth_guard.dart';
import 'features/auth/pages/login_page.dart';
import 'features/auth/pages/register_page.dart';
import 'features/auth/pages/verify_otp_page.dart';
import 'features/auth/pages/reset_password_page.dart';
import 'features/auth/pages/change_password_page.dart';
import 'features/auth/pages/complete_profile_page.dart';
import 'features/home/pages/home_page.dart';
import 'features/profile/pages/profile_page.dart';
import 'features/splash/pages/splash_page.dart';
import 'routes/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zacode',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          surface: AppColors.background,
          onSurface: AppColors.textPrimary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonPrimary,
            foregroundColor: AppColors.textOnPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: AppColors.inputBorderFocused,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.inputBorderError),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: AppColors.inputBorderError,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        textTheme: TextTheme(
          headlineLarge: AppTextStyles.h1,
          headlineMedium: AppTextStyles.h2,
          headlineSmall: AppTextStyles.h3,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
        ),
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
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: (settings) {
        return _buildRoute(settings);
      },
    );
  }

  Route<dynamic> _buildRoute(RouteSettings settings) {
    // Apply auth guard middleware
    return _createGuardedRoute(settings, () {
      switch (settings.name) {
        case AppRoutes.splash:
          return const SplashPage();
        case AppRoutes.login:
          return const LoginPage();
        case AppRoutes.register:
          return const RegisterPage();
        case AppRoutes.verifyOtp:
          final args = settings.arguments as Map<String, dynamic>?;
          return VerifyOtpPage(
            email: args?['email'] ?? '',
            isPasswordReset: args?['isPasswordReset'] ?? false,
          );
        case AppRoutes.resetPassword:
          return const ResetPasswordPage();
        case AppRoutes.changePassword:
          final args = settings.arguments as Map<String, dynamic>?;
          return ChangePasswordPage(
            email: args?['email'] ?? '',
            otpCode: args?['otpCode'] ?? '',
          );
        case AppRoutes.completeProfile:
          return const CompleteProfilePage();
        case AppRoutes.home:
          return const HomePage();
        case AppRoutes.profile:
          return const ProfilePage();
        default:
          return const Scaffold(
            body: Center(
              child: Text('Page Not Found'),
            ),
          );
      }
    });
  }

  Route<dynamic> _createGuardedRoute(
    RouteSettings settings,
    Widget Function() pageBuilder,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) {
        // Wrap page with auth guard widget
        return _AuthGuardWidget(
          routeName: settings.name ?? '',
          child: pageBuilder(),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Ultra-smooth fade with subtle scale for premium feel
        
        // Main fade animation with smooth curve
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: const SmoothFadeCurve(),
          ),
        );

        // Subtle scale animation for depth (98% to 100%)
        final scaleAnimation = Tween<double>(
          begin: 0.98,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: const SmoothScaleCurve(),
          ),
        );

        // Combine fade and scale for ultra-smooth transition
        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

// Ultra-smooth fade curve
class SmoothFadeCurve extends Curve {
  const SmoothFadeCurve();

  @override
  double transformInternal(double t) {
    final double invT = 1.0 - t;
    return 1.0 - (invT * invT * invT);
  }
}

// Smooth scale curve
class SmoothScaleCurve extends Curve {
  const SmoothScaleCurve();

  @override
  double transformInternal(double t) {
    final double invT = 1.0 - t;
    return 1.0 - (invT * invT);
  }
}

// Widget to handle auth guard logic
class _AuthGuardWidget extends StatefulWidget {
  final String routeName;
  final Widget child;

  const _AuthGuardWidget({
    required this.routeName,
    required this.child,
  });

  @override
  State<_AuthGuardWidget> createState() => _AuthGuardWidgetState();
}

class _AuthGuardWidgetState extends State<_AuthGuardWidget> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Skip auth check for splash page
    if (widget.routeName == AppRoutes.splash) {
      setState(() {
        _isChecking = false;
      });
      return;
    }

    // First check: if user is logged in and trying to access auth route
    var redirectTo = await AuthGuard.guardAuthRoute(
      widget.routeName,
      context,
    );

    // Second check: if user is NOT logged in and trying to access protected route
    if (redirectTo == null) {
      redirectTo = await AuthGuard.guardProtectedRoute(
        widget.routeName,
        context,
      );
    }

    if (mounted) {
      if (redirectTo != null) {
        // Redirect needed - navigate to appropriate route
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed(redirectTo!);
        });
      } else {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return widget.child;
  }
}
