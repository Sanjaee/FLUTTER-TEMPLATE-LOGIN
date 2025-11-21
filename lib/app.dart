import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/middleware/auth_guard.dart';
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
    // Apply auth guard middleware
    return _createGuardedRoute(settings, () {
      switch (settings.name) {
        case AppRoutes.login:
          return const LoginPage();
        case AppRoutes.register:
          return const RegisterPage();
        case AppRoutes.verifyOtp:
          final args = settings.arguments as Map<String, dynamic>?;
          return VerifyOtpPage(email: args?['email'] ?? '');
        case AppRoutes.resetPassword:
          return const ResetPasswordPage();
        case AppRoutes.verifyOtpReset:
          final args = settings.arguments as Map<String, dynamic>?;
          return VerifyOtpResetPage(email: args?['email'] ?? '');
        case AppRoutes.verifyResetPassword:
          final args = settings.arguments as Map<String, dynamic>?;
          return VerifyResetPasswordPage(
            email: args?['email'] ?? '',
            otp: args?['otp'] ?? '',
          );
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
        // Smooth EaseOutSlide transition (like Gojek/startup apps)
        final slideAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0), // Slide from right
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: const EaseOutSlideCurve(), // Custom smooth ease out curve
          ),
        );

        // Subtle fade for extra smoothness
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOut), // Quick fade in
          ),
        );

        // Combine slide and fade for premium smooth transition
        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350), // Optimal duration for smoothness
    );
  }
}

// Custom EaseOutSlide curve for smooth transitions (like Gojek/startup apps)
class EaseOutSlideCurve extends Curve {
  const EaseOutSlideCurve();

  @override
  double transformInternal(double t) {
    // Smooth ease out curve: starts fast, ends slow
    // Using cubic bezier-like easing for natural feel
    if (t < 0.5) {
      // First half: accelerate
      return 2 * t * t;
    } else {
      // Second half: decelerate smoothly
      final double f = t - 1.0;
      return 1.0 - (2 * f * f);
    }
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

