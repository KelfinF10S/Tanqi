import 'dart:async' as async;
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/card_component.dart';
import 'models/level_config.dart';

enum GamePhase { preview, playing, betweenLevels, finished }

/// Game utama: mengatur grid kartu, alur preview -> main -> ganti level -> selesai.
class MemoryMatchGame extends FlameGame {
  int currentLevelIndex = 0;
  GamePhase phase = GamePhase.preview;

  final List<CardComponent> _cards = [];
  CardComponent? _firstFlipped;
  CardComponent? _secondFlipped;
  bool _isChecking = false;

  int matchesFound = 0;
  double elapsedSeconds = 0;
  double previewCountdown = 0;

  final List<double> levelTimes = [];

  late TextComponent _levelLabel;
  late TextComponent _timerLabel;
  late TextComponent _statusLabel;

  LevelConfig get currentLevel => kLevels[currentLevelIndex];

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _buildHud();
    _startLevel(currentLevelIndex);
  }

  void _buildHud() {
    _levelLabel = TextComponent(
      text: '',
      position: Vector2(16, 16),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    _timerLabel = TextComponent(
      text: '00.00',
      position: Vector2(16, 44),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.amber,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    _statusLabel = TextComponent(
      text: '',
      position: Vector2(16, 80),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
    );
    addAll([_levelLabel, _timerLabel, _statusLabel]);
  }

  void _startLevel(int index) {
    _clearCards();
    matchesFound = 0;
    elapsedSeconds = 0;
    _firstFlipped = null;
    _secondFlipped = null;
    _isChecking = false;

    final config = kLevels[index];
    previewCountdown = config.previewSeconds;
    phase = GamePhase.preview;

    _levelLabel.text = 'LEVEL ${config.level} / ${kLevels.length}';
    _statusLabel.text = 'Hafalkan posisi kartu...';

    _buildGrid(config);
  }

  void _clearCards() {
    for (final c in _cards) {
      c.removeFromParent();
    }
    _cards.clear();
  }

  void _buildGrid(LevelConfig config) {
    final emojiPool = List<String>.from(kCardEmojis)..shuffle();
    final chosenEmojis = emojiPool.take(config.totalPairs).toList();
    final deck = [...chosenEmojis, ...chosenEmojis]..shuffle(Random());

    const double topOffset = 110;
    const double spacing = 10;
    final availableWidth = size.x - spacing * (config.columns + 1);
    final availableHeight = size.y - topOffset - spacing * (config.rows + 1);

    final cardWidth = availableWidth / config.columns;
    final cardHeight = availableHeight / config.rows;
    final cardSize = min(cardWidth, cardHeight);

    final gridWidth =
        cardSize * config.columns + spacing * (config.columns - 1);
    final gridHeight = cardSize * config.rows + spacing * (config.rows - 1);
    final startX = (size.x - gridWidth) / 2;
    final startY = topOffset + (availableHeight - gridHeight) / 2;

    int idx = 0;
    for (int r = 0; r < config.rows; r++) {
      for (int c = 0; c < config.columns; c++) {
        final emoji = deck[idx];
        final card = CardComponent(
          emoji: emoji,
          pairId: emoji.hashCode,
          onTapped: _onCardTapped,
          position: Vector2(
            startX + c * (cardSize + spacing),
            startY + r * (cardSize + spacing),
          ),
          size: Vector2.all(cardSize),
        );
        card.showFaceUp(animate: false); // preview: mulai terbuka semua
        _cards.add(card);
        add(card);
        idx++;
      }
    }
  }

  void _onCardTapped(CardComponent card) {
    if (phase != GamePhase.playing) return;
    if (_isChecking) return;
    if (card.state != CardState.faceDown) return;
    if (identical(card, _firstFlipped)) return;

    card.showFaceUp();

    if (_firstFlipped == null) {
      _firstFlipped = card;
      return;
    }

    _secondFlipped = card;
    _isChecking = true;

    async.Timer(const Duration(milliseconds: 550), _resolvePair);
  }

  void _resolvePair() {
    final a = _firstFlipped;
    final b = _secondFlipped;
    if (a != null && b != null) {
      if (a.emoji == b.emoji) {
        a.showMatched();
        b.showMatched();
        matchesFound++;
        if (matchesFound >= currentLevel.totalPairs) {
          _completeLevel();
        }
      } else {
        a.showFaceDown();
        b.showFaceDown();
      }
    }
    _firstFlipped = null;
    _secondFlipped = null;
    _isChecking = false;
  }

  void _completeLevel() {
    phase = GamePhase.betweenLevels;
    levelTimes.add(elapsedSeconds);
    _statusLabel.text = 'Level selesai!';

    if (currentLevelIndex >= kLevels.length - 1) {
      phase = GamePhase.finished;
      overlays.add('gameComplete');
    } else {
      overlays.add('levelComplete');
    }
  }

  void goToNextLevel() {
    overlays.remove('levelComplete');
    currentLevelIndex++;
    _startLevel(currentLevelIndex);
  }

  void restartGame() {
    overlays.remove('levelComplete');
    overlays.remove('gameComplete');
    currentLevelIndex = 0;
    levelTimes.clear();
    _startLevel(currentLevelIndex);
  }

  String get formattedTimer => elapsedSeconds.toStringAsFixed(2);

  @override
  void update(double dt) {
    super.update(dt);

    if (phase == GamePhase.preview) {
      previewCountdown -= dt;
      _statusLabel.text =
          'Hafalkan posisi kartu... (${previewCountdown.clamp(0, 99).toStringAsFixed(1)}s)';
      if (previewCountdown <= 0) {
        for (final c in _cards) {
          c.showFaceDown();
        }
        phase = GamePhase.playing;
        _statusLabel.text = 'Cari semua pasangan!';
      }
    } else if (phase == GamePhase.playing) {
      elapsedSeconds += dt;
    }

    if (phase == GamePhase.playing || phase == GamePhase.preview) {
      _timerLabel.text = formattedTimer;
    }
  }
}
