import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tanqiy/controllers/babkuis_controller.dart';
import 'package:tanqiy/core/colors.dart';

Future<void> showRetryDialog(
  QuizController controller,
  int materiId,
  Color accent,
) async {
  Get.dialog(
    AlertDialog(
      title: const Text(
        'إعادة الحل؟',
        textAlign: TextAlign.right,
        style: TextStyle(color: AppColors.textPrimary),
      ),
      content: const Text(
        'سيتم اعتماد نتيجتك الجديدة بدلاً من النتيجة السابقة.\n'
        'تُمنح نقاط الخبرة (XP) في المحاولة الأولى فقط.',
        textAlign: TextAlign.right,
        style: TextStyle(color: AppColors.textPrimary),
      ),
      backgroundColor: AppColors.bg,

      actions: [
        FilledButton(
          onPressed: () => Get.back(),
          child: const Text('إلغاء'),
          style: ButtonStyle(
            side: MaterialStatePropertyAll(BorderSide(color: accent)),
            foregroundColor: MaterialStatePropertyAll(accent),
            backgroundColor: MaterialStatePropertyAll(AppColors.bg)
          ),
        ),
        FilledButton(
          style: ButtonStyle(
            side: MaterialStatePropertyAll(BorderSide(color: accent)),
            backgroundColor: MaterialStatePropertyAll(accent),
            foregroundColor: MaterialStatePropertyAll(AppColors.textP),
          ),
          onPressed: () async {
            Get.back(); // tutup dialog
            await controller.retryMateri(materiId);
          },
          child: const Text('إعادة الحل'),
        ),
      ],
    ),
    barrierDismissible: false,
  );
}
