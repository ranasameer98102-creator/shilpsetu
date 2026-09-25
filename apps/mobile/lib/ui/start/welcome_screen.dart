import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

import '../../core/session.dart';
import '../widgets.dart';

/// First screen: who is using the phone. Big tiles, each speaks its label.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final s = context.read<Session>();
    Future<void> pick(String role) async {
      await s.setRole(role);
      if (!context.mounted) return;
      context.go(role == 'buyer' ? '/store' : '/language?next=/login');
    }

    return Scaffold(
      backgroundColor: SS.tealDeep,
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(20), children: [
          const SizedBox(height: 12),
          Row(children: [
            const Wordmark(size: 34),
            const Spacer(),
            const ThemeToggle(color: SS.cream),
            IconButton(
              onPressed: () => context.push('/language'),
              icon: const Icon(Icons.translate_rounded, color: SS.cream),
              tooltip: l.chooseLanguage,
            ),
          ]),
          Text(l.tagline, style: TextStyle(color: SS.sand, fontSize: 16)),
          const SizedBox(height: 18),
          Text(l.heroLine, style: const TextStyle(color: SS.cream, fontSize: 22, fontWeight: FontWeight.w600, height: 1.35)),
          const SizedBox(height: 28),
          Row(children: [
            Expanded(child: Text(l.chooseRole, style: const TextStyle(color: SS.marigold, fontSize: 20, fontWeight: FontWeight.w700))),
            SpeakButton(l.chooseRole, color: SS.marigold),
          ]),
          const SizedBox(height: 12),
          SpeakTile(icon: Icons.brush_rounded, label: l.roleArtisan, color: SS.maroon, big: true, onOpen: () => pick('artisan')),
          const SizedBox(height: 14),
          SpeakTile(icon: Icons.shopping_bag_rounded, label: l.roleBuyer, color: SS.teal, onOpen: () => pick('buyer')),
          const SizedBox(height: 14),
          SpeakTile(icon: Icons.storefront_rounded, label: l.roleKiosk, color: SS.ochre, onOpen: () => pick('operator')),
          const SizedBox(height: 28),
          Text(l.promise, style: TextStyle(color: SS.sand, fontSize: 14, height: 1.5)),
          const SizedBox(height: 18),
          GestureDetector(onTap: () => context.push('/about'), child: Credits(color: SS.sand)),
        ]),
      ),
    );
  }
}
