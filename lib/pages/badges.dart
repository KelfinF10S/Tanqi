import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tanqiy/core/colors.dart';
import 'package:tanqiy/widgets/custom_appbar.dart';

class BadgeModel {
  final String arabic;
  final String title;
  final String description;
  final String emoji;
  final bool unlocked;

  const BadgeModel({
    required this.arabic,
    required this.title,
    required this.description,
    required this.emoji,
    required this.unlocked,
  });
}

final badges = [
  BadgeModel(
    arabic: 'البداية',
    title: 'Bidayah',
    description: 'Bab 1 sempurna',
    emoji: '🌱',
    unlocked: true,
  ),

  BadgeModel(
    arabic: 'شعلة',
    title: 'Shu‘lah',
    description: 'Bab 2 sempurna',
    emoji: '🔥',
    unlocked: true,
  ),

  BadgeModel(
    arabic: 'برق',
    title: 'Barq',
    description: 'Bab 3 sempurna',
    emoji: '⚡',
    unlocked: false,
  ),

  BadgeModel(
    arabic: 'فاتح العلم',
    title: 'Fatih Al-Ilm',
    description: 'Semua bab sempurna',
    emoji: '👑',
    unlocked: false,
  ),

  BadgeModel(
    arabic: 'فجر الأفكار',
    title: 'Subuh Brainstorm',
    description: 'Submit 03.00–05.00',
    emoji: '🌄',
    unlocked: true,
  ),
];

class BadgePage extends StatelessWidget {
  const BadgePage({super.key});

  @override
  Widget build(BuildContext context) {
    final unlocked = badges.where((e) => e.unlocked).length;

    return Scaffold(
      appBar: CustomAppBar(arabicTitle: 'مجموعة الشارات'),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),

        child: ListView(
          padding: const EdgeInsets.all(16),

          children: [
            const SizedBox(height: 15),

            const Text(
              'الأوسمة',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textP,
              ),
            ),

            const SizedBox(height: 16),

            _collectionCard(unlocked),

            const SizedBox(height: 20),

            const Text(
              'مجموعة الإنجازات',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textP,
              ),
            ),

            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,

              physics: const NeverScrollableScrollPhysics(),

              itemCount: badges.length,

              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.86,
              ),

              itemBuilder: (context, i) => _BadgeCard(badge: badges[i]),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _collectionCard(int unlocked) {
  return Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.cardFill, AppColors.cardFillLight],
      ),

      borderRadius: BorderRadius.circular(16),

      border: Border.all(color: AppColors.cardBorder),
    ),

    child: Padding(
      padding: const EdgeInsets.all(16),

      child: Row(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 46)),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'متحف الإنجازات',

                  style: TextStyle(
                    fontSize: 20,

                    fontWeight: FontWeight.bold,

                    color: AppColors.textP,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '$unlocked / ${badges.length} Badge Terbuka',

                  style: const TextStyle(color: AppColors.textS),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _BadgeCard extends StatelessWidget {
  final BadgeModel badge;

  const _BadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    final locked = !badge.unlocked;

    return GestureDetector(
      onTap: () {
        Get.dialog(
          AlertDialog(
            backgroundColor: AppColors.cardFill,

            title: Text(locked ? 'Badge Terkunci' : badge.title),

            content: Text(badge.description),
          ),
        );
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),

        decoration: BoxDecoration(
          gradient: locked
              ? LinearGradient(
                  colors: [
                    AppColors.cardFillLightLocked,

                    AppColors.cardFillLightLocked,
                  ],
                )
              : const LinearGradient(
                  colors: [AppColors.cardFill, AppColors.cardFillLight],
                ),

          borderRadius: BorderRadius.circular(16),

          border: Border.all(
            color: locked ? AppColors.cardBorderLocked : AppColors.cardBorder,
          ),
        ),

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Text(
                locked ? '🔒' : badge.emoji,

                style: const TextStyle(fontSize: 36),
              ),

              const SizedBox(height: 12),

              Text(
                locked ? '؟؟؟' : badge.arabic,

                textAlign: TextAlign.center,

                style: TextStyle(
                  color: locked ? AppColors.textDisabled : AppColors.textP,

                  fontWeight: FontWeight.bold,

                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                locked ? 'Badge belum terbuka' : badge.title,

                textAlign: TextAlign.center,

                style: const TextStyle(color: AppColors.textS, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
