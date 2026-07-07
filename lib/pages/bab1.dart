import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tanqiy/controllers/babkuis_controller.dart';
import 'package:tanqiy/core/colors.dart';
import 'package:tanqiy/models/kategori_kata_model.dart';
import 'package:tanqiy/models/materibab_model.dart';
import 'package:tanqiy/models/soal_model.dart';
import 'package:tanqiy/models/stimulus_data_model.dart';
import 'package:tanqiy/models/bab_merged_model.dart';
import 'package:tanqiy/pages/loading.dart';
import 'package:tanqiy/widgets/background_painter.dart';
import 'package:tanqiy/widgets/retry_dialog.dart';

// ─────────────────────────────────────────
//  PAGE 1  (entry point)
// ─────────────────────────────────────────
class Page1 extends StatefulWidget {
  final BabMerged bab;

  const Page1({super.key, required this.bab});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> with SingleTickerProviderStateMixin {
  Future<MateriBAB>? _future;

  late final AnimationController _controller;

  Animation<double>? _fadeIn;

  int _activeKategori = 0;

  @override
  void initState() {
    super.initState();

    final babId = int.tryParse(widget.bab.id) ?? 1;

    // Animasi
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward();

    // Load data
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
            // fallback supaya tidak crash
            opacity: _fadeIn ?? const AlwaysStoppedAnimation<double>(1),

            child: _MateriBody(
              materi: snap.data!,

              babMerged: widget.bab,

              activeKategori: _activeKategori,

              onKategoriChange: (i) {
                if (!mounted) return;

                setState(() {
                  _activeKategori = i;
                });
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
            // Geometric pattern background
            CustomPaint(painter: GeomPainter()),
            // Gradient overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.bg],
                ),
              ),
            ),
            // Content
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
                  const Text(
                    'الباب الأول',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const Text(
                    'Anwāul Kalimah — Jenis-Jenis Kata',
                    style: TextStyle(
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
  final StimulusData stimulus;
  const _StimulusSection({required this.stimulus});

  @override
  Widget build(BuildContext context) {
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
            // Header
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
                      stimulus.sumber,
                      style: const TextStyle(
                        color: AppColors.goldLight,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Ayat
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    stimulus.ayatArab,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      height: 2.2,
                      fontWeight: FontWeight.w600,
                    ),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '"${stimulus.terjemah}"',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Narasi
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
                      stimulus.narasi,
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
  final List<KategoriKata> bab;
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
                        Text(
                          k.iconLabel,
                          style: TextStyle(
                            fontSize: 22,
                            color: isActive
                                ? k.accentColor
                                : AppColors.textMuted,
                            fontWeight: FontWeight.bold,
                          ),
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
  final KategoriKata kategori;
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
            if (kategori.tandaUmum.isNotEmpty) ...[
              _SectionLabel(
                label: 'العلامات العامة',
                color: kategori.accentColor,
              ),
              const SizedBox(height: 10),
              ...kategori.tandaUmum.map(
                (t) => _TandaUmumCard(tanda: t, color: kategori.accentColor),
              ),
              const SizedBox(height: 16),
            ],
            if (kategori.subBab.isNotEmpty) ...[
              _SectionLabel(label: 'الشرح', color: kategori.accentColor),
              const SizedBox(height: 10),
              ...kategori.subBab.asMap().entries.map((e) {
                final subId =
                    (e.value as Map<String, dynamic>)['id'] as String? ?? '';
                return _SubBabCard(
                  sub: e.value,
                  index: e.key,
                  accent: kategori.accentColor,
                  materiId: slugToMateriId[subId],
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
  final KategoriKata kategori;
  const _SectionHeader({required this.kategori});

  @override
  Widget build(BuildContext context) {
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
                  child: Text(
                    kategori.iconLabel,
                    style: TextStyle(
                      fontSize: 20,
                      color: kategori.accentColor,
                      fontWeight: FontWeight.bold,
                    ),
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
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bg.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  kategori.definisiArab,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    height: 2.0,
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  kategori.definisiLatin,
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
          ),
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
//  TANDA UMUM CARD
// ─────────────────────────────────────────
class _TandaUmumCard extends StatelessWidget {
  final dynamic tanda;
  final Color color;
  const _TandaUmumCard({required this.tanda, required this.color});

  @override
  Widget build(BuildContext context) {
    final t = tanda as Map<String, dynamic>;
    final contohList = t['contoh_ayat'] as List<dynamic>? ?? [];
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
                t['tanda'] ?? '',
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
            'العلامة: ${t['tanda'] ?? ''}',
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          ),
          iconColor: color,
          collapsedIconColor: AppColors.textMuted,
          children: contohList.map<Widget>((c) {
            final ce = c as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _AyatTile(
                arab: ce['arab'] ?? '',
                sumber: ce['sumber'] ?? '',
                terjemah: '',
                tag: ce['jenis_fiil'] ?? ce['faedah'] ?? '',
                accent: color,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  SUB BAB CARD (updated)
// ─────────────────────────────────────────
class _SubBabCard extends StatefulWidget {
  final dynamic sub;
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
  late final QuizController _quizCtrl;
  bool _quizLoaded = false;

  @override
  void initState() {
    super.initState();
    // pakai tag unik per materi supaya tidak bentrok
    _quizCtrl = Get.put(
      QuizController(),
      tag: 'quiz_${widget.materiId ?? widget.index}',
    );
  }

  void _loadQuiz() {
    if (widget.materiId == null || _quizLoaded) return;
    _quizCtrl.loadSoal(widget.materiId!);
    _quizLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.sub as Map<String, dynamic>;
    final judulArab = s['judul_arab'] as String? ?? '';
    final judulLatin =
        s['judul_latin'] as String? ?? s['judul'] as String? ?? '';
    final defArab =
        s['definisi_arab'] as String? ?? s['definisi'] as String? ?? '';
    final defLatin = s['definisi_latin'] as String? ?? '';
    final stimulus = s['contoh_stimulus'] as Map<String, dynamic>?;
    final tandaList = s['tanda'] as List<dynamic>?;
    final jenisList = s['jenis'] as List<dynamic>?;
    final hurufList = s['huruf'] as List<dynamic>?;

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
          onExpansionChanged: (expanded) {
            if (expanded) _loadQuiz();
          },
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
                      arab: stimulus['arab'] ?? '',
                      sumber: stimulus['sumber'] ?? '',
                      terjemah: stimulus['terjemah'] ?? '',
                      tag: 'Contoh',
                      accent: widget.accent,
                    ),
                  ],
                  if (tandaList != null && tandaList.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _SectionLabel(
                      label: 'العلامات',
                      color: widget.accent,
                    ), // tanda-tanda
                    const SizedBox(height: 8),
                    ...tandaList.map(
                      (t) => _TandaDetailTile(
                        tanda: t as Map<String, dynamic>,
                        accent: widget.accent,
                      ),
                    ),
                  ],
                  if (jenisList != null && jenisList.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _SectionLabel(
                      label: 'النوع',
                      color: widget.accent,
                    ), // jenis
                    const SizedBox(height: 8),
                    ...jenisList.map(
                      (j) => _JenisTile(
                        jenis: j as Map<String, dynamic>,
                        accent: widget.accent,
                      ),
                    ),
                  ],
                  if (hurufList != null && hurufList.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _SectionLabel(
                      label: 'قائمة الحروف',
                      color: widget.accent,
                    ), // daftar huruf
                    const SizedBox(height: 8),
                    ...hurufList.map(
                      (h) => _HurufTile(
                        huruf: h as Map<String, dynamic>,
                        accent: widget.accent,
                      ),
                    ),
                  ],

                  // ── QUIZ SECTION ──
                  if (widget.materiId != null) ...[
                    const SizedBox(height: 20),
                    _SectionLabel(
                      label: 'اختبار',
                      color: widget.accent,
                    ), // kuis
                    const SizedBox(height: 10),
                    _InlineQuiz(
                      controller: _quizCtrl,
                      accent: widget.accent,
                      materiId: widget.materiId!,
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
//  INLINE QUIZ
// ─────────────────────────────────────────
class _InlineQuiz extends StatelessWidget {
  final QuizController controller;
  final Color accent;
  final int materiId;

  const _InlineQuiz({
    required this.controller,
    required this.accent,
    required this.materiId,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CircularProgressIndicator(color: accent, strokeWidth: 2),
          ),
        );
      }

      if (controller.soalList.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bg.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withOpacity(0.2)),
          ),
          child: const Text(
            'لا توجد أسئلة لهذا الدرس حتى الآن.', // belum ada soal untuk materi ini
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        );
      }

      final total = controller.soalList.length;

      return Column(
        children: [
          // ── Progress dots (klik untuk navigasi) ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(total, (i) {
              final answered = controller.hasilPerSoal.containsKey(i);
              final isCorrect =
                  answered && controller.hasilPerSoal[i]!.isCorrect;
              final isCurrent = controller.currentIndex.value == i;

              Color dotColor;
              if (!answered) {
                dotColor = isCurrent ? accent : accent.withOpacity(0.25);
              } else {
                dotColor = isCorrect ? Colors.green : Colors.red;
              }

              return GestureDetector(
                onTap: () => controller.goToSoal(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isCurrent ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dotColor,
                    borderRadius: BorderRadius.circular(4),
                    border: isCurrent
                        ? Border.all(color: accent, width: 1.5)
                        : null,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),

          // ── Kartu soal aktif ──
          _SoalCard(
            soal: controller.soalList[controller.currentIndex.value],
            controller: controller,
            accent: accent,
          ),

          // ── Panel hasil (muncul setelah semua selesai) ──
          if (controller.quizSelesai.value) ...[
            const SizedBox(height: 20),
            _HasilPanel(
              controller: controller,
              accent: accent,
              materiId: materiId,
            ),
          ],
        ],
      );
    });
  }
}

class _HasilPanel extends StatelessWidget {
  final QuizController controller;
  final Color accent;
  final int materiId;

  const _HasilPanel({
    required this.controller,
    required this.accent,
    required this.materiId,
  });

  @override
  Widget build(BuildContext context) {
    final total = controller.soalList.length;
    final benar = controller.hasilPerSoal.values
        .where((h) => h.isCorrect)
        .length;
    final salah = total - benar;
    final xp = controller.totalXp.value;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withOpacity(0.12), AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(0.35)),
      ),
      child: Column(
        children: [
          // Judul
          Row(
            children: [
              Icon(Icons.emoji_events_rounded, color: accent, size: 20),
              const SizedBox(width: 8),
              Text(
                'نتيجة الاختبار', //hasil kuis
                style: TextStyle(
                  color: accent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // XP badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: accent.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded, color: accent, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '+$xp XP',
                      style: TextStyle(
                        color: accent,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // _StatChip(
              //   icon: Icons.bar_chart_rounded,
              //   label: '${controller.nilaiAkhir.value.toStringAsFixed(0)}',
              //   color: accent,
              //   sublabel: 'Nilai',
              // ),
            ],
          ),
          const SizedBox(height: 16),

          // Benar / Salah
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatChip(
                icon: Icons.check_circle_outline,
                label: '$benar صحيحة',
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              _StatChip(
                icon: Icons.cancel_outlined,
                label: '$salah خاطئة',
                color: Colors.red,
              ),
              const SizedBox(width: 12),
            ],
          ),

          const SizedBox(height: 20),

          // Tombol Review
          Obx(
            () => controller.showReview.value
                ? const SizedBox.shrink()
                : SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => controller.showReview.value = true,
                      icon: Icon(
                        Icons.rate_review_outlined,
                        color: accent,
                        size: 16,
                      ),
                      label: Text(
                        'عرض مراجعة الإجابات',
                        style: TextStyle(color: accent, fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: accent.withOpacity(0.6)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
          ),

          // Panel review
          Obx(
            () => controller.showReview.value
                ? Column(
                    children: [
                      _ReviewPanel(controller: controller, accent: accent),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonalIcon(
                          style: ButtonStyle(
                            side: MaterialStatePropertyAll(BorderSide(color: accent)),
                            backgroundColor: MaterialStatePropertyAll(
                              accent
                            ),
                            foregroundColor: MaterialStatePropertyAll(AppColors.textP),
                          ),
                          onPressed: () =>
                              showRetryDialog(controller, materiId, accent),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text("إعادة المحاولة"),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// Chip kecil statistik
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String? sublabel;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
    // ignore: unused_element_parameter
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (sublabel != null)
          Text(
            sublabel!,
            style: TextStyle(color: color.withOpacity(0.7), fontSize: 10),
          ),
      ],
    ),
  );
}

class _ReviewPanel extends StatelessWidget {
  final QuizController controller;
  final Color accent;

  const _ReviewPanel({required this.controller, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Divider(color: accent.withOpacity(0.2)),
        const SizedBox(height: 12),
        Text(
          'مراجعة الإجابات',
          style: TextStyle(
            color: accent,
            fontSize: 10,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(controller.soalList.length, (i) {
          final soal = controller.soalList[i];
          final hasil = controller.hasilPerSoal[i];
          if (hasil == null) return const SizedBox.shrink();

          final isCorrect = hasil.isCorrect;
          final color = isCorrect ? Colors.green : Colors.red;
          final selectedLabel = controller.selectedPerSoal[i] ?? '';

          // Cari teks opsi yang dipilih & jawaban benar
          final opsi = controller.opsiPerSoal[i] ?? [];
          String selectedTeks = '';
          String benarTeks = '';
          for (final o in opsi) {
            if (o['dbLabel'] == selectedLabel) selectedTeks = o['text'] ?? '';
            if (o['dbLabel'] == hasil.jawabanBenar) benarTeks = o['text'] ?? '';
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nomor + status
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel_rounded,
                      color: color,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isCorrect ? 'صحيح' : 'خطأ',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Pertanyaan
                Text(
                  soal.pertanyaan,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),

                // Jawaban yang dipilih
                _ReviewOpsiRow(
                  label: 'إجابتك',
                  teks: selectedTeks,
                  color: color,
                ),

                // Jawaban benar (tambahkan ! jika ingin selalu tampil)
                if (isCorrect) ...[
                  const SizedBox(height: 6),
                  _ReviewOpsiRow(
                    label: 'الإجابة الصحيحة',
                    teks: benarTeks,
                    color: Colors.green,
                  ),
                ],

                // Di _ReviewPanel, setelah blok "Jawaban benar", tambah:
                if (isCorrect &&
                    hasil.penjelasan != null &&
                    hasil.penjelasan!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.withOpacity(0.25)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: Colors.green,
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            hasil.penjelasan!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              height: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Penjelasan hanya untuk yang BENAR
                // (yang salah tidak ada penjelasan sesuai permintaan)
                // ← kosongkan saja, tidak ada blok penjelasan untuk yang salah
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _ReviewOpsiRow extends StatelessWidget {
  final String label, teks;
  final Color color;

  const _ReviewOpsiRow({
    required this.label,
    required this.teks,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '$label: ',
        style: TextStyle(
          color: color.withOpacity(0.8),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      Expanded(
        child: Text(
          teks,
          style: TextStyle(color: color, fontSize: 12, height: 1.4),
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────
//  SOAL CARD
// ─────────────────────────────────────────
class _SoalCard extends StatelessWidget {
  final SoalModel soal;
  final QuizController controller;
  final Color accent;

  const _SoalCard({
    required this.soal,
    required this.controller,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final idx = controller.currentIndex.value;
      final opsi = controller.opsiPerSoal[idx] ?? [];
      final selected = controller.selectedLabel;
      final status = controller.statusAktif;
      final hasil = controller.hasilAktif;
      final quizSelesai = controller.quizSelesai.value;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bg.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label soal ke-N
            Text(
              'السؤال ${idx + 1} من ${controller.soalList.length}',
              style: TextStyle(
                color: accent.withOpacity(0.7),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),

            // Pertanyaan
            Text(
              soal.pertanyaan,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 14),

            // Pilihan jawaban
            ...opsi.map((e) {
              final label = e['dbLabel']!;
              final teks = e['text']!;
              final isSelected = selected == label;

              // Warna reveal HANYA setelah quiz selesai semua
              Color borderColor = accent.withOpacity(0.2);
              Color bgColor = AppColors.bg.withOpacity(0.3);
              Color textColor = AppColors.textSecondary;

              if (quizSelesai && hasil != null) {
                if (hasil.isCorrect) {
                  if (label == hasil.jawabanBenar) {
                    borderColor = Colors.green;
                    bgColor = Colors.green.withOpacity(0.1);
                    textColor = Colors.green;
                  }
                } else {
                  if (isSelected) {
                    borderColor = Colors.red;
                    bgColor = Colors.red.withOpacity(0.1);
                    textColor = Colors.red;
                  }
                }
              } else if (isSelected) {
                borderColor = accent;
                bgColor = accent.withOpacity(0.1);
                textColor = accent;
              }

              return GestureDetector(
                onTap: () => controller.pilihJawaban(label),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: borderColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor),
                        ),
                        child: Center(
                          child: Text(
                            e['displayLabel']!,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          teks,
                          style: TextStyle(color: textColor, fontSize: 13),
                        ),
                      ),
                      // Ikon benar/salah setelah quiz selesai
                      if (quizSelesai &&
                          hasil != null &&
                          hasil.isCorrect &&
                          label == hasil.jawabanBenar)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        )
                      else if (isSelected)
                        const Icon(Icons.cancel, color: Colors.red, size: 16),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 8),

            // Tombol navigasi + submit
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tombol Kembali
                if (!controller.isFirstSoal)
                  OutlinedButton.icon(
                    onPressed: controller.prevSoal,
                    icon: const Icon(Icons.arrow_back_ios_new, size: 12),
                    label: const Text('العودة'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accent,
                      side: BorderSide(color: accent.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      textStyle: const TextStyle(fontSize: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),

                // Tombol kanan: Konfirmasi / Lanjut / (kosong jika soal terakhir sudah dijawab)
                if (status != 'answered') ...[
                  ElevatedButton(
                    onPressed: selected.isEmpty
                        ? null
                        : controller.submitJawaban,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: accent.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: controller.isSubmitting.value
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('تأكيد', style: TextStyle(fontSize: 13)),
                  ),
                ] else if (!controller.isLastSoal) ...[
                  ElevatedButton.icon(
                    onPressed: controller.nextSoal,
                    icon: const Icon(Icons.arrow_forward_ios, size: 12),
                    label: const Text('متابعة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
                // Soal terakhir & sudah dijawab → panel hasil akan muncul
              ],
            ),
          ],
        ),
      );
    });
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
//  AYAT TILE
// ─────────────────────────────────────────
class _AyatTile extends StatelessWidget {
  final String arab, sumber, terjemah, tag;
  final Color accent;
  const _AyatTile({
    required this.arab,
    required this.sumber,
    required this.terjemah,
    required this.tag,
    required this.accent,
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
      ],
    ),
  );
}

// ─────────────────────────────────────────
//  TANDA DETAIL TILE
// ─────────────────────────────────────────
class _TandaDetailTile extends StatelessWidget {
  final Map<String, dynamic> tanda;
  final Color accent;
  const _TandaDetailTile({required this.tanda, required this.accent});

  @override
  Widget build(BuildContext context) {
    final nama = tanda['nama'] as String? ?? tanda['huruf'] as String? ?? '';
    final ket =
        tanda['keterangan'] as String? ??
        tanda['dalil'] as String? ??
        tanda['faedah'] as String? ??
        '';
    final arab = tanda['contoh_arab'] as String? ?? '';
    final sumber = tanda['sumber'] as String? ?? '';
    final terjemah = tanda['terjemah'] as String? ?? '';

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
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  nama,
                  style: TextStyle(
                    color: accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
          if (ket.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              ket,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ],
          if (arab.isNotEmpty) ...[
            const SizedBox(height: 8),
            _AyatTile(
              arab: arab,
              sumber: sumber,
              terjemah: terjemah,
              tag: '',
              accent: accent,
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  JENIS TILE  (untuk isim)
// ─────────────────────────────────────────
class _JenisTile extends StatelessWidget {
  final Map<String, dynamic> jenis;
  final Color accent;
  const _JenisTile({required this.jenis, required this.accent});

  @override
  Widget build(BuildContext context) {
    final namaArab = jenis['nama_arab'] as String? ?? '';
    final namaLatin = jenis['nama_latin'] as String? ?? '';
    final definisi = jenis['definisi'] as String? ?? '';
    final arab = jenis['contoh_arab'] as String? ?? '';
    final terjemah = jenis['terjemah'] as String? ?? '';
    final subJenis = jenis['sub_jenis'] as List<dynamic>?;
    final tandaTanda = jenis['tanda_tanda'] as List<dynamic>?;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            namaArab,
            style: TextStyle(
              color: accent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
          Text(
            namaLatin,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          if (definisi.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              definisi,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ],
          if (arab.isNotEmpty) ...[
            const SizedBox(height: 10),
            _AyatTile(
              arab: arab,
              sumber: '',
              terjemah: terjemah,
              tag: '',
              accent: accent,
            ),
          ],
          if (subJenis != null && subJenis.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...subJenis.map((sj) {
              final s = sj as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _TandaDetailTile(
                  tanda: s,
                  accent: accent.withOpacity(0.75),
                ),
              );
            }),
          ],
          if (tandaTanda != null && tandaTanda.isNotEmpty) ...[
            const SizedBox(height: 10),
            _SectionLabel(label: 'علامات المؤنث', color: accent),
            const SizedBox(height: 6),
            ...tandaTanda.map((tt) {
              final t = tt as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _AyatTile(
                  arab: t['contoh_arab'] ?? '',
                  sumber: t['sumber'] ?? '',
                  terjemah: '',
                  tag: t['nama'] ?? '',
                  accent: accent,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  HURUF TILE (untuk harf)
// ─────────────────────────────────────────
class _HurufTile extends StatelessWidget {
  final Map<String, dynamic> huruf;
  final Color accent;
  const _HurufTile({required this.huruf, required this.accent});

  @override
  Widget build(BuildContext context) {
    final h = huruf['huruf'] as String? ?? '';
    final faedah =
        huruf['faedah'] as String? ?? huruf['faedah_arab'] as String? ?? '';
    final fLatin = huruf['faedah_latin'] as String? ?? '';
    final contoh = huruf['contoh_arab'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Huruf badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withOpacity(0.4)),
            ),
            child: Center(
              child: Text(
                h,
                style: TextStyle(
                  color: accent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (faedah.isNotEmpty)
                  Text(
                    faedah,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      height: 1.5,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                if (fLatin.isNotEmpty)
                  Text(
                    fLatin,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                if (contoh.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    contoh,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      height: 2.0,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
