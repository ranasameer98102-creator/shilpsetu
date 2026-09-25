import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

import '../../core/languages.dart';
import '../../core/session.dart';
import '../widgets.dart';

/// Language picker: large tiles with the language name in its own script, each plays its name aloud (§9.1).
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key, this.next});
  final String? next;

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String? armed;
  bool showAll = false;

  Future<void> _tap(AppLanguage lang) async {
    final s = context.read<Session>();
    if (armed != lang.code) {
      setState(() => armed = lang.code);
      await context.voice.speak(lang.native, lang: lang.code);
      return;
    }
    context.voice.language = lang.code;
    await s.setLanguage(lang.code);
    if (!mounted) return;
    if (widget.next != null) {
      context.go(widget.next!);
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final langs = showAll ? appLanguages : appLanguages.where((a) => a.ui).toList();
    return Scaffold(
      appBar: AppBar(title: Text(l.chooseLanguage)),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          child: Row(children: [
            Icon(Icons.touch_app_rounded, color: SS.ochre),
            const SizedBox(width: 8),
            Expanded(child: Text(l.tapToHear, style: Theme.of(context).textTheme.bodyMedium)),
            SpeakButton(l.tapToHear),
          ]),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.35),
            itemCount: langs.length + (showAll ? 0 : 1),
            itemBuilder: (_, i) {
              if (i == langs.length) {
                return OutlinedButton(onPressed: () => setState(() => showAll = true), child: const Text('+ 22'));
              }
              final lang = langs[i];
              final selected = armed == lang.code || (armed == null && context.read<Session>().language == lang.code);
              return Semantics(
                button: true,
                selected: selected,
                label: '${lang.native}, ${lang.english}',
                child: Material(
                  color: selected ? SS.teal : SS.white,
                  borderRadius: BorderRadius.circular(SS.radius),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(SS.radius),
                    onTap: () => _tap(lang),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(SS.radius),
                        border: Border.all(color: armed == lang.code ? SS.marigold : SS.sand, width: armed == lang.code ? 3 : 1),
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(lang.native,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.w700, color: selected ? SS.cream : SS.heading, height: 1.3)),
                        const SizedBox(height: 4),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.volume_up_rounded, size: 16, color: selected ? SS.sand : SS.slate),
                          const SizedBox(width: 4),
                          Text(lang.english, style: TextStyle(fontSize: 13, color: selected ? SS.sand : SS.slate)),
                        ]),
                      ]),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}
