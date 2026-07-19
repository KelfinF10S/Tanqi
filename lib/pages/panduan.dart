import 'package:flutter/material.dart';
import 'package:tanqiy/core/colors.dart';
import 'package:tanqiy/widgets/custom_appbar.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PanduanPage extends StatefulWidget {
  const PanduanPage({super.key});

  @override
  State<PanduanPage> createState() => _PanduanPageState();
}

class _PanduanPageState extends State<PanduanPage> {
  late YoutubePlayerController controller;

  @override
  void initState() {
    super.initState();

    controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        strictRelatedVideos: true,
        enableCaption: true,
      ),
    );

    controller.loadVideoById(videoId: 'BlenzQEvBzg');
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(arabicTitle: 'دليل الاستخدام'),

      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),

        child: Column(
          children: [
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),

                child: SizedBox(
                  width: double.infinity,
                  height: 260,

                  child: YoutubePlayer(controller: controller),
                ),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),

                children: [
                  _guideTimestampCard(context, controller),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _guideTimestampCard(
  BuildContext context,
  YoutubePlayerController controller,
) {
  final sections = [
    {
      'time': '00:00',
      'titleAr': 'الصفحة الرئيسية',
      'titleId': 'Halaman Beranda',
    },

    {
      'time': '00:23',
      'titleAr': 'المحتوى داخل الفصل',
      'titleId': 'Materi pada Bab',
    },

    {
      'time': '00:52',
      'titleAr': 'كيفية أداء الاختبار',
      'titleId': 'Penjelasan kuis',
    },

    {'time': '01:29', 'titleAr': 'صفحة الصفوف', 'titleId': 'Halaman Kelas'},

    {'time': '01:53', 'titleAr': 'الملف الشخصي', 'titleId': 'Profil'},

    {'time': '02:28', 'titleAr': 'الأوسمة', 'titleId': 'Lencana'},
  ];

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

      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.play_circle_fill_rounded, color: AppColors.textP),

              SizedBox(width: 8),

              Text(
                'دليل الفيديو',

                style: TextStyle(
                  fontSize: 18,

                  fontWeight: FontWeight.bold,

                  color: AppColors.textP,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Image.asset('lib/assets/cakra.png', scale: 4),

              const SizedBox(width: 10),

              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,

                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,

                        vertical: 10,
                      ),

                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,

                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            'أضفت الطوابع الزمنية لمساعدتك على التنقل بسرعة داخل الفيديو',

                            style: TextStyle(
                              fontSize: 12,

                              fontWeight: FontWeight.w600,

                              color: AppColors.textP,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            'Timestamp ini akan membantumu berpindah dengan cepat antar bagian video.',

                            style: TextStyle(
                              fontSize: 10,

                              color: AppColors.textS,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      left: -6,
                      top: 18,

                      child: Transform.rotate(
                        angle: 0.8,

                        child: Container(
                          width: 12,

                          height: 12,

                          color: AppColors.cardBorder,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          ...sections.map((item) {
            return InkWell(
              borderRadius: BorderRadius.circular(10),

              onTap: () async {
                final parts = item['time']!.split(':');

                final minute = int.parse(parts[0]);

                final second = int.parse(parts[1]);

                final totalSeconds = (minute * 60 + second).toDouble();

                await controller.loadVideoById(
                  videoId: 'BlenzQEvBzg',
                  startSeconds: totalSeconds,
                );
              },

              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),

                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,

                        vertical: 6,
                      ),

                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,

                        borderRadius: BorderRadius.circular(8),
                      ),

                      child: Text(
                        item['time']!,

                        style: const TextStyle(
                          fontWeight: FontWeight.bold,

                          color: AppColors.textP,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            item['titleAr']!,

                            style: const TextStyle(
                              fontSize: 14,

                              fontWeight: FontWeight.w600,

                              color: AppColors.textP,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            item['titleId']!,

                            style: const TextStyle(
                              fontSize: 11,

                              color: AppColors.textS,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.play_arrow_rounded,

                      color: AppColors.textP,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    ),
  );
}
