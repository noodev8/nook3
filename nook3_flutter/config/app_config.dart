import 'package:http/http.dart' as http;

class AppConfig {
  // Change this URL for your environment
  // static const String baseUrl = 'http://192.168.1.88:3000/api'; // Home
  // static const String baseUrl = 'http://192.168.1.108:3000/api'; // Work
  static const String baseUrl = 'https://nook.noodev8.com/api'; // Production

  static const String appName = 'The Nook of Welshpool';
  static const bool isDebugMode = false;
  static const Duration apiTimeout = Duration(seconds: 30);
  
  /// Create an HTTP client with configured timeout
  static http.Client createHttpClient() {
    return http.Client();
  }
  
  /// Make a GET request with timeout
  static Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
    return createHttpClient().get(url, headers: headers).timeout(apiTimeout);
  }
  
  /// Make a POST request with timeout
  static Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body}) {
    return createHttpClient().post(url, headers: headers, body: body).timeout(apiTimeout);
  }
  
  /// Make a PUT request with timeout
  static Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body}) {
    return createHttpClient().put(url, headers: headers, body: body).timeout(apiTimeout);
  }
  
  /// Make a DELETE request with timeout
  static Future<http.Response> delete(Uri url, {Map<String, String>? headers}) {
    return createHttpClient().delete(url, headers: headers).timeout(apiTimeout);
  }
}