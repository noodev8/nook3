import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class AuthService {
  // Server configuration using AppConfig
  static String get baseUrl => '${AppConfig.baseUrl}/auth';
  
  // SharedPreferences keys
  static const String _authTokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  
  // User model
  static User? _currentUser;
  static String? _authToken;

  // Get current user
  static User? get currentUser => _currentUser;
  static String? get authToken => _authToken;
  static bool get isLoggedIn => _authToken != null && _currentUser != null;

  /// Initialize auth service - loads saved login state
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load saved auth token
    _authToken = prefs.getString(_authTokenKey);
    
    // Load saved user data
    final userDataString = prefs.getString(_userDataKey);
    if (userDataString != null) {
      try {
        final userData = jsonDecode(userDataString);
        _currentUser = User.fromJson(userData);
      } catch (e) {
        // If user data is corrupted, clear it
        await _clearStoredAuthData();
      }
    }
  }

  /// Save auth data to persistent storage
  static Future<void> _saveAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_authToken != null) {
      await prefs.setString(_authTokenKey, _authToken!);
    }
    
    if (_currentUser != null) {
      await prefs.setString(_userDataKey, jsonEncode(_currentUser!.toJson()));
    }
  }

  /// Clear stored auth data
  static Future<void> _clearStoredAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_userDataKey);
  }

  /// Register new user
  static Future<AuthResult> register({
    required String email,
    required String displayName,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await AppConfig.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'display_name': displayName,
          'password': password,
          if (phone != null) 'phone': phone,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['return_code'] == 'SUCCESS') {
        // Don't store user data during registration - require email verification first
        return AuthResult(
          success: true,
          message: data['message'],
          user: User.fromJson(data['user']),
          requiresEmailVerification: true,
        );
      } else {
        return AuthResult(
          success: false,
          message: data['message'] ?? 'Registration failed',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Login user
  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await AppConfig.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['return_code'] == 'SUCCESS') {
        _authToken = data['token'];
        _currentUser = User.fromJson(data['user']);
        
        // Save auth data to persistent storage
        await _saveAuthData();
        
        return AuthResult(
          success: true,
          message: data['message'],
          user: _currentUser,
          token: _authToken,
        );
      } else if (data['return_code'] == 'EMAIL_NOT_VERIFIED') {
        return AuthResult(
          success: false,
          message: data['message'],
          requiresEmailVerification: true,
          userId: data['user_id'],
          email: data['email'],
        );
      } else {
        return AuthResult(
          success: false,
          message: data['message'] ?? 'Login failed',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Resend verification email
  static Future<AuthResult> resendVerificationEmail(String email) async {
    try {
      final response = await AppConfig.post(
        Uri.parse('$baseUrl/resend-verification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      return AuthResult(
        success: data['return_code'] == 'SUCCESS',
        message: data['message'],
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Send forgot password email
  static Future<AuthResult> forgotPassword(String email) async {
    try {
      final response = await AppConfig.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      return AuthResult(
        success: data['return_code'] == 'SUCCESS',
        message: data['message'],
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Reset password with token
  static Future<AuthResult> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await AppConfig.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'new_password': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      return AuthResult(
        success: data['return_code'] == 'SUCCESS',
        message: data['message'],
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Get user profile
  static Future<AuthResult> getProfile() async {
    if (_authToken == null) {
      return AuthResult(
        success: false,
        message: 'Not logged in',
      );
    }

    try {
      final response = await AppConfig.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      final data = jsonDecode(response.body);

      if (data['return_code'] == 'SUCCESS') {
        _currentUser = User.fromJson(data['user']);
        return AuthResult(
          success: true,
          user: _currentUser,
        );
      } else if (data['return_code'] == 'TOKEN_EXPIRED') {
        await logout();
        return AuthResult(
          success: false,
          message: 'Session expired. Please log in again.',
          tokenExpired: true,
        );
      } else {
        return AuthResult(
          success: false,
          message: data['message'] ?? 'Failed to get profile',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Update display name
  static Future<AuthResult> updateDisplayName(String displayName) async {
    if (_authToken == null) {
      return AuthResult(
        success: false,
        message: 'Not logged in',
      );
    }

    try {
      final response = await AppConfig.put(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode({'display_name': displayName}),
      );

      final data = jsonDecode(response.body);

      if (data['return_code'] == 'SUCCESS') {
        // Update local user data
        if (_currentUser != null) {
          _currentUser = _currentUser!.copyWith(displayName: displayName);
        }
        return AuthResult(
          success: true,
          message: data['message'],
          user: _currentUser,
        );
      } else if (data['return_code'] == 'TOKEN_EXPIRED') {
        await logout();
        return AuthResult(
          success: false,
          message: 'Session expired. Please log in again.',
          tokenExpired: true,
        );
      } else {
        return AuthResult(
          success: false,
          message: data['message'] ?? 'Failed to update display name',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Check if auth token is still valid
  static Future<bool> validateToken() async {
    if (_authToken == null) return false;

    final result = await getProfile();
    return result.success && !result.tokenExpired;
  }

  /// Logout user
  static Future<void> logout() async {
    _currentUser = null;
    _authToken = null;
    // Clear persistent storage
    await _clearStoredAuthData();
  }

  /// Continue as guest (anonymous user)
  static Future<AuthResult> continueAsGuest(String displayName) async {
    // Create anonymous user locally
    _currentUser = User(
      id: 0, // Anonymous users don't have real IDs
      email: null,
      displayName: displayName,
      isAnonymous: true,
      emailVerified: false,
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );
    
    // No auth token for anonymous users
    _authToken = null;

    // Save guest data to persistent storage
    await _saveAuthData();

    return AuthResult(
      success: true,
      message: 'Continuing as guest',
      user: _currentUser,
    );
  }
}

/// User model
class User {
  final int id;
  final String? email;
  final String? phone;
  final String displayName;
  final bool isAnonymous;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime lastActiveAt;

  User({
    required this.id,
    this.email,
    this.phone,
    required this.displayName,
    required this.isAnonymous,
    required this.emailVerified,
    required this.createdAt,
    required this.lastActiveAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
      displayName: json['display_name'],
      isAnonymous: json['is_anonymous'] ?? false,
      emailVerified: json['email_verified'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      lastActiveAt: DateTime.parse(json['last_active_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'display_name': displayName,
      'is_anonymous': isAnonymous,
      'email_verified': emailVerified,
      'created_at': createdAt.toIso8601String(),
      'last_active_at': lastActiveAt.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? phone,
    String? displayName,
    bool? isAnonymous,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      displayName: displayName ?? this.displayName,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}

/// Auth result model
class AuthResult {
  final bool success;
  final String message;
  final User? user;
  final String? token;
  final bool requiresEmailVerification;
  final bool tokenExpired;
  final int? userId;
  final String? email;

  AuthResult({
    required this.success,
    this.message = '',
    this.user,
    this.token,
    this.requiresEmailVerification = false,
    this.tokenExpired = false,
    this.userId,
    this.email,
  });
}