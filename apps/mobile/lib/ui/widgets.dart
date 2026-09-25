import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

import '../core/session.dart';
import '../core/voice.dart';
import '../l10n/app_localizations.dart';
import '../offline/sync_queue.dart';

extension L10nX on BuildContext {
  L10n get l => L10n.of(this);
  Voice get voice => read<Voice>();
}

/// Sun/moon button that flips between the light and dark theme.
class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key, this.color});
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<Session>();
    final l = context.l;
    return IconButton(
      tooltip: s.dark ? l.lightMode : l.darkMode,
      onPressed: () => s.setDark(!s.dark),
      icon: Icon(s.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: color),
    );
  }
}

/// Shopping (cart, orders) needs a buyer or artisan account. Returns true when ready; otherwise opens the
/// login screen (which comes back to [next]) and returns false. [replace] swaps the current screen for login.
Future<bool> ensureShopper(BuildContext context, String next, {bool replace = false}) async {
  final s = context.read<Session>();
  if (s.canShop) return true;
  if (s.signedIn) await s.logout(); // a kiosk/admin account cannot shop: sign in again as a buyer
  await s.setRole('buyer');
  if (context.mounted) {
    final login = '/login?next=${Uri.encodeComponent(next)}';
    replace ? context.pushReplacement(login) : context.push(login);
  }
  return false;
}

/// Errors are never text-only (§12): show them and speak them.
void spokenMessage(BuildContext context, String message, {bool error = false}) {
  context.voice.speak(message);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(children: [
      Icon(error ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
          color: error ? SS.marigold : SS.cream),
      const SizedBox(width: 10),
      Expanded(child: Text(message)),
    ]),
  ));
}

void spokenError(BuildContext context, Object e) {
  final l = context.l;
  final msg = e is ApiException && e.isNetwork ? l.errorNetwork : l.errorGeneric;
  spokenMessage(context, msg, error: true);
}

/// Small icon button that reads its label aloud (every icon has a spoken label).
class SpeakButton extends StatelessWidget {
  const SpeakButton(this.text, {super.key, this.color, this.size = 26});
  final String text;
  final Color? color; // default: heading colour of the current theme
  final double size;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: text,
        onPressed: () => context.voice.speak(text),
        icon: Icon(Icons.volume_up_rounded, color: color ?? SS.heading, size: size),
        constraints: const BoxConstraints(minWidth: SS.minTap, minHeight: SS.minTap),
      );
}

/// Big home tile. Speaks its label on the first tap; the second tap opens it (configurable, §9.10).
/// Long-press always speaks.
class SpeakTile extends StatefulWidget {
  const SpeakTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onOpen,
    this.color,
    this.badge,
    this.speakFirst = true,
    this.big = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onOpen;
  final Color? color; // tile fill; default navy
  final String? badge;
  final bool speakFirst;
  final bool big;

  @override
  State<SpeakTile> createState() => _SpeakTileState();
}

class _SpeakTileState extends State<SpeakTile> {
  DateTime? _spokeAt;

  void _tap() {
    final now = DateTime.now();
    if (!widget.speakFirst || (_spokeAt != null && now.difference(_spokeAt!) < const Duration(seconds: 6))) {
      _spokeAt = null;
      widget.onOpen();
      return;
    }
    _spokeAt = now;
    context.voice.speak(widget.label);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final fill = widget.color ?? SS.teal;
    final armed = _spokeAt != null;
    return Semantics(
      button: true,
      label: widget.label,
      child: Material(
        color: fill,
        borderRadius: BorderRadius.circular(SS.radiusLarge),
        elevation: armed ? 6 : 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(SS.radiusLarge),
          onTap: _tap,
          onLongPress: () => context.voice.speak(widget.label),
          child: Container(
            constraints: BoxConstraints(minHeight: widget.big ? 150 : 128),
            padding: const EdgeInsets.all(16),
            decoration: armed
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(SS.radiusLarge), border: Border.all(color: SS.marigold, width: 3))
                : null,
            child: Stack(children: [
              Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(widget.icon, color: SS.on(fill), size: widget.big ? 52 : 44),
                const SizedBox(height: 10),
                Text(widget.label,
                    style: TextStyle(fontFamily: SS.poppins, fontFamilyFallback: SS.fontFallback, color: SS.on(fill),
                        fontSize: 19, fontWeight: FontWeight.w700, height: 1.2)),
              ]),
              Positioned(right: 0, top: 0, child: Icon(Icons.volume_up_rounded, color: SS.on(fill).withValues(alpha: 0.7), size: 22)),
              if (widget.badge != null)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(color: SS.marigold, borderRadius: BorderRadius.circular(99)),
                    child: Text(widget.badge!,
                        style: TextStyle(color: SS.tealDeep, fontWeight: FontWeight.w700, fontFamily: SS.poppins)),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Large circular maroon mic with a cream glyph, inside two concentric dashed ochre rings that pulse while
/// recording (mockup screen 2).
class MicButton extends StatefulWidget {
  const MicButton({super.key, required this.active, this.onTap, this.onHoldStart, this.onHoldEnd, this.size = 132, this.label});
  final bool active;
  final VoidCallback? onTap;
  final VoidCallback? onHoldStart;
  final VoidCallback? onHoldEnd;
  final double size;
  final String? label;

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void didUpdateWidget(MicButton old) {
    super.didUpdateWidget(old);
    widget.active ? _pulse.repeat() : (_pulse..stop()..value = 0);
  }

  @override
  void initState() {
    super.initState();
    if (widget.active) _pulse.repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outer = widget.size * 1.9;
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPressStart: (_) => widget.onHoldStart?.call(),
        onLongPressEnd: (_) => widget.onHoldEnd?.call(),
        child: SizedBox(
          width: outer,
          height: outer,
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (_, _) => CustomPaint(
              painter: _RingsPainter(progress: _pulse.value, active: widget.active, inner: widget.size),
              child: Center(
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: SS.maroon,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: SS.maroon.withValues(alpha: 0.5), blurRadius: widget.active ? 28 : 14, spreadRadius: 2)
                    ],
                  ),
                  child: Icon(widget.active ? Icons.stop_rounded : Icons.mic_rounded, color: SS.cream, size: widget.size * 0.45),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  _RingsPainter({required this.progress, required this.active, required this.inner});
  final double progress;
  final bool active;
  final double inner;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    for (var i = 0; i < 2; i++) {
      final base = inner / 2 + 18 + i * 22;
      final grow = active ? 8 * math.sin((progress + i * .35) * 2 * math.pi).abs() : 0;
      final r = base + grow;
      final paint = Paint()
        ..color = SS.ochre.withValues(alpha: active ? 0.95 - i * 0.3 : 0.6 - i * 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4;
      const dashes = 36;
      for (var d = 0; d < dashes; d++) {
        final a0 = d * 2 * math.pi / dashes + (active ? progress * (i.isEven ? 1 : -1) : 0);
        canvas.drawArc(Rect.fromCircle(center: c, radius: r), a0, math.pi / dashes, false, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) => old.progress != progress || old.active != active;
}

/// Live audio waveform bars in marigold/ochre.
class Waveform extends StatelessWidget {
  const Waveform({super.key, required this.levels, this.height = 56, this.active = true});
  final List<double> levels;
  final double height;
  final bool active;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
          for (var i = 0; i < levels.length; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 90),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 5,
              height: math.max(4, height * (active ? levels[i] : 0.08)),
              decoration: BoxDecoration(
                  color: i.isEven ? SS.marigold : SS.ochre, borderRadius: BorderRadius.circular(3)),
            ),
        ]),
      );
}

/// "Saved on phone — will upload when network returns" / "All synced".
class SyncBanner extends StatelessWidget {
  const SyncBanner({super.key, this.dark = false});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final q = context.watch<SyncQueue>();
    final l = context.l;
    final (icon, text, color) = !q.online && q.pendingCount > 0
        ? (Icons.cloud_off_rounded, l.savedOnPhone, SS.ochre)
        : q.running || q.pendingCount > 0
            ? (Icons.cloud_upload_rounded, '${l.syncing} ${l.pendingCount(q.pendingCount)}', SS.marigold)
            : (Icons.cloud_done_rounded, l.allSynced, SS.verifiedGreen);
    return Semantics(
      liveRegion: true,
      child: InkWell(
        onTap: () {
          context.voice.speak(text);
          q.online = true;
          q.run();
        },
        borderRadius: BorderRadius.circular(99),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: dark ? Colors.white.withValues(alpha: 0.08) : SS.white,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Flexible(
                child: Text(text,
                    style: TextStyle(color: dark ? SS.cream : SS.ink, fontSize: 14, fontFamily: SS.poppins),
                    maxLines: 2)),
          ]),
        ),
      ),
    );
  }
}

String statusLabel(L10n l, String status) => switch (status) {
      'queued' => l.statusQueued,
      'uploading' => l.statusUploading,
      'processing' => l.statusProcessing,
      'needs_review' => l.statusNeedsReview,
      'ready' => l.statusReady,
      'live' => l.statusLive,
      'failed' => l.statusFailed,
      'unpublished' => l.statusUnpublished,
      _ => status,
    };

String orderStatusLabel(L10n l, String s) => switch (s) {
      'placed' => l.orderPlaced,
      'accepted' => l.orderAccepted,
      'packed' => l.orderPacked,
      'shipped' => l.orderShipped,
      'delivered' => l.orderDelivered,
      'declined' => l.orderDeclined,
      'cancelled' => l.orderCancelled,
      _ => s,
    };

/// Section header in teal with a speak button.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 8, 10),
        child: Row(children: [
          Expanded(child: Text(text, style: Theme.of(context).textTheme.titleLarge)),
          ?trailing,
        ]),
      );
}
