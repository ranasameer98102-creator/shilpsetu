import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

import '../../core/session.dart';
import '../widgets.dart';
import 'assistant.dart';
import 'mascot.dart';

/// Loads Shilpi's greeting once per screen and exposes it (the FAB reuses it as the chat's first message).
class GreetingController extends ChangeNotifier {
  Map<String, dynamic>? data;

  Future<void> load(Session s) async {
    try {
      data = Map<String, dynamic>.from(await s.api.get('/assistant/greeting', {'lang': s.language}));
      notifyListeners();
    } catch (_) {}
  }
}

/// Duolingo-style card: mascot + speech bubble; artisans see streak, daily goal and badges, buyers the craft of the day.
class GreetingCard extends StatelessWidget {
  const GreetingCard({super.key, required this.data});
  final Map<String, dynamic>? data;

  @override
  Widget build(BuildContext context) {
    final g = data;
    if (g == null) return const SizedBox.shrink();
    final l = context.l;
    final badges = (g['badges'] as List? ?? []).cast<Map>();
    final goal = g['goal'] as Map?;
    final craft = g['craft_of_day'] as Map?;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(SS.radius),
        onTap: () => openAssistant(context, greeting: g),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [SS.teal, SS.tealDeep]),
            borderRadius: BorderRadius.circular(SS.radius),
            border: Border.all(color: SS.marigold.withValues(alpha: 0.4)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Mascot(size: 64, mood: '${g['mood'] ?? 'happy'}'),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                  ),
                  child: Text('${g['message']}',
                      style: const TextStyle(color: SS.cream, fontSize: 16, height: 1.35, fontFamily: SS.poppins)),
                ),
              ),
              SpeakButton('${g['message']}', color: SS.cream),
            ]),
            if (goal != null) ...[
              const SizedBox(height: 12),
              Row(children: [
                _Stat(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: const Color(0xFFFF9F43),
                  value: '${g['streak'] ?? 0}',
                  label: l.dayStreak,
                ),
                const SizedBox(width: 10),
                _GoalRing(done: (goal['done'] ?? 0) as int, target: (goal['target'] ?? 1) as int, label: l.todaysGoal),
              ]),
              const SizedBox(height: 10),
              SizedBox(
                height: 70,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: badges.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => _Badge(badges[i]),
                ),
              ),
            ],
            if (craft != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SS.marigold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(SS.radiusSmall),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.today_rounded, color: SS.marigold, size: 18),
                    const SizedBox(width: 6),
                    Text(l.craftOfTheDay,
                        style: const TextStyle(color: SS.marigold, fontWeight: FontWeight.w700, fontFamily: SS.poppins)),
                  ]),
                  const SizedBox(height: 4),
                  Text('${craft['name']} · ${craft['region']}',
                      style: const TextStyle(color: SS.cream, fontSize: 17, fontWeight: FontWeight.w600, fontFamily: SS.poppins)),
                  const SizedBox(height: 4),
                  Text('${l.didYouKnow} ${craft['fact']}',
                      style: TextStyle(color: SS.sand, fontSize: 14, height: 1.4, fontFamily: SS.poppins)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: SS.marigold),
                      onPressed: () => context.push('/store/search?q=${Uri.encodeQueryComponent('${craft['name']}'.split(' ').first)}'),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(l.exploreCraft),
                    ),
                  ),
                ]),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.iconColor, required this.value, required this.label});
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Icon(icon, color: iconColor, size: 30),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(value, style: const TextStyle(color: SS.cream, fontSize: 22, fontWeight: FontWeight.w800, fontFamily: SS.poppins)),
              Text(label, style: TextStyle(color: SS.sand, fontSize: 12, fontFamily: SS.poppins)),
            ]),
          ]),
        ),
      );
}

class _GoalRing extends StatelessWidget {
  const _GoalRing({required this.done, required this.target, required this.label});
  final int done;
  final int target;
  final String label;

  @override
  Widget build(BuildContext context) {
    final complete = done >= target;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          SizedBox(
            width: 34,
            height: 34,
            child: Stack(alignment: Alignment.center, children: [
              CircularProgressIndicator(
                value: target == 0 ? 0 : math.min(1, done / target),
                strokeWidth: 5,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                color: complete ? const Color(0xFF4ADE80) : SS.marigold,
              ),
              Icon(complete ? Icons.check_rounded : Icons.flag_rounded, size: 16, color: SS.cream),
            ]),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$done / $target', style: const TextStyle(color: SS.cream, fontSize: 18, fontWeight: FontWeight.w800, fontFamily: SS.poppins)),
              Text(label, style: TextStyle(color: SS.sand, fontSize: 12, fontFamily: SS.poppins), overflow: TextOverflow.ellipsis),
            ]),
          ),
        ]),
      ),
    );
  }
}

const _badgeIcons = {
  'rocket_launch': Icons.rocket_launch_rounded,
  'inventory': Icons.inventory_2_rounded,
  'celebration': Icons.celebration_rounded,
  'star': Icons.star_rounded,
  'local_fire_department': Icons.local_fire_department_rounded,
  'verified': Icons.verified_rounded,
};

class _Badge extends StatelessWidget {
  const _Badge(this.b);
  final Map b;

  @override
  Widget build(BuildContext context) {
    final earned = b['earned'] == true;
    return Tooltip(
      message: '${b['label']}',
      child: SizedBox(
        width: 74,
        child: Column(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: earned ? const LinearGradient(colors: [Color(0xFF22D3EE), Color(0xFF0284C7)]) : null,
              color: earned ? null : Colors.white.withValues(alpha: 0.08),
              boxShadow: earned ? [BoxShadow(color: SS.marigold.withValues(alpha: 0.5), blurRadius: 10)] : null,
            ),
            child: Icon(earned ? (_badgeIcons[b['icon']] ?? Icons.emoji_events_rounded) : Icons.lock_rounded,
                color: earned ? Colors.white : SS.sand, size: 22),
          ),
          const SizedBox(height: 4),
          Text('${b['label']}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: earned ? SS.cream : SS.sand, fontSize: 11, fontFamily: SS.poppins)),
        ]),
      ),
    );
  }
}

/// Confetti + a cheering Shilpi, e.g. when a product goes live. Dismisses itself.
Future<void> celebrate(BuildContext context, String message) async {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
      builder: (_) => Material(
          type: MaterialType.transparency, child: _Celebration(message: message, onDone: () => entry.remove())));
  overlay.insert(entry);
  context.voice.speak(message);
}

class _Celebration extends StatefulWidget {
  const _Celebration({required this.message, required this.onDone});
  final String message;
  final VoidCallback onDone;

  @override
  State<_Celebration> createState() => _CelebrationState();
}

class _CelebrationState extends State<_Celebration> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))
    ..forward().whenComplete(widget.onDone);
  final _rnd = math.Random(7);
  late final pieces = List.generate(70, (i) => (_rnd.nextDouble(), _rnd.nextDouble(), _rnd.nextInt(5), _rnd.nextDouble()));

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const colors = [Color(0xFF22D3EE), Color(0xFFFFB347), Color(0xFF4ADE80), Color(0xFFFF7AA2), Colors.white];
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: c,
        builder: (context, _) {
          final t = c.value;
          final fade = t < 0.85 ? 1.0 : (1 - t) / 0.15;
          final size = MediaQuery.sizeOf(context);
          return Opacity(
            opacity: fade.clamp(0.0, 1.0),
            child: Stack(children: [
              for (final (x, delay, ci, spin) in pieces)
                Positioned(
                  left: x * size.width,
                  top: -20 + (t * 1.4 - delay * 0.4).clamp(0.0, 1.2) * size.height,
                  child: Transform.rotate(
                    angle: spin * 12 * t,
                    child: Container(width: 8, height: 14, color: colors[ci]),
                  ),
                ),
              Center(
                child: Transform.scale(
                  scale: Curves.elasticOut.transform(math.min(1, t * 2.5)),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: SS.tealDeep,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: SS.marigold, width: 2),
                      boxShadow: [BoxShadow(color: SS.marigold.withValues(alpha: 0.5), blurRadius: 30)],
                    ),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Mascot(size: 110, mood: 'cheer'),
                      const SizedBox(height: 10),
                      Text(widget.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: SS.cream, fontSize: 22, fontWeight: FontWeight.w700, fontFamily: SS.poppins,
                              decoration: TextDecoration.none)),
                    ]),
                  ),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }
}
