import 'package:flutter/material.dart';
import 'package:tanqiy/core/colors.dart';

// ─── LOADING SCREEN ───────────────────────────────────────────────────────────

class LoadingScreen extends StatefulWidget {
  const LoadingScreen();
  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.bg,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: Tween<double>(begin: 0.85, end: 1.0).animate(_pulse),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.gold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.3),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'ن',
                      style: TextStyle(
                        fontSize: 36,
                        color: AppColors.gold,
                        fontFamily: 'serif',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Memuat…',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      );
}

// ─── ERROR SCREEN ─────────────────────────────────────────────────────────────

class ErrorScreen extends StatelessWidget {
  final String error;
  const ErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.bg,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppColors.rose, size: 48),
              const SizedBox(height: 12),
              const Text('Gagal memuat data',
                  style: TextStyle(
                      color: AppColors.textPrimary, fontSize: 16)),
              const SizedBox(height: 6),
              Text(error,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
        ),
      );
}