import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

import '../../core/session.dart';
import '../../core/voice.dart';
import '../widgets.dart';
import 'mascot.dart';

/// Opens the chat with Shilpi. [greeting] (from /assistant/greeting) becomes the first message.
Future<void> openAssistant(BuildContext context, {Map<String, dynamic>? greeting, String? ask}) =>
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AssistantSheet(greeting: greeting, ask: ask),
    );

/// Floating Shilpi button for home screens.
class AssistantFab extends StatelessWidget {
  const AssistantFab({super.key, this.greeting});
  final Map<String, dynamic>? greeting;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: context.l.askShilpi,
        child: GestureDetector(
          onTap: () => openAssistant(context, greeting: greeting),
          child: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SS.tealDeep,
              border: Border.all(color: SS.marigold, width: 2),
              boxShadow: [BoxShadow(color: SS.marigold.withValues(alpha: 0.45), blurRadius: 16)],
            ),
            alignment: Alignment.center,
            child: const Mascot(size: 52),
          ),
        ),
      );
}

class _Msg {
  _Msg(this.fromUser, this.text, {this.products = const [], this.actions = const []});
  final bool fromUser;
  final String text;
  final List<Map> products;
  final List<Map> actions;
}

class _AssistantSheet extends StatefulWidget {
  const _AssistantSheet({this.greeting, this.ask});
  final Map<String, dynamic>? greeting;
  final String? ask;

  @override
  State<_AssistantSheet> createState() => _AssistantSheetState();
}

class _AssistantSheetState extends State<_AssistantSheet> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final msgs = <_Msg>[];
  List<String> suggestions = const [];
  String mood = 'wave';
  bool thinking = false, talking = false;

  @override
  void initState() {
    super.initState();
    final g = widget.greeting;
    if (g != null) {
      msgs.add(_Msg(false, '${g['message']}'));
      suggestions = List<String>.from(g['suggestions'] ?? const []);
      mood = '${g['mood'] ?? 'wave'}';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.ask != null) {
        _send(widget.ask!);
      } else if (g == null) {
        _loadGreeting();
      } else {
        _say('${g['message']}');
      }
    });
  }

  @override
  void dispose() {
    context.read<Voice>().stopSpeaking();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadGreeting() async {
    final s = context.read<Session>();
    try {
      final g = Map<String, dynamic>.from(await s.api.get('/assistant/greeting', {'lang': s.language}));
      if (!mounted) return;
      setState(() {
        msgs.add(_Msg(false, '${g['message']}'));
        suggestions = List<String>.from(g['suggestions'] ?? const []);
        mood = '${g['mood'] ?? 'wave'}';
      });
      _say('${g['message']}');
    } catch (_) {}
  }

  /// Read the reply aloud and move the mascot's mouth for about as long as it takes.
  Future<void> _say(String text) async {
    setState(() => talking = true);
    context.voice.speak(text);
    await Future.delayed(Duration(milliseconds: math.min(9000, 600 + text.length * 55)));
    if (mounted) setState(() => talking = false);
  }

  Future<void> _send(String text) async {
    text = text.trim();
    if (text.isEmpty || thinking) return;
    final s = context.read<Session>();
    _input.clear();
    setState(() {
      msgs.add(_Msg(true, text));
      thinking = true;
      mood = 'think';
    });
    _toEnd();
    try {
      final history = [
        for (final m in msgs.reversed.take(6).toList().reversed) {'role': m.fromUser ? 'user' : 'assistant', 'text': m.text},
      ];
      final r = Map<String, dynamic>.from(
          await s.api.post('/assistant/chat', {'message': text, 'lang': s.language, 'history': history}));
      if (!mounted) return;
      setState(() {
        msgs.add(_Msg(false, '${r['reply']}',
            products: (r['products'] as List? ?? []).cast<Map>(), actions: (r['actions'] as List? ?? []).cast<Map>()));
        suggestions = List<String>.from(r['suggestions'] ?? const []);
        mood = '${r['mood'] ?? 'happy'}';
      });
      _toEnd();
      _say('${r['reply']}');
    } catch (e) {
      if (mounted) spokenError(context, e);
    } finally {
      if (mounted) setState(() => thinking = false);
    }
  }

  void _toEnd() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent + 400,
              duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        }
      });

  Future<void> _listen() async {
    final v = context.read<Voice>();
    if (v.listening) {
      await v.stopListening();
      return;
    }
    await v.listen(onFinal: (t) => _send(t)); // on failure the app explains why (Voice.onProblem)
  }

  void _go(String route) {
    Navigator.pop(context);
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final v = context.watch<Voice>();
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      expand: false,
      builder: (context, sheetScroll) => Container(
        decoration: BoxDecoration(
          color: SS.page,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          // header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [SS.teal, SS.tealDeep]),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Row(children: [
              Mascot(size: 56, mood: mood, talking: talking),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.assistantName, style: const TextStyle(color: SS.cream, fontSize: 20, fontWeight: FontWeight.w700, fontFamily: SS.poppins)),
                  Text(thinking ? l.assistantThinking : l.assistantTagline,
                      style: TextStyle(color: SS.sand, fontSize: 13, fontFamily: SS.poppins)),
                ]),
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: SS.cream),
                  tooltip: l.close),
            ]),
          ),
          // conversation
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
              children: [
                for (final m in msgs) _bubble(context, m),
                if (thinking) const _TypingDots(),
              ],
            ),
          ),
          if (suggestions.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: suggestions.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ActionChip(
                  label: Text(suggestions[i]),
                  avatar: Icon(Icons.auto_awesome_rounded, size: 16, color: SS.ochre),
                  onPressed: () => _send(suggestions[i]),
                ),
              ),
            ),
          // input
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, 8, 12, 10 + MediaQuery.viewInsetsOf(context).bottom),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _send,
                    decoration: InputDecoration(hintText: v.listening && v.partial.isNotEmpty ? v.partial : l.askAnything),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton.filled(
                  onPressed: _listen,
                  tooltip: l.tapToSpeak,
                  style: IconButton.styleFrom(backgroundColor: v.listening ? SS.danger : SS.maroon, minimumSize: const Size(52, 52)),
                  icon: Icon(v.listening ? Icons.stop_rounded : Icons.mic_rounded, color: Colors.white),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => _send(_input.text),
                  tooltip: l.send,
                  icon: Icon(Icons.send_rounded, color: SS.ochre),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _bubble(BuildContext context, _Msg m) {
    final text = Theme.of(context).textTheme.bodyLarge;
    if (m.fromUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10, left: 60),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: SS.maroon,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18), topRight: Radius.circular(18), bottomLeft: Radius.circular(18), bottomRight: Radius.circular(4)),
          ),
          child: Text(m.text, style: text?.copyWith(color: Colors.white)),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          const Mascot(size: 34),
          const SizedBox(width: 6),
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(right: 40),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: SS.white,
                boxShadow: SS.cardShadow,
                border: Border.all(color: SS.marigold.withValues(alpha: 0.35)),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18), topRight: Radius.circular(18), bottomRight: Radius.circular(18), bottomLeft: Radius.circular(4)),
              ),
              child: Text(m.text, style: text),
            ),
          ),
        ]),
        if (m.products.isNotEmpty)
          SizedBox(
            height: 292,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(40, 10, 0, 4),
              itemCount: m.products.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final p = Map<String, dynamic>.from(m.products[i]);
                return SizedBox(
                    width: 164,
                    child: ProductCard(product: p, verifiedLabel: context.l.verifiedArtisan, onTap: () => _go('/store/p/${p['id']}')));
              },
            ),
          ),
        if (m.actions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 40, top: 8),
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              for (final a in m.actions)
                FilledButton.tonalIcon(
                  onPressed: () => _go('${a['route']}'),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: Text('${a['label']}'),
                ),
            ]),
          ),
      ]),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(children: [
        const Mascot(size: 34, mood: 'think'),
        const SizedBox(width: 8),
        AnimatedBuilder(
          animation: c,
          builder: (_, _) => Row(children: [
            for (var i = 0; i < 3; i++)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SS.ochre.withValues(alpha: 0.3 + 0.7 * (0.5 + 0.5 * math.sin((c.value - i * 0.2) * 2 * math.pi))),
                ),
              ),
          ]),
        ),
      ]);
}
