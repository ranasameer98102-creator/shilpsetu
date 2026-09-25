import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

/// Opening title: the letters of SHILPSETU drop in one by one with a cyan glow, a light sweeps across the word
/// while it slowly zooms, then it rushes towards the viewer and fades into the app. Tap to skip.
class SplashOverlay extends StatefulWidget {
  const SplashOverlay({super.key, required this.onDone});
  final VoidCallback onDone;

  @override
  State<SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<SplashOverlay> with SingleTickerProviderStateMixin {
  static const word = 'SHILPSETU';
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000));
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // Respect "remove animations": a short fade instead of the full title sequence.
    if (MediaQuery.of(context).disableAnimations) c.duration = const Duration(milliseconds: 900);
    c.forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  double _seg(double t, double a, double b, [Curve curve = Curves.linear]) =>
      curve.transform(((t - a) / (b - a)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final size = math.min(w / 8.2, 72.0);
    return GestureDetector(
      onTap: () {
        c.stop();
        widget.onDone();
      },
      child: AnimatedBuilder(
        animation: c,
        builder: (context, _) {
          final t = c.value;
          final exit = _seg(t, 0.82, 1.0, Curves.easeInCubic); // rush towards the viewer
          final drift = 1 + 0.12 * _seg(t, 0.38, 0.82, Curves.easeInOut); // slow push-in
          final sweep = _seg(t, 0.42, 0.78, Curves.easeInOut); // light passing across the letters
          return Opacity(
            opacity: 1 - exit,
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(colors: [Color(0xFF0F2F57), Color(0xFF050B16)], radius: 1.1),
              ),
              alignment: Alignment.center,
              child: Transform.scale(
                scale: drift * (1 + 2.2 * exit),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  ShaderMask(
                    blendMode: BlendMode.srcATop,
                    shaderCallback: (r) => LinearGradient(
                      colors: const [Colors.transparent, Color(0xCCFFFFFF), Colors.transparent],
                      stops: [sweep - 0.18, sweep, sweep + 0.18].map((v) => v.clamp(0.0, 1.0)).toList(),
                    ).createShader(r),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      for (var i = 0; i < word.length; i++) _letter(word[i], _seg(t, 0.04 + i * 0.04, 0.3 + i * 0.04), size),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  Opacity(
                    opacity: _seg(t, 0.5, 0.7) * (1 - _seg(t, 0.8, 0.86)),
                    child: const Text('Every craft, always in market',
                        style: TextStyle(fontFamily: SS.poppins, color: Color(0xFF9FDDF0), fontSize: 15, letterSpacing: 2)),
                  ),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _letter(String ch, double p, double size) {
    final pop = Curves.easeOutBack.transform(p);
    return Opacity(
      opacity: p.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, -40 * (1 - pop)),
        child: Transform.scale(
          scale: 1.8 - 0.8 * pop,
          child: Text(ch,
              style: TextStyle(
                fontFamily: SS.poppins,
                fontSize: size,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: Colors.white,
                shadows: [
                  Shadow(color: SS.marigold.withValues(alpha: 0.9 * p), blurRadius: 24),
                  Shadow(color: const Color(0xFF0369A1).withValues(alpha: 0.8 * p), blurRadius: 48),
                ],
              )),
        ),
      ),
    );
  }
}
