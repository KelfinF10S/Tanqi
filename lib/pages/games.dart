import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:tanqiy/core/colors.dart';
import 'package:tanqiy/game/memory_match_game.dart';
import 'package:tanqiy/game/overlays.dart';
import 'package:tanqiy/widgets/custom_appbar.dart';

class GamesPage extends StatelessWidget {
  GamesPage({super.key});
  final game = MemoryMatchGame();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBarEnd,
      appBar: CustomAppBar(arabicTitle: 'لعبة إلكترونية'),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: GameWidget(
            game: game,
            overlayBuilderMap: {
              'levelComplete': (context, MemoryMatchGame g) =>
                  LevelCompleteOverlay(game: g),
              'gameComplete': (context, MemoryMatchGame g) =>
                  GameCompleteOverlay(game: g),
            },
          ),
        ),
      ),
    );
  }
}
