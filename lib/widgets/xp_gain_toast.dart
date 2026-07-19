import 'package:flutter/material.dart';
import 'package:get/get.dart';

class XpGainToast {
  static void show(int xp) {
    try {
      final overlayContext = Get.overlayContext;
      if (overlayContext == null) return;

      final overlay = Overlay.of(overlayContext, rootOverlay: true);
      late OverlayEntry entry;

      entry = OverlayEntry(
        builder: (context) =>
            _XpGainWidget(xp: xp, onDone: () => entry.remove()),
      );

      overlay.insert(entry);
    } catch (e) {
      debugPrint('[XpGainToast] gagal menampilkan toast: $e');
      // sengaja tidak rethrow — kegagalan tampilan XP tidak boleh mengganggu alur kuis
    }
  }
}

class _XpGainWidget extends StatefulWidget {
  final int xp;
  final VoidCallback onDone;

  const _XpGainWidget({required this.xp, required this.onDone});

  @override
  State<_XpGainWidget> createState() => _XpGainWidgetState();
}

class _XpGainWidgetState extends State<_XpGainWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fade = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: const Offset(0, -0.6),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.35,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  '+${widget.xp} XP',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
