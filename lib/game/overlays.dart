import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tanqiy/core/colors.dart';
import 'memory_match_game.dart';

/// Overlay muncul setiap kali satu level selesai, menampilkan waktu yang
/// dicapai dan tombol untuk lanjut ke level berikutnya.
class LevelCompleteOverlay extends StatelessWidget {
  final MemoryMatchGame game;
  const LevelCompleteOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final time = game.levelTimes.last.toStringAsFixed(2);
    final levelNumber = game.currentLevel.level;

    return Center(
      child: _Card(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(
            'Level $levelNumber Selesai!',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Waktu: $time detik',
            style: const TextStyle(fontSize: 16, color: Colors.amber),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: game.goToNextLevel,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(AppColors.appBarStart),
            ),
            child: const Text(
              'Lanjut ke Level Berikutnya',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Overlay muncul setelah level terakhir (3) selesai, merekap waktu tiap level.
class GameCompleteOverlay extends StatelessWidget {
  final MemoryMatchGame game;
  const GameCompleteOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final times = game.levelTimes;
    final total = times.fold<double>(0, (sum, t) => sum + t);

    return Center(
      child: _Card(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          const Text(
            'Semua Level Selesai!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < times.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                'Level ${i + 1}: ${times[i].toStringAsFixed(2)} detik',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'Total: ${total.toStringAsFixed(2)} detik',
            style: const TextStyle(fontSize: 16, color: Colors.amber),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: game.restartGame,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(AppColors.appBarStart),
            ),
            child: const Text(
              'Main Lagi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color.fromARGB(
              255,
              0,
              0,
              0,
            ).withOpacity(0.2), // frosted tint
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1.5,
            ),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    );
  }
}
