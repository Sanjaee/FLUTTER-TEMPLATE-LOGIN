import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/utils/storage_helper.dart';
import 'api_client.dart';
import 'google_auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// Register user - returns RegisterResponse (requires OTP verification)
  /// Go backend: POST /api/v1/auth/register
  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Go backend returns RegisterResponse, not AuthResponse
        // User needs to verify OTP to get tokens
        return RegisterResponse.fromJson(response.data);
      } else {
        throw Exception('Registration failed');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Login user
  /// Go backend: POST /api/v1/auth/login
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        // Ensure response.data is not null and is a Map
        if (response.data == null) {
          throw Exception('Empty response from server');
        }
        
        if (response.data is! Map<String, dynamic>) {
          throw Exception('Invalid response format from server');
        }
        
        final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);

        // Save tokens and user data
        await _saveAuthData(authResponse);

        return authResponse;
      } else {
        throw Exception('Login failed');
      }
    } on DioException catch (e) {
      // Check for EMAIL_NOT_VERIFIED error from Go backend
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          final errorMsg = data['error']?.toString().toLowerCase() ?? '';
          if (errorMsg.contains('email not verified') || 
              errorMsg.contains('verify your email')) {
            throw EmailNotVerifiedException(email: request.email);
          }
        }
      }
      throw _handleError(e);
    }
  }

  /// Verify OTP - returns tokens after successful verification
  /// Go backend: POST /api/v1/auth/verify-otp
  Future<AuthResponse> verifyOTP(OTPVerifyRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.verifyOtp,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        // Ensure response.data is not null and is a Map
        if (response.data == null) {
          throw Exception('Empty response from server');
        }
        
        if (response.data is! Map<String, dynamic>) {
          throw Exception('Invalid response format from server');
        }
        
        final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);

        // Save tokens and user data
        await _saveAuthData(authResponse);

        return authResponse;
      } else {
        throw Exception('OTP verification failed');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Resend OTP
  /// Go backend: POST /api/v1/auth/resend-otp
  Future<void> resendOTP(String email) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.resendOtp,
        data: {'email': email},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to resend OTP');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Request password reset (forgot password)
  /// Go backend: POST /api/v1/auth/forgot-password
  Future<void> requestResetPassword(String email) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to request password reset');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Verify reset password with OTP and set new password
  /// Go backend: POST /api/v1/auth/verify-reset-password
  Future<void> verifyResetPassword(VerifyResetPasswordRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.verifyResetPassword,
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Password reset failed');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Reset password with token (alternative method)
  /// Go backend: POST /api/v1/auth/reset-password
  Future<AuthResponse> resetPassword(String token, String newPassword) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.resetPassword,
        data: {
          'token': token,
          'new_password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        // Ensure response.data is not null and is a Map
        if (response.data == null) {
          throw Exception('Empty response from server');
        }
        
        if (response.data is! Map<String, dynamic>) {
          throw Exception('Invalid response format from server');
        }
        
        final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);
        await _saveAuthData(authResponse);
        return authResponse;
      } else {
        throw Exception('Password reset failed');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Google Sign In with Google Sign In package
  Future<AuthResponse> signInWithGoogle() async {
    try {
      // Sign in with Google
      final GoogleSignInAccount? googleUser =
          await GoogleAuthService.signInWithGoogle();

      if (googleUser == null) {
        throw Exception('Google Sign In was cancelled');
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null) {
        throw Exception('Failed to get Google access token');
      }

      // Create request for backend
      final request = GoogleOAuthRequest(
        email: googleUser.email,
        fullName: googleUser.displayName ?? googleUser.email.split('@')[0],
        profilePhoto: googleUser.photoUrl,
        googleId: googleUser.id,
      );

      // Send to backend
      return await googleOAuth(request);
    } catch (e) {
      if (e is DioException) {
        throw _handleError(e);
      }
      rethrow;
    }
  }

  /// Google OAuth (direct API call)
  /// Go backend: POST /api/v1/auth/google-oauth
  Future<AuthResponse> googleOAuth(GoogleOAuthRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.googleOAuth,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        // Ensure response.data is not null and is a Map
        if (response.data == null) {
          throw Exception('Empty response from server');
        }
        
        if (response.data is! Map<String, dynamic>) {
          throw Exception('Invalid response format from server');
        }
        
        final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);

        // Save tokens and user data
        await _saveAuthData(authResponse);

        return authResponse;
      } else {
        throw Exception('Google OAuth failed');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Refresh access token
  /// Go backend: POST /api/v1/auth/refresh-token
  Future<AuthResponse> refreshAccessToken(String refreshToken) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        // Ensure response.data is not null and is a Map
        if (response.data == null) {
          throw Exception('Empty response from server');
        }
        
        if (response.data is! Map<String, dynamic>) {
          throw Exception('Invalid response format from server');
        }
        
        final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);

        // Save new tokens and user data
        await _saveAuthData(authResponse);

        return authResponse;
      } else {
        throw Exception('Failed to refresh token');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get current user profile (authenticated)
  /// Go backend: GET /api/v1/auth/me
  Future<UserModel> getMe() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.getMe);

      if (response.statusCode == 200) {
        final responseData = response.data;
        // Go backend wraps response in {"success": true, "data": {...}}
        if (responseData is Map<String, dynamic>) {
          // Check if wrapped in data
          final data = responseData.containsKey('data') 
              ? responseData['data'] as Map<String, dynamic> 
              : responseData;
          
          // Check if user is nested
          if (data.containsKey('user')) {
            return UserModel.fromJson(data['user']);
          }
          return UserModel.fromJson(data);
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to get user profile');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Verify email with token
  /// Go backend: POST /api/v1/auth/verify-email
  Future<AuthResponse> verifyEmail(String token) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.verifyEmail,
        data: {'token': token},
      );

      if (response.statusCode == 200) {
        // Ensure response.data is not null and is a Map
        if (response.data == null) {
          throw Exception('Empty response from server');
        }
        
        if (response.data is! Map<String, dynamic>) {
          throw Exception('Invalid response format from server');
        }
        
        final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);
        await _saveAuthData(authResponse);
        return authResponse;
      } else {
        throw Exception('Email verification failed');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update user profile
  /// Note: Go backend doesn't have a dedicated update endpoint yet
  /// This will need to be implemented on the backend
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      // For now, use the getMe endpoint - backend needs update endpoint
      // When backend has PUT /api/v1/auth/me or /api/v1/user/profile:
      // final response = await _apiClient.dio.put(
      //   ApiEndpoints.getMe,
      //   data: data,
      // );
      // return UserModel.fromJson(response.data['user'] ?? response.data);
      
      // Temporary: just return current user after simulating update
      final user = await getMe();
      await StorageHelper.saveUser(user);
      return user;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Logout - clear local data and sign out from Google
  Future<void> logout() async {
    await GoogleAuthService.signOut();
    await StorageHelper.clearAll();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await StorageHelper.isLoggedIn();
  }

  /// Get stored user data from local storage
  Future<UserModel?> getStoredUser() async {
    return await StorageHelper.getUser();
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    return await StorageHelper.getAccessToken();
  }

  /// Get stored refresh token
  Future<String?> getRefreshToken() async {
    return await StorageHelper.getRefreshToken();
  }

  /// Save authentication data (tokens and user)
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    await StorageHelper.saveTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
    );
    await StorageHelper.saveUser(authResponse.user);
    await StorageHelper.saveUserType(authResponse.user.userType);
    await StorageHelper.setLoggedIn(true);
  }

  /// Error handling - extracts error message from DioException
  String _handleError(DioException e) {
    // Try to extract error message from response
    if (e.response?.data != null) {
      final errorData = e.response!.data;
      if (errorData is Map<String, dynamic>) {
        // Go backend returns error in 'error' or 'message' field
        return errorData['error'] ??
            errorData['message'] ??
            'Terjadi kesalahan';
      }
      if (errorData is String) {
        return errorData;
      }
    }

    // Handle specific error types
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout. Silakan periksa koneksi internet Anda.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return 'Sesi telah berakhir. Silakan login kembali.';
        } else if (statusCode == 403) {
          return 'Akses ditolak.';
        } else if (statusCode == 404) {
          return 'Data tidak ditemukan.';
        } else if (statusCode == 500) {
          return 'Terjadi kesalahan pada server.';
        }
        return 'Terjadi kesalahan. Silakan coba lagi.';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      case DioExceptionType.connectionError:
        return 'Tidak ada koneksi internet.';
      default:
        return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }
}
