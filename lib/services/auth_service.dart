import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class AuthService {
  static const String baseUrl = AppConfig.apiBaseUrl;
  late final GoogleSignIn _googleSignIn;
  
  AuthService() {
    _googleSignIn = GoogleSignIn(
      clientId: AppConfig.googleClientId,
    );
  }

  // Email/Phone Sign-In
  Future<Map<String, dynamic>?> signInWithEmailOrPhone(String emailOrPhone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'emailOrPhone': emailOrPhone,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        return data;
      }
      return null;
    } catch (e) {
      throw e;
    }
  }

  // Register with email and phone
  Future<Map<String, dynamic>?> register(String name, String email, String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Registration failed';
      }
    } catch (e) {
      throw e;
    }
  }

  // Google Sign-In
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': googleAuth.idToken,
          'accessToken': googleAuth.accessToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        return data;
      }
      return null;
    } catch (e) {
      throw e;
    }
  }

  // Save JWT token
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  // Get JWT token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Sign out
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await _googleSignIn.signOut();
  }

  // Get current user info
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$baseUrl/auth/delete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await signOut();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Reset password directly
  Future<Map<String, dynamic>?> resetPassword(String emailOrPhone, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'emailOrPhone': emailOrPhone,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      throw e;
    }
  }
}