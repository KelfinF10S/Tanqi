import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tanqiy/core/colors.dart';
import 'package:tanqiy/models/kategori_kata_model.dart';
import 'package:tanqiy/models/materibab_model.dart';
import 'package:tanqiy/models/stimulus_data_model.dart';

// ─────────────────────────────────────────
//  PAGE 1  (entry point)
// ─────────────────────────────────────────
class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> with SingleTickerProviderStateMixin {
  Future<MateriBAB>? _future;
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  int _activeKategori = 0;

  @override
  void initState() {
    super.initState();
    _future = _loadMateri();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<MateriBAB> _loadMateri() async {
    String data = await rootBundle.loadString('lib/assets/bab1_anwaul_kalimah.json');
    if (data.startsWith('\uFEFF')) data = data.substring(1);
    return MateriBAB.fromJson(jsonDecode(data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FutureBuilder<MateriBAB>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const _LoadingScreen();
          }
          if (snap.hasError) {
            return _ErrorScreen(error: snap.error.toString());
          }
          if (!snap.hasData) {
            return const _ErrorScreen(error: 'Data tidak tersedia');
          }
          return FadeTransition(
            opacity: _fadeIn,
            child: _MateriBody(
              materi:           snap.data!,
              activeKategori:   _activeKategori,
              onKategoriChange: (i) => setState(() => _activeKategori = i),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────
//  LOADING SCREEN
// ─────────────────────────────────────────
class _LoadingScreen extends StatefulWidget {
  const _LoadingScreen();
  @override
  State<_LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<_LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(_pulse),
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(color: AppColors.gold, width: 2),
                boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.3), blurRadius: 24, spreadRadius: 4)],
              ),
              child: const Center(
                child: Text('ن', style: TextStyle(fontSize: 36, color: AppColors.gold, fontFamily: 'serif')),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Memuat materi…', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  ERROR SCREEN
// ─────────────────────────────────────────
class _ErrorScreen extends StatelessWidget {
  final String error;
  const _ErrorScreen({required this.error});
  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.bg,
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.rose, size: 48),
            const SizedBox(height: 12),
            Text('Gagal memuat data', style: const TextStyle(color: AppColors.textPrimary, fontSize: 16)),
            const SizedBox(height: 6),
            Text(error, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ]),
        ),
      );
}

// ─────────────────────────────────────────
//  MAIN BODY
// ─────────────────────────────────────────
class _MateriBody extends StatelessWidget {
  final MateriBAB materi;
  final int activeKategori;
  final ValueChanged<int> onKategoriChange;

  const _MateriBody({
    required this.materi,
    required this.activeKategori,
    required this.onKategoriChange,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildSliverAppBar(context),
        SliverToBoxAdapter(child: _ProgressBanner(total: materi.bab.length, done: activeKategori)),
        SliverToBoxAdapter(child: _StimulusSection(stimulus: materi.stimulus)),
        SliverToBoxAdapter(child: _KategoriPicker(
          bab: materi.bab, active: activeKategori, onTap: onKategoriChange,
        )),
        SliverToBoxAdapter(
          child: _KategoriDetail(
            kategori: materi.bab[activeKategori],
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
        icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Geometric pattern background
            CustomPaint(painter: _GeomPainter()),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                    ),
                    child: const Text(
                      'TANQĪ • Nahwu Qurani',
                      style: TextStyle(color: AppColors.gold, fontSize: 10, letterSpacing: 2),
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
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
//  GEOMETRIC BACKGROUND PAINTER
// ─────────────────────────────────────────
class _GeomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // octagonal Islamic pattern
    for (double x = -40; x < size.width + 40; x += 60) {
      for (double y = -40; y < size.height + 40; y += 60) {
        final r = 22.0;
        final path = Path();
        for (int i = 0; i < 8; i++) {
          final angle = (i * 45 - 22.5) * 3.14159 / 180;
          final px = x + r * 1.3 * (i == 0 ? 1 : (i < 5 ? (i % 2 == 0 ? 1 : -1) : (i % 2 == 0 ? 1 : -1)));
          final py = y + r * (i == 0 ? 1 : (i < 5 ? (i % 2 == 0 ? -1 : 1) : (i % 2 == 0 ? -1 : 1)));
          if (i == 0) path.moveTo(x + r * 0.7, y - r);
          path.lineTo(x + r * _cos(i * 45), y + r * _sin(i * 45));
        }
        path.close();
        canvas.drawPath(path, paint);

        // simple diamond
        final d = Paint()..color = AppColors.gold.withOpacity(0.04)..style = PaintingStyle.fill;
        final dp = Path()
          ..moveTo(x, y - 16)
          ..lineTo(x + 16, y)
          ..lineTo(x, y + 16)
          ..lineTo(x - 16, y)
          ..close();
        canvas.drawPath(dp, d);
      }
    }
  }

  double _cos(int deg) => (deg == 0) ? 1 : (deg == 45) ? 0.707 : (deg == 90) ? 0 :
      (deg == 135) ? -0.707 : (deg == 180) ? -1 : (deg == 225) ? -0.707 :
      (deg == 270) ? 0 : 0.707;
  double _sin(int deg) => (deg == 0) ? 0 : (deg == 45) ? 0.707 : (deg == 90) ? 1 :
      (deg == 135) ? 0.707 : (deg == 180) ? 0 : (deg == 225) ? -0.707 :
      (deg == 270) ? -1 : -0.707;

  @override
  bool shouldRepaint(_) => false;
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
      child: Row(children: [
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
          '${(pct * 100).toInt()}% dijelajahi',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
      ]),
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(bottom: BorderSide(color: AppColors.gold.withOpacity(0.2))),
              ),
              child: Row(children: [
                const Icon(Icons.auto_stories_rounded, color: AppColors.gold, size: 16),
                const SizedBox(width: 8),
                const Text('Ayat Stimulus', style: TextStyle(color: AppColors.gold, fontSize: 12, letterSpacing: 1)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(stimulus.sumber, style: const TextStyle(color: AppColors.goldLight, fontSize: 10)),
                ),
              ]),
            ),
            // Ayat
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
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
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontStyle: FontStyle.italic, height: 1.6),
                  textAlign: TextAlign.center,
                ),
              ]),
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
                    child: Icon(Icons.lightbulb_outline, color: AppColors.goldDark, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      stimulus.narasi,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.7),
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

  const _KategoriPicker({required this.bab, required this.active, required this.onTap});

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
              'Pilih Topik',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1.5),
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
                      color: isActive ? k.accentColor.withOpacity(0.15) : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isActive ? k.accentColor : AppColors.divider,
                        width: isActive ? 1.5 : 1,
                      ),
                      boxShadow: isActive
                          ? [BoxShadow(color: k.accentColor.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))]
                          : [],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(k.iconLabel,
                          style: TextStyle(
                            fontSize: 22,
                            color: isActive ? k.accentColor : AppColors.textMuted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(k.judulLatin.split(' ').first,
                          style: TextStyle(
                            fontSize: 11,
                            color: isActive ? k.accentColor : AppColors.textSecondary,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
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
  const _KategoriDetail({required this.kategori});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(anim),
            child: child,
          )),
      child: Padding(
        key: ValueKey(kategori.id),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul & definisi
            _SectionHeader(kategori: kategori),
            const SizedBox(height: 16),
            // Tanda umum (jika ada)
            if (kategori.tandaUmum.isNotEmpty) ...[
              _SectionLabel(label: 'Tanda-tanda Umum', color: kategori.accentColor),
              const SizedBox(height: 10),
              ...kategori.tandaUmum.map((t) => _TandaUmumCard(tanda: t, color: kategori.accentColor)),
              const SizedBox(height: 16),
            ],
            // Sub-bab
            if (kategori.subBab.isNotEmpty) ...[
              _SectionLabel(label: 'Pembahasan', color: kategori.accentColor),
              const SizedBox(height: 10),
              ...kategori.subBab.asMap().entries.map((e) =>
                  _SubBabCard(sub: e.value, index: e.key, accent: kategori.accentColor)),
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
      child: Column(children: [
        Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: kategori.accentColor.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: kategori.accentColor.withOpacity(0.5)),
              ),
              child: Center(
                child: Text(
                  kategori.iconLabel,
                  style: TextStyle(fontSize: 20, color: kategori.accentColor, fontWeight: FontWeight.bold),
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
                    style: TextStyle(color: kategori.accentColor, fontSize: 22, fontWeight: FontWeight.bold),
                    textDirection: TextDirection.rtl,
                  ),
                  Text(kategori.judulLatin, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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
          child: Column(children: [
            Text(
              kategori.definisiArab,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, height: 2.0),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              kategori.definisiLatin,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontStyle: FontStyle.italic, height: 1.6),
              textAlign: TextAlign.center,
            ),
          ]),
        ),
      ]),
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
  Widget build(BuildContext context) => Row(children: [
        Container(width: 3, height: 14, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(label.toUpperCase(), style: TextStyle(color: color, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
      ]);
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
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(t['tanda'] ?? '', style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold), textDirection: TextDirection.rtl),
            ),
          ),
          title: Text('Tanda: ${t['tanda'] ?? ''}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
          iconColor: color,
          collapsedIconColor: AppColors.textMuted,
          children: contohList.map<Widget>((c) {
            final ce = c as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _AyatTile(
                arab:    ce['arab']       ?? '',
                sumber:  ce['sumber']     ?? '',
                terjemah: '',
                tag:     ce['jenis_fiil'] ?? ce['faedah'] ?? '',
                accent:  color,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  SUB BAB CARD
// ─────────────────────────────────────────
class _SubBabCard extends StatelessWidget {
  final dynamic sub;
  final int index;
  final Color accent;
  const _SubBabCard({required this.sub, required this.index, required this.accent});

  @override
  Widget build(BuildContext context) {
    final s = sub as Map<String, dynamic>;
    final judulArab  = s['judul_arab']   as String? ?? '';
    final judulLatin = s['judul_latin']  as String? ?? s['judul'] as String? ?? '';
    final defArab    = s['definisi_arab']  as String? ?? s['definisi'] as String? ?? '';
    final defLatin   = s['definisi_latin'] as String? ?? '';
    final stimulus   = s['contoh_stimulus'] as Map<String, dynamic>?;
    final tandaList  = s['tanda'] as List<dynamic>?;
    final jenisList  = s['jenis'] as List<dynamic>?;
    final hurufList  = s['huruf'] as List<dynamic>?;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: accent.withOpacity(0.15), shape: BoxShape.circle),
            child: Center(child: Text('${index + 1}', style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.bold))),
          ),
          title: Text(
            judulArab.isNotEmpty ? judulArab : judulLatin,
            style: TextStyle(
              color: judulArab.isNotEmpty ? accent : AppColors.textSecondary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
            textDirection: judulArab.isNotEmpty ? TextDirection.rtl : TextDirection.ltr,
          ),
          subtitle: Text(
            judulLatin,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
          backgroundColor: accent.withOpacity(0.04),
          collapsedBackgroundColor: Colors.transparent,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Definisi
                  if (defArab.isNotEmpty || defLatin.isNotEmpty)
                    _DefinisiBox(arab: defArab, latin: defLatin, accent: accent),
                  // Stimulus ayat
                  if (stimulus != null) ...[
                    const SizedBox(height: 12),
                    _AyatTile(
                      arab:    stimulus['arab']    ?? '',
                      sumber:  stimulus['sumber']  ?? '',
                      terjemah: stimulus['terjemah'] ?? '',
                      tag:     'Contoh',
                      accent:  accent,
                    ),
                  ],
                  // Tanda-tanda
                  if (tandaList != null && tandaList.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _SectionLabel(label: 'Tanda-tanda', color: accent),
                    const SizedBox(height: 8),
                    ...tandaList.map((t) => _TandaDetailTile(tanda: t as Map<String, dynamic>, accent: accent)),
                  ],
                  // Jenis (isim)
                  if (jenisList != null && jenisList.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _SectionLabel(label: 'Jenis', color: accent),
                    const SizedBox(height: 8),
                    ...jenisList.map((j) => _JenisTile(jenis: j as Map<String, dynamic>, accent: accent)),
                  ],
                  // Huruf (harf)
                  if (hurufList != null && hurufList.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _SectionLabel(label: 'Daftar Huruf', color: accent),
                    const SizedBox(height: 8),
                    ...hurufList.map((h) => _HurufTile(huruf: h as Map<String, dynamic>, accent: accent)),
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
  const _DefinisiBox({required this.arab, required this.latin, required this.accent});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bg.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withOpacity(0.15)),
        ),
        child: Column(children: [
          if (arab.isNotEmpty)
            Text(arab, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, height: 2.0), textDirection: TextDirection.rtl, textAlign: TextAlign.center),
          if (arab.isNotEmpty && latin.isNotEmpty) const SizedBox(height: 6),
          if (latin.isNotEmpty)
            Text(latin, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontStyle: FontStyle.italic, height: 1.6), textAlign: TextAlign.center),
        ]),
      );
}

// ─────────────────────────────────────────
//  AYAT TILE
// ─────────────────────────────────────────
class _AyatTile extends StatelessWidget {
  final String arab, sumber, terjemah, tag;
  final Color accent;
  const _AyatTile({required this.arab, required this.sumber, required this.terjemah, required this.tag, required this.accent});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accent.withOpacity(0.06), AppColors.bg.withOpacity(0.4)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withOpacity(0.2)),
        ),
        child: Column(children: [
          Text(arab, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, height: 2.0), textDirection: TextDirection.rtl, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
              Text(sumber, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
          ]),
          if (terjemah.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('"$terjemah"', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontStyle: FontStyle.italic, height: 1.6), textAlign: TextAlign.center),
          ],
        ]),
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
    final nama      = tanda['nama']        as String? ?? tanda['huruf']  as String? ?? '';
    final ket       = tanda['keterangan']  as String? ?? tanda['dalil']  as String? ?? tanda['faedah'] as String? ?? '';
    final arab      = tanda['contoh_arab'] as String? ?? '';
    final sumber    = tanda['sumber']      as String? ?? '';
    final terjemah  = tanda['terjemah']    as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(nama, style: TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.w600), textDirection: TextDirection.rtl)),
        ]),
        if (ket.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(ket, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.5)),
        ],
        if (arab.isNotEmpty) ...[
          const SizedBox(height: 8),
          _AyatTile(arab: arab, sumber: sumber, terjemah: terjemah, tag: '', accent: accent),
        ],
      ]),
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
    final namaArab  = jenis['nama_arab']  as String? ?? '';
    final namaLatin = jenis['nama_latin'] as String? ?? '';
    final definisi  = jenis['definisi']   as String? ?? '';
    final arab      = jenis['contoh_arab'] as String? ?? '';
    final terjemah  = jenis['terjemah']   as String? ?? '';
    final subJenis  = jenis['sub_jenis']  as List<dynamic>?;
    final tandaTanda = jenis['tanda_tanda'] as List<dynamic>?;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(namaArab, style: TextStyle(color: accent, fontSize: 18, fontWeight: FontWeight.bold), textDirection: TextDirection.rtl, textAlign: TextAlign.center),
        Text(namaLatin, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), textAlign: TextAlign.center),
        if (definisi.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(definisi, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontStyle: FontStyle.italic, height: 1.5)),
        ],
        if (arab.isNotEmpty) ...[
          const SizedBox(height: 10),
          _AyatTile(arab: arab, sumber: '', terjemah: terjemah, tag: '', accent: accent),
        ],
        if (subJenis != null && subJenis.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...subJenis.map((sj) {
            final s = sj as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TandaDetailTile(tanda: s, accent: accent.withOpacity(0.75)),
            );
          }),
        ],
        if (tandaTanda != null && tandaTanda.isNotEmpty) ...[
          const SizedBox(height: 10),
          _SectionLabel(label: 'Tanda Mu\'annats', color: accent),
          const SizedBox(height: 6),
          ...tandaTanda.map((tt) {
            final t = tt as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _AyatTile(arab: t['contoh_arab'] ?? '', sumber: t['sumber'] ?? '', terjemah: '', tag: t['nama'] ?? '', accent: accent),
            );
          }),
        ],
      ]),
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
    final h       = huruf['huruf']       as String? ?? '';
    final faedah  = huruf['faedah']      as String? ?? huruf['faedah_arab']  as String? ?? '';
    final fLatin  = huruf['faedah_latin'] as String? ?? '';
    final contoh  = huruf['contoh_arab'] as String? ?? '';

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
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withOpacity(0.4)),
            ),
            child: Center(
              child: Text(h, style: TextStyle(color: accent, fontSize: 18, fontWeight: FontWeight.bold), textDirection: TextDirection.rtl),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (faedah.isNotEmpty)
                Text(faedah, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, height: 1.5), textDirection: TextDirection.rtl),
              if (fLatin.isNotEmpty)
                Text(fLatin, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontStyle: FontStyle.italic, height: 1.4)),
              if (contoh.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(contoh, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, height: 2.0), textDirection: TextDirection.rtl),
              ],
            ],
          )),
        ],
      ),
    );
  }
}
