import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tanqiy/controllers/babkuis_controller.dart';
import 'package:tanqiy/core/colors.dart';
import 'package:tanqiy/widgets/retry_dialog.dart';

class KuisReviewPage extends StatefulWidget {
  final int babId;
  final String babJudul;

  const KuisReviewPage({
    super.key,
    required this.babId,
    required this.babJudul,
  });

  @override
  State<KuisReviewPage> createState() => _KuisReviewPageState();
}

class _KuisReviewPageState extends State<KuisReviewPage> {
  late final ReviewController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ReviewController(), tag: 'review_${widget.babId}');
    controller.loadReview(widget.babId);
  }

  @override
  void dispose() {
    Get.delete<ReviewController>(tag: 'review_${widget.babId}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.gold;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text(
          'نتيجة الاختبار',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: accent));
        }

        final nilai = controller.nilai.value;
        final lulus = nilai >= 70;
        final benar = controller.soalList
            .where((s) => s.isCorrect == true)
            .length;
        final total = controller.soalList.length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent.withOpacity(0.15), AppColors.surface],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accent.withOpacity(0.4)),
                ),
                child: Column(
                  children: [
                    Icon(
                      lulus ? Icons.emoji_events_rounded : Icons.refresh_rounded,
                      color: lulus ? accent : Colors.orange,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      nilai.toStringAsFixed(0),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      lulus
                          ? 'ممتاز! لقد اجتزت الاختبار'
                          : 'تحتاج ٧٠ على الأقل للنجاح',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$benar / $total إجابات صحيحة',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (!lulus)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => showRetryDialog(
                      context,
                      widget.babId,
                      widget.babJudul,
                      accent,
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('إعادة المحاولة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 12),
              const Text(
                'مراجعة الإجابات',
                style: TextStyle(
                  color: accent,
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...controller.soalList.map((s) {
                final isCorrect = s.isCorrect ?? false;
                final color = isCorrect ? Colors.green : Colors.red;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isCorrect
                                ? Icons.check_circle
                                : Icons.cancel_rounded,
                            color: color,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isCorrect ? 'صحيح' : 'خطأ',
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.pertanyaan,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                      if (!isCorrect) ...[
                        const SizedBox(height: 6),
                        Text(
                          'جوابك: ${s.jawabanUser}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }
}