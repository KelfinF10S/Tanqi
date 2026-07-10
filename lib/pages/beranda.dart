import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tanqiy/controllers/babkuis_controller.dart';
import 'package:tanqiy/core/colors.dart';
import 'package:tanqiy/models/bab_merged_model.dart';
import 'package:tanqiy/pages/bab1.dart';
import 'package:tanqiy/widgets/snackbar.dart';

class Beranda extends StatefulWidget {
  Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  final BabController controller = Get.put(BabController());

  @override
  void initState() {
    fetchBabData();
    super.initState();
  }

  void fetchBabData() async {
    await controller.fetchBab();
  }

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

              _welcomeCard(context),

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

                  // CARD GAME
                  _buildStaticCard(
                    context,
                    'لَوْحَةُ الصَّدَارَةِ',
                    'Leaderboard',
                    () {
                      Get.toNamed('/page3');
                    },
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
          'تحذير',
          'لا يمكنك فتح هذا الفصل بعد. أكمل الفصل السابق أولاً',
        );
      } else {
        Get.to(() => BabPage(bab: bab));
      }
    },

    child: Container(
      decoration: bab.locked
          ? BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.cardFillLightLocked,
                  AppColors.cardFillLightLocked,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorderLocked),
            )
          : BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.cardFill, AppColors.cardFillLight],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),

      child: Stack(
        children: [
          Padding(
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
                    color: bab.locked
                        ? AppColors.textDisabled
                        : AppColors.textP,
                  ),
                ),

                // Text(
                //   bab.materi.judulLatin,
                //   textAlign: TextAlign.center,

                //   style: const TextStyle(fontSize: 12, color: AppColors.textS),

                //   overflow: TextOverflow.ellipsis,
                //   maxLines: 3,
                // ),
              ],
            ),
          ),

          // BADGE NILAI
          if (bab.quiz?.nilai != 0.0)
            Positioned(
              right: 10,
              bottom: 10,

              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),

                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(999),
                ),

                child: Text(
                  'الدرجة :  ${bab.quiz!.nilai.toInt()}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textP,
                  ),
                ),
              ),
            ),
        ],
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
            // const SizedBox(height: 8),
            // Text(
            //   subtitle,
            //   style: const TextStyle(fontSize: 12, color: AppColors.textS),
            //   textAlign: TextAlign.center,
            // ),
          ],
        ),
      ),
    ),
  );
}

Widget _welcomeCard(BuildContext context) {
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
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أهلاً بكم في تانكي، هيا نتعلم معاً بمتعة!',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textP,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Image.asset('lib/assets/cakra.png', scale: 3),
        ],
      ),
    ),
  );
}
