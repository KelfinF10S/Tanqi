import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tanqiy/controllers/auth_controller.dart';
import 'package:tanqiy/core/colors.dart';
import 'package:tanqiy/pages/auth.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.put(AuthController());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final username = prefs.getString('auth_username');
      print('=== CEK SHARED PREFS ===');
      print('Token   : $token');
      print('Username: $username');
      print('========================');

      // Jalankan keduanya bersamaan, tunggu yang lebih lama
      final results = await Future.wait([
        auth.verifyTokenOnLaunch(),
        Future.delayed(const Duration(seconds: 3)),
      ]);

      final isValid = results[0] as bool;
      print('=== verifyTokenOnLaunch: $isValid ===');

      if (isValid) {
        Get.offAllNamed('/menu');
      } else {
        Get.offAll(() => const AuthPage());
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Logo ──────────────────────────────────────
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: AppColors.cardBorder, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gradientTop.withOpacity(0.6),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset('lib/assets/Icon.jpeg', fit: BoxFit.cover),
                ),
              ),

              const SizedBox(height: 28),

              // ── Nama Aplikasi ─────────────────────────────
              const Text(
                'تنقي',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.appBarTitle,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 30),

              // ── Loading Indicator ─────────────────────────
              SizedBox(
                width: 160,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const LinearProgressIndicator(
                    minHeight: 3,
                    backgroundColor: AppColors.cardFillLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.appBarTitle,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Memuat...',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
