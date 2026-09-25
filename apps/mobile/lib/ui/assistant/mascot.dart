import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

/// Shilpi, the ShilpSetu mascot: a little clay pot with a diya flame, big blinking eyes and a moving mouth.
/// Moods: happy (gentle bob), wave (sway), cheer (jump), think (eyes up). [talking] animates the mouth.
class Mascot extends StatefulWidget {
  const Mascot({super.key, this.size = 72, this.mood = 'happy', this.talking = false});
  final double size;
  final String mood;
  final bool talking;

  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
    ..repeat();

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.of(context).disableAnimations;
    return Semantics(
      label: 'Shilpi',
      image: true,
      child: AnimatedBuilder(
        animation: c,
        builder: (context, _) {
          final t = still ? 0.0 : c.value;
          final wave = math.sin(t * 2 * math.pi);
          double dy = -2 * wave, angle = 0;
          switch (widget.mood) {
            case 'cheer':
              dy = -widget.size * 0.14 * math.max(0, math.sin(t * 4 * math.pi)); // two hops per loop
            case 'wave':
              angle = 0.12 * math.sin(t * 4 * math.pi);
          }
          return Transform.translate(
            offset: Offset(0, dy),
            child: Transform.rotate(
              angle: angle,
              child: CustomPaint(
                size: Size.square(widget.size),
                painter: _ShilpiPainter(t: t, mood: widget.mood, talking: widget.talking && !still),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ShilpiPainter extends CustomPainter {
  _ShilpiPainter({required this.t, required this.mood, required this.talking});
  final double t;
  final String mood;
  final bool talking;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final cx = w / 2;

    // soft cyan glow behind
    canvas.drawCircle(Offset(cx, h * 0.6), w * 0.42,
        Paint()..color = SS.marigold.withValues(alpha: 0.18)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));

    // flame (diya) flickering on top
    final flick = 1 + 0.08 * math.sin(t * 2 * math.pi * 5) + 0.04 * math.sin(t * 2 * math.pi * 13);
    final flame = Path()
      ..moveTo(cx, h * (0.02 + 0.03 * (1 - flick)))
      ..quadraticBezierTo(cx + w * 0.11 * flick, h * 0.16, cx, h * 0.24)
      ..quadraticBezierTo(cx - w * 0.11 * flick, h * 0.16, cx, h * (0.02 + 0.03 * (1 - flick)));
    canvas.drawPath(flame, Paint()..shader = const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFFFFF3B0), Color(0xFFFFB347), Color(0xFF22D3EE)],
    ).createShader(Rect.fromLTWH(cx - w * 0.12, 0, w * 0.24, h * 0.25)));

    // pot body
    final body = Path()
      ..moveTo(cx - w * 0.2, h * 0.3)
      ..cubicTo(cx - w * 0.5, h * 0.42, cx - w * 0.46, h * 0.92, cx, h * 0.95)
      ..cubicTo(cx + w * 0.46, h * 0.92, cx + w * 0.5, h * 0.42, cx + w * 0.2, h * 0.3)
      ..close();
    canvas.drawPath(
        body,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E4B82), Color(0xFF0F2F57), Color(0xFF081528)],
          ).createShader(Rect.fromLTWH(0, h * 0.28, w, h * 0.7)));
    // highlight
    canvas.drawOval(Rect.fromLTWH(cx - w * 0.33, h * 0.44, w * 0.1, h * 0.22),
        Paint()..color = Colors.white.withValues(alpha: 0.12));
    // rim
    final rim = Rect.fromCenter(center: Offset(cx, h * 0.3), width: w * 0.5, height: h * 0.1);
    canvas.drawOval(rim, Paint()..color = const Color(0xFF0A1A33));
    canvas.drawOval(rim, Paint()..color = SS.marigold..style = PaintingStyle.stroke..strokeWidth = w * 0.035);
    // painted band (cyan dots like blue pottery)
    for (var i = -2; i <= 2; i++) {
      canvas.drawCircle(Offset(cx + i * w * 0.13, h * 0.84 - (i * i) * h * 0.006), w * 0.022,
          Paint()..color = SS.marigold.withValues(alpha: 0.85));
    }

    // eyes (blink every ~2.4 s; look up while thinking)
    final blink = (t % 1) > 0.93 ? 0.12 : 1.0;
    final look = mood == 'think' ? -h * 0.025 : 0.0;
    for (final dx in [-w * 0.13, w * 0.13]) {
      final eye = Rect.fromCenter(center: Offset(cx + dx, h * 0.52), width: w * 0.16, height: h * 0.19 * blink);
      canvas.drawOval(eye, Paint()..color = Colors.white);
      if (blink > 0.5) {
        canvas.drawCircle(Offset(cx + dx + w * 0.01, h * 0.535 + look), w * 0.045, Paint()..color = const Color(0xFF0A1A33));
        canvas.drawCircle(Offset(cx + dx + w * 0.025, h * 0.515 + look), w * 0.015, Paint()..color = Colors.white);
      }
    }
    // cheeks
    for (final dx in [-w * 0.24, w * 0.24]) {
      canvas.drawCircle(Offset(cx + dx, h * 0.64), w * 0.045, Paint()..color = const Color(0x66FF7AA2));
    }
    // mouth
    final mouthY = h * 0.69;
    if (talking || mood == 'cheer') {
      final open = talking ? 0.35 + 0.65 * (0.5 + 0.5 * math.sin(t * 2 * math.pi * 9)).abs() : 1.0;
      final m = Rect.fromCenter(center: Offset(cx, mouthY), width: w * 0.16, height: h * 0.1 * open);
      canvas.drawOval(m, Paint()..color = const Color(0xFF3A0D1E));
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, mouthY + h * 0.02 * open), width: w * 0.08, height: h * 0.035 * open),
          Paint()..color = const Color(0xFFFF7AA2));
    } else if (mood == 'think') {
      canvas.drawCircle(Offset(cx + w * 0.03, mouthY), w * 0.028, Paint()..color = const Color(0xFF3A0D1E));
    } else {
      final smile = Path()
        ..moveTo(cx - w * 0.08, mouthY - h * 0.01)
        ..quadraticBezierTo(cx, mouthY + h * 0.06, cx + w * 0.08, mouthY - h * 0.01);
      canvas.drawPath(smile, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = w * 0.03
        ..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(_ShilpiPainter old) => old.t != t || old.mood != mood || old.talking != talking;
}
