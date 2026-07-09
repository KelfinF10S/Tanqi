import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tanqiy/controllers/babkuis_controller.dart';
import 'package:tanqiy/core/colors.dart';
import 'package:tanqiy/pages/kuis_review_page.dart';
import 'package:tanqiy/widgets/quiz_soal_widgets.dart';

class KuisPage extends StatefulWidget {
  final int babId;
  final String babJudul;

  const KuisPage({super.key, required this.babId, required this.babJudul});

  @override
  State<KuisPage> createState() => _KuisPageState();
}

class _KuisPageState extends State<KuisPage> {
  late final QuizController controller;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(QuizController(), tag: 'kuis_${widget.babId}');
    controller.loadKuis(widget.babId);

    ever(controller.showReview, (bool val) {
      if (val && !_navigated) {
        _navigated = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => KuisReviewPage(
                babId: widget.babId,
                babJudul: widget.babJudul,
              ),
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    Get.delete<QuizController>(tag: 'kuis_${widget.babId}');
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
        title: Text(
          widget.babJudul,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.soalAktif.value == null) {
          return const Center(child: CircularProgressIndicator(color: accent));
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Text(
              controller.errorMessage.value,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          );
        }

        final meta = controller.kuisMeta.value;
        final soal = controller.soalAktif.value;

        if (soal == null) {
          return const Center(child: CircularProgressIndicator(color: accent));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (meta != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: meta.totalSoal == 0
                        ? 0
                        : meta.sudahDijawab / meta.totalSoal,
                    minHeight: 6,
                    backgroundColor: AppColors.divider,
                    valueColor: const AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'سؤال ${meta.sudahDijawab + 1} من ${meta.totalSoal}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
              ],
              QuizSoalWidget(soal: soal, controller: controller, accent: accent),
              const SizedBox(height: 20),
              Obx(() {
                final hasil = controller.hasilAktif.value;
                final jawabanDipilih = controller.jawabanDipilih.value;

                if (hasil == null) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: jawabanDipilih == null
                          ? null
                          : controller.submitJawaban,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: accent.withOpacity(0.3),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isSubmitting.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'تأكيد',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  );
                }

                final isCorrect = hasil.isCorrect;
                final color = isCorrect ? Colors.green : Colors.red;

                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel_rounded,
                            color: color,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isCorrect ? 'إجابة صحيحة!' : 'إجابة خاطئة',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCorrect &&
                        hasil.penjelasan != null &&
                        hasil.penjelasan!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          hasil.penjelasan!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.lanjutSoal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'متابعة',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        );
      }),
    );
  }
}