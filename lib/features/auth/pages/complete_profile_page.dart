import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/navigation.dart';
import '../../../data/services/auth_service.dart';
import '../../../core/utils/storage_helper.dart';
import '../../../routes/app_routes.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  String _selectedUserType = 'member';
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _checkIfProfileComplete();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // Check if profile is already complete, redirect to home if yes
  Future<void> _checkIfProfileComplete() async {
    try {
      final authService = AuthService();
      final user = await authService.getMe();

      // Check if userType and gender are already set
      if (user.gender != null && user.gender!.isNotEmpty) {
        if (mounted) {
          NavigationHelper.goToAndClearStack(context, AppRoutes.home);
        }
      }
    } catch (e) {
      // If error, stay on this page
    }
  }

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your gender'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      
      // Prepare update data
      final updateData = {
        'user_type': _selectedUserType,
        'gender': _selectedGender,
      };

      // Add phone only if not empty
      if (_phoneController.text.trim().isNotEmpty) {
        updateData['phone'] = _phoneController.text.trim();
      }

      // Update profile
      final user = await authService.updateProfile(updateData);
      
      // Save userType to storage
      await StorageHelper.saveUserType(user.userType);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile completed successfully!'),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate to home
        NavigationHelper.goToAndClearStack(context, AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Prevent going back without completing profile
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Complete Your Profile'),
              content: const Text(
                'Please complete your profile to continue using the app.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Continue'),
                ),
                TextButton(
                  onPressed: () async {
                    // Logout and go back to login
                    final authService = AuthService();
                    await authService.logout();
                    if (context.mounted) {
                      NavigationHelper.goToAndClearStack(context, AppRoutes.login);
                    }
                  },
                  child: const Text('Logout', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text('Complete Your Profile', style: AppTextStyles.h3),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // Info text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Please complete your profile information to get started',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Phone field (optional)
                  CustomTextField(
                    label: 'Phone Number (Optional)',
                    hint: 'Enter your phone number',
                    controller: _phoneController,
                    validator: Validators.phone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),

                  const SizedBox(height: 16),

                  // User type dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User Type *', style: AppTextStyles.inputLabel),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedUserType,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.inputBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.inputBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.inputBorderFocused,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.inputBackground,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'member', child: Text('Member')),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admin'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedUserType = value!;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Gender dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gender *', style: AppTextStyles.inputLabel),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.inputBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.inputBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.inputBorderFocused,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.inputBackground,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('Select Gender'),
                          ),
                          DropdownMenuItem(value: 'male', child: Text('Male')),
                          DropdownMenuItem(value: 'female', child: Text('Female')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select your gender';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Complete profile button
                  CustomButton(
                    text: 'Complete Profile',
                    onPressed: _completeProfile,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: 16),

                  // Logout button
                  TextButton(
                    onPressed: () async {
                      final authService = AuthService();
                      await authService.logout();
                      if (mounted) {
                        NavigationHelper.goToAndClearStack(context, AppRoutes.login);
                      }
                    },
                    child: Text(
                      'Logout',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

