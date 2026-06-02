import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:tanqiy/core/colors.dart';
import 'package:tanqiy/pages/splashscreen.dart';
import 'pages/bab1.dart';
import 'pages/page2.dart';
import 'pages/page3.dart';
import 'pages/page4.dart';
import 'pages/page5.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TANQI Learning App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/menu': (context) => const MenuPage(),
        '/page1': (context) => Page1(),
        '/page2': (context) => Page2(),
        '/page3': (context) => Page3(),
        '/page4': (context) => Page4(),
        '/page5': (context) => Page5(),
        '/splash': (context) => SplashScreen(),
      },
    );
  }
}

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  bool _isSearchVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تنقي',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: AppColors.appBarTitle,
          ),
        ),
        backgroundColor: AppColors.appBarBg,
        elevation: 0,
        foregroundColor: AppColors.textP,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textP),
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.textP),
            onPressed: () {},
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.appBarGradient,
          ),
        ),
        bottom: _isSearchVisible
            ? PreferredSize(
                preferredSize: const Size.fromHeight(48.0),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari kursus...',
                      hintStyle: const TextStyle(color: AppColors.textS),
                      filled: true,
                      fillColor: AppColors.cardFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.search, color: AppColors.textS),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    style: const TextStyle(color: AppColors.textP),
                    cursorColor: AppColors.textP,
                  ),
                ),
              )
            : null,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.bodyGradient,
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const SizedBox(height: 24),
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
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textS,
              ),
            ),
            const SizedBox(height: 24),
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
                _buildCourseCard(context, 'أنواع الكلمات', 'الباب الأول', 'assets/images/flutter.png', '/page1'),
                _buildCourseCard(context, 'دليل الاستخدام ', '', 'assets/images/design.png', '/page2'),
                _buildCourseCard(context, 'الباب الثاني', 'المعرب والمبني', 'assets/images/business.png', '/page3'),
                _buildCourseCard(context, 'الباب الثالث', 'انواع الجمل ', 'assets/images/language.png', '/page4'),
                _buildCourseCard(context, ' الباب الرابع', 'انواع التراكيب والأساليب ', 'assets/images/music.png', '/page5'),
                _buildCourseCard(context, 'لعبة إلكترونية ', '', 'assets/images/time.png', '/page1'),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.bottomNavBg,
        selectedItemColor: AppColors.textP,
        unselectedItemColor: AppColors.textS,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Jelajahi'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Kelas Saya'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
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

  Widget _buildCourseCard(BuildContext context, String title, String description, String imagePath, String route) {
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
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textS,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}