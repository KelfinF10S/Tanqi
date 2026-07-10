import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tanqiy/controllers/babkuis_controller.dart';
import 'package:tanqiy/core/colors.dart';
import 'package:tanqiy/models/nahwu_node_model.dart';
import 'package:tanqiy/models/nahwu_node_ui_extension.dart'; // <-- WAJIB: sumber accentColor/iconLabel
import 'package:tanqiy/models/materibab_model.dart';
import 'package:tanqiy/models/stimulus_data_model.dart';
import 'package:tanqiy/models/bab_merged_model.dart';
import 'package:tanqiy/pages/kuis_page.dart';
import 'package:tanqiy/pages/loading.dart';
import 'package:tanqiy/widgets/background_painter.dart';

// ─────────────────────────────────────────
//  PAGE 1  (entry point)
// ─────────────────────────────────────────
class BabPage extends StatefulWidget {
  final BabMerged bab;

  const BabPage({super.key, required this.bab});

  @override
  State<BabPage> createState() => _BabPageState();
}

class _BabPageState extends State<BabPage> with SingleTickerProviderStateMixin {
  Future<MateriBAB>? _future;
  late final AnimationController _controller;
  Animation<double>? _fadeIn;
  int _activeKategori = 0;

  @override
  void initState() {
    super.initState();

    final babId = int.tryParse(widget.bab.id) ?? 1;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();

    _future = _initPage(babId);
  }

  Future<MateriBAB> _initPage(int babId) async {
    await Get.find<BabController>().loadSlugMap(babId);
    if (!mounted) {
      throw Exception('Widget sudah tidak aktif');
    }
    return widget.bab.materi;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FutureBuilder<MateriBAB>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingScreen();
          }
          if (snap.hasError) {
            return ErrorScreen(error: snap.error.toString());
          }
          if (!snap.hasData) {
            return const ErrorScreen(error: 'البيانات غير متوفرة');
          }

          return FadeTransition(
            opacity: _fadeIn ?? const AlwaysStoppedAnimation<double>(1),
            child: _MateriBody(
              materi: snap.data!,
              babMerged: widget.bab,
              activeKategori: _activeKategori,
              onKategoriChange: (i) {
                if (!mounted) return;
                setState(() => _activeKategori = i);
              },
              slugToMateriId: Get.find<BabController>().slugToMateriId,
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────
//  MAIN BODY
// ─────────────────────────────────────────
class _MateriBody extends StatelessWidget {
  final MateriBAB materi;
  final BabMerged babMerged;
  final int activeKategori;
  final ValueChanged<int> onKategoriChange;
  final Map<String, int> slugToMateriId;

  const _MateriBody({
    required this.materi,
    required this.babMerged,
    required this.activeKategori,
    required this.onKategoriChange,
    required this.slugToMateriId,
  });

  @override
  Widget build(BuildContext context) {
    final babId = int.tryParse(babMerged.id) ?? 1;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildSliverAppBar(context),
        SliverToBoxAdapter(
          child: _ProgressBanner(
            total: materi.bab.length,
            done: activeKategori,
          ),
        ),
        SliverToBoxAdapter(child: _StimulusSection(stimulus: materi.stimulus)),
        SliverToBoxAdapter(
          child: _KategoriPicker(
            bab: materi.bab,
            active: activeKategori,
            onTap: onKategoriChange,
          ),
        ),
        SliverToBoxAdapter(
          child: _KategoriDetail(
            kategori: materi.bab[activeKategori],
            slugToMateriId: slugToMateriId,
          ),
        ),
        SliverToBoxAdapter(
          child: _KuisEntryCard(
            babId: babId,
            babJudul: babMerged.materi.judulLatin,
          ),
        ),
        // SliverToBoxAdapter(child: _GameEntryCard(babId: babId)),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 200,
      backgroundColor: AppColors.bg,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: 18,
          color: AppColors.textPrimary,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: GeomPainter()),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.bg],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.4),
                      ),
                    ),
                    child: const Text(
                      'TANQĪ • Nahwu Qurani',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    babMerged.materi.judulArab,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textDirection: TextDirection.rtl,
                  ),

                  Text(
                    babMerged.materi.judulLatin,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  KUIS ENTRY CARD — 1 per bab
// ─────────────────────────────────────────
class _KuisEntryCard extends StatelessWidget {
  final int babId;
  final String babJudul;
  const _KuisEntryCard({required this.babId, required this.babJudul});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.gold.withOpacity(0.12), AppColors.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gold.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold.withOpacity(0.4)),
              ),
              child: const Icon(
                Icons.quiz_rounded,
                color: AppColors.gold,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'اختبار الباب',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'اختبر فهمك لهذا الباب بأكمله',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KuisPage(babId: babId, babJudul: babJudul),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'ابدأ',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// GAME ENTRY CARD — 1 per bab
// ─────────────────────────────────────────
class _GameEntryCard extends StatelessWidget {
  final int babId;

  const _GameEntryCard({required this.babId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardFillLightLocked,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardFillLocked),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.cardFillLightLocked,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardFillLight),
              ),
              child: const Icon(
                Icons.gamepad,
                color: AppColors.cardFillLight,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ألعاب هذا الباب',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'أكمل التدريبات أو الاختبار أولًا',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: AppColors.cardFillLight,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(Icons.lock, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  PROGRESS BANNER
// ─────────────────────────────────────────
class _ProgressBanner extends StatelessWidget {
  final int total, done;
  const _ProgressBanner({required this.total, required this.done});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : done / total;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 4,
                backgroundColor: AppColors.divider,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'تم استكشاف ${(pct * 100).toInt()}٪',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  STIMULUS SECTION
// ─────────────────────────────────────────
class _StimulusSection extends StatelessWidget {
  final StimulusData? stimulus;
  const _StimulusSection({required this.stimulus});

  @override
  Widget build(BuildContext context) {
    // 'stimulus' adalah public field, jadi tidak bisa dipromosikan otomatis
    // dari StimulusData? -> StimulusData oleh null-check di atasnya.
    // Tampung dulu ke variabel lokal supaya promosi tipe berlaku.
    final s = stimulus;
    if (s == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.card, AppColors.surface],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gold.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                border: Border(
                  bottom: BorderSide(color: AppColors.gold.withOpacity(0.2)),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_stories_rounded,
                    color: AppColors.gold,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'الآية المحفزة',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  if ((s.sumber ?? '').isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        s.sumber!,
                        style: const TextStyle(
                          color: AppColors.goldLight,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    s.ayatArab,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      height: 2.2,
                      fontWeight: FontWeight.w600,
                    ),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                  ),
                  if ((s.terjemah ?? '').isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      '"${s.terjemah}"',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            if ((s.narasi ?? '').isNotEmpty)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bg.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.goldDark,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s.narasi!,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          height: 1.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  KATEGORI PICKER (tab horizontal)
// ─────────────────────────────────────────
class _KategoriPicker extends StatelessWidget {
  final List<NahwuNode> bab;
  final int active;
  final ValueChanged<int> onTap;

  const _KategoriPicker({
    required this.bab,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'اختر موضوعًا',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
          ),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: bab.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final k = bab[i];
                final isActive = i == active;
                return GestureDetector(
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    width: 110,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isActive
                          ? k.accentColor.withOpacity(0.15)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isActive ? k.accentColor : AppColors.divider,
                        width: isActive ? 1.5 : 1,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: k.accentColor.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(
                        //   k.iconLabel,
                        //   style: TextStyle(
                        //     fontSize: 22,
                        //     color: isActive
                        //         ? k.accentColor
                        //         : AppColors.textMuted,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        isActive
                            ? Icon(
                                Icons.menu_book_rounded,
                                color: k.accentColor,
                                size: 25,
                              )
                            : Icon(
                                Icons.book,
                                color: AppColors.divider,
                                size: 20,
                              ),

                        const Spacer(),
                        Text(
                          k.judulLatin.split(' ').first,
                          style: TextStyle(
                            fontSize: 11,
                            color: isActive
                                ? k.accentColor
                                : AppColors.textSecondary,
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  KATEGORI DETAIL
// ─────────────────────────────────────────
class _KategoriDetail extends StatelessWidget {
  final NahwuNode kategori;
  final Map<String, int> slugToMateriId;

  const _KategoriDetail({required this.kategori, required this.slugToMateriId});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: Padding(
        key: ValueKey(kategori.id),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(kategori: kategori),
            const SizedBox(height: 16),
            if (kategori.hasAturan) ...[
              _SectionLabel(
                label: 'العلامات العامة',
                color: kategori.accentColor,
              ),
              const SizedBox(height: 10),
              ...kategori.aturan.map(
                (a) => _TandaUmumCard(tanda: a, color: kategori.accentColor),
              ),
              const SizedBox(height: 16),
            ],
            if (kategori.hasChildren) ...[
              _SectionLabel(label: 'الشرح', color: kategori.accentColor),
              const SizedBox(height: 10),
              ...kategori.children.asMap().entries.map((e) {
                final sub = e.value;
                return _SubBabCard(
                  sub: sub,
                  index: e.key,
                  accent: kategori.accentColor,
                  materiId: slugToMateriId[sub.id],
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  SECTION HEADER (judul + definisi)
// ─────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final NahwuNode kategori;
  const _SectionHeader({required this.kategori});

  @override
  Widget build(BuildContext context) {
    final defArab = kategori.definisiArab ?? '';
    final defLatin = kategori.definisiLatin ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: kategori.accentColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: kategori.accentColor.withOpacity(0.5),
                  ),
                ),
                child: Center(
                  // child: Text(
                  //   kategori.iconLabel,
                  //   style: TextStyle(
                  //     fontSize: 20,
                  //     color: kategori.accentColor,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: kategori.accentColor,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kategori.judulArab,
                      style: TextStyle(
                        color: kategori.accentColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    Text(
                      kategori.judulLatin,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (defArab.isNotEmpty || defLatin.isNotEmpty) ...[
            const SizedBox(height: 16),
            _DefinisiBox(
              arab: defArab,
              latin: defLatin,
              accent: kategori.accentColor,
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  SECTION LABEL
// ─────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 3,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────
//  TANDA UMUM CARD  (dulu baca Map mentah, sekarang Aturan)
// ─────────────────────────────────────────
class _TandaUmumCard extends StatelessWidget {
  final Aturan tanda;
  final Color color;
  const _TandaUmumCard({required this.tanda, required this.color});

  @override
  Widget build(BuildContext context) {
    final label = tanda.labelArab ?? tanda.labelLatin ?? '';
    final ket = tanda.keteranganLatin ?? tanda.keteranganArab ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
          ),
          title: Text(
            'العلامة: $label',
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          ),
          iconColor: color,
          collapsedIconColor: AppColors.textMuted,
          children: [
            if (ket.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  ket,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ...tanda.contoh.map((c) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _AyatTile(
                  arab: c.arab,
                  sumber: c.sumber ?? '',
                  terjemah: c.terjemah ?? '',
                  tag: c.kategoriLatin ?? c.kategoriArab ?? '',
                  analisis: c.analisisLatin ?? c.analisisArab,
                  accent: color,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  SUB BAB CARD  (dulu baca Map mentah, sekarang NahwuNode)
// ─────────────────────────────────────────
class _SubBabCard extends StatefulWidget {
  final NahwuNode sub;
  final int index;
  final Color accent;
  final int? materiId;

  const _SubBabCard({
    required this.sub,
    required this.index,
    required this.accent,
    this.materiId,
  });

  @override
  State<_SubBabCard> createState() => _SubBabCardState();
}

class _SubBabCardState extends State<_SubBabCard> {
  @override
  Widget build(BuildContext context) {
    final sub = widget.sub;
    final judulArab = sub.judulArab;
    final judulLatin = sub.judulLatin;
    final defArab = sub.definisiArab ?? '';
    final defLatin = sub.definisiLatin ?? '';
    final stimulus = sub.contohStimulus;
    final aturanList = sub.aturan;
    final tabelList = sub.tabel;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: widget.accent.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: widget.accent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${widget.index + 1}',
                style: TextStyle(
                  color: widget.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          title: Text(
            judulArab.isNotEmpty ? judulArab : judulLatin,
            style: TextStyle(
              color: judulArab.isNotEmpty
                  ? widget.accent
                  : AppColors.textSecondary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
            textDirection: judulArab.isNotEmpty
                ? TextDirection.rtl
                : TextDirection.ltr,
          ),
          subtitle: Text(
            judulLatin,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          backgroundColor: widget.accent.withOpacity(0.04),
          collapsedBackgroundColor: Colors.transparent,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (defArab.isNotEmpty || defLatin.isNotEmpty)
                    _DefinisiBox(
                      arab: defArab,
                      latin: defLatin,
                      accent: widget.accent,
                    ),
                  if (stimulus != null) ...[
                    const SizedBox(height: 12),
                    _AyatTile(
                      arab: stimulus.arab,
                      sumber: stimulus.sumber ?? '',
                      terjemah: stimulus.terjemah ?? '',
                      tag: 'Contoh',
                      analisis: stimulus.analisisLatin ?? stimulus.analisisArab,
                      accent: widget.accent,
                    ),
                  ],
                  if (aturanList.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _SectionLabel(label: 'العلامات', color: widget.accent),
                    const SizedBox(height: 8),
                    ...aturanList.map(
                      (a) => _AturanTile(aturan: a, accent: widget.accent),
                    ),
                  ],
                  if (tabelList.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _SectionLabel(label: 'الجدول', color: widget.accent),
                    const SizedBox(height: 8),
                    ...tabelList.map(
                      (t) => _TabelTile(tabel: t, accent: widget.accent),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  DEFINISI BOX
// ─────────────────────────────────────────
class _DefinisiBox extends StatelessWidget {
  final String arab, latin;
  final Color accent;
  const _DefinisiBox({
    required this.arab,
    required this.latin,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.bg.withOpacity(0.7),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: accent.withOpacity(0.15)),
    ),
    child: Column(
      children: [
        if (arab.isNotEmpty)
          Text(
            arab,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              height: 2.0,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
        if (arab.isNotEmpty && latin.isNotEmpty) const SizedBox(height: 6),
        if (latin.isNotEmpty)
          Text(
            latin,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    ),
  );
}

// ─────────────────────────────────────────
//  AYAT TILE  (+ optional analisis, memuat field analisis_arab/latin baru)
// ─────────────────────────────────────────
class _AyatTile extends StatelessWidget {
  final String arab, sumber, terjemah, tag;
  final String? analisis;
  final Color accent;
  const _AyatTile({
    required this.arab,
    required this.sumber,
    required this.terjemah,
    required this.tag,
    required this.accent,
    this.analisis,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [accent.withOpacity(0.06), AppColors.bg.withOpacity(0.4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: accent.withOpacity(0.2)),
    ),
    child: Column(
      children: [
        Text(
          arab,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            height: 2.0,
          ),
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (tag.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accent.withOpacity(0.3)),
                ),
                child: Text(tag, style: TextStyle(color: accent, fontSize: 10)),
              ),
              const SizedBox(width: 8),
            ],
            if (sumber.isNotEmpty)
              Text(
                sumber,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        if (terjemah.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            '"$terjemah"',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (analisis != null && analisis!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            analisis!,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    ),
  );
}

// ─────────────────────────────────────────
//  ATURAN TILE — pengganti generik untuk _TandaDetailTile / _JenisTile /
//  _HurufTile lama. Dulu terpisah 3 widget karena JSON tiap bab beda
//  bentuk (nama/huruf/dalil/faedah...); sekarang semua sudah seragam
//  lewat Aturan, jadi cukup satu widget untuk semuanya.
// ─────────────────────────────────────────
class _AturanTile extends StatelessWidget {
  final Aturan aturan;
  final Color accent;

  const _AturanTile({required this.aturan, required this.accent});

  @override
  Widget build(BuildContext context) {
    final label = aturan.labelArab ?? aturan.labelLatin ?? '';
    final labelLatin = aturan.labelLatin;
    final ket = aturan.keteranganLatin ?? aturan.keteranganArab ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  softWrap: true,
                  maxLines: null,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    color: accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          if (labelLatin != null &&
              labelLatin.isNotEmpty &&
              labelLatin != label) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Text(
                labelLatin,
                softWrap: true,
                maxLines: null,
                overflow: TextOverflow.visible,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ),
          ],

          if (ket.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              ket,
              softWrap: true,
              maxLines: null,
              overflow: TextOverflow.visible,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ],

          if (aturan.contoh.isNotEmpty)
            ...aturan.contoh.map(
              (c) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _AyatTile(
                  arab: c.arab,
                  sumber: c.sumber ?? '',
                  terjemah: c.terjemah ?? '',
                  tag: c.kategoriLatin ?? c.kategoriArab ?? '',
                  analisis: c.analisisLatin ?? c.analisisArab,
                  accent: accent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  TABEL TILE — untuk TabelItem (mis. tabel bina majhul: madhi vs mudhari')
// ─────────────────────────────────────────
class _TabelTile extends StatelessWidget {
  final TabelItem tabel;
  final Color accent;
  const _TabelTile({required this.tabel, required this.accent});

  @override
  Widget build(BuildContext context) {
    final label = tabel.labelLatin ?? tabel.labelArab ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Text(
              label,
              style: TextStyle(
                color: accent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 6),
          ...tabel.kolom.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(
                      e.key,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      e.value,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
