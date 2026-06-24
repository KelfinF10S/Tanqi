// ============================================================
//  AUTH CONTROLLER
// ============================================================
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tanqiy/core/const.dart';
import 'package:tanqiy/data/auth_local.dart';
import 'package:tanqiy/models/user_model.dart';
import 'package:tanqiy/pages/auth.dart';
import 'package:tanqiy/widgets/snackbar.dart';

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
  
  final isGuru = false.obs; // sementara untuk register

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

  // ── REFRESH USER ─────────────────────────────────────
  Future<void> refreshUser() async {
    final token = await AuthStorage.getToken();
    if (token == null || token.isEmpty) return;

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
        final newUser = UserModel.fromJson(
          data['user'] as Map<String, dynamic>,
        );

        // null trick: paksa Obx rebuild tanpa flicker
        // karena ProfilePage pakai _lastUser saat value null
        currentUser.value = null;
        await Future.delayed(Duration.zero);
        currentUser.value = newUser;
      }
    } catch (_) {}
  }

  // ── LOGOUT ────────────────────────────────────────────
  Future<void> logout() async {
    await AuthStorage.clearAll();
    currentUser.value = null;
    Get.offAll(() => const AuthPage());
    showSnackbar('Logout', 'Kamu telah keluar dari akun', isError: false);
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
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
        currentUser.value = user;

        await AuthStorage.saveToken(token, username: user.username);

        showSnackbar(
          'Berhasil',
          'Selamat datang, ${user.username}! 👋',
          isError: false,
        );
        Get.offAllNamed('/menu');
      } else {
        showSnackbar(
          'Gagal Login',
          data['msg'] ?? data['message'] ?? 'Terjadi kesalahan',
        );
      }
    } catch (e) {
      showSnackbar('Error', 'Tidak dapat terhubung ke server: $e');
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
        showSnackbar(
          'Berhasil',
          'Akun berhasil dibuat! Silakan login 🎉',
          isError: false,
        );
        switchMode(true);
      } else {
        showSnackbar(
          'Gagal Daftar',
          data['msg'] ?? data['message'] ?? 'Terjadi kesalahan',
        );
      }
    } catch (e) {
      showSnackbar('Error', 'Tidak dapat terhubung ke server: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── UPDATE USERNAME ───────────────────────────────────
  Future<bool> updateUsername(String newUsername) async {
    isLoading.value = true;

    try {
      final token = await AuthStorage.getToken();

      if (token == null || token.isEmpty) {
        showSnackbar('Error', 'Token tidak ditemukan');
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
        final updatedUser = UserModel.fromJson(
          data['user'] as Map<String, dynamic>,
        );

        currentUser.value = null;
        await Future.delayed(Duration.zero);
        currentUser.value = updatedUser;

        await AuthStorage.saveToken(token, username: updatedUser.username);

        showSnackbar(
          'Berhasil',
          'Username berhasil diperbarui',
          isError: false,
        );
        return true;
      } else {
        showSnackbar('Gagal', data['message'] ?? 'Gagal memperbarui username');
        return false;
      }
    } catch (e) {
      showSnackbar('Error', 'Tidak dapat terhubung ke server: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
