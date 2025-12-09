import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/middleware/auth_guard.dart';
import '../../../core/utils/navigation.dart';
import '../../../data/services/api_client.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Initialize API client
    ApiClient().init();
    
    // Wait for a moment to show splash
    await Future.delayed(const Duration(seconds: 2));
    
    // Get initial route based on auth status
    final initialRoute = await AuthGuard.getInitialRoute();
    
    if (mounted) {
      NavigationHelper.goToAndClearStack(context, initialRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo/Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.apps,
                color: AppColors.textOnPrimary,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            
            // App Name
            Text(
              'Zacode',
              style: AppTextStyles.h1,
            ),
            const SizedBox(height: 8),
            
            // Tagline
            Text(
              'Your authentication template',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 48),
            
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

