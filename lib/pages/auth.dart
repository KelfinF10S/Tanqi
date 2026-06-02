import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tanqiy/core/colors.dart';
import 'package:tanqiy/core/const.dart';

const String _baseUrl = AppConst.baseUrl;
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

// ============================================================
//  AUTH CONTROLLER
// ============================================================
class AuthController extends GetxController {
  final isLogin = true.obs;
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

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

  final currentUser = Rxn<Map<String, dynamic>>();

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
        currentUser.value = data['user'] as Map<String, dynamic>?;
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

  Future<void> logout() async {
    await AuthStorage.clearAll();
    currentUser.value = null;
    Get.offAll(() => const AuthPage());
    _showSnackbar('Logout', 'Kamu telah keluar dari akun', isError: false);
  }

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
        final token = data['token'] ?? data['access_token'] ?? '';
        await AuthStorage.saveToken(token, username: usernameController.text.trim());
        _showSnackbar('Berhasil', 'Login berhasil! Selamat datang 👋', isError: false);
        await cekSharedPrefs();
        Get.offAllNamed('/menu');
      } else {
        _showSnackbar('Gagal Login', data['msg'] ?? data['message'] ?? 'Terjadi kesalahan');
      }
    } catch (e) {
      _showSnackbar('Error', 'Tidak dapat terhubung ke server: $e');
    } finally {
      isLoading.value = false;
    }
  }

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
        _showSnackbar('Berhasil', 'Akun berhasil dibuat! Silakan login 🎉', isError: false);
        switchMode(true);
      } else {
        _showSnackbar('Gagal Daftar', data['msg'] ?? data['message'] ?? 'Terjadi kesalahan');
      }
    } catch (e) {
      _showSnackbar('Error', 'Tidak dapat terhubung ke server: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _showSnackbar(String title, String message, {bool isError = true}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: isError ? const Color(0xFFEF4444) : AppColors.gradientTop,
      colorText: AppColors.textP,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      icon: Icon(
        isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
        color: AppColors.textP,
      ),
    );
  }
}

// ============================================================
//  AUTH PAGE
// ============================================================
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildTabSwitcher(controller),
                  const SizedBox(height: 36),
                  Obx(
                    () => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: controller.isLogin.value
                          ? _LoginForm(key: const ValueKey('login'), controller: controller)
                          : _RegisterForm(key: const ValueKey('register'), controller: controller),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Logo Icon ────────────────────────────────────
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: AppColors.appBarGradient,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.gradientTop.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 20),
        const Text(
          'مرحباً بك',
          style: TextStyle(
            color: AppColors.appBarTitle,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Masuk atau buat akun baru untuk melanjutkan',
          style: TextStyle(color: AppColors.textS, fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildTabSwitcher(AuthController controller) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.cardFillLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            _TabButton(
              label: 'Masuk',
              isSelected: controller.isLogin.value,
              onTap: () => controller.switchMode(true),
            ),
            _TabButton(
              label: 'Daftar',
              isSelected: !controller.isLogin.value,
              onTap: () => controller.switchMode(false),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab Button ───────────────────────────────────────────────
class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.appBarGradient : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.textP : AppColors.textS,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
//  LOGIN FORM
// ============================================================
class _LoginForm extends StatelessWidget {
  final AuthController controller;
  const _LoginForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AuthField(
            controller: controller.usernameController,
            label: 'Username',
            hint: 'Masukkan username kamu',
            icon: Icons.person_outline_rounded,
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Username wajib diisi';
              return null;
            },
          ),
          const SizedBox(height: 16),
          Obx(() => _AuthField(
            controller: controller.passwordController,
            label: 'Password',
            hint: 'Masukkan password kamu',
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            isPasswordVisible: controller.isPasswordVisible.value,
            onTogglePassword: controller.togglePasswordVisibility,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Password wajib diisi';
              return null;
            },
          )),
          const SizedBox(height: 32),
          Obx(() => _SubmitButton(
            label: 'Masuk',
            isLoading: controller.isLoading.value,
            onTap: controller.login,
          )),
          const SizedBox(height: 20),
          _SwitchModeText(
            text: 'Belum punya akun?',
            actionText: 'Daftar sekarang',
            onTap: () => controller.switchMode(false),
          ),
        ],
      ),
    );
  }
}

// ============================================================
//  REGISTER FORM
// ============================================================
class _RegisterForm extends StatelessWidget {
  final AuthController controller;
  const _RegisterForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AuthField(
            controller: controller.usernameController,
            label: 'Username',
            hint: 'Buat username kamu',
            icon: Icons.person_outline_rounded,
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Username wajib diisi';
              if (val.trim().length < 3) return 'Username minimal 3 karakter';
              return null;
            },
          ),
          const SizedBox(height: 16),
          Obx(() => _AuthField(
            controller: controller.passwordController,
            label: 'Password',
            hint: 'Buat password (min. 8 karakter)',
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            isPasswordVisible: controller.isPasswordVisible.value,
            onTogglePassword: controller.togglePasswordVisibility,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Password wajib diisi';
              if (val.length < 8) return 'Password minimal 8 karakter';
              return null;
            },
          )),
          const SizedBox(height: 16),
          Obx(() => _AuthField(
            controller: controller.confirmPasswordController,
            label: 'Konfirmasi Password',
            hint: 'Ulangi password kamu',
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            isPasswordVisible: controller.isConfirmPasswordVisible.value,
            onTogglePassword: controller.toggleConfirmPasswordVisibility,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Konfirmasi password wajib diisi';
              if (val != controller.passwordController.text) return 'Password tidak cocok';
              return null;
            },
          )),
          const SizedBox(height: 32),
          Obx(() => _SubmitButton(
            label: 'Daftar',
            isLoading: controller.isLoading.value,
            onTap: controller.register,
          )),
          const SizedBox(height: 20),
          _SwitchModeText(
            text: 'Sudah punya akun?',
            actionText: 'Masuk sekarang',
            onTap: () => controller.switchMode(true),
          ),
        ],
      ),
    );
  }
}

// ============================================================
//  REUSABLE WIDGETS
// ============================================================
class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onTogglePassword;
  final String? Function(String?)? validator;

  const _AuthField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onTogglePassword,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.appBarTitle,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !isPasswordVisible,
          style: const TextStyle(color: AppColors.textP, fontSize: 15),
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textS, fontSize: 14),
            prefixIcon: Icon(icon, color: AppColors.textS, size: 20),
            suffixIcon: isPassword
                ? GestureDetector(
                    onTap: onTogglePassword,
                    child: Icon(
                      isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textS,
                      size: 20,
                    ),
                  )
                : null,
            filled: true,
            fillColor: AppColors.cardFillLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.appBarTitle, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
            errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const _SubmitButton({required this.label, required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          gradient: isLoading
              ? const LinearGradient(colors: [AppColors.gradientMid, AppColors.gradientBottom])
              : AppColors.appBarGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.gradientTop.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textP,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}

class _SwitchModeText extends StatelessWidget {
  final String text;
  final String actionText;
  final VoidCallback onTap;

  const _SwitchModeText({required this.text, required this.actionText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$text ', style: const TextStyle(color: AppColors.textS, fontSize: 13)),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: const TextStyle(
              color: AppColors.appBarTitle,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}