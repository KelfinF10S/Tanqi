import 'package:flutter/material.dart';
import 'package:tanqiy/core/colors.dart';

class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bodyGradient),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
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
            const SizedBox(height: 8),
            const Text(
              '',
              style: TextStyle(fontSize: 16, color: AppColors.textS),
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
                _buildCourseCard(
                  context,
                  'أنواع الكلمات',
                  'الباب الأول',
                  'assets/images/flutter.png',
                  '/page1',
                ),
                _buildCourseCard(
                  context,
                  'دليل الاستخدام ',
                  '',
                  'assets/images/design.png',
                  '/page2',
                ),
                _buildCourseCard(
                  context,
                  'الباب الثاني',
                  'المعرب والمبني',
                  'assets/images/business.png',
                  '/page3',
                ),
                _buildCourseCard(
                  context,
                  'الباب الثالث',
                  'انواع الجمل ',
                  'assets/images/language.png',
                  '/page4',
                ),
                _buildCourseCard(
                  context,
                  ' الباب الرابع',
                  'انواع التراكيب والأساليب ',
                  'assets/images/music.png',
                  '/page5',
                ),
                _buildCourseCard(
                  context,
                  'لعبة إلكترونية ',
                  '',
                  'assets/images/time.png',
                  '/page1',
                ),
              ],
            ),
          ],
        ),
      ),
      
    );
  }

  Widget _buildCategoryChip(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(color: AppColors.textP)),
      backgroundColor: AppColors.cardFill,
      labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildCourseCard(
    BuildContext context,
    String title,
    String description,
    String imagePath,
    String route,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.cardFill, AppColors.cardFillLight],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                description,
                style: const TextStyle(fontSize: 14, color: AppColors.textS),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}