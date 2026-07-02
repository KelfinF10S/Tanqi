import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:tanqiy/core/colors.dart';


enum CardState { faceDown, faceUp, matched }

typedef OnCardTapped = void Function(CardComponent card);

/// Satu kartu di papan. Menampilkan emoji saat faceUp/matched,
/// dan warna solid ("punggung kartu") saat faceDown.
class CardComponent extends PositionComponent with TapCallbacks {
  final String emoji;
  final int pairId;
  final OnCardTapped onTapped;

  CardState state = CardState.faceDown;
  bool isAnimating = false;

  late final TextComponent _emojiText;

  static final Paint _faceDownPaint = Paint()..color = AppColors.appBarStart;
  static final Paint _faceUpPaint = Paint()..color = AppColors.surface;
  static final Paint _matchedPaint = Paint()..color = AppColors.textP;

  CardComponent({
    required this.emoji,
    required this.pairId,
    required this.onTapped,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size, anchor: Anchor.topLeft) {
    // Dibuat langsung di constructor (bukan onLoad) supaya field ini sudah
    // terisi begitu CardComponent selesai dikonstruksi — showFaceUp/showFaceDown
    // bisa dipanggil dengan aman sebelum onLoad async selesai berjalan.
    _emojiText = TextComponent(
      text: '',
      anchor: Anchor.center,
      position: size / 2,
      textRenderer: TextPaint(
        style: TextStyle(fontSize: size.x * 0.45),
      ),
    );
  }

  @override
  Future<void> onLoad() async {
    add(_emojiText);
  }

  @override
  void render(Canvas canvas) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(size.x * 0.15),
    );
    final Paint paint;
    switch (state) {
      case CardState.faceDown:
        paint = _faceDownPaint;
        break;
      case CardState.faceUp:
        paint = _faceUpPaint;
        break;
      case CardState.matched:
        paint = _matchedPaint;
        break;
    }
    canvas.drawRRect(rrect, paint);
  }

  void showFaceUp({bool animate = true}) {
    state = CardState.faceUp;
    _emojiText.text = emoji;
    if (animate) _playFlipEffect();
  }

  void showFaceDown({bool animate = true}) {
    state = CardState.faceDown;
    _emojiText.text = '';
    if (animate) _playFlipEffect();
  }

  void showMatched() {
    state = CardState.matched;
    _emojiText.text = emoji;
    _playPulseEffect();
  }

  void _playFlipEffect() {
    isAnimating = true;
    add(
      ScaleEffect.to(
        Vector2(1.0, 1.0),
        EffectController(duration: 0.15, reverseDuration: 0.15),
        onComplete: () => isAnimating = false,
      ),
    );
  }

  void _playPulseEffect() {
    add(
      ScaleEffect.by(
        Vector2.all(1.12),
        EffectController(duration: 0.12, reverseDuration: 0.12),
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isAnimating) return;
    if (state == CardState.matched) return;
    onTapped(this);
  }
}
