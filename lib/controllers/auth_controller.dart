// ============================================================
//  AUTH CONTROLLER
// ============================================================
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tanqiy/core/colors.dart';
import 'package:tanqiy/core/const.dart';
import 'package:tanqiy/data/auth_local.dart';
import 'package:tanqiy/models/user_model.dart';
import 'package:tanqiy/pages/auth.dart';

class AuthController extends GetxController {
  final String _baseUrl = AppConst.baseUrl;

  final isLogin = true.obs;
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final currentUser = Rxn<UserModel>();

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void switchMode(bool toLogin) {
    isLogin.value = toLogin;
    _clearFields();
  }

  void _clearFields() {
    usernameController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    isPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;
  }

  void togglePasswordVisibility() =>
      isPasswordVisible.value = !isPasswordVisible.value;

  void toggleConfirmPasswordVisibility() =>
      isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;

  // ── VERIFIKASI TOKEN ──────────────────────────────────
  Future<bool> verifyTokenOnLaunch() async {
    final token = await AuthStorage.getToken();
    if (token == null || token.isEmpty) return false;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Simpan sebagai UserModel
        currentUser.value = UserModel.fromJson(
          data['user'] as Map<String, dynamic>,
        );
        return true;
      } else {
        await AuthStorage.clearAll();
        currentUser.value = null;
        return false;
      }
    } catch (_) {
      return false;
    }
  }

  // ── LOGOUT ────────────────────────────────────────────
  Future<void> logout() async {
    await AuthStorage.clearAll();
    currentUser.value = null;
    Get.offAll(() => const AuthPage());
    _showSnackbar('Logout', 'Kamu telah keluar dari akun', isError: false);
  }

  // ── LOGIN ─────────────────────────────────────────────
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;
    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': usernameController.text.trim(),
          'password': passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['access_token'] ?? data['token'] ?? '';

        // Parse dan simpan UserModel
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
        currentUser.value = user;

        // Simpan token ke local storage
        await AuthStorage.saveToken(token, username: user.username);

        print('=== LOGIN BERHASIL ===');
        print('User: ${user.username} (id: ${user.id})');
        print('Token: $token');
        print('=====================');

        _showSnackbar(
          'Berhasil',
          'Selamat datang, ${user.username}! 👋',
          isError: false,
        );
        Get.offAllNamed('/menu');
      } else {
        _showSnackbar(
          'Gagal Login',
          data['msg'] ?? data['message'] ?? 'Terjadi kesalahan',
        );
      }
    } catch (e) {
      _showSnackbar('Error', 'Tidak dapat terhubung ke server: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── REGISTER ──────────────────────────────────────────
  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) return;
    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': usernameController.text.trim(),
          'password': passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackbar(
          'Berhasil',
          'Akun berhasil dibuat! Silakan login 🎉',
          isError: false,
        );
        switchMode(true);
      } else {
        _showSnackbar(
          'Gagal Daftar',
          data['msg'] ?? data['message'] ?? 'Terjadi kesalahan',
        );
      }
    } catch (e) {
      _showSnackbar('Error', 'Tidak dapat terhubung ke server: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── UPDATE USERNAME ──────────────────────────
  Future<bool> updateUsername(String newUsername) async {
    isLoading.value = true;

    try {
      final token = await AuthStorage.getToken();

      if (token == null || token.isEmpty) {
        _showSnackbar('Error', 'Token tidak ditemukan');
        return false;
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/api/auth/update-username'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'username': newUsername.trim()}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // update current user
        final updatedUser = UserModel.fromJson(
          data['user'] as Map<String, dynamic>,
        );

        currentUser.value = updatedUser;

        // update username di local storage
        await AuthStorage.saveToken(token, username: updatedUser.username);

        _showSnackbar(
          'Berhasil',
          'Username berhasil diperbarui',
          isError: false,
        );

        return true;
      } else {
        _showSnackbar('Gagal', data['message'] ?? 'Gagal memperbarui username');

        return false;
      }
    } catch (e) {
      _showSnackbar('Error', 'Tidak dapat terhubung ke server: $e');

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _showSnackbar(String title, String message, {bool isError = true}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: isError
          ? const Color(0xFFEF4444)
          : AppColors.gradientTop,
      colorText: AppColors.textP,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      icon: Icon(
        isError
            ? Icons.error_outline_rounded
            : Icons.check_circle_outline_rounded,
        color: AppColors.textP,
      ),
    );
  }
}
