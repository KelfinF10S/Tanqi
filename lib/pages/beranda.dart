import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tanqiy/controllers/babkuis_controller.dart';
import 'package:tanqiy/core/colors.dart';
import 'package:tanqiy/models/bab_merged_model.dart';
import 'package:tanqiy/pages/bab1.dart';
import 'package:tanqiy/pages/page2.dart';
import 'package:tanqiy/pages/page3.dart';
import 'package:tanqiy/pages/page4.dart';
import 'package:tanqiy/pages/page5.dart';
import 'package:tanqiy/widgets/snackbar.dart';

class Beranda extends StatelessWidget {
  Beranda({super.key});

  final BabController controller = Get.put(BabController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.textSecondary),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 15),

              const Text(
                'اهلا و سهلا',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textP,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'المحتويات',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textP,
                ),
              ),

              const SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  // CARD BAB DARI JSON
                  ...controller.babList.map(
                    (bab) => _buildBabCard(context, bab),
                  ),

                  // CARD PANDUAN
                  _buildStaticCard(
                    context,
                    'دليل الاستخدام',
                    'Panduan Penggunaan',
                    () {
                      Get.toNamed('/panduan');
                    },
                  ),

                  // CARD GAME
                  _buildStaticCard(
                    context,
                    'لعبة إلكترونية',
                    'Permainan Digital',
                    () {
                      Get.toNamed('/games');
                    },
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

Widget _buildBabCard(BuildContext context, BabMerged bab) {
  return GestureDetector(
    onTap: () {
      debugPrint('🔍 RAW LOCKED : ${bab.quiz?.locked}');
      debugPrint('🔍 TYPE : ${bab.quiz?.locked.runtimeType}');
      debugPrint('🤔 KONDISI LOCKED : ${bab.locked}');
      if (bab.locked) {
        showSnackbar(
          'Peringatan : تحذير',
          'لا تزال الفصول مغلقة، أكمل الفصل السابق أولاً\nBab masih terkunci, selesaikan bab sebelumnya terlebih dahulu',
        );
      } else {
        Get.to(() => getBabPage(bab));
      }
    },
    child: Container(
      decoration: bab.locked
          ? BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.cardFillLightLocked, AppColors.cardFillLightLocked],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorderLocked),
            )
          : BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.cardFill, AppColors.cardFillLight],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              bab.materi.judulArab,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: bab.locked ? AppColors.textDisabled : AppColors.textP,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              bab.materi.judulLatin,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textS),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildStaticCard(
  BuildContext context,
  String title,
  String subtitle,
  VoidCallback onTap,
) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.cardFill, AppColors.cardFillLight],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textP,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: AppColors.textS),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget getBabPage(BabMerged bab) {
  switch (bab.id) {
    case '1':
      return Page1(bab: bab);

    case '2':
      return Page3(materi: bab.materi);

    case '3':
      return Page4(materi: bab.materi);

    case '4':
      return Page5(materi: bab.materi);

    default:
      return const Scaffold(body: Center(child: Text('Bab tidak ditemukan')));
  }
}
