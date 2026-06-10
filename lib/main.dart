import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:tanqiy/controllers/auth_controller.dart';
import 'package:tanqiy/core/colors.dart';
import 'package:tanqiy/pages/beranda.dart';
import 'package:tanqiy/pages/games.dart';
import 'package:tanqiy/pages/jelajahi.dart';
import 'package:tanqiy/pages/kelas.dart';
import 'package:tanqiy/pages/profil.dart';
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/menu': (context) => const MenuPage(),
        // '/page1': (context) => Page1(),
        '/panduan': (context) => Page2(),
        // '/page3': (context) => Page3(),
        // '/page4': (context) => Page4(),
        // '/page5': (context) => Page5(),
        '/games': (context) => GamesPage(),
        '/splash': (context) => SplashScreen(),
      },
    );
  }
}

// ============================================================
//  MENU PAGE (Shell dengan Bottom Nav + IndexedStack)
// ============================================================
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _currentIndex = 0;
  bool _isSearchVisible = false;

  final List<Widget> _pages = [
    Beranda(),
    Jelajahi(),
    KelasPage(),
    ProfilePage(),
  ];

  // Label AppBar per tab
  final List<String> _titles = ['تنقي', 'جستجو', 'كلاسي', 'پروفیل'];
  final List<bool> _showAppBar = [true, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _showAppBar[_currentIndex]
          ? AppBar(
              title: Text(
                _titles[_currentIndex],
                style: const TextStyle(
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
                  onPressed: () =>
                      setState(() => _isSearchVisible = !_isSearchVisible),
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: AppColors.textP),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return DraggableScrollableSheet(
                          expand: false,
                          builder: (context, scrollController) {
                            return ListView(
                              controller: scrollController,
                              children: [ListTile(title: Text("Pengaturan"))],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.appBarGradient,
                ),
              ),
              bottom: _isSearchVisible
                  ? PreferredSize(
                      preferredSize: const Size.fromHeight(60.0),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 16.0,
                          bottom: 8.0,
                          top: 8,
                        ),
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
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.textS,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                            ),
                          ),
                          style: const TextStyle(color: AppColors.textP),
                          cursorColor: AppColors.textP,
                        ),
                      ),
                    )
                  : null,
            )
          : null,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.bottomNavBg,
        selectedItemColor: AppColors.textP,
        unselectedItemColor: AppColors.textS,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (index != 0) _isSearchVisible = false;
          });

          if (index == 3) {
            Get.find<AuthController>().refreshUser();
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Jelajahi'),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Kelas Saya',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// ============================================================
//  HOME BODY (isi tab Beranda)
// ============================================================
class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.bodyGradient),
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
            style: TextStyle(fontSize: 16, color: AppColors.textS),
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
              _buildCourseCard(
                context,
                'أنواع الكلمات',
                'الباب الأول',
                '/page1',
              ),
              _buildCourseCard(context, 'دليل الاستخدام', '', '/page2'),
              _buildCourseCard(
                context,
                'الباب الثاني',
                'المعرب والمبني',
                '/page3',
              ),
              _buildCourseCard(
                context,
                'الباب الثالث',
                'انواع الجمل',
                '/page4',
              ),
              _buildCourseCard(
                context,
                'الباب الرابع',
                'انواع التراكيب والأساليب',
                '/page5',
              ),
              _buildCourseCard(context, 'لعبة إلكترونية', '', '/page1'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(
    BuildContext context,
    String title,
    String description,
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
