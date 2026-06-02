import 'package:shared_preferences/shared_preferences.dart';

const String _keyToken = 'auth_token';
const String _keyUsername = 'auth_username';

// ============================================================
//  AUTH STORAGE
// ============================================================
class AuthStorage {
  static Future<void> saveToken(String token, {String? username}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    if (username != null) await prefs.setString(_keyUsername, username);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUsername);
  }
}

Future<void> cekSharedPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  print('=== CEK SHARED PREFS ===');
  print('Token: ${prefs.getString('auth_token')}');
  print('Username: ${prefs.getString('auth_username')}');
  print('=======================');
}