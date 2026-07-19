import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tanqiy/controllers/auth_controller.dart';
import 'package:tanqiy/controllers/leaderboard_controller.dart';
import 'package:tanqiy/core/colors.dart';
import 'package:tanqiy/models/class_member_model.dart';
import 'package:tanqiy/widgets/custom_appbar.dart';

// ── Page ─────────────────────────────────────────────────────────────────────

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LeaderboardController());
    final auth_controller = Get.find<AuthController>();

    String myUsername = auth_controller.currentUser.value?.username ?? '';

    return Scaffold(
      backgroundColor: AppColors.gradientBottom,
      appBar: CustomAppBar(
        arabicTitle: 'دليل الاستخدام',
       
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          decoration: const BoxDecoration(gradient: AppColors.splashGradient),
          child: SafeArea(
            child: Builder(
              builder: (context) {
                final myRank = controller.rankOf(myUsername);
                final myData = controller.memberOf(myUsername);

                return Column(
                  children: [
                    // ── Kartu profil sendiri, selalu terlihat, tidak ikut scroll ──
                    if (myData != null && myRank != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                        child: _MyRankCard(me: myData, rank: myRank),
                      ),

                    // ── Daftar seluruh pengguna ─────────────────────────
                    Expanded(
                      child: RefreshIndicator(
                        color: Colors.white, // warna panah/spinner
                        backgroundColor:
                            AppColors.cardFillLight, // warna lingkaran belakang
                        onRefresh: controller.refreshLeaderboard,
                        child: controller.leaderboard.isEmpty
                            ? ListView(
                                // physics ini wajib supaya pull-to-refresh
                                // tetap bisa ditarik meskipun list kosong
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(
                                    height:
                                        MediaQuery.sizeOf(context).height * 0.6,
                                    child: _buildEmpty(),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  8,
                                  20,
                                  20,
                                ),
                                itemCount: controller.leaderboard.length,
                                itemBuilder: (context, i) {
                                  final user = controller.leaderboard[i];
                                  final rank = i + 1;
                                  final isMe = user.username == myUsername;
                                  return _LeaderboardTile(
                                    user: user,
                                    rank: rank,
                                    isMe: isMe,
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      }),
    );
  }

  // ── Empty State ──────────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.leaderboard, color: AppColors.textS, size: 48),
          const SizedBox(height: 12),
          const Text(
            'لا يوجد بيانات بعد',
            style: TextStyle(
              color: AppColors.textP,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Kartu profil sendiri ─────────────────────────────────────────────────────

class _MyRankCard extends StatelessWidget {
  final ClassMember me;
  final int rank;

  const _MyRankCard({required this.me, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.appBarGradient,
        // borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.appBarTitle.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'ترتيبك الحالي',
            style: TextStyle(
              color: AppColors.appBarTitle.withOpacity(0.85),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Badge / nomor peringkat
              _RankBadge(rank: rank, size: 46),
              const SizedBox(width: 14),

              // Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cardFillLight,
                  border: Border.all(color: AppColors.appBarTitle, width: 2),
                ),
                child: Center(
                  child: Text(
                    me.initials,
                    style: const TextStyle(
                      color: AppColors.appBarTitle,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Nama & level
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      me.username,
                      style: const TextStyle(
                        color: AppColors.appBarTitle,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'الفصول المكتملة ${me.babSelesai}',
                      style: TextStyle(
                        color: AppColors.appBarTitle.withOpacity(0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // XP
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${me.currentXP}',
                    style: const TextStyle(
                      color: AppColors.appBarTitle,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'XP',
                    style: TextStyle(
                      color: AppColors.appBarTitle.withOpacity(0.85),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Baris satu pengguna di daftar ───────────────────────────────────────────

class _LeaderboardTile extends StatelessWidget {
  final ClassMember user;
  final int rank;
  final bool isMe;

  const _LeaderboardTile({
    required this.user,
    required this.rank,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardFillLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rank == 1
              ? const Color(0xFFFFD700).withOpacity(0.7)
              : isMe
              ? AppColors.appBarTitle.withOpacity(0.5)
              : AppColors.cardBorder,
          width: rank == 1 || isMe ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          _RankBadge(rank: rank, size: 45),
          const SizedBox(width: 12),

          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.appBarGradient,
              border: Border.all(color: AppColors.cardBorder, width: 1.5),
            ),
            child: Center(
              child: Text(
                user.initials,
                style: const TextStyle(
                  color: AppColors.appBarTitle,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Nama & level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: const TextStyle(
                    color: AppColors.textP,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'الفصول المكتملة ${user.babSelesai}',
                  style: const TextStyle(color: AppColors.textS, fontSize: 11),
                ),
              ],
            ),
          ),

          // XP
          Text(
            '${user.currentXP} XP',
            style: const TextStyle(
              color: AppColors.textP,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Badge Peringkat (1-4 pakai gambar, rank 1 dibuat lebih besar & mentereng) ─

class _RankBadge extends StatelessWidget {
  final int rank;
  final double size;

  const _RankBadge({required this.rank, required this.size});

  bool get _isChampion => rank == 1;

  // Rank 1 dibuat 50% lebih besar dari ukuran dasar supaya terasa spesial.
  double get _effectiveSize => _isChampion ? size * 1.2 : size;

  // Daftarkan foldernya di pubspec.yaml, contoh:
  // assets:
  //   - lib/assets/
  String? get _assetPath {
    if (rank < 1 || rank > 4) return null;
    return 'lib/assets/badge$rank.png';
  }

  @override
  Widget build(BuildContext context) {
    final path = _assetPath;
    final effectiveSize = _effectiveSize;

    if (path != null) {
      final image = Image.asset(
        path,
        fit: BoxFit.contain,
        // fallback ke nomor biasa kalau asset belum ditambahkan
        errorBuilder: (context, error, stackTrace) =>
            _numberCircle(effectiveSize),
      );

      // Rank 1 dikasih lingkaran emas bercahaya di belakang gambarnya.
      if (_isChampion) {
        return Container(
          width: effectiveSize,
          height: effectiveSize,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.55),
                blurRadius: 14,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipOval(child: image),
        );
      }

      return SizedBox(
        width: effectiveSize,
        height: effectiveSize,
        child: image,
      );
    }

    return _numberCircle(effectiveSize);
  }

  Widget _numberCircle(double effectiveSize) {
    return Container(
      width: effectiveSize,
      height: effectiveSize,
      decoration: BoxDecoration(
        color: AppColors.cardFillLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Center(
        child: Text(
          '$rank',
          style: TextStyle(
            color: AppColors.textP,
            fontSize: effectiveSize * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
