import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tanqiy/core/colors.dart';

import '../models/kamus_entry.dart';

class KamusPage extends StatefulWidget {
  const KamusPage({super.key});

  @override
  State<KamusPage> createState() => _KamusPageState();
}

class _KamusPageState extends State<KamusPage> {
  final TextEditingController _searchController = TextEditingController();

  List<KamusEntry> _semuaEntri = [];
  List<KamusEntry> _hasilFilter = [];
  String _kategoriAktif = KamusKategori.semua;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _muatData();
    _searchController.addListener(_terapkanFilter);
  }

  @override
  void dispose() {
    _searchController.removeListener(_terapkanFilter);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _muatData() async {
    try {
      final raw = await rootBundle.loadString('lib/assets/kamus.json');
      final List<dynamic> decoded = json.decode(raw) as List<dynamic>;
      final entries = decoded
          .map((e) => KamusEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _semuaEntri = entries;
        _hasilFilter = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل في تحميل القاموس. تحقق من مسار ملف القاموس.';
        _isLoading = false;
      });
    }
  }

  void _terapkanFilter() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _hasilFilter = _semuaEntri.where((entry) {
        final cocokKategori =
            _kategoriAktif == KamusKategori.semua ||
            entry.kategori == _kategoriAktif;
        if (!cocokKategori) return false;
        if (query.isEmpty) return true;
        return entry.arab.toLowerCase().contains(query) ||
            entry.arti.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _pilihKategori(String kategori) {
    setState(() => _kategoriAktif = kategori);
    _terapkanFilter();
  }

  static Color forKategori(String kategori) {
    switch (kategori) {
      case KamusKategori.huruf:
        return AppColors.chipHuruf;
      case KamusKategori.isim:
        return AppColors.chipIsim;
      case KamusKategori.fiil:
        return AppColors.chipFiil;
      default:
        return AppColors.chipSemua;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(gradient: AppColors.splashGradient),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildSearchField(),
              const SizedBox(height: 16),
              _buildKategoriChips(),
              const SizedBox(height: 12),
              _buildHasilCounter(),
              Expanded(child: _buildDaftarKata()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text(
            'كَامُوس',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.cardFill,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Icon(
              Icons.menu_book,
              color: AppColors.textPrimary,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: AppColors.textPrimary),
        cursorColor: AppColors.appBarBg,
        decoration: InputDecoration(
          hintText: 'ابحث عن كلمة عربية أو معناها...',
          hintStyle: const TextStyle(color: AppColors.textHint),
          prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textHint),
                  onPressed: () => _searchController.clear(),
                ),
          filled: true,
          fillColor: AppColors.cardFillLight,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.appBarBg, width: 1.4),
          ),
        ),
      ),
    );
  }

  Widget _buildKategoriChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: KamusKategori.semuaKategori.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final kategori = KamusKategori.semuaKategori[index];
          final aktif = kategori == _kategoriAktif;
          final warna = forKategori(kategori);
          return GestureDetector(
            onTap: () => _pilihKategori(kategori),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: aktif
                    ? LinearGradient(colors: [warna, warna.withOpacity(0.75)])
                    : null,
                color: aktif ? null : AppColors.cardFillLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: aktif ? warna : AppColors.cardBorder),
              ),
              child: Text(
                kategori,
                style: TextStyle(
                  color: aktif ? AppColors.textP : AppColors.textSecondary,
                  fontWeight: aktif ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHasilCounter() {
    if (_isLoading || _errorMessage != null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        'تم العثور على ${_hasilFilter.length} كلمة',
        textAlign: TextAlign.end,
        style: const TextStyle(color: AppColors.textHint, fontSize: 12.5),
      ),
    );
  }

  Widget _buildDaftarKata() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.textHint),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    if (_hasilFilter.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              color: AppColors.cardFillLight,
              size: 44,
            ),
            const SizedBox(height: 12),
            const Text(
              'لم يتم العثور على الكلمة',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'جرّب كلمة مفتاحية أخرى',
              style: TextStyle(color: AppColors.textHint, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
      itemCount: _hasilFilter.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _KataCard(entry: _hasilFilter[index]),
    );
  }
}

class _KataCard extends StatelessWidget {
  final KamusEntry entry;

  const _KataCard({required this.entry});

  static Color forKategori(String kategori) {
    switch (kategori) {
      case KamusKategori.huruf:
        return AppColors.chipHuruf;
      case KamusKategori.isim:
        return AppColors.chipIsim;
      case KamusKategori.fiil:
        return AppColors.chipFiil;
      default:
        return AppColors.chipSemua;
    }
  }

  @override
  Widget build(BuildContext context) {
    final warna = forKategori(entry.kategori);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBorderLocked,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardFillLightLocked),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 44,
            decoration: BoxDecoration(
              color: warna,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.arti,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  entry.kategori,
                  style: TextStyle(
                    color: warna,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            entry.arab,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
