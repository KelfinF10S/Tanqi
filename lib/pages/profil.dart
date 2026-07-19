import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tanqiy/controllers/auth_controller.dart';
import 'package:tanqiy/controllers/leaderboard_controller.dart';
import 'package:tanqiy/core/colors.dart';
import 'package:tanqiy/data/auth_local.dart';
import 'package:tanqiy/models/class_member_model.dart';
import 'package:tanqiy/pages/auth.dart';
import 'package:tanqiy/widgets/rolechip.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final auth_controller = Get.find<AuthController>();
  final leaderboard_controller = Get.put(LeaderboardController());
  bool _isEditing = false;
  late TextEditingController _usernameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    auth_controller.refreshUser();
    leaderboard_controller.fetchLeaderboard();

    _usernameController = TextEditingController(
      text: auth_controller.currentUser.value?.username,
    );

    ever(auth_controller.currentUser, (user) {
      if (!_isEditing && user != null) {
        _usernameController.text = user.username;
      }
    });
  }

  @override
  void dispose() {
    _usernameController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gradientBottom,
      body: Obx(() {
        final user = auth_controller.currentUser.value;

        if (user == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.appBarTitle),
          );
        }

        final myRank = leaderboard_controller.rankOf(user.username);

        return Container(
          decoration: const BoxDecoration(gradient: AppColors.splashGradient),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Header ──────────────────────────────────
                  const Text(
                    'الملف الشخصي',
                    style: TextStyle(
                      color: AppColors.appBarTitle,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const Text(
                    'ملفي الشخصي',
                    style: TextStyle(color: AppColors.textS, fontSize: 13),
                  ),

                  const SizedBox(height: 36),

                  // ── Avatar ───────────────────────────────────
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.appBarGradient,
                      border: Border.all(
                        color: AppColors.appBarTitle,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gradientTop.withOpacity(0.5),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        user.initials,
                        style: const TextStyle(
                          color: AppColors.appBarTitle,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  roleChip(
                    ClassMember(
                      id: user.id!,
                      username: user.username,
                      level: user.level,
                      currentXP: user.currentXP,
                      // maxXP: user.maxXP,
                      babSelesai: user.babSelesai,
                      role: user.role == 'murid'
                          ? MemberRole.murid
                          : MemberRole.guru,
                    ),
                  ),
                  SizedBox(height: 15),

                  // ── Card Username ────────────────────────────
                  _buildCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'اسم المستخدم',
                            style: TextStyle(
                              color: AppColors.appBarTitle,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                color: AppColors.textS,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _isEditing
                                    ? TextFormField(
                                        controller: _usernameController,
                                        autofocus: true,
                                        style: const TextStyle(
                                          color: AppColors.textP,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 10,
                                              ),
                                          filled: true,
                                          fillColor: AppColors.cardFillLight,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: const BorderSide(
                                              color: AppColors.cardBorder,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: const BorderSide(
                                              color: AppColors.cardBorder,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: const BorderSide(
                                              color: AppColors.appBarTitle,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                        validator: (val) {
                                          if (val == null ||
                                              val.trim().isEmpty) {
                                            return 'لا يمكن أن يكون اسم المستخدم فارغًا';
                                          }
                                          if (val.trim().length < 3) {
                                            return 'الحد الأدنى 3 أحرف';
                                          }
                                          return null;
                                        },
                                      )
                                    : Text(
                                        user.username,
                                        style: const TextStyle(
                                          color: AppColors.textP,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 8),
                              // Tombol Edit / Simpan
                              GestureDetector(
                                onTap: () async {
                                  if (_isEditing) {
                                    if (_formKey.currentState!.validate()) {
                                      final success = await auth_controller
                                          .updateUsername(
                                            _usernameController.text,
                                          );
                                      if (success) {
                                        setState(() => _isEditing = false);
                                      }
                                    }
                                  } else {
                                    setState(() => _isEditing = true);
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: _isEditing
                                        ? const LinearGradient(
                                            colors: [
                                              Color(0xFF22C55E),
                                              Color(0xFF16A34A),
                                            ],
                                          )
                                        : AppColors.appBarGradient,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _isEditing
                                            ? Icons.check
                                            : Icons.edit_outlined,
                                        color: AppColors.textP,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _isEditing ? 'حفظ' : 'تعديل',
                                        style: const TextStyle(
                                          color: AppColors.textP,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Tombol Batal saat editing
                          if (_isEditing) ...[
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isEditing = false;
                                  // Reset ke username asli dari model
                                  _usernameController.text = user.username;
                                });
                              },
                              child: const Text(
                                'إلغاء',
                                style: TextStyle(
                                  color: AppColors.textS,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: AppColors.appBarGradient,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.emoji_events,
                                color: AppColors.appBarTitle,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'الترتيب والإنجازات',
                              style: TextStyle(
                                color: AppColors.appBarTitle,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.cardFillLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.leaderboard,
                                color: AppColors.appBarTitle,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                myRank != null ? '#$myRank' : '-',
                                style: const TextStyle(
                                  color: AppColors.appBarTitle,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'الترتيب الحالي',
                                style: TextStyle(
                                  color: AppColors.textS,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        if (myRank != null && myRank <= 4)
                          _buildBadgeCard(myRank)
                        else
                          _buildNoBadgeCard(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Informasi Bab Selesai ────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.menu_book,
                          label: 'الفصول المكتملة',
                          value: '${user.babSelesai}',
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.star,
                          label: 'إجمالي XP',
                          value: '${user.currentXP}',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ── Tombol Logout ────────────────────────────
                  GestureDetector(
                    onTap: () {
                      Get.dialog(
                        AlertDialog(
                          backgroundColor: const Color.fromARGB(255, 40, 20, 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: AppColors.cardBorder),
                          ),
                          title: const Text(
                            'تسجيل الخروج؟',
                            style: TextStyle(color: AppColors.appBarTitle),
                          ),
                          content: const Text(
                            'هل أنت متأكد أنك تريد تسجيل الخروج من هذا الحساب؟',
                            style: TextStyle(color: AppColors.textS),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text(
                                'إلغاء',
                                style: TextStyle(color: AppColors.textS),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.back();
                                AuthStorage.clearAll();
                                Get.offAll(() => const AuthPage());
                              },
                              child: const Text(
                                'تسجيل الخروج',
                                style: TextStyle(color: Color(0xFFEF4444)),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.cardFillLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFEF4444).withOpacity(0.5),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout,
                            color: Color(0xFFEF4444),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'تسجيل الخروج',
                            style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBadgeCard(int rank) {
    const titles = {
      1: 'المركز الأول',
      2: 'المركز الثاني',
      3: 'المركز الثالث',
      4: 'المركز الرابع',
    };

    const descriptions = {
      1: 'صاحب أعلى عدد من\nنقاط الخبرة حاليًا',
      2: 'في المرتبة الثانية\nضمن المتصدرين',
      3: 'في المرتبة الثالثة\nضمن المتصدرين',
      4: 'ضمن أفضل أربعة\nفي الترتيب',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardFillLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Expanded(
                child: Text(
                  'شارة',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.workspace_premium,
                color: AppColors.appBarTitle,
                size: 20,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    titles[rank] ?? 'المركز $rank',
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: AppColors.appBarTitle,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descriptions[rank] ?? '',
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textS,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: AppColors.cardFillLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Image.asset(
                  'lib/assets/badge$rank.png',
                  width: 80,
                  height: 80,
                  // fallback ke ikon biasa kalau asset belum ditambahkan
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.workspace_premium,
                    color: AppColors.appBarTitle,
                    size: 48,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoBadgeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardFillLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'لم تحصل على شارة بعد.\nادخل ضمن أفضل أربعة\nللحصول على الشارة.',
              textAlign: TextAlign.end,
              style: TextStyle(color: AppColors.textS, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.workspace_premium_outlined,
            color: AppColors.textS,
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardFillLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: child,
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap, // <- nullable
  }) {
    return GestureDetector(
      onTap: onTap, // kalau null otomatis tidak bisa ditekan
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardFillLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.appBarTitle, size: 22),

            const SizedBox(height: 6),

            Text(
              value,
              style: const TextStyle(
                color: AppColors.textP,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              label,
              style: const TextStyle(color: AppColors.textS, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
