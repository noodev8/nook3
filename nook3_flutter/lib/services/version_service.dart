/*
=======================================================================================================================================
Version Service - App Version Checking
=======================================================================================================================================
This service handles version checking against the backend API to determine if the app needs to be updated.
Called on app startup to ensure users have the minimum required version.
=======================================================================================================================================
*/

import 'dart:convert';
import '../config/app_config.dart';

class VersionService {
  // Server configuration using AppConfig
  static String get _baseUrl => AppConfig.baseUrl.replaceAll('/api', '');
  static const String _versionCheckEndpoint = '/api/version-check';
  
  /// Check if the current app version meets the server requirements
  /// Returns a VersionCheckResult with status and messages
  static Future<VersionCheckResult> checkVersion(String appVersion) async {
    try {
      final url = Uri.parse('$_baseUrl$_versionCheckEndpoint');
      
      final response = await AppConfig.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'app_version': appVersion,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        return VersionCheckResult(
          isUpdateRequired: data['return_code'] == 'APP_UPDATE_REQUIRED',
          returnCode: data['return_code'],
          message: data['message'] ?? '',
          currentVersion: data['current_version'] ?? appVersion,
          requiredVersion: data['required_version'] ?? '',
        );
      } else {
        return VersionCheckResult(
          isUpdateRequired: false,
          returnCode: 'SERVER_ERROR',
          message: 'Unable to check app version. Please try again later.',
          currentVersion: appVersion,
          requiredVersion: '',
        );
      }
    } catch (e) {
      // Network error or other exception
      return VersionCheckResult(
        isUpdateRequired: false,
        returnCode: 'NETWORK_ERROR',
        message: 'Unable to connect to server. Please check your internet connection.',
        currentVersion: appVersion,
        requiredVersion: '',
      );
    }
  }
}

/// Result class for version check operations
class VersionCheckResult {
  final bool isUpdateRequired;
  final String returnCode;
  final String message;
  final String currentVersion;
  final String requiredVersion;

  VersionCheckResult({
    required this.isUpdateRequired,
    required this.returnCode,
    required this.message,
    required this.currentVersion,
    required this.requiredVersion,
  });

  /// Check if the version check was successful (no errors)
  bool get isSuccess => returnCode == 'SUCCESS';
  
  /// Check if there was a network or server error
  bool get hasError => returnCode == 'NETWORK_ERROR' || returnCode == 'SERVER_ERROR';
}