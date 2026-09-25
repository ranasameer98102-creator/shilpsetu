import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config.dart';
import '../../core/session.dart';
import '../widgets.dart';

/// Help: missed-call / IVR helpline, request a callback from a helper, and a spoken walkthrough.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.helpTitle)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        SpeakTile(
          icon: Icons.phone_in_talk_rounded,
          label: l.callHelpline,
          color: SS.teal,
          onOpen: () => launchUrl(Uri.parse('tel:${AppConfig.helpline}')),
        ),
        const SizedBox(height: 12),
        SpeakTile(
          icon: Icons.support_agent_rounded,
          label: l.requestCallback,
          color: SS.ochre,
          onOpen: () async {
            final s = context.read<Session>();
            try {
              await s.api.post('/notify/callback');
              if (context.mounted) spokenMessage(context, l.callbackRequested);
            } catch (e) {
              if (context.mounted) spokenError(context, e);
            }
          },
        ),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Icon(Icons.play_circle_fill_rounded, color: SS.maroon, size: 44),
            title: Text(l.howToUse, style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text(l.fiveSteps),
            onTap: () => context.voice.speak('${l.howToUse}. ${l.fiveSteps}. ${l.promise}'),
          ),
        ),
      ]),
    );
  }
}
