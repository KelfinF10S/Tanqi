import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tanqiy/controllers/babkuis_controller.dart';
import 'package:tanqiy/pages/kuis_page.dart';

void showRetryDialog(
  BuildContext context,
  int babId,
  String babJudul,
  Color accent,
) {
  Get.dialog(
    AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text('إعادة المحاولة', style: TextStyle(color: Colors.white)),
      content: const Text(
        'سيتم إعادة تعيين الاختبار وبدء محاولة جديدة. هل تريد المتابعة؟',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: () async {
            Get.back(); // tutup dialog
            Get.back(); // tutup halaman review

            final controller = Get.put(QuizController(), tag: 'kuis_$babId');
            await controller.retryKuis(babId);

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => KuisPage(babId: babId, babJudul: babJudul),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.black,
          ),
          child: const Text('إعادة المحاولة'),
        ),
      ],
    ),
    barrierDismissible: false,
  );
}