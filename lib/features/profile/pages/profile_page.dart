import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/utils/navigation.dart';
import '../../../routes/app_routes.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final authService = AuthService();
      final user = await authService.getMe();
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final authService = AuthService();
      await authService.logout();
      
      if (mounted) {
        NavigationHelper.goToAndClearStack(context, AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
        elevation: 0,
        title: Text(
          'Profile',
          style: AppTextStyles.h3.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          onPressed: () => NavigationHelper.goBack(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Header
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            backgroundImage: _user?.profilePhoto != null
                                ? NetworkImage(_user!.profilePhoto!)
                                : null,
                            child: _user?.profilePhoto == null
                                ? Icon(
                                    Icons.person,
                                    size: 50,
                                    color: AppColors.primary,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _user?.fullName ?? 'N/A',
                            style: AppTextStyles.h3.copyWith(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _user?.email ?? 'N/A',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Profile Details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardBackgroundDark : AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailItem(
                            context,
                            'Email',
                            _user?.email ?? 'N/A',
                            Icons.email_outlined,
                          ),
                          const Divider(height: 32),
                          _buildDetailItem(
                            context,
                            'Phone',
                            _user?.phone ?? 'Tidak ada',
                            Icons.phone_outlined,
                          ),
                          const Divider(height: 32),
                          _buildDetailItem(
                            context,
                            'Tipe User',
                            _user?.userType ?? 'N/A',
                            Icons.badge_outlined,
                          ),
                          const Divider(height: 32),
                          _buildDetailItem(
                            context,
                            'Gender',
                            _user?.gender ?? 'Tidak ada',
                            Icons.person_outline,
                          ),
                          const Divider(height: 32),
                          _buildDetailItem(
                            context,
                            'Status',
                            _user?.isVerified == true ? 'Terverifikasi' : 'Belum Terverifikasi',
                            _user?.isVerified == true ? Icons.verified : Icons.verified_user_outlined,
                            color: _user?.isVerified == true ? AppColors.success : AppColors.warning,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Logout Button
                    CustomButton(
                      text: 'Logout',
                      onPressed: _handleLogout,
                      isPrimary: true,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final itemColor = color ?? AppColors.primary;

    return Row(
      children: [
        Icon(
          icon,
          color: itemColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
