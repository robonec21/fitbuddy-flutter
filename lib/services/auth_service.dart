import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../router.dart';

class AuthService {
  final String baseUrl = ApiConfig.baseUrl;
  final storage = const FlutterSecureStorage();
  final AuthStateNotifier authNotifier;

  AuthService(this.authNotifier); 

  Future<String?> signUp(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)['token'];
      await storage.write(key: 'jwt_token', value: token);
      authNotifier.checkAuthState(); 
      return token;
    }
    throw Exception('Failed to sign up');
  }

  Future<String?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)['token'];
      await storage.write(key: 'jwt_token', value: token);
      authNotifier.checkAuthState();
      return token;
    }
    throw Exception('Failed to login');
  }

  Future<void> logout() async {
    await storage.delete(key: 'jwt_token');
    authNotifier.checkAuthState();
  }

  Future<bool> isAuthenticated() async {
    final token = await storage.read(key: 'jwt_token');
    return token != null;
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'jwt_token');
  }

  Future<bool> handleUnauthorizedResponse() async {
    await storage.delete(key: 'jwt_token');
    authNotifier.checkAuthState();
    return false;
  }
}