import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tanqiy/controllers/babkuis_controller.dart';
import 'package:tanqiy/core/colors.dart';
import 'package:tanqiy/models/kuis_baru/soal_kuis_model.dart';

class QuizSoalWidget extends StatelessWidget {
  final SoalKuisModel soal;
  final QuizController controller;
  final Color accent;

  const QuizSoalWidget({
    super.key,
    required this.soal,
    required this.controller,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
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
          Text(
            soal.pertanyaan,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          _buildByTipe(),
        ],
      ),
    );
  }

  Widget _buildByTipe() {
    switch (soal.tipe) {
      case 'multiple_choice':
        return _MultipleChoiceCard(
          key: ValueKey('mc_${soal.id}'),
          soal: soal,
          controller: controller,
          accent: accent,
        );
      case 'drag_drop':
        return _DragDropCard(
          key: ValueKey('dd_${soal.id}'),
          soal: soal,
          controller: controller,
          accent: accent,
        );
      case 'tap_object':
        return _TapObjectCard(
          key: ValueKey('to_${soal.id}'),
          soal: soal,
          controller: controller,
          accent: accent,
        );
      default:
        return const Text(
          'Tipe soal tidak dikenal',
          style: TextStyle(color: AppColors.textMuted),
        );
    }
  }
}

// ─────────────────────────────────────────
// MULTIPLE CHOICE
// ─────────────────────────────────────────
class _MultipleChoiceCard extends StatelessWidget {
  final SoalKuisModel soal;
  final QuizController controller;
  final Color accent;

  const _MultipleChoiceCard({
    super.key,
    required this.soal,
    required this.controller,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final pilihan = Map<String, String>.from(soal.konten['pilihan'] ?? {});
    final urutanKey = controller.urutanPilihanMC(soal);

    return Obx(() {
      final selected = controller.jawabanDipilih.value as String?;
      final hasil = controller.hasilAktif.value;
      final benarKey = hasil?.jawabanBenar is Map
          ? hasil!.jawabanBenar['benar'] as String?
          : null;

      return Column(
        children: urutanKey.asMap().entries.map((entry) {
          final displayIndex = entry.key; // posisi tampil: 0,1,2,3
          final key = entry.value; // key asli dari data: A/B/C/D
          final teks = pilihan[key]!;
          final displayLabel = String.fromCharCode(
            65 + displayIndex,
          ); // A,B,C,D urut
          final isSelected = selected == key;

          Color borderColor = accent.withOpacity(0.25);
          Color bgColor = AppColors.bg.withOpacity(0.3);
          Color textColor = AppColors.textSecondary;

          if (hasil != null) {
            if (key == benarKey) {
              borderColor = Colors.green;
              bgColor = Colors.green.withOpacity(0.1);
              textColor = Colors.green;
            } else if (isSelected && !hasil.isCorrect) {
              borderColor = Colors.red;
              bgColor = Colors.red.withOpacity(0.1);
              textColor = Colors.red;
            }
          } else if (isSelected) {
            borderColor = accent;
            bgColor = accent.withOpacity(0.1);
            textColor = accent;
          }

          return GestureDetector(
            onTap: hasil == null ? () => controller.pilihJawaban(key) : null,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: borderColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor),
                    ),
                    child: Center(
                      child: Text(
                        displayLabel,
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
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

// ─────────────────────────────────────────
// DRAG & DROP
// ─────────────────────────────────────────
class _DragDropCard extends StatefulWidget {
  final SoalKuisModel soal;
  final QuizController controller;
  final Color accent;

  const _DragDropCard({
    super.key,
    required this.soal,
    required this.controller,
    required this.accent,
  });

  @override
  State<_DragDropCard> createState() => _DragDropCardState();
}

class _DragDropCardState extends State<_DragDropCard> {
  final Map<String, String> _pasangan = {}; // item -> target

  void _updateJawaban() {
    widget.controller.pilihJawaban(Map<String, String>.from(_pasangan));
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.controller.urutanItemDD(widget.soal); // <-- ganti
    final targets = widget.controller.urutanTargetDD(widget.soal);
    final hasil = widget.controller.hasilAktif.value;
    final locked = hasil != null;

    final belumDipasang = items
        .where((i) => !_pasangan.containsKey(i))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (belumDipasang.isNotEmpty) ...[
          const Text(
            'اسحب الكلمة إلى الفئة الصحيحة',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: belumDipasang.map((item) {
              return Draggable<String>(
                data: item,
                feedback: Material(
                  color: Colors.transparent,
                  child: _ItemChip(
                    text: item,
                    accent: widget.accent,
                    dragging: true,
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: _ItemChip(text: item, accent: widget.accent),
                ),
                child: _ItemChip(text: item, accent: widget.accent),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
        ...targets.map((target) {
          final terpasang = _pasangan.entries
              .where((e) => e.value == target)
              .map((e) => e.key)
              .toList();

          return DragTarget<String>(
            onWillAccept: (data) => !locked,
            onAccept: (item) {
              setState(() {
                _pasangan[item] = target;
              });
              _updateJawaban();
            },
            builder: (context, candidate, rejected) {
              final isHovering = candidate.isNotEmpty;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isHovering
                      ? widget.accent.withOpacity(0.15)
                      : AppColors.bg.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isHovering ? widget.accent : AppColors.divider,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      target,
                      style: TextStyle(
                        color: widget.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: terpasang.map((item) {
                        return GestureDetector(
                          onTap: locked
                              ? null
                              : () {
                                  setState(() => _pasangan.remove(item));
                                  _updateJawaban();
                                },
                          child: _ItemChip(
                            text: item,
                            accent: widget.accent,
                            filled: true,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ],
    );
  }
}

class _ItemChip extends StatelessWidget {
  final String text;
  final Color accent;
  final bool dragging;
  final bool filled;

  const _ItemChip({
    required this.text,
    required this.accent,
    this.dragging = false,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: filled ? accent.withOpacity(0.2) : accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withOpacity(dragging ? 0.8 : 0.4)),
      ),
      child: Text(text, style: TextStyle(color: accent, fontSize: 13)),
    );
  }
}

// ─────────────────────────────────────────
// TAP OBJECT
// ─────────────────────────────────────────
class _TapObjectCard extends StatefulWidget {
  final SoalKuisModel soal;
  final QuizController controller;
  final Color accent;

  const _TapObjectCard({
    super.key,
    required this.soal,
    required this.controller,
    required this.accent,
  });

  @override
  State<_TapObjectCard> createState() => _TapObjectCardState();
}

class _TapObjectCardState extends State<_TapObjectCard> {
  final Set<String> _dipilih = {};

  void _toggle(String id) {
    final hasil = widget.controller.hasilAktif.value;
    if (hasil != null) return;

    setState(() {
      if (_dipilih.contains(id)) {
        _dipilih.remove(id);
      } else {
        _dipilih.add(id);
      }
    });
    widget.controller.pilihJawaban(_dipilih.toList());
  }

  @override
  Widget build(BuildContext context) {
    final objects = widget.controller.urutanObjekTO(widget.soal);
    final hasil = widget.controller.hasilAktif.value;
    final correctIds = hasil?.jawabanBenar is Map
        ? List<String>.from(hasil!.jawabanBenar['correct_ids'] ?? [])
        : <String>[];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: objects.map((obj) {
        final id = obj['id'] as String;
        final label = obj['label'] as String;
        final isSelected = _dipilih.contains(id);

        Color borderColor = widget.accent.withOpacity(0.3);
        Color bgColor = AppColors.bg.withOpacity(0.4);
        Color textColor = AppColors.textSecondary;

        if (hasil != null) {
          if (correctIds.contains(id)) {
            borderColor = Colors.green;
            bgColor = Colors.green.withOpacity(0.12);
            textColor = Colors.green;
          } else if (isSelected) {
            borderColor = Colors.red;
            bgColor = Colors.red.withOpacity(0.12);
            textColor = Colors.red;
          }
        } else if (isSelected) {
          borderColor = widget.accent;
          bgColor = widget.accent.withOpacity(0.15);
          textColor = widget.accent;
        }

        return GestureDetector(
          onTap: () => _toggle(id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              label,
              style: TextStyle(color: textColor, fontSize: 14),
            ),
          ),
        );
      }).toList(),
    );
  }
}
