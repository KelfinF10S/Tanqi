import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tanqiy/core/colors.dart';

// ── Model ────────────────────────────────────────────────────────────────────

enum MemberRole { murid, guru }

class ClassMember {
  final String username;
  final int level;
  final int currentXP;
  final int maxXP;
  final int babSelesai;
  final MemberRole role;

  const ClassMember({
    required this.username,
    required this.level,
    required this.currentXP,
    required this.maxXP,
    required this.babSelesai,
    required this.role,
  });

  String get initials {
    final parts = username.trim().split(' ');
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return username.substring(0, username.length >= 2 ? 2 : 1).toUpperCase();
  }

  double get xpProgress =>
      maxXP == 0 ? 0 : (currentXP / maxXP).clamp(0.0, 1.0);

  int get xpRemaining => maxXP - currentXP;

  bool get isMaxLevel => level >= 10;
}

// ── Dummy Data ────────────────────────────────────────────────────────────────

final List<ClassMember> _dummyMembers = [
  ClassMember(
    username: 'Ustadz Ahmad Fauzi',
    level: 10,
    currentXP: 5000,
    maxXP: 5000,
    babSelesai: 30,
    role: MemberRole.guru,
  ),
  ClassMember(
    username: 'Ustadzah Maryam',
    level: 9,
    currentXP: 4200,
    maxXP: 5000,
    babSelesai: 27,
    role: MemberRole.guru,
  ),
  ClassMember(
    username: 'Bilal Hakim',
    level: 5,
    currentXP: 1800,
    maxXP: 2500,
    babSelesai: 12,
    role: MemberRole.murid,
  ),
  ClassMember(
    username: 'Fatimah Zahra',
    level: 7,
    currentXP: 3100,
    maxXP: 4000,
    babSelesai: 19,
    role: MemberRole.murid,
  ),
  ClassMember(
    username: 'Yusuf Abdillah',
    level: 3,
    currentXP: 900,
    maxXP: 1500,
    babSelesai: 6,
    role: MemberRole.murid,
  ),
  ClassMember(
    username: 'Khansa Nabilah',
    level: 6,
    currentXP: 2400,
    maxXP: 3000,
    babSelesai: 15,
    role: MemberRole.murid,
  ),
  ClassMember(
    username: 'Ibrahim Malik',
    level: 4,
    currentXP: 1200,
    maxXP: 2000,
    babSelesai: 9,
    role: MemberRole.murid,
  ),
  ClassMember(
    username: 'Aisyah Putri',
    level: 8,
    currentXP: 3600,
    maxXP: 4500,
    babSelesai: 22,
    role: MemberRole.murid,
  ),
  ClassMember(
    username: 'Hasan Basri',
    level: 2,
    currentXP: 450,
    maxXP: 1000,
    babSelesai: 3,
    role: MemberRole.murid,
  ),
  ClassMember(
    username: 'Zainab Aulia',
    level: 5,
    currentXP: 2100,
    maxXP: 2500,
    babSelesai: 11,
    role: MemberRole.murid,
  ),
];

// ── Page ─────────────────────────────────────────────────────────────────────

class KelasPage extends StatefulWidget {
  const KelasPage({super.key});

  @override
  State<KelasPage> createState() => _KelasPageState();
}

class _KelasPageState extends State<KelasPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  final Set<int> _expandedIndexes = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ClassMember> get _filtered {
    if (_query.trim().isEmpty) return _dummyMembers;
    return _dummyMembers
        .where((m) =>
            m.username.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    // Pisahkan guru & murid
    final gurus = filtered.where((m) => m.role == MemberRole.guru).toList();
    final murids = filtered.where((m) => m.role == MemberRole.murid).toList();

    return Scaffold(
      backgroundColor: AppColors.gradientBottom,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: filtered.isEmpty
              ? _buildEmpty()
              : ListView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  children: [
                    // ── Header Info ──────────────────────────────
                    _buildHeaderInfo(),
                    const SizedBox(height: 24),

                    // ── Guru ─────────────────────────────────────
                    if (gurus.isNotEmpty) ...[
                      _buildSectionLabel(
                        icon: Icons.school_rounded,
                        label: 'Pengajar',
                        count: gurus.length,
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(gurus.length, (i) {
                        final globalIndex = _dummyMembers.indexOf(gurus[i]);
                        return _MemberCard(
                          member: gurus[i],
                          isExpanded: _expandedIndexes.contains(globalIndex),
                          onToggle: () => setState(() {
                            if (_expandedIndexes.contains(globalIndex)) {
                              _expandedIndexes.remove(globalIndex);
                            } else {
                              _expandedIndexes.add(globalIndex);
                            }
                          }),
                        );
                      }),
                      const SizedBox(height: 24),
                    ],

                    // ── Murid ────────────────────────────────────
                    if (murids.isNotEmpty) ...[
                      _buildSectionLabel(
                        icon: Icons.people_alt_rounded,
                        label: 'Anggota Kelas',
                        count: murids.length,
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(murids.length, (i) {
                        final globalIndex = _dummyMembers.indexOf(murids[i]);
                        return _MemberCard(
                          member: murids[i],
                          isExpanded: _expandedIndexes.contains(globalIndex),
                          onToggle: () => setState(() {
                            if (_expandedIndexes.contains(globalIndex)) {
                              _expandedIndexes.remove(globalIndex);
                            } else {
                              _expandedIndexes.add(globalIndex);
                            }
                          }),
                        );
                      }),
                    ],

                    const SizedBox(height: 16),
                  ],
                ),
        ),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 56),
      child: Container(
        decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Title row
              SizedBox(
                height: kToolbarHeight,
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.appBarTitle,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الفصل الدراسي',
                            style: TextStyle(
                              color: AppColors.appBarTitle,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            'Kelas Saya',
                            style: TextStyle(
                              color: AppColors.appBarTitle,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.cardFillLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Text(
                        '${_dummyMembers.length} Anggota',
                        style: const TextStyle(
                          color: AppColors.appBarTitle,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Search bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.cardFillLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.search_rounded,
                        color: AppColors.textS,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _query = val),
                          style: const TextStyle(
                            color: AppColors.textP,
                            fontSize: 14,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Cari anggota...',
                            hintStyle: TextStyle(
                              color: AppColors.textS,
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (_query.isNotEmpty)
                        GestureDetector(
                          onTap: () => setState(() {
                            _query = '';
                            _searchController.clear();
                          }),
                          child: const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Icon(
                              Icons.close_rounded,
                              color: AppColors.textS,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header Info ─────────────────────────────────────────────────────────────

  Widget _buildHeaderInfo() {
    final totalGuru =
        _dummyMembers.where((m) => m.role == MemberRole.guru).length;
    final totalMurid =
        _dummyMembers.where((m) => m.role == MemberRole.murid).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardFillLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          _buildInfoStat(
            icon: Icons.school_rounded,
            value: '$totalGuru',
            label: 'Guru',
          ),
          _buildDivider(),
          _buildInfoStat(
            icon: Icons.people_alt_rounded,
            value: '$totalMurid',
            label: 'Murid',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.appBarTitle, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textP,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.textS, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.cardBorder,
    );
  }

  // ── Section Label ────────────────────────────────────────────────────────────

  Widget _buildSectionLabel({
    required IconData icon,
    required String label,
    required int count,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: AppColors.appBarGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.appBarTitle, size: 14),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.appBarTitle,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.cardFillLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: AppColors.textS,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ── Empty State ──────────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            color: AppColors.textS,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Tidak ditemukan',
            style: const TextStyle(
              color: AppColors.textP,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tidak ada anggota dengan nama "$_query"',
            style: const TextStyle(color: AppColors.textS, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Member Card ───────────────────────────────────────────────────────────────

class _MemberCard extends StatelessWidget {
  final ClassMember member;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _MemberCard({
    required this.member,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.cardFillLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpanded
                ? AppColors.appBarTitle.withOpacity(0.5)
                : AppColors.cardBorder,
            width: isExpanded ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            // ── Collapsed Header ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.appBarGradient,
                      border: Border.all(
                        color: member.role == MemberRole.guru
                            ? AppColors.appBarTitle
                            : AppColors.cardBorder,
                        width: member.role == MemberRole.guru ? 2 : 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        member.initials,
                        style: const TextStyle(
                          color: AppColors.appBarTitle,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Name & Role
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.username,
                          style: const TextStyle(
                            color: AppColors.textP,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            _roleChip(),
                            const SizedBox(width: 8),
                            Text(
                              'Level ${member.level}',
                              style: const TextStyle(
                                color: AppColors.textS,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Chevron
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textS,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            // ── Expanded Detail ─────────────────────────────
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: _buildExpandedDetail(),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleChip() {
    final isGuru = member.role == MemberRole.guru;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        gradient: isGuru ? AppColors.appBarGradient : null,
        color: isGuru ? null : AppColors.cardFillLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGuru
              ? AppColors.appBarTitle.withOpacity(0.4)
              : AppColors.cardBorder,
        ),
      ),
      child: Text(
        isGuru ? '👑 Guru' : '📖 Murid',
        style: TextStyle(
          color: isGuru ? AppColors.appBarTitle : AppColors.textS,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildExpandedDetail() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x10FFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          _statItem(
            icon: Icons.star_rounded,
            label: 'Level',
            value: '${member.level}',
          ),
          const SizedBox(width: 10),
          _statItem(
            icon: Icons.bolt_rounded,
            label: 'Total XP',
            value: '${member.currentXP}',
          ),
          const SizedBox(width: 10),
          _statItem(
            icon: Icons.menu_book_rounded,
            label: 'Bab Selesai',
            value: '${member.babSelesai}',
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardFillLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.appBarTitle, size: 16),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textP,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textS,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
