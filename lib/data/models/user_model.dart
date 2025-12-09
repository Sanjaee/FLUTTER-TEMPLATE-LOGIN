class UserModel {
  final String id;
  final String email;
  final String? username;
  final String? phone;
  final String fullName;
  final String userType;
  final String? profilePhoto;
  final DateTime? dateOfBirth;
  final String? gender;
  final bool isActive;
  final bool isVerified;
  final DateTime? lastLogin;
  final String loginType;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  UserModel({
    required this.id,
    required this.email,
    this.username,
    this.phone,
    required this.fullName,
    required this.userType,
    this.profilePhoto,
    this.dateOfBirth,
    this.gender,
    required this.isActive,
    required this.isVerified,
    this.lastLogin,
    required this.loginType,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Safe parsing with null checks
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString(),
      phone: json['phone']?.toString(),
      fullName: json['full_name']?.toString() ?? '',
      userType: json['user_type']?.toString() ?? 'member',
      profilePhoto: json['profile_photo']?.toString(),
      dateOfBirth: json['date_of_birth'] != null && json['date_of_birth'].toString().isNotEmpty
          ? DateTime.tryParse(json['date_of_birth'].toString()) 
          : null,
      gender: json['gender']?.toString(),
      isActive: json['is_active'] is bool ? json['is_active'] as bool : (json['is_active']?.toString().toLowerCase() == 'true'),
      isVerified: json['is_verified'] is bool ? json['is_verified'] as bool : (json['is_verified']?.toString().toLowerCase() == 'true'),
      lastLogin: json['last_login'] != null && json['last_login'].toString().isNotEmpty
          ? DateTime.tryParse(json['last_login'].toString()) 
          : null,
      loginType: json['login_type']?.toString() ?? 'credential',
      createdAt: json['created_at'] != null && json['created_at'].toString().isNotEmpty
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null && json['updated_at'].toString().isNotEmpty
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'phone': phone,
      'full_name': fullName,
      'user_type': userType,
      'profile_photo': profilePhoto,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'is_active': isActive,
      'is_verified': isVerified,
      'last_login': lastLogin?.toIso8601String(),
      'login_type': loginType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? phone,
    String? fullName,
    String? userType,
    String? profilePhoto,
    DateTime? dateOfBirth,
    String? gender,
    bool? isActive,
    bool? isVerified,
    DateTime? lastLogin,
    String? loginType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      userType: userType ?? this.userType,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      lastLogin: lastLogin ?? this.lastLogin,
      loginType: loginType ?? this.loginType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AuthResponse {
  final UserModel user;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  
  AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Go backend wraps response in {"success": true, "data": {...}}
    // Handle both wrapped and unwrapped formats
    Map<String, dynamic> data;
    if (json.containsKey('data') && json['data'] != null) {
      data = json['data'] as Map<String, dynamic>;
    } else {
      data = json;
    }
    
    // Ensure user data exists
    if (data['user'] == null) {
      throw Exception('User data is missing from response');
    }
    
    return AuthResponse(
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      accessToken: data['access_token']?.toString() ?? '',
      refreshToken: data['refresh_token']?.toString() ?? '',
      expiresIn: data['expires_in'] is int ? data['expires_in'] as int : 900, // 15 minutes default from Go backend
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
    };
  }
}

/// Register response from Go backend
class RegisterResponse {
  final String message;
  final UserModel? user;
  final bool requiresVerification;
  final String? verificationToken;

  RegisterResponse({
    required this.message,
    this.user,
    required this.requiresVerification,
    this.verificationToken,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    // Go backend wraps response in {"success": true, "message": "...", "data": {...}}
    // Handle both wrapped and unwrapped formats
    final data = json.containsKey('data') ? json['data'] as Map<String, dynamic>? : null;
    
    return RegisterResponse(
      message: json['message'] ?? '',
      user: (data?['user'] ?? json['user']) != null 
          ? UserModel.fromJson(data?['user'] ?? json['user']) 
          : null,
      requiresVerification: data?['requires_verification'] ?? json['requires_verification'] ?? true,
      verificationToken: data?['verification_token'] ?? json['verification_token'],
    );
  }
}

class EmailNotVerifiedException implements Exception {
  final String email;
  EmailNotVerifiedException({required this.email});
  @override
  String toString() => 'EMAIL_NOT_VERIFIED';
}

class RegisterRequest {
  final String fullName;
  final String email;
  final String? username;
  final String? phone;
  final String password;
  final String userType;
  final String? gender;
  final DateTime? dateOfBirth;
  
  RegisterRequest({
    required this.fullName,
    required this.email,
    this.username,
    this.phone,
    required this.password,
    required this.userType,
    this.gender,
    this.dateOfBirth,
  });
  
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'full_name': fullName,
      'email': email,
      'password': password,
      'user_type': userType,
    };
    
    // Only include optional fields if they have values
    if (username != null && username!.isNotEmpty) {
      map['username'] = username;
    }
    if (phone != null && phone!.isNotEmpty) {
      map['phone'] = phone;
    }
    if (gender != null && gender!.isNotEmpty) {
      map['gender'] = gender;
    }
    if (dateOfBirth != null) {
      map['date_of_birth'] = dateOfBirth!.toIso8601String().split('T')[0]; // Format: 2006-01-02
    }
    
    return map;
  }
}

class LoginRequest {
  final String email;
  final String password;
  
  LoginRequest({
    required this.email,
    required this.password,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class OTPVerifyRequest {
  final String email;
  final String otpCode;
  
  OTPVerifyRequest({
    required this.email,
    required this.otpCode,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp_code': otpCode,
    };
  }
}

class ResendOTPRequest {
  final String email;
  
  ResendOTPRequest({
    required this.email,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class ResetPasswordRequest {
  final String email;
  
  ResetPasswordRequest({
    required this.email,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class VerifyResetPasswordRequest {
  final String email;
  final String otpCode;
  final String newPassword;
  
  VerifyResetPasswordRequest({
    required this.email,
    required this.otpCode,
    required this.newPassword,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp_code': otpCode,
      'new_password': newPassword,
    };
  }
}

class RefreshTokenRequest {
  final String refreshToken;
  
  RefreshTokenRequest({
    required this.refreshToken,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'refresh_token': refreshToken,
    };
  }
}

class GoogleOAuthRequest {
  final String email;
  final String fullName;
  final String? profilePhoto;
  final String googleId;
  
  GoogleOAuthRequest({
    required this.email,
    required this.fullName,
    this.profilePhoto,
    required this.googleId,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'full_name': fullName,
      'profile_photo': profilePhoto ?? '',
      'google_id': googleId,
    };
  }
}

/// Update profile request
class UpdateProfileRequest {
  final String? username;
  final String? phone;
  final String? fullName;
  final String? userType;
  final String? profilePhoto;
  final String? gender;
  final DateTime? dateOfBirth;
  
  UpdateProfileRequest({
    this.username,
    this.phone,
    this.fullName,
    this.userType,
    this.profilePhoto,
    this.gender,
    this.dateOfBirth,
  });
  
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    
    if (username != null) map['username'] = username;
    if (phone != null) map['phone'] = phone;
    if (fullName != null) map['full_name'] = fullName;
    if (userType != null) map['user_type'] = userType;
    if (profilePhoto != null) map['profile_photo'] = profilePhoto;
    if (gender != null) map['gender'] = gender;
    if (dateOfBirth != null) {
      map['date_of_birth'] = dateOfBirth!.toIso8601String().split('T')[0];
    }
    
    return map;
  }
}
